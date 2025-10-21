# Contributing to Documentation

This guide explains how to add new pages or documentation to the Keycloak Operations project.

## Adding a New Page

### Step 1: Create the Markdown File

Create a new `.md` file in the `docs/` directory. Use descriptive filenames with hyphens for spaces:
```bash
docs/your-page-name.md
```

### Step 2: Write the Content

Use standard Markdown syntax:
```markdown
# Page Title

## Section Heading

Content here...

### Subsection

More content...

- Bullet points
- Another point

1. Numbered lists
2. Second item

[Links](url)
```

### Step 3: Add to Navigation

Edit `mkdocs.yml` and add your new page to the `nav` section:
```yaml
nav:
  - Home: index.md
  - Documentation: documentation.md
  - Your New Page: your-page-name.md
```
For nested navigation:

```yaml
nav:
  - Home: index.md
  - Getting Started:
    - Overview: getting-started/overview.md
    - Quick Start: getting-started/quick-start.md
    - Your New Guide: getting-started/your-guide.md

```

### Step 4: Test Locally

Run the documentation site locally to verify:
```bash
# Activate virtual environment
source venv/bin/activate

# Start local server
mkdocs serve
```

Visit `http://localhost:8000` to preview your changes.

### Step 5: Commit and Push
```bash
git add docs/your-page-name.md mkdocs.yml
git commit -m "Add new documentation page: [page title]"
git push
```

## Best Practices

- Use clear, descriptive titles
- Include a brief introduction at the top
- Use headings to organize content (H1 for title, H2 for sections, H3 for subsections)
- Keep lines under 80 characters for readability
- Use relative links for internal documentation
- Include code examples where helpful
- Test all links and code snippets before committing

## Current Directory Structure
```
keycloak-ops/
├── .github/
│   └── workflows/
│       └── deploy-docs.yml    # GitHub Actions deployment workflow
├── docs/
│   ├── index.md               # Home page
│   ├── documentation.md       # Main documentation page
│   └── contributing.md        # This file
├── venv/                      # Virtual environment (not in git)
├── .gitignore
├── mkdocs.yml                 # MkDocs configuration
├── requirements.txt           # Python dependencies
└── README.md                  # Project overview
```

## Need Help?

If you need assistance or have questions about contributing documentation:

1. Check existing documentation files (`index.md`, `documentation.md`) for examples
2. Review the [MkDocs documentation](https://www.mkdocs.org/)
3. Review the [Material for MkDocs documentation](https://squidfunk.github.io/mkdocs-material/)
4. Open an issue on [GitHub](https://github.com/ADORSYS-GIS/keycloak-ops/issues) for questions
