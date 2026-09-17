# labs

One folder = one subdomain. Push to `main` and the `mirror` workflow publishes
`<folder>/` to `https://<folder>.anatole.wiki` (via a mirror repo `a2br/<folder>` + GitHub Pages)
and rebuilds the directory at `https://labs.anatole.wiki`.

- Put a complete `index.html` (doctype/html/head/body) in `<name>/`; name = lowercase letters, digits, dashes.
- Optionally describe it in `labs.json`.
- `git add <name> && git commit && git push`. Done. First publish of a new name takes a few minutes (Pages build + TLS cert).

Needs the repo secret `LABS_PAT` (classic token, scope `repo`). Details for agents in `AGENTS.md`.
