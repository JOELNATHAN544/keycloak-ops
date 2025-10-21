# Contributing to Documentation

This guide explains how to add new pages or documentation to the Keycloak Operations project.

## Adding a New Page

### Step 1: Create the Markdown File

Create a new `.md` file in the appropriate directory under `docs/`. Use descriptive filenames with hyphens for spaces:

- For general documentation: `docs/your-page-name.md`
- For getting started guides: `docs/getting-started/your-guide.md`
- For installation docs: `docs/installation/your-topic.md`
- For operations: `docs/operations/your-operation.md`
- For reference: `docs/reference/your-reference.md`

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
  - Your Page: your-page-name.md
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
mkdocs serve
```

Visit `http://localhost:8000` to preview your changes.

### Step 5: Commit and Push

```bash
git add .
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
- Test all links and code snippets

## Directory Structure

```
docs/
├── index.md                 # Home page
├── documentation.md         # Main documentation page
├── getting-started/
│   ├── overview.md
│   ├── quick-start.md
│   └── prerequisites.md
├── installation/
│   ├── guide.md
│   └── configuration.md
├── operations/
│   ├── deployment.md
│   ├── monitoring.md
│   └── troubleshooting.md
├── reference/
│   ├── api.md
│   └── config.md
├── architecture.md
├── changelog.md
└── contributing.md          # This file
```

## Need Help?

If you need assistance or have questions about contributing documentation, please:

1. Check existing documentation for examples
2. Review the MkDocs documentation: https://www.mkdocs.org/
3. Open an issue on GitHub for questions