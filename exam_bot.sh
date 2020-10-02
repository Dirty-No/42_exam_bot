#!/bin/bash

if [ $# -ne 2 ];
then
    echo "Invalid arguments"
    echo "Usage : ./exam_bot.sh login_list.txt 'C Piscine Exam XX'"
    exit
fi

LIST=$(cat "$1")
EXAM="$2"

get_grades()
{
    echo "$(./check_list.sh "$1" "$2")" | sort
}

START_TIME="10"
END_TIME="18"
SLEEP_TIME="0"

while [ $(date +"%H") -lt $START_TIME ]; do
    printf "waiting for exam's start... $(date +"(%H:%M:%S)")\r"
done

#LAST_TWEET=$(./tweet.sh "$(printf "FINALL $EXAM HAS BEGUN !\nMONITORED PARTICIPANTS :\n$LIST\n" | tee exam.log | tee /dev/tty | head -c 279 | tr '\n' '#' | sed 's/#/%0D/g')")

echo "$LAST_TWEET"
GRADES_OLD=$(get_grades "$1" "$2")

while [ $(date +"%H") -lt $END_TIME ]; do

    GRADES_NEW=$(get_grades "$1" "$2")

    GRADES_DIFF=$(diff <(echo "$GRADES_OLD") <(echo "$GRADES_NEW") | grep '>' | tr '>' '|' )
    if [ "$GRADES_DIFF" ];
       then
        while IFS= read -r line; do
    ./tweet.sh "$(printf "%10s%10s" "$(date +"(%H:%M:%S)")" "$line")"
done <<< "$GRADES_DIFF"
    fi
    GRADES_OLD=$(echo "$GRADES_NEW")
    echo $(date +"(%H:%M:%S)") sleeping...
    sleep $SLEEP_TIME
done

GRADES_NEW=$(get_grades "$1" "$2")
SUCCESS=$(echo "$GRADES_NEW" | grep success)
SUCCESS=$(echo "$SUCCESS" | sort | tee RESULTS.txt)
FAIL=$(echo "$GRADES_NEW" | grep fail)
FAIL=$(echo "$FAIL" | sort | tee --append RESULTS.txt)
FINAL=$(printf "RESULTS:\n\nSUCCESSES:\n%s\nFAILS:\n%s" "$SUCCESS" "$FAIL" | sed '/^$/d' | tee --append exam.log)

DATE="$(date +"(%H:%M:%S)" | tr -d '\n')"
LAST_TWEET=$(./tweet.sh "$DATE $2 HAS ENDED")
echo FINAL "$FINAL" END

echo "$FINAL" | while read line ; do
    echo LINE: $line
    TMP_LINE=$(echo "$line" | tr -d '\n' | tr -d '\r' | tr '\t' ' ')
    DATE=$(date +"(%H:%M:%S)" | tr -d '\n')
    MY_LINE=$(echo "$DATE $TMP_LINE")
    echo MY LINE "$MY_LINE"
    echo LAST TWEET "$LAST_TWEET" END
    LAST_TWEET=$(./tweet.sh -r 'anonoelle' "$LAST_TWEET" "$MY_LINE")
    echo NEW TWEET "$LAST_TWEET" END
    sleep 2
done