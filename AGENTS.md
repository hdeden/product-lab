# Repository Guidelines

## Project Structure & Module Organization
- `docs/_system/` contains shared methods, glossaries, and ADR guidance.
- `docs/_templates/` holds reusable research and delivery templates (e.g., `docs/_templates/06_tech_spec.md`).
- `writing/_system/` and `writing/_templates/` mirror the docs system for novel workflows.
- `writing/novels/<title>/README.md` is the entry point for each novel.
- `projects/<product>/` is a placeholder workspace for each product; add `docs/`, `app/`, and `backend/` as needed.

## Build, Test, and Development Commands
This repository is documentation-first and has no build or test runner configured.
- `rg "keyword"`: search across docs and templates.
- `rg --files`: list tracked files to locate templates quickly.
- `git status`: verify working tree changes before edits.

## Coding Style & Naming Conventions
- Use Markdown with clear headings and short paragraphs; keep formatting consistent with existing docs.
- Follow template naming patterns: numbered prefixes like `00_exploration.md`, `06_revision.md`.
- Prefer ASCII-only content unless a template already uses localized language.
- For writing assets, align with `writing/_system/style_rules.md` for tone and formatting.

## Testing Guidelines
- No automated tests are defined at the repo level.
- For delivery work, use the test plan template at `docs/_templates/08_test_plan.md` and store outputs under the relevant `projects/<product>/docs/` folder.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and descriptive (e.g., `Add novel writing workspace with chapter lifecycle system`).
- Keep commits focused on one topic; separate template changes from project artifacts when possible.
- PRs should include a concise summary, relevant template references, and links to related issues or decision logs in `docs/_system/decision_log.md` when applicable.

## Research & Delivery Workflow
- Follow the repository flow: explore → research → synthesis → requirements → BA design → tech spec → implementation plan → test plan → delivery.
- Use `docs/_templates/` in order to keep artifacts consistent across projects.
