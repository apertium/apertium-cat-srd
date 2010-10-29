#!/bin/bash

if [[ $# -lt 1 ]]; then
	echo "Not enough arguments to generation-test.sh";
	echo "bash generation-test.sh <corpus>";
	exit;
fi

if [[ $1 == "-r" ]]; then
	if [[ $# -lt 2 ]]; then 
		echo $#;
		echo "Not enough arguments to generation-test.sh -r";
		echo "bash generation-test.sh -r <corpus>";
		exit;
	fi
	args=("$@")
	echo "Corpus in: "`dirname $2`;
	echo -n "Processing corpus for generation test... ";
	rm -f /tmp/sc-ca.corpus.txt
	for i in `seq 1 $#`; do 
		if [[ ${args[$i]} != "" && -f ${args[$i]} ]]; then 
			cat ${args[$i]} >> /tmp/sc-ca.corpus.txt
		fi
	done
	echo "done.";
	echo -n "Translating corpus for generation test (this could take some time)... ";
	cat /tmp/sc-ca.corpus.txt | apertium -d ../ sc-ca-transfer | sed 's/\$\W*\^/$\n^/g' > /tmp/sc-ca.gentest.transfer
	echo "done.";
fi

if [[ ! -f /tmp/sc-ca.gentest.transfer ]]; then
	echo "Something went wrong in processing the corpus, you have no output file.";
	echo "Try running:"
	echo "   sh generation-test.sh -r <corpus>";
	exit;
fi

cat /tmp/sc-ca.gentest.transfer  | sed 's/^ //g' | grep -v -e '@' -e '*' -e '[0-9]<num>' -e '#}' -e '#{' | sed 's/\$>/$/g' | sed 's/^\W*\^/^/g' | sort -f | uniq -c | sort -gr > /tmp/sc-ca.gentest.stripped
cat /tmp/sc-ca.gentest.stripped | grep -v '\^\W<' | lt-proc -d ../sc-ca.autogen.bin > /tmp/sc-ca.gentest.surface
cat /tmp/sc-ca.gentest.stripped | grep -v '\^\W<'  | sed 's/^ *[0-9]* \^/^/g' > /tmp/sc-ca.gentest.nofreq
paste /tmp/sc-ca.gentest.surface /tmp/sc-ca.gentest.nofreq  > /tmp/sc-ca.generation.errors.txt
cat /tmp/sc-ca.generation.errors.txt  | grep -v '#' | grep '\/' > /tmp/sc-ca.multiform
cat /tmp/sc-ca.generation.errors.txt  | grep '[0-9] #.*\/' > /tmp/sc-ca.multibidix 
cat /tmp/sc-ca.generation.errors.txt  | grep '[0-9] #' | grep -v '\/' > /tmp/sc-ca.tagmismatch 

echo "";
echo "===============================================================================";
echo "Multiple surface forms for a single lexical form";
echo "===============================================================================";
cat /tmp/sc-ca.multiform

echo "";
echo "===============================================================================";
echo "Multiple bidix entries for a single source language lexical form";
echo "===============================================================================";
cat /tmp/sc-ca.multibidix

echo "";
echo "===============================================================================";
echo "Tag mismatch between transfer and generation";
echo "===============================================================================";
cat /tmp/sc-ca.tagmismatch

echo "";
echo "===============================================================================";
echo "Summary";
echo "===============================================================================";
wc -l /tmp/sc-ca.multiform /tmp/sc-ca.multibidix /tmp/sc-ca.tagmismatch
