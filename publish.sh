#!/usr/bin/env bash
# publish.sh — put a static side project on <name>.anatole.wiki via GitHub Pages.
#
#   ./publish.sh tautologist ./tautologist        # first time: creates repo, enables Pages, sets subdomain
#   ./publish.sh tautologist ./tautologist        # later: just commits + pushes the update
#
# One-time prerequisites (do these once, by hand):
#   1. DNS at your registrar:  *.anatole.wiki   CNAME   <github-user>.github.io
#   2. GitHub → Settings → Pages → Verified domains → add anatole.wiki (prevents subdomain takeover)
#   3. gh CLI installed and logged in:  gh auth login
set -euo pipefail

DOMAIN="anatole.wiki"
name="${1:?usage: publish.sh <name> <dir>}"
dir="${2:?usage: publish.sh <name> <dir>}"
[[ "$name" =~ ^[a-z0-9-]+$ ]] || { echo "name must be lowercase letters, digits, dashes"; exit 1; }
[[ -f "$dir/index.html" ]] || { echo "$dir has no index.html"; exit 1; }

user="$(gh api user -q .login)"
repo="$user/$name"
host="$name.$DOMAIN"

cd "$dir"
echo "$host" > CNAME
touch .nojekyll                      # serve files as-is, no Jekyll processing
[[ -d .git ]] || git init -q -b main
git add -A
git commit -qm "publish $(date +%F)" || true   # no-op if nothing changed

if gh repo view "$repo" >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$repo.git"
  git push -q -u origin main
  echo "updated $repo"
else
  gh repo create "$name" --public --source=. --remote=origin --push >/dev/null
  echo "created $repo"
  # enable Pages from main:/ and attach the subdomain
  gh api -X POST "repos/$repo/pages" -f build_type=legacy -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 || true
  gh api -X PUT  "repos/$repo/pages" -f cname="$host" >/dev/null
fi

# wait for the site, then turn on HTTPS enforcement once the certificate exists
echo -n "waiting for https://$host "
for _ in $(seq 1 60); do
  state="$(gh api "repos/$repo/pages" -q '.https_certificate.state // "none"' 2>/dev/null || echo none)"
  if [[ "$state" == "approved" ]]; then
    gh api -X PUT "repos/$repo/pages" -F https_enforced=true >/dev/null 2>&1 || true
    echo; echo "live: https://$host"; exit 0
  fi
  echo -n "."; sleep 10
done
echo; echo "pushed; certificate still provisioning (state: $state). Check https://$host in a few minutes."
