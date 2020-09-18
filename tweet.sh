#!/bin/sh


if [ "$1" = "-r" ];
then

  NAME="$2"
  TWEET_ID="$3"
  TWEET="$4"
  TOKEN=$(curl -s -b cookies_twitter.txt -c cookies_twitter.txt "https://mobile.twitter.com/$NAME/reply/$TWEET_ID?p=r" \
    -H "referer: https://mobile.twitter.com/$NAME/status/$TWEET_ID?p=v" \
    --compressed | grep authenticity_token | sed '/value="/!d;s//&\n/;s/.*\n//;:a;/"/bb;$!{n;ba};:b;s//\n&/;P;D' | tail -1)
  
  TWEET_PAGE=$(curl -s -L -b cookies_twitter.txt -c cookies_twitter.txt 'https://mobile.twitter.com/compose/tweet' \
    -H "referer: https://mobile.twitter.com/$NAME/reply/$TWEET_ID?p=r" \
    --data-raw "authenticity_token=$TOKEN&tweet%5Bin_reply_to_status_id%5D=$TWEET_ID&tweet%5Btext%5D=$TWEET&wfa=1&commit=Reply" \
    --compressed)
  
else
  TOKEN=$(curl -s -b cookies_twitter.txt -c cookies_twitter.txt 'https://mobile.twitter.com/compose/tweet' \
    -H 'referer: https://mobile.twitter.com/' \
    --compressed | grep authenticity_token | sed '/value="/!d;s//&\n/;s/.*\n//;:a;/"/bb;$!{n;ba};:b;s//\n&/;P;D' | tail -1)

  TWEET="$1"

  TWEET_PAGE=$(curl -s -L -b cookies_twitter.txt -c cookies_twitter.txt 'https://mobile.twitter.com/compose/tweet' \
    -H 'referer: https://mobile.twitter.com/compose/tweet' \
    --data-raw "authenticity_token=$TOKEN&tweet%5Btext%5D=$TWEET+&wfa=1&commit=Tweet" \
    --compressed)
fi

TWEET_ID=$(echo "$TWEET_PAGE" | grep -B1 "$TWEET" | grep -E -o [0-9] | tr -d '\n')
if [ -z "$TWEET_ID" ];
then echo "$TWEET_PAGE"
else echo "$TWEET_ID"
fi

