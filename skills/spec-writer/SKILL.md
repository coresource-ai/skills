---
name: spec-writer
description: Write structured specifications that maximize AI coding agent planning output. Produces specs with intent, success criteria, constraints, risks, and edge cases that any agent can map to a convergent execution plan.
---

# Spec Writer

This skill teaches you how to write a specification (spec) that any AI coding agent can consume as authoritative input for planning and execution. A well-structured spec reduces ambiguity, prevents replan cycles, and produces convergent results—whether the agent uses a contract graph, a task list, or another internal representation.

The skill covers spec structure, required sections, and verification strategy. It does NOT cover agent execution or runtime behavior—those are downstream consumers of the spec output.

## Core vs Advanced Sections

A spec has two tiers. **Default to the core tier, and keep it as small as the task permits.** The advanced sections exist for unusual cases and add cost (author time, reader time, agent-side replan friction when the decomposition is wrong) — they are not free.

**Required core sections (always write these):**
`## Task`, `## Success Criteria`.

**Repository URL header (write when known):**
If the target GitHub repository URL is supplied by the user or can be inferred from the current checkout, write the canonical `https://github.com/<owner>/<repo>` URL as the first non-empty line of the spec, followed by a blank line, before `## Task`. This URL is metadata, not a section, and is not counted as a core section. If no repository URL is known, omit it rather than blocking an otherwise concrete spec.

**Optional core context (add only when relevant):**
`## Constraints`, `## Assumptions`, `## Risks`, `## Edge Cases`, `## Open Questions`.

`## Task` and `## Success Criteria` are enough for a valid minimal spec. Optional context improves convergence when it names real constraints, assumptions, risks, edge cases, or open decisions. Modern coding agents will decompose work, order steps, and derive verification on their own when the objective and criteria are clear.

