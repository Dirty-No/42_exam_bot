#!/bin/sh

VAL="3"

printf "ARGS: $1 , $2 , $3 , $4 \n" >> tweet.log

if [ "$1" = "-r" ];
	then
			NAME="$2"
			TWEET_ID="$3"
			TWEET="$4"
			TOKEN=$(curl -s -b cookies_twitter.txt -c cookies_twitter.txt "https://mobile.twitter.com/$NAME/reply/$TWEET_ID?p=r" \
				-H "referer: https://mobile.twitter.com/$NAME/status/$TWEET_ID?p=v" \
				--compressed | grep authenticity_token | sed '/value="/!d;s//&\n/;s/.*\n//;:a;/"/bb;$!{n;ba};:b;s//\n&/;P;D' | tail -1)
			sleep 2
			while [ "$VAL" -gt '0' ] ;do
			TWEET_PAGE=$(curl -s -L -b cookies_twitter.txt -c cookies_twitter.txt 'https://mobile.twitter.com/compose/tweet' \
				-H "referer: https://mobile.twitter.com/$NAME/reply/$TWEET_ID?p=r" \
				--data-raw "authenticity_token=$TOKEN&tweet%5Bin_reply_to_status_id%5D=$TWEET_ID&tweet%5Btext%5D=$TWEET&wfa=1&commit=Reply" \
				--compressed)
				if [ -z "$(echo "$TWEET_PAGE" | grep 403)" ];
					then VAL="0"
					else
						printf "403 ON $TWEET \n $TWEET_PAGE \n TOKEN : $TOKEN \n END \n" >> tweet.log
						sleep 5
						VAL=$(expr $VAL - 1)
				fi
			done
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

convert_utf8()
{
	echo "$1"	\
	|	sed 's/\;/_MY_SEMICOLON_LABEL_/g'				|	sed 's/#/_MY_HASHTAG_LABEL_/g' | sed 's/\&//g'	      \
	|	sed 's/%/\&#25\;/g'		|	sed 's/!/\&#21\;/g'	|	sed "s/'/\&#39;/g"                       \
	|	sed 's/"/\&#22\;/g'		|	sed 's/\$/\&#24\;/g'	\
	|	sed 's/+/\&#2B\;/g'		|	sed 's/,/\&#2C\;/g'	| 	sed 's/\//\&#2F\;/g'       \
	|	sed 's/_MY_SEMICOLON_LABEL_/\&#3B\;/g'			|	sed 's/</\&#3C\;/g'		| 	sed 's/=/\&#3D\;/g'		\
	|	sed 's/>/\&#3E\;/g'		|	sed 's/?/\&#3F\;/g'	|	sed 's/@/\&#40\;/g'		| 	sed 's/\[/\&#5B\;/g'	      \
	|	sed 's/]/\&#5D\;/g'		|	sed 's/\^/\&#5E\;/g'	|	sed 's/`/\&#60\;/g' | sed 's/ *$//g'	      \
	| 	sed 's/_MY_HASHTAG_LABEL_/#/g'
}


TWEET=$(convert_utf8 "$TWEET")
TWEET_ID=$(echo "$TWEET_PAGE" | grep -B1 "$TWEET")
echo TWEET : "$TWEET" FOUND: "$TWEET_ID" >> tweet.log
TWEET_ID=$(echo "$TWEET_ID" | sed "s/$TWEET//g" | grep -E -o [0-9] | tr -d '\n')
if [ -z "$TWEET_ID" ];
then 
	echo "$TWEET_PAGE" >> tweet.log
	echo "FAIL : $TWEET_ID END"
	echo "FAIL $TWEET" >> tweet.log
	echo "PAGE: $TWEET_PAGE" >> tweet.log
else 
	echo "$TWEET_ID"
fi

sleep 5
