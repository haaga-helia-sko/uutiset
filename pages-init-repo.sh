#!/usr/bin/env bash
set -euo pipefail

ORG="haaga-helia-sko"
REPO="uutiset"

KEY="$HOME/.ssh/github-pages/${ORG}_${REPO}"
REMOTE="git@github.com:${ORG}/${REPO}.git"

if [ ! -f "$KEY" ]; then
    echo "Virhe: deploy key puuttuu:"
    echo "$KEY"
    echo
    echo "Aja ensin:"
    echo "~/bin/pages-setup.sh"
    exit 1
fi

export GIT_SSH_COMMAND="ssh \
    -i '$KEY' \
    -o IdentitiesOnly=yes \
    -o StrictHostKeyChecking=accept-new"

echo "Testataan GitHub-yhteyttä repositoryyn:"
echo "${ORG}/${REPO}"
echo

if ! git ls-remote "$REMOTE" >/dev/null; then
    echo
    echo "GitHub-yhteys epäonnistui."
    echo
    echo "Tarkista GitHubista:"
    echo "Settings -> Deploy keys"
    echo
    echo "ja että avaimella on:"
    echo "Allow write access"
    exit 1
fi

echo "GitHub-yhteys toimii."

if git ls-remote \
    --exit-code \
    --heads \
    "$REMOTE" \
    gh-pages >/dev/null 2>&1
then
    echo
    echo "gh-pages-haara on jo olemassa."
    exit 0
fi

TMP="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP"
}
trap cleanup EXIT

cd "$TMP"

git init
git checkout --orphan gh-pages

cat > index.html <<'EOF'
<!doctype html>
<html lang="fi">
<head>
    <meta charset="utf-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <title>Haaga-Helia SKO uutiset</title>
</head>

<body>

<h1>Haaga-Helia SKO uutiset</h1>

<p>
GitHub Pages deployment Kapsi.fi-palvelimelta toimii.
</p>

</body>
</html>
EOF

# Älä anna GitHubin käsitellä sivua Jekyll-projektina.
touch .nojekyll

git add .

git \
    -c user.name="Kapsi Pages deployer" \
    -c user.email="pages@haaga-helia-sko.invalid" \
    commit -m "Initialize GitHub Pages"

git remote add origin "$REMOTE"

git push \
    -u \
    origin \
    gh-pages

echo
echo "=============================================="
echo "gh-pages-haara luotu."
echo "=============================================="
echo
echo "Mene nyt GitHubiin:"
echo
echo "https://github.com/${ORG}/${REPO}/settings/pages"
echo
echo "Valitse:"
echo
echo "Source:"
echo "  Deploy from a branch"
echo
echo "Branch:"
echo "  gh-pages"
echo
echo "Folder:"
echo "  /(root)"
echo
echo "Sivun osoite tulee olemaan:"
echo
echo "https://${ORG}.github.io/${REPO}/"