**Advanced sections (rarely needed — see [When to Add Advanced Sections](#when-to-add-advanced-sections)):**
`## Milestones`, `## Steps`, `## Assertions`.

Only add these when the work is large or multi-phase enough that the author — not the agent — must dictate dependency ordering or pin specific assertions. In most cases, omitting them produces *better* plans because the agent picks the decomposition that fits its own capabilities.

## When to Use This Skill

Use this skill whenever you want an AI coding agent to produce a convergent plan with minimal backtracking. The spec you write becomes the **authoritative input** that the agent parses to understand intent, decompose work, and verify results—so a well-structured spec directly reduces ambiguity and failed verification.

### Concrete Triggers

- **New feature or greenfield project.** Capture intent, criteria, constraints, and risks. The agent decomposes the work.
- **Bug fix specification.** When a bug needs more than a one-line fix, provide a spec with a clear Problem / Root Cause / Expected Behavior structure.
- **Human-in-the-loop (HITL) design review.** Edit the spec to correct the agent's understanding rather than relying on clarification rounds.
- **Spec-first workflow for any AI agent.** Write the spec once and feed it to whichever coding agent you use; the structure travels across tools without format translation.
- **Maximum convergence, minimum replan.** Clear criteria, constraints, and edge cases give the agent strong seed data.

### When NOT to Use

- Trivial code changes that need no planning (typos, constant updates). Use a lightweight instruction instead.
- The work is already complete and verified. The spec is a planning input, not a post-hoc artifact.
- You are writing tooling or agent skills for other agents. This skill teaches spec writing for human authors communicating intent to AI agents.

## Work Procedure

Six authoring passes, in order, gated by a pre-step input-sufficiency check. Steps 2 and 3 produce the required sections; Steps 4 through 6 add optional context only when it is relevant. After Step 6, decide whether [advanced sections](#advanced-sections-optional) are warranted, then run [Finalize](#finalize) (validate + emit).

For worked examples — [`examples/since-flag.md`](examples/since-flag.md) (core-only with optional context) and [`examples/search-endpoint.md`](examples/search-endpoint.md) (maximal, with advanced sections) — load on demand. Not required reading.

---

### Step 0: Confirm Input Sufficiency (gate)

Before drafting, confirm you can fill in `## Task` and `## Success Criteria` concretely from what the user has given you. If either would be vague, **stop and ask 1–3 targeted questions** rather than guessing — a spec with a vague objective or untestable criteria produces worse plans than no spec at all.

Signals of thin input:
- Task statement would be a single vague verb ("improve", "refactor", "clean up") with no object or measurable outcome.
- Success Criteria would be aspirational ("works well", "fast enough") with no command, output pattern, or threshold.
- You don't know which files, routes, schemas, or surfaces the work touches.

When you stop to ask, name the gap directly: "I need a concrete acceptance test for X — what command or output should prove it works?" Do not draft a placeholder and ask later.

**`<!-- TODO -->` fallback.** Only insert TODO markers and proceed if the user explicitly says "just draft what you can," declines to clarify, or asks for a skeleton. In that case, mark every gap with `<!-- TODO: [what is missing] -->`, set the handoff `Status:` to `incomplete`, and surface the TODOs in the status line.

---

### Step 1: Read the Existing Codebase and Documentation

Ground yourself in the real code, config, schemas, and docs the work will touch. Note exact file paths, function names, types, and schema keys. Record current shapes of CLI flags, API routes, config keys, or database schemas. Capture the target GitHub repository URL from the user prompt or, when working in the checkout, infer it from `git remote get-url origin` and normalize SSH/Git URLs to `https://github.com/<owner>/<repo>`. **Output:** A working list of file paths and surfaces that constrain the design, plus the repository URL when known.

---

### Step 2: Define the Intent and Objective

Write a single, unambiguous statement of what the work must accomplish. If a repository URL is known, it must be the first non-empty line, followed by a blank line. Then start with `## Task` (also accepted: `## Task Description`). One or two paragraphs capturing **what** and **why**—avoid *how*.

**Example:**
```markdown
https://github.com/example/my-tool

## Task
Add a `--timeout` flag to the `run` command that caps wall-clock
duration of each step. When exceeded, cancel the step and record
a `timeout` reason in the summary.
```

---

### Step 3: Define Concrete Success Criteria

Transform the objective into observable, verifiable outcomes under `## Success Criteria`. Use measurable language: "command exits 0," "output contains X," "file Y is created."

**Example:**
```markdown
## Success Criteria
- `my-tool run --timeout 5s` cancels a step running longer than 5s.
- The summary shows `terminalReason: "timeout"` for cancelled steps.
- Steps without `--timeout` are unaffected (no regression).
```

---

### Step 4: Identify Constraints and Assumptions

- `## Constraints`: hard, non-negotiable rules. Reference specific files, CLI surfaces, schema versions, and compatibility commitments.
- `## Assumptions`: falsifiable environmental facts. If any assumption is wrong, the plan may need revision.

---

### Step 5: Enumerate Risks and Edge Cases

- `## Risks`: concrete failure modes with specific impact.
- `## Edge Cases`: boundary conditions—empty inputs, max values, concurrency, network failures, missing files, permission denials. Use a `Boundary | Values | Rationale` table.

**Example:** `| Timeout value | 0, negative, > 24h | 0 = no timeout; negative → error; > 24h must not overflow |`

---

### Step 6: Capture Open Questions

Use `## Open Questions` for unresolved design decisions the agent must resolve during planning (or escalate). Bullet list. If nothing is unresolved, omit the section.

---

## Advanced Sections (Optional)

> **Skip this section unless the work genuinely requires it.** In most cases the core sections above are sufficient and the agent will produce a better plan without author-dictated decomposition.

### When to Add Advanced Sections

Add `## Milestones`, `## Steps`, or `## Assertions` only when **all** of these apply:

- The work spans multiple sittings or multiple contributors, and ordering matters across them.
- The author has knowledge about dependencies (e.g., "schema migration must precede route changes") that is not derivable from reading the codebase.
- The verification surface is complex enough that the author wants to pin specific pass/fail gates the agent must not skip.

If only one or two of these apply, prefer the core spec and trust the agent to decompose.

You can also add only the subset that helps — for example, `## Milestones` without `## Steps` is valid when you want to enforce phase ordering but not micromanage atomic tasks.

### Optional: Milestones

Break the work into ordered, independently verifiable milestones. Create `## Milestones` with `###` blocks. Use labeled fields: `Dependencies:`, `Testable Outcomes:`, `Referenced Artifacts:`. Optional stable IDs like `` ### `m1` Name ``.

**Example:**
```markdown
## Milestones

### `m1` Timeout Parsing and Validation
Dependencies: []
Testable Outcomes:
- `my-tool run --timeout 5s` parses without error
- `my-tool run --timeout -1` exits non-zero with validation error
Referenced Artifacts:
- src/commands/run.ts
- src/executor/state.ts
```

### Optional: Steps

Create `## Steps`. Each step is an atomic unit of work with a `###` heading and optional ID, labeled fields `Milestone:` and `File Paths:`, a short description, and a `**Verification:**` block with copy-pasteable commands.

**Example:**
```markdown
## Steps

### `s1` Add --timeout CLI Flag
Milestone: `m1`
File Paths:
- src/commands/run.ts
- test/commands/run.test.ts

Add the `--timeout` flag using the existing CLI framework. Accept
duration syntax. Reject negative values. Zero means "no timeout."

**Verification:**
- Run `my-tool run --timeout 5s --dry-run` and confirm the flag is parsed.
- Run `my-tool run --timeout -1` and confirm non-zero exit.
- Run existing tests to confirm no regression.
```

### Optional: Assertions

Create `## Assertions` when you need pin pass/fail gates the agent must not skip. Every milestone (if present) should have at least one positive-path assertion and at least one negative-path assertion (append `(negative path)` to the heading). Each assertion is a `###` block with the full field set: `Id:`, `Milestone:`, `Owner Work Item:`, `Description:`, and `Evidence Requirements:` (concrete, copy-pasteable evidence like commands, file paths, or output patterns).

Assertions are pass/fail gates derived from the milestone's Testable Outcomes and the step's Verification commands — not duplicates. A step's verification confirms the step ran; an assertion confirms the milestone's contract holds.

**Example:**
```markdown
## Assertions

### `a1` Timeout Cancels Long Step (positive path)
Id: a1
Milestone: `m1`
Owner Work Item: `s1`
Description: A step exceeding the timeout is cancelled and recorded.
Evidence Requirements:
- `my-tool run --timeout 1s` on a 5s step exits non-zero within 2s.
- Summary JSON contains `"terminalReason":"timeout"`.

### `a2` Negative Timeout Rejected (negative path)
Id: a2
Milestone: `m1`
Owner Work Item: `s1`
Description: Negative timeout values are rejected at parse time.
Evidence Requirements:
- `my-tool run --timeout -1` exits non-zero.
- stderr contains `invalid timeout`.
```

---

## Finalize

After the required sections, any optional context, and any advanced sections are drafted, finalize with two phases: **validate**, then **emit**.

### Validate

Run the spec through the [Writing Checklist](#writing-checklist). A failing required check blocks handoff. Optional context checks only apply when the section or surface is present or clearly relevant. Advanced-section checks only apply to the advanced sections you authored.

### Emit

Two outputs, in this order:

1. **Full spec to stdout.** Print the complete spec markdown. When a repository URL is known, it is the first non-empty line, followed by a blank line, then `## Task`. This is the authoritative output: downstream agents read it from here, and the user reads it inline in the conversation.
2. **One-line status, then return.** After the spec body, print a single status line and return control. Do not write to disk.

**Status line format:**

```
Spec ready — <N> core sections, <M> success criteria<, K advanced if K > 0>.
Next: review above, edit a section, ask me to save a copy, or hand to the agent.
```

- `<N>` counts core sections present (Task, Success Criteria, Constraints, Assumptions, Risks, Edge Cases, Open Questions).
- `<M>` counts bullets under `## Success Criteria`.
- `<K>` counts advanced sections used. Omit the clause when zero.

If the user asks to save a copy after emit, ask them for a path and use a normal file write — do not pick a path silently. There is no hardcoded sidecar location; `/tmp/specs/`, project paths, and platform-specific temp dirs are all the user's choice.

---

## Section Reference

| Section (`##`) | Tier | Aliases | `###` Block Fields | Planning Concept |
|----------------|------|---------|--------------------|-------------------|
| `## Task` | core required | `## Task Description` | *(none—prose body)* | Objective — the single goal every milestone and step must serve. |
| `## Success Criteria` | core required | — | *(bullet list of measurable outcomes)* | Success Criteria — testable anchors for judging completion. |
| `## Constraints` | core optional | — | *(bullet list)* | Constraints — boundaries that invalidate any plan that violates them. |
| `## Assumptions` | core optional | — | *(bullet list)* | Assumptions — hypotheses; if false, the plan may need revision. |
| `## Risks` | core optional | — | *(bullet list)* | Risks — concrete failure modes and impact. |
| `## Edge Cases` | core optional | — | `Boundary \| Values \| Rationale` table | Edge Cases — boundary inputs and concurrency the plan must cover. |
| `## Open Questions` | core optional | — | *(bullet list)* | Open Questions — ambiguities the agent must resolve during planning. |
| `## Milestones` | **advanced** | — | `Dependencies:`, `Testable Outcomes:`, `Referenced Artifacts:` | Milestones — author-dictated decomposition; use only when ordering matters. |
| `## Steps` | **advanced** | — | `Milestone:`, `File Paths:`, `**Verification:**` block | Steps — atomic tasks; use only to pin specific verification. |
| `## Assertions` | **advanced** | — | `Id:`, `Milestone:`, `Owner Work Item:`, `Description:`, `Evidence Requirements:` | Assertions — pin pass/fail gates the agent must not skip. |

**Heading ID pattern** (advanced sections): `` ### `m1` Milestone Name `` — backticked ID, then name. Append `(negative path)` to negative-path assertion headings.

**Non-goals:** Declare explicit out-of-scope items as bullets in `## Constraints` (hard exclusions) or `## Assumptions` (scope assumptions). There is no dedicated `## Non-Goals` section.

---

## Writing Checklist

Validate your spec against this checklist before handoff (the [Validate](#validate) phase of Finalize). `## Task` and `## Success Criteria` are the only required sections. Do not fail a spec solely because it omits optional context.

**Required checks (always apply):**

| # | Check | Pass? |
|---|-------|-------|
| 1 | If the target GitHub repository URL is known, it is the first non-empty line before `## Task` | ☐ |
| 2 | `## Task` present with clear objective | ☐ |
| 3 | Success criteria are measurable | ☐ |

**Optional context checks (apply only when present or relevant):**

| # | Check | Pass? |
|---|-------|-------|
| C1 | If `## Constraints` is present, it lists hard rules with concrete references | ☐ |
| C2 | If `## Assumptions` is present, assumptions are falsifiable and contain no hidden design decisions | ☐ |
| C3 | If `## Risks` is present, risks name concrete failure modes | ☐ |
| C4 | If `## Edge Cases` is present, boundaries are concrete (empty, max, concurrent, perms, or task-specific equivalents) | ☐ |
| C5 | If `## Open Questions` is present, it captures unresolved decisions rather than vague TODOs | ☐ |
| C6 | If a public surface changes, syntax and validation are explicit in `## Success Criteria` or `## Constraints` | ☐ |
| C7 | If existing behavior changes, backwards compatibility is addressed in `## Success Criteria`, `## Constraints`, or `## Risks` | ☐ |
| C8 | If multiple config sources exist, merge precedence is defined | ☐ |

**Advanced checks (apply only to authored advanced sections):**

| # | Check | Pass? |
|---|-------|-------|
| A1 | If `## Milestones` is present, each milestone has `Dependencies:`, `Testable Outcomes:`, and `Referenced Artifacts:` | ☐ |
| A2 | If `## Milestones` is present, every milestone's outcomes are independently verifiable | ☐ |
| A3 | If `## Steps` is present, each step has `Milestone:` and `File Paths:` | ☐ |
| A4 | If `## Steps` is present, every step has at least one copy-pasteable verification command | ☐ |
| A5 | If `## Assertions` is present, each assertion has the full field set | ☐ |
| A6 | If `## Assertions` is present and failure-mode coverage is relevant, at least one assertion is marked `(negative path)` | ☐ |

## Worked Examples

- **Core-only** ([`examples/since-flag.md`](examples/since-flag.md)) — a small CLI flag spec using no advanced sections. Match this for most specs when optional context is useful.
- **Maximal** ([`examples/search-endpoint.md`](examples/search-endpoint.md)) — a search-endpoint spec exercising **every** section including advanced (Milestones, Steps, Assertions). Reference when adding advanced sections, not as the default.

---

## Anti-Patterns

Weak draft sections — and the fix for each. If your draft matches the ❌ side, an agent will have to clarify before it can plan.

**Vague Task.**
- ❌ "Improve the search experience."
- ✅ "Add a `q`-parameter `GET /api/v1/search` endpoint that returns paginated product results from the existing catalog."
- Why: no object, no surface, no measurable outcome.

**Untestable Success Criterion.**
- ❌ "Search feels fast and intuitive."
- ✅ "Response time is under 200 ms for result sets up to 100 items."
- Why: no command to run, no threshold to compare against.

**Vague Risk.**
- ❌ "There may be performance problems."
- ✅ "Full-table scan under load: if the query planner does not use the FTS index, p95 response time exceeds 200 ms at 50 concurrent requests."
- Why: a risk without a specific failure mode and impact cannot be mitigated or monitored.

**Hidden Design Decision in Assumptions.**
- ❌ "Assumption: we will use Elasticsearch for the index."
- ✅ "Constraint: must use the existing Postgres FTS index in `src/db/products.ts`." (Or move to `## Open Questions` if unresolved.)
- Why: assumptions are environmental facts, not technology choices. Burying a design decision here hides it from the plan review.

**Decorative Milestone** *(only relevant if you authored advanced sections)*.
- ❌ `` ### `m1` Make Everything Work ``
- ✅ `` ### `m1` Search Route Parses and Validates Query Parameters ``
- Why: the bad name has no scope and no testable outcome; it cannot serve as a gate.

**Soft Assertion** *(only relevant if you authored advanced sections)*.
- ❌ `Evidence Requirements: search works correctly.`
- ✅ `Evidence Requirements: curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/v1/search?q=widget" outputs 200.`
- Why: a soft assertion cannot pass or fail on its own — there is no command to run or output to check.

---

## When to Return to Orchestrator

Return control to the calling agent when one of these holds:

1. **Spec emitted.** Body printed to stdout with the status line per [Finalize: Emit](#emit), contains at least `## Task` and `## Success Criteria`, and passes the required [Writing Checklist](#writing-checklist) checks plus any applicable optional checks.
2. **User cancelled.** "stop," "cancel," "never mind" — confirm and do not emit a partial spec.
3. **Spec already sufficient.** User supplied an existing spec that meets the minimum and passes the checklist — confirm and return without rewriting.
4. **Incomplete with TODOs.** Only if the user opted into the [Step 0](#step-0-confirm-input-sufficiency-gate) fallback. Emit the partial spec, set status to `incomplete`, and list every `<!-- TODO -->` location in the status line.

Do **not** return while mid-procedure, waiting on an in-flight tool result, or before running the [Writing Checklist](#writing-checklist).
