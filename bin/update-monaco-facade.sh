#!/bin/bash

# Bash strict mode
set -euo pipefail
ORIG_IFS="$IFS"
IFS=$'\n\t'

set -x

ROOT_DIR="$(git rev-parse --show-toplevel)"
TS_IMPORTER_DIR="$ROOT_DIR/project/ts-importer"
# Directory where the build installs the NPM modules of metabrowse-js
NODE_MODULES_DIR="$(cd "$ROOT_DIR" && ./mill --ticker false show jsBundle.nodeModules | sed -E 's/^"[^/]*(\/.*)"$/\1/')/node_modules"
NPM_MONACO_D_TS="$NODE_MODULES_DIR/monaco-editor/monaco.d.ts"
MONACO_D_TS="$TS_IMPORTER_DIR/monaco.d.ts"
MONACO_SCALA="$ROOT_DIR/metabrowse-js/src/main/scala/monaco/Monaco.scala"

if [[ ! -d "$TS_IMPORTER_DIR" ]]; then
  git clone https://github.com/sjrd/scala-js-ts-importer.git "$TS_IMPORTER_DIR"
fi

# Curated list of edits required for scala-js-ts-importer to parse monaco.d.ts
sed \
   -e 's/): [^ ]* is [^; ]*;/): boolean;/' \
   -e 's/: void | /: /' \
   -e '/^declare namespace monaco.languages.\(typescript\|html\|css\|json\) {$/,/^}$/d' \
   -e 's/ const enum / enum /' \
   < "$NPM_MONACO_D_TS" \
   > "$MONACO_D_TS"

(cd "$TS_IMPORTER_DIR" && sbt -batch "run $MONACO_D_TS $MONACO_SCALA")
