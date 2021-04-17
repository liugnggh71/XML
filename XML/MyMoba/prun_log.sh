#!/bin/sh
# Display and run custom code with logging in $CODE_code_PATH directory
. ${CODE_code_PATH}/PATH.sh

v_run_code=${1}

function empty_lines
{
a=1
while [[ $a -le $1 ]]
do
echo ''
a=$((a + 1))
done
}

function code_review
{
echo '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^$$$$$^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
pg ${CODE_code_PATH}/${v_run_code}.sh
echo '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
echo '$$$$$$$$ Code review finished Press [Enter] key to start script running...'
echo '$$$$$$$$ Or type Ctrl-C to exit'
read ppppp
}

empty_lines 50
review_code=YeS
echo 'Review code, type n if want to skip, type return if want to continue'
read input
review_code=${input:-$review_code}
case "$review_code" in
  YeS ) code_review ;;
  n|N ) echo "Skipping code review";;
  * ) echo "invalid" && exit ;;
esac
empty_lines 25

dstring=`date +%Y%m%d%H%M%S`
${CODE_code_PATH}/${v_run_code}.sh | tee ${OPATCH_log_PATH}/${v_run_code}_${dstring}.log
