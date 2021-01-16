#!/bin/bash

#hnusně zbastlený rychloskript na nalezení nečeských (resp. neslovníkových dle `aspell`) slov na faktaoklimatu.cz
#crysman (copyleft) 2020-2021
#
#version 2021-01-17
#
#changelog:
# - 2021-01-17 přidány kontroly, barevný výstup, custom slovník
#

#tput color table
#Color       #define       Value       RGB
#black     COLOR_BLACK       0     0, 0, 0
#red       COLOR_RED         1     max,0,0
#green     COLOR_GREEN       2     0,max,0
#yellow    COLOR_YELLOW      3     max,max,0
#blue      COLOR_BLUE        4     0,0,max
#magenta   COLOR_MAGENTA     5     max,0,max
#cyan      COLOR_CYAN        6     0,max,max
#white     COLOR_WHITE       7     max,max,max

function _err() {
  echo "`tput setaf 1`ERR: $1, exitting`tput sgr0`" >&2
  exit    
}

function _info() {
  echo "`tput setaf 5`INFO: $1`tput sgr0`"
}

#check prereqs or die:
test -w /tmp >/dev/null 2>&1 || _err "unable to write to /tmp"
which wget >/dev/null 2>&1 || _err "this script requires 'wget'"
which aspell >/dev/null 2>&1 || _err "this script requires 'aspell'"
aspell dump dicts | grep ^cs >/dev/null 2>&1 || _err "this script requires 'aspell-cs' package"
which lynx >/dev/null 2>&1 || _err "this script requires 'lynx'"

#vars:  
VERSION="2021-01-17"
DOMAIN="faktaoklimatu.cz"
TMPDIR="/tmp/${DOMAIN}_spellcheck_$VERSION"
TMPOUTFILE="misspelled.txt"
CUSTOMDICT="FoKCustomDict.cs.pws"

#prepare /tmp...
mkdir -p "$TMPDIR" &&
cp -f "$CUSTOMDICT" "$TMPDIR" &&
cd "$TMPDIR" 

#get all text pages into faktaoklimatu.cz folder:
test -d "$TMPDIR/$DOMAIN" && {
  _info "most probably already downloaded, using local copy..."    
} || {
  _info "checking up the online version on $DOMAIN (might take a while)..." &&
  for URL in `wget --spider --force-html -r -l10 --reject '*.js,*.css,*.ico,*.txt,*.gif,*.jpg,*.jpeg,*.png,*.mp3,*.pdf,*.tgz,*.flv,*.avi,*.mpeg,*.iso,*.zip,*.svg,*.mp4,*.mov' --ignore-tags=img,link,script --header="Accept: text/html" -D "$DOMAIN" "$DOMAIN" 2>&1 | grep ^Removing | sed 's~\.tmp.*~~' | awk '{print $2}'`; do lynx -dump -nolist "https://$URL" > "./$URL"; done
} &&

#get all czech-only misspelled words
_info "finding and writing-out misspelled words..."
for f in `find faktaoklimatu.cz -type f`; do cat "$f" | aspell -l cs list; done | sort | uniq | aspell -l en list | aspell --master="./$CUSTOMDICT" -l cs list | tee ${TMPOUTFILE} &&

_info "printing-out where the words are located..." &&
for WORD in `cat ${TMPDIR}/${TMPOUTFILE}`; do _info "misspelled: /$WORD/:"; grep -RI "$WORD" --exclude=${TMPOUTFILE} ./; echo ""; done &&

#go back to original dir
cd - >/dev/null &&
echo "---" &&
echo "OK, all done." &&
echo "(copy of misspelled words is in $TMPDIR/$TMPOUTFILE)"
