# Helm Chart Repository Copilot Instructions

These are the preferred guidelines for code generation and suggestions in this Helm chart repository:

- Follow Helm best practices for chart structure and templating.
- Use YAML anchors and aliases for repeated values where appropriate.
- Prefer parameterization via `values.yaml` over hardcoding values in templates.
- Place reusable template logic in `_helpers.tpl` and reference it from other templates.
- Write clear, descriptive comments for all templates and values.
- Validate charts with `helm lint` before committing changes.
- Ensure all charts are compatible with supported Kubernetes versions and follow Kubernetes best practices.
- Use semantic versioning for chart versions in `Chart.yaml`.
- Do not include secrets or sensitive data in the repository; use external secret management solutions.
- Keep `README.md` and chart documentation up to date with usage and configuration instructions.
- Prefer explicit resource requests and limits in deployment templates.
- Use `.Release.Name` and `.Values` for namespacing and configuration.
- Avoid deprecated Kubernetes APIs and features.
