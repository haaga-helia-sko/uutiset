#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# deploy-ghpages.sh
# Julkaisee hakemiston $HOME/sites/uutiset sisallon gh-pages-haaraan
# repoon haaga-helia-sko/uutiset -> https://haaga-helia-sko.github.io/uutiset/
# Ajettavissa niin usein kuin haluaa, myos cronista.
# ---------------------------------------------------------------------------
set -euo pipefail

GH_ORG="haaga-helia-sko"
GH_REPO="uutiset"
GH_USER="jusju"
BRANCH="gh-pages"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_ALIAS="gh-uutiset"
# 1 = Markdown-lahteet, GitHub kaantaa ne Jekyllilla (index.md -> index.html)
# 0 = valmiit HTML-tiedostot, Jekyll ohitetaan (.nojekyll)
JEKYLL=1
CUSTOM_DOMAIN=""          # jata tyhjaksi, jos ei omaa verkkotunnusta

# --- Valitaan toimiva yhteys (portti 22, varalla 443) -----------------------
REMOTE=""
for a in "$HOST_ALIAS" "${HOST_ALIAS}-443"; do
    if git ls-remote "git@${a}:${GH_ORG}/${GH_REPO}.git" >/dev/null 2>&1; then
        REMOTE="git@${a}:${GH_ORG}/${GH_REPO}.git"
        break
    fi
done
if [ -z "$REMOTE" ]; then
    echo "VIRHE: repoon ${GH_ORG}/${GH_REPO} ei saa yhteytta. Aja ./setup-ghpages.sh" >&2
    exit 1
fi

# --- Tarkistukset -----------------------------------------------------------
if [ ! -d "$SRC_DIR" ]; then
    echo "VIRHE: lahdehakemistoa ei ole: $SRC_DIR" >&2
    exit 1
fi
if [ -z "$(ls -A "$SRC_DIR")" ]; then
    echo "VIRHE: $SRC_DIR on tyhja, ei julkaista mitaan." >&2
    exit 1
fi
if [ ! -f "$SRC_DIR/index.html" ] && [ ! -f "$SRC_DIR/index.md" ] && [ ! -f "$SRC_DIR/README.md" ]; then
    echo "VAROITUS: $SRC_DIR:ssa ei ole index.md, index.html eika README.md." >&2
    echo "          Sivuston juuri antaa 404." >&2
fi
if [ "$JEKYLL" -eq 1 ] && [ -f "$SRC_DIR/index.md" ]; then
    if ! head -n 1 "$SRC_DIR/index.md" | grep -q '^---[[:space:]]*$'; then
        echo "VAROITUS: index.md ei ala '---'-rivilla (YAML front matter)." >&2
        echo "          Jekyll ei kaanna tiedostoa, vaan se nakyy raakana." >&2
    fi
fi

# --- Tyohakemisto -----------------------------------------------------------
WORK="$(mktemp -d "${TMPDIR:-/tmp}/ghpages.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

if git ls-remote --exit-code --heads "$REMOTE" "$BRANCH" >/dev/null 2>&1; then
    echo "Haetaan olemassa oleva haara $BRANCH..."
    git clone --quiet --depth 1 --branch "$BRANCH" "$REMOTE" "$WORK"
else
    echo "Haaraa $BRANCH ei ole, luodaan uusi..."
    git init --quiet "$WORK"
    git -C "$WORK" checkout --quiet -b "$BRANCH"
    git -C "$WORK" remote add origin "$REMOTE"
fi

git -C "$WORK" config user.name  "$GH_USER"
git -C "$WORK" config user.email "${GH_USER}@users.noreply.github.com"

# --- Sisallon korvaus -------------------------------------------------------
find "$WORK" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
find "$SRC_DIR" -mindepth 1 -maxdepth 1 ! -name '.git' -exec cp -a {} "$WORK"/ \;

if [ "$JEKYLL" -eq 0 ]; then
    # Ohitetaan Jekyll: HTML menee lapi sellaisenaan, _-alkuiset kansiot toimivat
    touch "$WORK/.nojekyll"
fi

if [ -n "$CUSTOM_DOMAIN" ]; then
    printf '%s\n' "$CUSTOM_DOMAIN" > "$WORK/CNAME"
fi

git -C "$WORK" add -A

if git -C "$WORK" diff --cached --quiet; then
    echo "Ei muutoksia, ei julkaista mitaan."
    exit 0
fi

git -C "$WORK" commit --quiet -m "Deploy from kapsi $(date '+%Y-%m-%d %H:%M:%S')"
git -C "$WORK" push --quiet origin "HEAD:refs/heads/${BRANCH}"

echo "Julkaistu."
if [ -n "$CUSTOM_DOMAIN" ]; then
    echo "Osoite: https://${CUSTOM_DOMAIN}/"
else
    echo "Osoite: https://${GH_ORG}.github.io/${GH_REPO}/"
fi

