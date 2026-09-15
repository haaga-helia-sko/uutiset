#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# setup-ghpages.sh
# Kertaluonteinen asennus kapsi.fi:lle: luo SSH-avaimen, kirjoittaa
# ssh-config-merkinnat ja testaa luku- seka kirjoitusoikeuden.
# Repo: https://github.com/haaga-helia-sko/uutiset
# ---------------------------------------------------------------------------
set -uo pipefail

GH_ORG="haaga-helia-sko"
GH_REPO="uutiset"
GH_USER="jusju"
KEY_PATH="$HOME/.ssh/id_ed25519_ghpages_uutiset"
HOST_ALIAS="gh-uutiset"
SRC_DIR="$HOME/sites/uutiset"

# --- 1. Avain ---------------------------------------------------------------
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ -f "$KEY_PATH" ]; then
    echo "Avain on jo olemassa: $KEY_PATH"
else
    echo "Luodaan uusi ed25519-avain ilman salasanaa (skripti- ja cron-ajoa varten)..."
    ssh-keygen -t ed25519 -N "" -C "kapsi-${GH_USER}-${GH_ORG}-${GH_REPO}" -f "$KEY_PATH" || exit 1
fi
chmod 600 "$KEY_PATH"
chmod 644 "${KEY_PATH}.pub"

# --- 2. ssh-config ----------------------------------------------------------
CONFIG="$HOME/.ssh/config"
touch "$CONFIG"
chmod 600 "$CONFIG"

add_host_block() {
    alias_name="$1"; host_name="$2"; port="$3"
    if grep -qE "^[[:space:]]*Host[[:space:]]+${alias_name}([[:space:]]|$)" "$CONFIG"; then
        echo "ssh-config sisaltaa jo hostin '${alias_name}', ei muuteta."
        return
    fi
    cat >> "$CONFIG" <<EOF

Host ${alias_name}
    HostName ${host_name}
    Port ${port}
    User git
    IdentityFile ${KEY_PATH}
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
EOF
    echo "Lisattiin ssh-config-merkinta: ${alias_name} -> ${host_name}:${port}"
}

add_host_block "$HOST_ALIAS" "github.com" 22
add_host_block "${HOST_ALIAS}-443" "ssh.github.com" 443

mkdir -p "$SRC_DIR"

# --- 3. Onko avain jo lisatty GitHubiin? ------------------------------------
echo
echo "== Testataan yhteytta =="
WORKING_ALIAS=""
for a in "$HOST_ALIAS" "${HOST_ALIAS}-443"; do
    OUT="$(ssh -o BatchMode=yes -o ConnectTimeout=10 -T "$a" 2>&1)"
    if printf '%s' "$OUT" | grep -q "successfully authenticated"; then
        WORKING_ALIAS="$a"
        echo "Autentikointi onnistui aliaksella '$a'."
        break
    fi
    echo "Alias '$a': ei viela toimi."
done

if [ -z "$WORKING_ALIAS" ]; then
    cat <<EOF

==========================================================================
SEURAAVA VAIHE (selaimessa, kerran):

1. Kopioi alla oleva julkinen avain (yksi rivi, kokonaisuudessaan).
2. Mene: https://github.com/${GH_ORG}/${GH_REPO}/settings/keys
3. "Add deploy key"
     Title: kapsi-${GH_USER}
     Key:   (liita alla oleva rivi)
     [x] Allow write access      <-- PAKOLLINEN, muuten push ei onnistu
4. Save, ja aja tama skripti uudelleen.

--- julkinen avain ---
$(cat "${KEY_PATH}.pub")
----------------------

Jos GitHub sanoo "Key is already in use": sama avain on jo lisatty
tilillesi ${GH_USER}. Poista se sielta (Settings -> SSH keys) tai poista
tiedostot ${KEY_PATH}* ja aja tama skripti uudelleen.
==========================================================================
EOF
    exit 1
fi

REMOTE="git@${WORKING_ALIAS}:${GH_ORG}/${GH_REPO}.git"

# --- 4. Lukuoikeus ----------------------------------------------------------
echo
echo "== Lukuoikeus =="
if git ls-remote --heads "$REMOTE" >/dev/null 2>&1; then
    echo "OK. Haarat repossa ${GH_ORG}/${GH_REPO}:"
    git ls-remote --heads "$REMOTE" | awk '{print "   " $2}'
else
    echo "VIRHE: repoa ei voi lukea osoitteesta $REMOTE" >&2
    exit 1
fi

# --- 5. Kirjoitusoikeus -----------------------------------------------------
echo
echo "== Kirjoitusoikeus (push --dry-run, ei muuta mitaan) =="
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git init -q "$TMP"
git -C "$TMP" remote add origin "$REMOTE"
git -C "$TMP" config user.name "$GH_USER"
git -C "$TMP" config user.email "${GH_USER}@users.noreply.github.com"
git -C "$TMP" commit -q --allow-empty -m test

PUSHOUT="$(git -C "$TMP" push --dry-run origin "HEAD:refs/heads/__write_test__" 2>&1)"
if printf '%s' "$PUSHOUT" | grep -qi "denied\|read-only\|not authorized\|protected"; then
    echo "$PUSHOUT" >&2
    cat <<EOF >&2

VIRHE: ei kirjoitusoikeutta.
Deploy keysta puuttuu "Allow write access". Poista avain osoitteessa
https://github.com/${GH_ORG}/${GH_REPO}/settings/keys ja lisaa se
uudelleen ruksi paalla.
EOF
    exit 1
fi
echo "OK, kirjoitusoikeus on kunnossa."

cat <<EOF

==========================================================================
Asennus valmis.

Laita sivuston tiedostot (index.html yms.) hakemistoon:
    $SRC_DIR

ja aja sitten:
    ./deploy-ghpages.sh

Ensimmaisen julkaisun jalkeen kay kerran laittamassa Pages paalle:
    https://github.com/${GH_ORG}/${GH_REPO}/settings/pages
    Source: Deploy from a branch -> Branch: gh-pages -> / (root) -> Save

Sivusto: https://${GH_ORG}.github.io/${GH_REPO}/
==========================================================================
EOF

