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

START_TIME="0"
END_TIME="0"
SLEEP_TIME="0"

while [ $(date +"%H") -lt $START_TIME ]; do
    printf "waiting for exam's start... $(date +"(%H:%M:%S)")\r"
done

LAST_TWEET=$(./tweet.sh "$(printf "$EXAM HAS BEGUN !\nMONITORED PARTICIPANTS :\n$LIST\n" | tee exam.log | tee /dev/tty | head -c 279 | tr '\n' '#' | sed 's/#/%0D/g')")

echo "$LAST_TWEET"
GRADES_OLD=$(get_grades "$1" "$2")

while [ $(date +"%H") -lt $END_TIME ]; do

    GRADES_NEW=$(get_grades "$1" "$2")

    GRADES_DIFF=$(diff <(echo "$GRADES_OLD") <(echo "$GRADES_NEW") | grep '>' | tr '>' '|')
    if [ "$GRADES_DIFF" ];
        then echo "$GRADES_DIFF" | xargs -L1 ./tweet.sh $(date +"(%H:%M:%S)" | tee /dev/tty | tee --append exam.log)
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
FINAL=$(printf "RESULTS:\n\nSUCCESSES:\n%s\nFAILS:\n%s" "$SUCCESS" "$FAIL" | tee --append exam.log)

echo "$FINAL" | while read line ; do
    echo $line
    LAST_TWEET=$(./tweet.sh -r 'anonoelle' "$LAST_TWEET" "$line")
done
