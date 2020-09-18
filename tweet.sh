#!/bin/sh

TOKEN=$(curl -s -b cookies_twitter.txt -c cookies_twitter.txt 'https://mobile.twitter.com/compose/tweet' \
  -H 'referer: https://mobile.twitter.com/' \
  --compressed | grep authenticity_token | sed '/value="/!d;s//&\n/;s/.*\n//;:a;/"/bb;$!{n;ba};:b;s//\n&/;P;D' | tail -1)

TWEET="$1 $2 $3 $4 $5"

echo "TWEET:" "$TWEET"

curl -s -b cookies_twitter.txt -c cookies_twitter.txt 'https://mobile.twitter.com/compose/tweet' \
  -H 'referer: https://mobile.twitter.com/compose/tweet' \
  --data-raw "authenticity_token=$TOKEN&tweet%5Btext%5D=$TWEET+&wfa=1&commit=Tweet" \
  --compressed > /dev/null
