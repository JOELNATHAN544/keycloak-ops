# keycloak-ops Documentation

A comprehensive documentation site for Keycloak Community Edition (CC) deployment and operations, built with MkDocs and hosted on GitHub Pages.

## 📋 Project Overview

This repository contains the source code for the Keycloak Operations Documentation website. The documentation provides operational guidance for managing Keycloak CC deployments, covering:

- Installation and configuration procedures
- Deployment strategies (standalone, clustered, containerized)
- Monitoring and observability setup
- Troubleshooting common operational issues
- Best practices and reference materials
- API and configuration references

The documentation is structured using MkDocs with the Material theme, providing a clean, responsive, and searchable documentation experience.

## 🚀 Local Development Setup

### Prerequisites

- Python 3.8 or higher
- Git
- Basic knowledge of MkDocs (optional but helpful)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ADORSYS-GIS/keycloak-ops.git
   cd keycloak-ops
   ```

2. **Create a virtual environment (recommended):**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Start the development server:**
   ```bash
   mkdocs serve
   ```

5. **Open your browser** and navigate to `http://localhost:8000` to view the documentation.

## 📝 How to Add/Edit Documentation

### File Structure

The documentation follows this structure:
```
docs/
├── index.md                    # Homepage
├── getting-started/
│   ├── overview.md            # Getting started overview
│   ├── prerequisites.md       # System requirements
│   └── quick-start.md         # Quick start guide
├── installation/
│   ├── guide.md               # Installation procedures
│   └── configuration.md       # Configuration options
├── operations/
│   ├── deployment.md          # Deployment strategies
│   ├── monitoring.md          # Monitoring setup
│   └── troubleshooting.md     # Troubleshooting guide
└── reference/
    ├── api.md                 # API reference
    └── config.md              # Configuration reference
```

### Adding New Content

1. **Create or edit Markdown files** in the appropriate `docs/` subdirectory
2. **Update `mkdocs.yml`** if adding new pages to the navigation:
   ```yaml
   nav:
     - Your Section:
       - New Page: your-section/new-page.md
   ```
3. **Follow Markdown best practices:**
   - Use descriptive headings
   - Include code blocks with syntax highlighting
   - Add internal links using relative paths
   - Use MkDocs extensions (admonitions, tabs, etc.) where appropriate

### Content Guidelines

- Write in clear, concise English
- Include practical examples and code snippets
- Provide cross-references to related sections
- Use admonitions for important notes, warnings, and tips
- Test all links and examples locally

## 🧪 How to Test Changes Locally

### Preview Changes

1. **Start the development server:**
   ```bash
   mkdocs serve
   ```

2. **Make your changes** to `.md` files or `mkdocs.yml`

3. **View changes in real-time** at `http://localhost:8000`

### Build and Validate

1. **Build the site locally:**
   ```bash
   mkdocs build
   ```

2. **Check for build errors** in the terminal output

3. **Preview the built site:**
   ```bash
   python -m http.server 8001 -d site/
   ```
   Then visit `http://localhost:8001`

### Testing Checklist

- [ ] All pages load without errors
- [ ] Navigation works correctly
- [ ] Search functionality works
- [ ] Links are valid and functional
- [ ] Code syntax highlighting is correct
- [ ] Responsive design works on mobile/desktop

## 🚀 Deployment Process

### Automatic Deployment

The documentation is automatically deployed to GitHub Pages when changes are pushed to the `main` branch. The deployment process includes:

1. **Trigger:** Push to `main` or `pipeline-deployment` branch, or manual workflow dispatch
2. **Build:** Install Python dependencies and build documentation with MkDocs
3. **Deploy:** Upload built site to GitHub Pages

### Manual Deployment

You can also trigger deployment manually:

1. Go to the repository's **Actions** tab
2. Select the **"Deploy Documentation to GitHub Pages"** workflow
3. Click **"Run workflow"**

### Deployment URL

Once deployed, the documentation is available at: https://adorsys-gis.github.io/keycloak-ops/

## 🔄 CI/CD Pipeline Flow

The CI/CD pipeline is defined in `.github/workflows/deploy-docs.yml` and consists of two jobs:

### Build Job
- **Environment:** Ubuntu latest
- **Steps:**
  1. Checkout repository
  2. Setup Python 3.x with pip caching
  3. Install MkDocs and Material theme
  4. Build documentation (`mkdocs build`)
  5. Upload built site as artifact

### Deploy Job
- **Environment:** GitHub Pages environment
- **Dependencies:** Requires successful build job
- **Steps:**
  1. Deploy artifact to GitHub Pages
  2. Generate deployment URL

### Pipeline Triggers
- **Automatic:** Push to `main` or `pipeline-deployment` branches
- **Manual:** Workflow dispatch from GitHub Actions UI

### Security & Permissions
- Uses GitHub-provided tokens with minimal required permissions
- Pages write access for deployment
- ID token for secure authentication

## 🐛 Troubleshooting Common Issues

### Local Development Issues

**MkDocs server won't start:**
```bash
# Ensure you're in the correct directory
cd /path/to/keycloak-ops

# Check Python version
python --version  # Should be 3.8+

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

**Port 8000 already in use:**
```bash
# Use a different port
mkdocs serve -a 0.0.0.0:8001
```

**Build fails with import errors:**
```bash
# Clear pip cache and reinstall
pip cache purge
pip install -r requirements.txt
```

### Content Issues

**Links not working:**
- Use relative paths for internal links: `../section/page.md`
- Test all links locally before committing

**Syntax highlighting not working:**
- Ensure code blocks have correct language specifiers
- Check that MkDocs extensions are properly configured in `mkdocs.yml`

### Deployment Issues

**GitHub Pages deployment fails:**
- Check the Actions tab for error details
- Ensure `mkdocs.yml` is valid YAML
- Verify all referenced files exist

**Site not updating after deployment:**
- Wait 2-3 minutes for GitHub Pages to propagate
- Check the deployment status badge
- Clear browser cache or try incognito mode

### Getting Help

- Check existing [GitHub Issues](https://github.com/ADORSYS-GIS/keycloak-ops/issues)
- Review [MkDocs documentation](https://www.mkdocs.org/)
- Contact the ADORSYS-GIS team for support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes and test locally
4. Commit your changes: `git commit -am 'Add new feature'`
5. Push to the branch: `git push origin feature/your-feature`
6. Submit a Pull Request

## 📄 License

This documentation is maintained by the ADORSYS-GIS team. See the repository for licensing information.

---

**Last updated:** October 2025