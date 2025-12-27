# Gemini Workspace (`product-lab`)

This file provides context for Gemini to interact with the `product-lab` repository.

## Directory Overview

This repository is a structured workspace for product development, research, and creative writing. It follows a "documentation-first" methodology, where processes, research, and specifications are meticulously documented before and during project delivery.

The repository is organized into three main sections:

*   `docs/`: Contains shared documentation, system guidelines, and templates for research and delivery artifacts.
*   `projects/`: Workspaces for individual products. Each product has its own documentation, application, and backend directories.
*   `writing/`: A dedicated space for creative writing projects, including novels, with its own set of templates and guidelines.

There is no buildable code in the root of this project; it is primarily a documentation and project management repository.

## Key Files

*   `README.md`: The main entry point for understanding the repository's structure and the research-to-delivery workflow.
*   `AGENTS.md`: Provides detailed guidelines for interacting with the repository, including project structure, naming conventions, and workflow.
*   `docs/_system/`: Holds shared system-level documentation, such as research methodologies, decision logs, and glossaries.
*   `docs/_templates/`: Contains reusable templates for a consistent approach to research and delivery artifacts across different projects.
*   `writing/_system/`: Contains system-level documentation and rules for creative writing projects.
*   `writing/_templates/`: Contains reusable templates for the creative writing process, from idea generation to revision.

## Usage

This repository is intended to be used as a structured environment for managing the entire lifecycle of products and creative writing projects. The workflow is sequential, starting from exploration and research and moving through to delivery and implementation.

To interact with this repository, you should:

1.  **Understand the structure:** Familiarize yourself with the `docs`, `projects`, and `writing` directories and their purposes.
2.  **Use the templates:** When creating new artifacts, use the templates provided in `docs/_templates/` and `writing/_templates/` to ensure consistency.
3.  **Follow the workflow:** Adhere to the research-to-delivery flow outlined in the `README.md` and `AGENTS.md` files.

## Development Conventions

*   **No Build/Test Runner:** This is a documentation-first repository with no automated build or test runners.
*   **Searching:** Use `rg "keyword"` to search for content across the repository.
*   **File Listing:** Use `rg --files` to list all tracked files.
*   **Commit Messages:** Commit messages should be short, imperative, and descriptive.
*   **Pull Requests:** PRs should be concise and reference relevant templates or decision logs.
