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

## Install in Codex

Add the GitHub repository as a Codex plugin marketplace:

```bash
codex plugin marketplace add coresource-ai/skills --ref main
codex plugin add skills@coresourceai-skills
```

The `skills` plugin exposes every skill under `./skills`.

## Install in Claude Code

Clone the repository and copy the skill into Claude Code's skills directory:

```bash
git clone https://github.com/coresource-ai/skills.git
cd skills
./scripts/install.sh claude
```

This installs `spec-writer` to `~/.claude/skills/spec-writer`.

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
