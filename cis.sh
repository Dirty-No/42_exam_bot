#!/bin/bash


LAST_TWEET="$(./tweet.sh "Alphabet DU LOL XD")"
for x in {a..z}
do
echo "$LAST_TWEET"

    LAST_TWEET=$(./tweet.sh -r anonoelle "$LAST_TWEET" "XD $x")
done