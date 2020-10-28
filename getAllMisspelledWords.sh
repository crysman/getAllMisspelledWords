#!/bin/bash

#hnusně zbastlený rychloskript na nalezení nečeských (resp. neslovníkových dle `aspell`) slov na faktaoklimatu.cz
#crysman (copyleft) 2020-10
#
#version 0.1
#
#requirements:
#  - rw to /tmp
#  - wget, aspell, aspell-cs, lynx
#  -

DOMAIN="faktaoklimatu.cz"
TMPDIR="/tmp/${DOMAIN}_spellcheck"

mkdir -p "$TMPDIR" && cd "$TMPDIR" &&

#get all text pages into faktaoklimatu.cz folder:
for URL in `wget --spider --force-html -r -l10 --reject '*.js,*.css,*.ico,*.txt,*.gif,*.jpg,*.jpeg,*.png,*.mp3,*.pdf,*.tgz,*.flv,*.avi,*.mpeg,*.iso,*.zip,*.svg,*.mp4,*.mov' --ignore-tags=img,link,script --header="Accept: text/html" -D "$DOMAIN" "$DOMAIN" 2>&1 | grep ^Removing | sed 's~\.tmp.*~~' | awk '{print $2}'`; do lynx -dump -nolist "https://$URL" > "./$URL"; done &&

#get all czech-only misspelled words
for f in `find faktaoklimatu.cz -type f`; do cat "$f" | aspell -l cs list; done | sort | uniq | aspell -l en list | tee misspelled.txt &&

cd - >/dev/null &&
echo "---" &&
echo "OK, all done." &&
echo "(copy of misspelled words is in $TMPDIR/misspelled.txt)"
