# CoreSourceAI Skills

Portable Agent Skills for coding agents.

For Codex marketplace installs, this repository publishes a plugin named `spec-writer`. It currently ships:

- `spec-writer`: drafts agent-ready implementation specifications with a clear task, measurable success criteria, optional constraints/risks/edge cases, and optional advanced planning sections.

## Layout

```text
.
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── .agents/plugins/marketplace.json
├── .codex-plugin/plugin.json
├── marketplace.json
├── plugins/spec-writer/
│   ├── .codex-plugin/plugin.json
│   └── skills/spec-writer/
├── scripts/
│   ├── install.sh
│   ├── package.sh
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
codex plugin add spec-writer@coresourceai-skills
```

The `spec-writer` plugin exposes the `spec-writer` skill.

## How to Use

Invoke `spec-writer` by name in your prompt:

```text
Use $spec-writer to draft an agent-ready implementation spec for adding a --since flag to the list command.
```

For Claude Code, plugin skills are also available as slash commands after install:

```text
/skills:spec-writer draft an agent-ready implementation spec for adding a --since flag to the list command.
```

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

## Install in Claude.ai

Download the latest Claude.ai skill bundle from the GitHub release asset:

https://github.com/coresource-ai/skills/releases/download/latest/spec-writer.zip

Then upload `spec-writer.zip` in Claude.ai from `Customize > Skills > + Create skill > Upload a skill`.

The ZIP is rebuilt on every push to `main` and contains `spec-writer/SKILL.md` at the top level, which is the upload shape Claude.ai expects.

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

## Package

Build the Claude.ai upload ZIP locally:

```bash
./scripts/package.sh
```

The output is `dist/spec-writer.zip`.
