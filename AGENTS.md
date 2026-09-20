# labs — publishing a project to `<name>.anatole.wiki`

This repo (`a2br/labs`, local copy `~/Developer/labs`) is the single source of truth for Anatole's
static side projects. **One top-level folder = one subdomain.** A GitHub Actions workflow
(`.github/workflows/mirror.yml`) mirrors each folder to its own repo `a2br/<name>` and serves it with
GitHub Pages at `https://<name>.anatole.wiki`; it also rebuilds the directory page `https://labs.anatole.wiki`.

## To publish or update a project

1. Create/edit `<name>/index.html`. `name` = lowercase letters, digits, dashes (it is the subdomain).
   `index.html` must be a **complete HTML document** (doctype, html, head, body), self-contained
   (inline CSS/JS, data: URIs for images; Google Fonts / cdnjs are fine). Extra files in the folder are served too.
2. Optionally add/adjust the one-line description in `labs.json`.
3. `git add <name> labs.json && git commit -m "<name>: …" && git push origin main`.

That is all. Do **not** add `CNAME` or `.nojekyll` (the workflow adds them), do not create the mirror repo
by hand, do not touch DNS. First publish of a new name is live in ~1–2 min; HTTPS a few minutes later.
Re-mirror everything: Actions → mirror → Run workflow.

## How it works (already set up — never redo)

- OVH DNS: `*.anatole.wiki CNAME a2br.github.io.` → every subdomain resolves to GitHub Pages.
  Plus the `_github-pages-challenge-a2br` TXT record used to verify the domain.
- `anatole.wiki` is a **verified Pages domain** on the a2br account → only a2br's repos may claim `*.anatole.wiki`.
- The workflow, for each changed folder: `gh repo create a2br/<name>` if missing → orphan commit of the folder
  (+ `CNAME`, `.nojekyll`) force-pushed to `<name>:main` → Pages enabled from `main:/`, custom domain set,
  HTTPS enforced. Mirror repos are build outputs; never edit them directly.
- The `labs` repo itself is published with Pages "GitHub Actions" source at `labs.anatole.wiki`.
- Secret `LABS_PAT` (classic token, scope `repo`) lets the workflow create/push mirror repos. If a run fails with
  "secret LABS_PAT is missing" or 401/403, the token is absent or expired: Anatole makes a new one at
  https://github.com/settings/tokens/new?scopes=repo and sets it at https://github.com/a2br/labs/settings/secrets/actions.

## Removing a project

Delete the folder and push. The workflow only warns; archive or delete `a2br/<name>` by hand.

## Verify

    curl -sI https://<name>.anatole.wiki | head -1        # HTTP/2 200
    gh run list -R a2br/labs -L 3                         # workflow status

## Fallbacks

- `publish.sh <name> ./<name>` publishes one folder directly with a logged-in `gh` (bypasses the workflow;
  same result). Useful if Actions is broken.
- No git credentials at all (e.g. Claude's sandbox): create/edit files through GitHub's web editor in the
  `labs` repo (`https://github.com/a2br/labs/new/main?filename=<name>/index.html`); the push triggers the workflow.

## Do not

- Touch other DNS records at OVH.
- Remove the verified domain or the `_github-pages-challenge-a2br` TXT record.
- Commit secrets, or reuse a live name unless replacing that project on purpose.

## Existing projects

- `tautologist` — propositional-logic rewriter for CS-550 (2026-09-18).
- `pomodoro` — Ripen, work / rest timer with a day timeline and a pixel tomato (2026-09-20).
