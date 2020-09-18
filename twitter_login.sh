#!/bin/sh

echo "" > cookies_twitter.txt

# GET NO-JAVASCRIPT SESSION
curl -s -c cookies_twitter.txt 'https://mobile.twitter.com/i/nojs_router?path=%2Fsession%2Fnew' \
  -X 'POST' \
  -H 'origin: https://mobile.twitter.com' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36' \
--compressed > /dev/null

# GET LOGIN PAGE FOR CSRF TOKEN

LOGIN_PAGE=$(curl -s -b cookies_twitter.txt -c cookies_twitter.txt 'https://mobile.twitter.com/session/new' \
  --compressed)

TOKEN=$(echo "$LOGIN_PAGE" | grep authenticity_token | sed '/value="/!d;s//&\n/;s/.*\n//;:a;/"/bb;$!{n;ba};:b;s//\n&/;P;D')

LOGIN="$1"
PASSWORD="$2"

curl -s -b cookies_twitter.txt -c cookies_twitter.txt 'https://mobile.twitter.com/sessions' \
  --data-raw "authenticity_token=$TOKEN&session%5Busername_or_email%5D=$LOGIN&session%5Bpassword%5D=$PASSWORD&remember_me=1&wfa=1&commit=Se+connecter&ui_metrics=" \
  --compressed > /dev/null
