#!/bin/bash

if [[ "$#" < "4" ]]; then
    echo "Usage: ./mergeAndFormat with the following parameters ([] specifies optional ones)."
    echo -e "\tact=\"merge|format\" : merge to merge TCGA files in a folder and format, format for already merged file"
    echo -e "\tin=\"folder|file\" : input either a folder (for merge option) or a file (for format option)"
    echo -e "\t[is=\",|t|s|;\"] : input file splitor "
    echo -e "\tout=\"output\" : output file"
    echo -e "\tdic=\"27k|450k|850k|file\ : type of the illumina array, or a file with CpG sites genomic positions"
    echo -e "\t[sub=\"0|1|2\"] : subgroup of samples; for merge option, tumors (0), normals (1), controls (2) or all (when null)"
    echo -e "\t[ds=\",|t|s|;\"] : if a file is provided for type, what is the splitor "
    exit 1
fi

inputsep="t"
dicsep=","

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
	act)         action=${VALUE} ;;
	input)       input=${VALUE};;
	is)          inputsep=${VALUE} ;;
	output)      out=${VALUE} ;;
	dic)         type=${VALUE} ;;
	sub)         pattern=${VALUE} ;;
	s)          dicsep=${VALUE} ;;
	*)
    esac
done
if [ $action == "merge" ]
   then
   folder=$input
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
fi

if [ $action == "format" ]
then
    merged=$input
fi

perl methylSaguaroFormatter.pl -i $merged -d $type -o $out -is $inputsep -ds $dicsep -c m
