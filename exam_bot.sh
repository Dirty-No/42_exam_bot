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

START_TIME="18"
END_TIME="22"
SLEEP_TIME="10"

while [ $(date +"%H") -lt $START_TIME ]; do
    printf "waiting for exam's start... $(date +"(%H:%M:%S)")\r"
done

./tweet.sh "$EXAM HAS STARTED !\
MONITORED PARTICIPANTS :\
$LIST" | tee exam.log

GRADES_OLD=$(get_grades "$1" "$2")

while [ $(date +"%H") -lt $END_TIME ]; do

    GRADES_NEW=$(get_grades "$1" "$2")

    GRADES_DIFF=$(diff <(echo "$GRADES_OLD") <(echo "$GRADES_NEW") | grep '>' | tr '>' '|')
    if [ "$GRADES_DIFF" ];
        then echo "$GRADES_DIFF" | xargs -L1 ./tweet.sh $(date +"(%H:%M:%S)") | tee --append exam.log
    fi
    GRADES_OLD=$(echo "$GRADES_NEW")
    echo $(date +"(%H:%M:%S)") sleeping...
    sleep $SLEEP_TIME
done


SUCCESS=$(echo "$(echo "$GRADE_NEW" | grep success)" | sort | tee RESULTS.txt)
FAIL=$(echo "$(echo "$GRADE_OLD" | grep fail)" | sort | tee --append RESULTS.txt)
./tweet.sh "$EXAM HAS ENDED !\
RESULTS:\
SUCCESSES:\
$SUCCESS\
\
FAILS:\
$FAIL" | tee --append exam.log