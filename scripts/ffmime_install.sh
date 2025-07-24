
#!/bin/bash

set -e

# Define paths and MIME type
MIME_DIR="$HOME/.local/share/mime"
APP_DIR="$HOME/.local/share/applications"
MIME_TYPE="application/x-ff-bz2"
MIME_XML="$MIME_DIR/application/x-ff-bz2.xml"
DESKTOP_FILE="$APP_DIR/nsxiv-ffbz2.desktop"

echo "[+] Creating MIME type XML at $MIME_XML"
mkdir -p "$(dirname "$MIME_XML")"
cat > "$MIME_XML" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="$MIME_TYPE">
    <comment>Compressed FF image</comment>
    <glob pattern="*.ff.bz2"/>
  </mime-type>
</mime-info>
EOF

echo "[+] Ensuring MIME packages directory exists"
mkdir -p "$MIME_DIR/packages"

echo "[+] Updating MIME database"
update-mime-database "$MIME_DIR"

echo "[+] Creating desktop entry for nsxiv"
mkdir -p "$APP_DIR"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=NSxiv for FF.BZ2 Images
Exec=bash -c 'TMPDIR=\$(mktemp -d) && bzip2 -dc "%f" > "\$TMPDIR/image.ff" && nsxiv "\$TMPDIR/image.ff"'
Type=Application
MimeType=$MIME_TYPE;
NoDisplay=false
Terminal=false
Categories=Graphics;
EOF

echo "[+] Updating desktop database"
update-desktop-database "$APP_DIR"

echo "[+] Setting nsxiv as default for $MIME_TYPE"
xdg-mime default "$(basename "$DESKTOP_FILE")" "$MIME_TYPE"

echo "[✓] Done! .ff.bz2 files should now open in nsxiv."

