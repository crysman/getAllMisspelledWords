#!/bin/bash
#adds a new word to custom dictionary (and keeps it sorted)

DICT="FoKCustomDict.cs.pws"
if test -n "$1"; then
  newWord="$1"
else
  echo "ERR: a word to add missing..."
  exit 2
fi  

if test -w "$DICT"; then
  #print all but first line
  echo "$newWord" >> "$DICT" &&
  words=`tail -n +2 "$DICT" | sort | uniq` &&
  echo "personal_ws-1.1 cs 0 utf-8" > "$DICT" &&
  echo "$words" >> "$DICT"
else
  echo "ERR: $DICT not writable..."
  exit 3
fi
