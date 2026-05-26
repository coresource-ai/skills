# Example Spec: `--since` Flag for List Command

A **core-only** spec for adding a `--since` filter to `mytool list`. Demonstrates a compact spec with required sections plus relevant optional context, and no advanced sections.

---

## Task

Add a `--since <duration>` flag to `mytool list` that filters output to items created within the given window. Without the flag, behavior is unchanged.

## Success Criteria

- `mytool list --since 24h` outputs only items with `created_at` in the last 24 hours.
- `mytool list --since 7d` accepts day-suffix duration syntax.
- `mytool list` with no flag returns the full unfiltered list (no regression).
- `mytool list --since garbage` exits non-zero with `invalid duration` on stderr.

## Constraints

- Reuse the duration parser in `src/util/duration.ts`. Do not add a new one.
- Filter server-side via the existing `created_after` query parameter; do not post-filter in the client.
- Update `mytool list --help` to document the new flag.

## Assumptions

- The `list` command already calls a server endpoint that supports `created_after`.
- Items always have a populated `created_at` timestamp.
- `--since` is not already taken by another flag on this command.

## Risks

- **Time-zone mismatch.** If the client computes the cutoff in local time but the server interprets `created_after` as UTC, the window will be off by the local offset.
- **Missing index.** A `created_after` filter without a covering index on `created_at` could be slow on large tables.

## Edge Cases

| Boundary | Values | Rationale |
|----------|--------|-----------|
| Zero duration | `--since 0s` | Should return empty list, not error |
| Negative duration | `--since -1h` | Reject with parse error |
| Very large duration | `--since 100y` | Must not overflow; should effectively return all items |
| Malformed syntax | `--since 5`, `--since hour` | Reject with parse error |

## Open Questions

- Should `--since` also accept absolute timestamps (e.g., `--since 2026-01-01`), or is duration-only acceptable for v1?
