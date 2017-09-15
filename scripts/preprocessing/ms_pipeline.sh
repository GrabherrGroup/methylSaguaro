#!/bin/bash

folder="$1"
out="$2"
pattern="$3"
homedir=$(pwd)
H=$(ls -l $folder | grep "^d" | awk '{print $9}')
N=$(ls -l $folder | grep "^d" | wc -l )
stringarray=($H)
tmp="temp.out"
second="second.out"
merged="$homedir/merged.out"
regex='TCGA-[a-zA-Z0-9][a-zA-Z0-9]-[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]-'$pattern
cd $folder/${stringarray[0]}
file=$(ls *.txt)
name=$(head -1 "$file" | cut -f2)
if [[ $name =~ $regex ]]
then
    echo -e "cgId\t$name" > $merged #"../$out"
    cut -f1,2 "$file" | sed 1,2d  >> $merged #"../$out"
else
    echo -e "cgId" > $merged #"../$out"
    cut -f1 "$file" | sed 1,2d  >> $merged #"../$out"
fi
cd ..
for ((i = 1; i<=$N-1 ; i++));do
    echo $i
    cd ${stringarray[i]}
    beta=$(ls j*.txt)
    #echo $beta >> "../$out"
    label=$(head -1 "$beta" | cut -f2)
    if [[ $label =~ $regex ]]
    then	
	echo $label > "../$second"
	cut -f2 "$beta" | sed 1,2d >> "../$second"
	cmd=$(paste $merged "../$second"  > "../$tmp")
	mv "../$tmp" $merged
    fi
    cd ..
done
rm $second
cd $homedir
perl formatInput.pl -i $merged -d 450k_dictionary.csv -o $out -c m -s t
rm $merged
