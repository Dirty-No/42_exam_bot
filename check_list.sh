#!/bin/sh

if [ $# -ne 2 ];
then
    echo "Invalid arguments"
    echo "Usage : ./check_list.sh login_list.txt 'C Piscine Exam XX'"
    exit
fi

cat "$1" | xargs -L1 -I{} ./get_grade.sh {} "$2" &
wait