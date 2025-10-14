# Architecture Overview

## Documentation Site Architecture

```mermaid
graph TB
    A[GitHub Repository] --> B[MkDocs Configuration]
    B --> C[Markdown Content]
    C --> D[MkDocs Build Process]
    D --> E[Static Site Generation]
    E --> F[GitHub Pages Hosting]

    G[Contributors] --> H[Pull Requests]
    H --> I[Code Review]
    I --> J[Merge to Main]
    J --> K[CI/CD Pipeline]
    K --> L[Automated Deployment]

    M[Users] --> N[GitHub Pages URL]
    N --> O[Documentation Site]

    P[Local Development] --> Q[mkdocs serve]
    Q --> R[Live Preview]

    style A fill:#e1f5fe
    style F fill:#c8e6c9
    style O fill:#c8e6c9
    style R fill:#fff3e0
```

## Content Structure

```
keycloak-ops/
├── docs/                          # Documentation source
│   ├── index.md                  # Homepage
│   ├── getting-started/          # Getting started guides
│   ├── installation/             # Installation docs
│   ├── operations/               # Operational guides
│   └── reference/                # Reference materials
├── mkdocs.yml                    # MkDocs configuration
├── requirements.txt              # Python dependencies
├── .github/workflows/            # CI/CD workflows
│   └── deploy-docs.yml
└── README.md                     # Project documentation
```

## Deployment Pipeline

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as GitHub
    participant CI as GitHub Actions
    participant Pages as GitHub Pages

    Dev->>Git: Push to main branch
    Git->>CI: Trigger workflow
    CI->>CI: Checkout code
    CI->>CI: Setup Python
    CI->>CI: Install dependencies
    CI->>CI: Build documentation
    CI->>CI: Upload artifact
    CI->>Pages: Deploy to Pages
    Pages->>Pages: Site live
```

## Technology Stack

- **Static Site Generator:** MkDocs
- **Theme:** Material for MkDocs
- **Hosting:** GitHub Pages
- **CI/CD:** GitHub Actions
- **Version Control:** Git
- **Content Format:** Markdown with extensions

## Key Components

### MkDocs Configuration (`mkdocs.yml`)
- Site metadata and settings
- Theme configuration with light/dark mode
- Navigation structure
- Markdown extensions for enhanced features

### Content Organization
- Modular structure with clear separation of concerns
- Cross-referenced documentation sections
- Consistent formatting and style

### CI/CD Pipeline
- Automated testing and building
- Secure deployment to GitHub Pages
- Status monitoring with badges

This architecture ensures maintainable, scalable, and user-friendly documentation delivery.