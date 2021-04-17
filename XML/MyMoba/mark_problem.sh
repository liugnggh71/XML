foo=$(printf "%02d" $1)
xd=`date +"%Y-%m-%dT%H:%M:%S"`
cat << EOX > problem_${foo}.xml
<problem_finish_mark>
  <problem_no>$foo</problem_no>
  <finish_time>$xd</finish_time>
  <answer>$2</answer>
</problem_finish_mark>
EOX
