# Example Spec: Search Endpoint

A complete spec for adding a `GET /api/v1/search` endpoint to a REST API. Demonstrates every section the spec-writer skill emits, with realistic content, generic file paths, and copy-pasteable verification commands. Copy this file as a starting template — the `##` and `###` levels below are the literal heading levels the parser expects.

---

## Task

Add a `GET /api/v1/search` endpoint that accepts a `q` query parameter and returns paginated results from the existing product catalog. The endpoint must support optional `limit` and `offset` parameters, return JSON matching the existing product schema, and handle empty results gracefully.

## Success Criteria

- `curl "http://localhost:3000/api/v1/search?q=widget"` returns HTTP 200 with a JSON array of matching products.
- `curl "http://localhost:3000/api/v1/search?q=zzzzzzzzzz"` returns HTTP 200 with an empty results array.
- `curl "http://localhost:3000/api/v1/search"` returns HTTP 400 with error `{"error":"missing required parameter: q"}`.
- Response time is under 200ms for result sets up to 100 items.

## Constraints

- Must use the existing `src/db/products.ts` query layer — do not introduce a new ORM or raw SQL path.
- Response schema must match `src/schemas/product.ts` exactly.
- API route must be registered in `src/routes/index.ts` following the existing middleware chain.
- `limit` must be capped at 100 server-side.

## Assumptions

- The product catalog table `products` has a full-text index on `name` and `description`. If no index exists, a migration must be added before this work starts.
- Authentication is handled by middleware upstream; this endpoint is public.
- The existing test harness (`npm test`) uses `vitest` with `supertest`.

## Risks

- **Full-table scan under load.** If the query planner does not use the full-text index, response times could exceed the 200ms target under concurrent load.
- **Breaking existing middleware.** Adding a new route to `src/routes/index.ts` could inadvertently reorder the middleware chain and break authentication for other endpoints.
- **Query injection.** Unsanitized `q` parameter could expose SQL injection if the query layer does not parameterize inputs.

## Edge Cases

| Boundary | Values | Rationale |
|----------|--------|-----------|
| Empty query | `q=` or `q` omitted | Must return 400, not crash or return all products |
| Very long query | `q` > 500 chars | Must truncate or reject with 400; must not cause buffer overflow |
| Negative limit/offset | `limit=-1`, `offset=-5` | Must reject with 400 |
| Zero limit | `limit=0` | Must return empty results, not crash |
| Limit cap | `limit=999` | Must cap at 100 server-side |
| Special characters | `q=<script>`, `q='; DROP--` | Must escape or parameterize; must not inject |
| Concurrent requests | 50 simultaneous requests | Response times must stay under 500ms at p95 |

## Open Questions

- Should search support partial-word matching (trigram) or exact-word only?
- Should we log search queries for analytics? If so, to which service?
- Is the full-text index already deployed to production, or does a migration need to run first?

## Milestones

### `m1` Search Route and Validation

Dependencies: []
Testable Outcomes:
- `GET /api/v1/search` with valid `q` returns 200.
- Missing `q` returns 400 with structured error.
- Invalid `limit`/`offset` returns 400.
Referenced Artifacts:
- src/routes/search.ts
- src/routes/index.ts
- src/schemas/search.ts

### `m2` Query Execution and Results

Dependencies: [`m1`]
Testable Outcomes:
- Valid query returns products matching the search term.
- Empty query returns empty array with 200.
- Results respect `limit` and `offset`.
Referenced Artifacts:
- src/db/products.ts
- src/services/search.ts

### `m3` Edge Cases and Hardening

Dependencies: [`m2`]
Testable Outcomes:
- Query injection attempts return 400 or empty results.
- Limit cap (100) is enforced server-side.
- Concurrent requests stay under 500ms at p95.
Referenced Artifacts:
- src/middleware/validation.ts
- test/search.test.ts

## Steps

### `s1` Create Search Route with Parameter Validation

Milestone: `m1`
File Paths:
- src/routes/search.ts
- src/schemas/search.ts
- src/routes/index.ts

Create `src/routes/search.ts` with a `GET /api/v1/search` handler. Parse and validate `q` (required, string, 1-200 chars), `limit` (optional, integer, 1-100, default 20), and `offset` (optional, integer, ≥0, default 0). Register the route in `src/routes/index.ts`.

**Verification:**
- Run `curl -s "http://localhost:3000/api/v1/search?q=test" | jq '.status'` and confirm 200.
- Run `curl -s "http://localhost:3000/api/v1/search" | jq '.error'` and confirm `"missing required parameter: q"`.
- Run `curl -s "http://localhost:3000/api/v1/search?q=test&limit=-1" | jq '.error'` and confirm validation error.

### `s2` Implement Search Query Against Product Catalog

Milestone: `m2`
File Paths:
- src/services/search.ts
- src/db/products.ts

Add a `searchProducts(q, limit, offset)` function in `src/services/search.ts` that calls the existing `src/db/products.ts` query layer. Use parameterized queries. Return results sorted by relevance.

**Verification:**
- Run `npm test -- --testPathPattern=search` and confirm all tests pass.
- Run `curl -s "http://localhost:3000/api/v1/search?q=widget" | jq '.results | length'` and confirm non-zero count.

### `s3` Add Edge Case Handling and Hardening

Milestone: `m3`
File Paths:
- src/middleware/validation.ts
- src/routes/search.ts
- test/search.test.ts

Add input sanitization: reject queries over 200 chars, reject non-integer `limit`/`offset`, cap `limit` at 100. Add rate limiting if not already present.

**Verification:**
- Run `curl -s "http://localhost:3000/api/v1/search?q=%3Cscript%3E"` and confirm 400 or safe empty results.
- Run `curl -s "http://localhost:3000/api/v1/search?q=test&limit=999"` and confirm only 100 results returned.
- Run `ab -n 50 -c 10 "http://localhost:3000/api/v1/search?q=test"` and confirm p95 < 500ms.

## Assertions

### `a1` Happy Path (positive path)

Id: a1
Milestone: `m1`
Owner Work Item: `s1`
Description: Valid search with matching term returns 200 with results array.
Evidence Requirements:
- `curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/v1/search?q=widget"` outputs `200`.
- Response body contains `{"results":[...]}` with at least one result when `widget` exists in catalog.

### `a2` Missing Required Parameter (negative path)

Id: a2
Milestone: `m1`
Owner Work Item: `s1`
Description: Missing `q` parameter returns 400 with structured error.
Evidence Requirements:
- `curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/v1/search"` outputs `400`.
- Response body contains `{"error":"missing required parameter: q"}`.

### `a3` SQL Injection Rejection (negative path)

Id: a3
Milestone: `m3`
Owner Work Item: `s3`
Description: SQL injection payload in `q` parameter returns 400 or safe empty results.
Evidence Requirements:
- `curl -s "http://localhost:3000/api/v1/search?q='; DROP TABLE products;--"` returns HTTP 400 OR HTTP 200 with empty results.
- No database errors in server logs.
