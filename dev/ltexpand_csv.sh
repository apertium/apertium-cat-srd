lt-expand $1 | sed 's/:/::/g' | sed 's/::>::/:LR:/g' | sed 's/::<::/:RL:/g'  | grep -v -e 'REGEXP' -e '<cm>' -e '<abbr>' | sed 's/:/,/g'
