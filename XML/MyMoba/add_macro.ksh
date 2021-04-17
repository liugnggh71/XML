#!/bin/sh

function empty_lines
{
  a=1
  while [[ $a -le $1 ]]
  do
    echo ''
    a=$((a + 1))
  done
}

empty_lines 50

ls -l | grep ^d

echo "Please enter existing directory or a new home(No default):"

read macro_dir

empty_lines 50

if [ ! -d "${macro_dir}" ]; then
    mkdir ${macro_dir}
fi

mkdir ${macro_dir}/${macro_dir}
cp template/template.xml ${macro_dir}/${macro_dir}.xml
cp template/__WORK_DIR.xml ${macro_dir}
cp template/__WORK_DIR.ksh ${macro_dir}
cp template/code_list.xml ${macro_dir}
cp template/template.xpr ${macro_dir}/${macro_dir}.xpr
cp template/__Help.txt ${macro_dir}
cp template/__Contact.txt ${macro_dir}
cp template/Steps.xml ${macro_dir}

sed -i -e "s/template/${macro_dir}/g" ${macro_dir}/__WORK_DIR.ksh
sed -i -e "s/template/${macro_dir}/g" ${macro_dir}/${macro_dir}.xml
sed -i -e "s/template/${macro_dir}/g" ${macro_dir}/${macro_dir}.xpr
sed -i -e "s/template/${macro_dir}/g" ${macro_dir}/code_list.xml
sed -i -e "s/template/${macro_dir}/g" ${macro_dir}/Steps.xml

ls -l ${macro_dir}
