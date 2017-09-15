#!/usr/bin/perl -w

use warnings;
use strict;
use Getopt::Long;

########################################################################################
#### This script converts DNA methylation array data into methylSaguaro or PiiL format
#### Author: Behrooz Torabi Moghadam
#### Created: 17.5.2017
########################################################################################

my $input;
my $dictionary;
my $separator;
my $output;
my $format;

if (@ARGV != 10 ) {
    print "Wrong argument! Usage: perl formatInput.pl -i inputFile -d dictionaryFile -s separator(,|t|-|s|...) -o outputFile -c convertTo(p for PiiL |m for methylSaguaro)\n";
    exit;
}

GetOptions ("i=s" => \$input,    # input file
	    "d=s"   => \$dictionary,      # dictionary file
	    "s=s" => \$separator , #separated by
	    "c=s" => \$format , #convert to PiiL or Saguaro
	    "o=s" => \$output)  #output
or die("Error in command line arguments! Usage: perl formatInput.pl -i inputFile -d dictionaryFile -s separator(,|t|-|s|...) -o outputFile -c convertTo(p for PiiL |m for methylSaguaro)\n");

chomp $dictionary;
chomp $input;
if (!-e $input)
{print "$input does not exist!\n";
exit;}
elsif (!-e $dictionary)
{print "$dictionary does not exist!\n";
exit;}

open(IN,$input);
open(DIC,$dictionary);
open(OUT,">>$output");

my ($record,$row,@rest);

my $counter = 0;
my %genes;
my %cancerTypes;
my $header = "Chr" . "\t" . "Pos" . "\t";
my $size;

print "Processing dictionary file ...\n";

while ($record = <DIC>){
    chomp $record;
    my @info = split(/,/,$record);
    $size = @info;
    $format = lc $format;
    my $chromosome = 'Chr' . $info[1]; 
    if ($format eq 'm'){
	
	$genes{$info[0]} = [$chromosome,$info[2]] # cg = [ChrX,position]
    }
    elsif ($format eq 'p'){
	if ($size == 5){
	    $genes{$info[0]} = [$chromosome,$info[2],$info[3],$info[4]]; # cg = [ChrX,position,gene,region]
	} 
	else {
	    $genes{$info[0]} = [$chromosome,$info[2],$info[3]]; # cg = [ChrX,position, gene]
	}
    }
}
print "Done.\n";
if ($separator eq 't'){
    $separator = "\\t";
} elsif ($separator eq 's'){
    $separator = "\\s";
}

my $samples = <IN>; # read the first line including sample IDs
chomp $samples;
if ($format eq 'p'){
    print OUT $samples . "\n";
}
elsif ($format eq 'm'){
    my @ids = split(/$separator/,$samples);
    shift @ids;
    print OUT "Chr" . "\t" . "Position" . "\t" . join("\t",@ids) . "\n" ;
}

my $geneName;

print "Processing the input file and writing the output file ... \n";
while ($record = <IN>){
    chomp $record;
    my ($cg,@rest) = split(/$separator/,$record);
    
    if ($format eq 'm'){
	if (exists $genes{$cg}){
	    print OUT $genes{$cg}[0] . "\t" . $genes{$cg}[1] . "\t" . join("\t",@rest) . "\n";
	}
    }
    elsif ($format eq 'p'){
	if (exists $genes{$cg}){
	    if ($size == 5){
		print OUT $genes{$cg}[2] . "_" . $cg . "_" . $genes{$cg}[0] . ":$genes{$cg}[1]_" . $genes{$cg}[3] . "," . join(",",@rest) . "\n";
	    }
	    elsif ($size == 4){
		print OUT $genes{$cg}[2] . "_" . $cg . "_" . $genes{$cg}[0] . ":$genes{$cg}[1]," . join(",",@rest) . "\n";
	    }
	}
    }
}
print "Done.\n";
print "Sorting the output ... \n";
my $command = "grep -v ChrX $output | grep -v ChrY | sort -k 1.4,1 -n -s -k2 -n > temp.txt";
system($command);
system("grep ChrX $output | sort -k2 -n >> temp.txt");
system("grep ChrY $output | sort -k2 -n >> temp.txt");
system("mv temp.txt $output");
print "Done.\n";
print "The converted data was successfully written to $output\n";
