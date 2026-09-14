#!/usr/bin/env bash
set -euo pipefail

ORG="haaga-helia-sko"
REPO="uutiset"
GITHUB_USER="jusju"

KEYDIR="$HOME/.ssh/github-pages"
KEY="$KEYDIR/${ORG}_${REPO}"

mkdir -p "$KEYDIR"
chmod 700 "$HOME/.ssh"
chmod 700 "$KEYDIR"

if [ ! -f "$KEY" ]; then
    echo "Luodaan deploy key repositorylle ${ORG}/${REPO}..."

    ssh-keygen \
        -t ed25519 \
        -N "" \
        -C "kapsi-${ORG}-${REPO}" \
        -f "$KEY"
else
    echo "Deploy key on jo olemassa:"
    echo "$KEY"
fi

chmod 600 "$KEY"
chmod 644 "$KEY.pub"

echo
echo "======================================================"
echo "PUBLIC DEPLOY KEY"
echo "======================================================"
cat "$KEY.pub"
echo
echo "======================================================"
echo
echo "Lisää tämä GitHubissa repositoryyn:"
echo
echo "https://github.com/${ORG}/${REPO}"
echo
echo
echo "Settings"
echo "  -> Deploy keys"
echo "  -> Add deploy key"
echo
echo "Title:"
echo "  Kapsi.fi GitHub Pages deploy"
echo
echo "Key:"
echo "  yllä tulostettu avain"
echo
echo "Valitse:"
echo "  [x] Allow write access"
echo
echo "GitHub user jolla tämä tehdään:"
echo "  ${GITHUB_USER}"
echo
echo "Kun avain on lisätty, aja:"
echo
echo "  ~/bin/pages-init-repo.sh"


