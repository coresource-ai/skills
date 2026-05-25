# CoreSourceAI Skills

Portable Agent Skills for coding agents.

This repository is also a Codex plugin named `skills`. It currently ships:

- `spec-writer`: drafts agent-ready implementation specifications with a clear task, measurable success criteria, optional constraints/risks/edge cases, and optional advanced planning sections.

## Layout

```text
.
├── .codex-plugin/plugin.json
├── marketplace.json
├── scripts/
│   ├── install.sh
│   └── validate.sh
└── skills/
    └── spec-writer/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── examples/
```

## Codex Plugin Install

From this repo root:

```bash
codex plugin marketplace add "$(pwd)"
```

Then install the `skills` plugin from the Codex plugin UI. The plugin exposes every skill under `./skills`.

## Direct Skill Install

Install `spec-writer` into common Agent Skills roots:

```bash
./scripts/install.sh codex
./scripts/install.sh claude
```

Install into any Agent Skills-compatible root:

```bash
./scripts/install.sh generic /path/to/skills-root
```

## Validate

```bash
./scripts/validate.sh
```

The validation script checks JSON syntax, required plugin files, skill frontmatter, examples, and install script syntax.
