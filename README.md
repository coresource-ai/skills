# CoreSourceAI Skills

Portable Agent Skills for coding agents.

This repository is also a Codex plugin named `skills`. It currently ships:

- `spec-writer`: drafts agent-ready implementation specifications with a clear task, measurable success criteria, optional constraints/risks/edge cases, and optional advanced planning sections.

## Layout

```text
.
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
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

## Install in Codex

Add the GitHub repository as a Codex plugin marketplace:

```bash
codex plugin marketplace add coresource-ai/skills --ref main
codex plugin add skills@coresourceai-skills
```

The `skills` plugin exposes every skill under `./skills`.

## Install in Claude Code

Install the plugin directly from the GitHub marketplace:

```bash
claude plugin marketplace add coresource-ai/skills
claude plugin install skills@coresourceai-skills
```

Or from inside Claude Code:

```text
/plugin marketplace add coresource-ai/skills
/plugin install skills@coresourceai-skills
```

## Direct Skill Install

Install into Codex or Claude Code from a local checkout:

```bash
./scripts/install.sh codex
./scripts/install.sh claude
```

Install into any Agent Skills-compatible root from a local checkout:

```bash
./scripts/install.sh generic /path/to/skills-root
```

## Validate

```bash
./scripts/validate.sh
```

The validation script checks JSON syntax, required plugin files, skill frontmatter, examples, and install script syntax.
