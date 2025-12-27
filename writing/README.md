# Writing

This folder holds the writing pipeline that sits alongside the rest of the workspace. It keeps creative work separated from product work while still sharing the same tooling, notes, and review habits used elsewhere in the repo.

## Phase Flow

idea -> exploration -> theme -> outline -> draft -> revision

Each phase has its own folder and template to keep scope small and decisions traceable.

## Rule Hierarchy

Writing guidance is layered. When conflicts occur, follow `writing/_system/rule_hierarchy.md`:
chapter metadata > novel README > style profile > global system rules.

## Global vs Style vs Novel Rules

- Global rules live in `writing/_system/` (workflow, style rules, glossaries).
- Style profiles live in `writing/_styles/` and define genre/tone/audience guidance.
- Novel-specific rules live in each `writing/novels/<title>/README.md`.

## Style Checklist

Use the checklist in `writing/_system/style_checklist.md` during revision to ensure
metadata, pacing, and tone align with the selected style profile.

## Choosing a Style Profile

Add a `Style Profile: <name>` line in the novel README. Profiles are stored as
`writing/_styles/<name>.md`. Use a single primary profile per novel and note any
exceptions in chapter metadata.

## Tools: Codex and Gemini

- Codex: structured help for planning, outlining, tracking decisions, and turning notes into drafts. Used for clarity, consistency, and speeding up iteration.
- Gemini: divergent ideation, alternative takes, and pressure-testing themes. Used to broaden options before converging.

No story text is stored here until a phase explicitly calls for it in its folder.
