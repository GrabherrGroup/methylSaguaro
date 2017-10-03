#!/usr/bin/perl -w

use warnings;
use strict;
use Getopt::Long;

########################################################################################
##   This script extracts cacti information from methylSaguaro output files          ###
##   Author: Behrooz Torabi Moghadam                                                 ###
##   Created: 18.5.2017                                                              ###
########################################################################################

my $localtrees;
my $cactusFile;
my $dictionary;
my $delimiter=",";
my $folder;
my $input;
my $output;

if (@ARGV < 8 ) {
    print "Missing argument! Usage: -i inputFile -o outputFolder -d dictionary (27k|450k|850k|file) [-ds ,|t|s|;|...] -r resultsFolder\n";
    exit;
}

GetOptions ("i=s" => \$input,    # methylSaguaro input file
	    "o=s" => \$output,  # methylSaguaro output folder
	    "d=s" => \$dictionary , # dictionary file
            "ds:s" => \$delimiter , # dictionary file's delimiter
	    "r=s" => \$folder ) # output results folder
or die("Error in command line arguments! Usage: -i inputFile -o outputFolder -d dictionary (27k|450k|850k|file) [-ds ,|t|s|;|...] -r resultsFolder\n");

chomp $dictionary;
chomp $output;
chomp $folder;

for ($dictionary){
    if (/27k/) {$dictionary="27k_dictionary.csv"}
    elsif (/450k/) {$dictionary="450k_dictionary.csv"}
    elsif (/850k/) {$dictionary="850k_dictionary.csv"}
}

$cactusFile = $output . "/saguaro.cactus";
$localtrees = $output . "/LocalTrees.out";

if (!-e $localtrees)
{print "$localtrees does not exist!\n";
exit;}
elsif(!-e $input)
{print "$input does not exist!\n";
 exit;}
elsif (!-e $dictionary)
{print "$dictionary does not exist!\n";
exit;}
elsif (!-e $cactusFile)
{print "$cactusFile does not exist!\n";
 exit;}
if (!-e $folder)
{system("mkdir $folder");}

open(DIC,$dictionary);
open(IN,$input);

my ($record,$row,@rest);
my $counter = 0;
my $size;
my %genes;

# read in the dictionary file
print "Processing the dictionary file ...\n";
while ($record = <DIC>){
    chomp $record;
    my @info = split(/$delimiter/,$record);
    $size = @info;
    my $coordinate = "Chr" . $info[1] . ":" . $info[2]; 
    if ($size == 3){
	
	$genes{$coordinate} = [$info[0],"NA","NA"]
    }
    elsif ($size == 5){
	$genes{$coordinate} = [$info[0],$info[3],$info[4]]; 
    } 
    else {
	$genes{$coordinate} = [$info[0],$info[3],"NA"];
    }
}

print "Done.\n";

print "Extracting regions of each cactus ...\n";

my %cactiHash;
my @temp;
my %regionTracker;

for (my $i =0; $i <= 10; $i ++){   #considering cacti 11 and 12 as background
    my $cactus = "cactus$i";
    my @result = `grep '^$cactus\t' $localtrees`;

    if (@result){
	my @positions;
	print "cactus $i\n";
	$counter = 0;
	foreach my $line (@result){
	    $counter++;
	    chomp $line;
	    my ($cac, $chrom, $start, $dash, $end,@rest) = split(/\s/,$line);
	    @temp = ();
	    chop $chrom;
	    push @temp, $chrom;
	    push @temp, $start;
	    push @temp, $end;

	    push @positions, @temp;
	}
	$cactiHash{$i} = \@positions;
	$regionTracker{$i} = 1;
    }
}

print "Done.\n";

print "Extracting the CpG sites consisting each region ...\n";
my $samples = <IN>; # read the first line including sample IDs
chomp $samples;

my $geneName;
my $title;
my @arr;
my %printed;
my $found = 0;

while ($row = <IN>){
    chomp $row;
    $found = 0;
    my ($chromosome,$position,@rest) = split(/\t/,$row);
    $title = 1;
    foreach my $key(keys %cactiHash){
	#$counter = 0;
	if ($found){last;}
	my $file = $folder . "/cactus" . $key . "_sitesInRegions.txt";
	open(OUT,">>$file");
	#@arr = @{$cactiHash{$key}};
	@arr = @{$cactiHash{$key}};
	
	for (my $i = 0; $i < @arr ; $i += 3){
	    if ($chromosome eq $arr[$i]){
		if (($position >= $arr[$i+1]) && ($position <= $arr[$i+2])){
		    my $coord = $chromosome . ":" . $position;
		    if (exists $genes{$coord}){
			my $title = $arr[$i] . ":" . $arr[$i+1] . "-" . $arr[$i+2];
			if (!exists $printed{$title}){
			    print OUT "region" . $regionTracker{$key} . " -> " . $arr[$i] . ":" . $arr[$i+1] . "-" . $arr[$i+2] . "\n";
			    $regionTracker{$key} ++;
			    $printed{$title} = "true";
			}
			print OUT $coord . "\t" . $genes{$coord}[0] . "\t" . $genes{$coord}[1] . "\t" . $genes{$coord}[2] . "\n";
			$found = 1;
			last;
		    }
		}
	    }
	} # end of for
    } # end of foreach
}
print "Done.\n";

print "Generating distance matrix files ...\n";
my $linesAfter = `head -3 $cactusFile | sed 1,2d | awk '{print NF}'`;
chop $linesAfter;
foreach my $key(keys %cactiHash){
    my $distance = $folder . "/cactus" . $key . "_distanceMatrix.txt";
    #open(OUT,">>$distance");
    #print "grep '^cactus$key\n' -A $linesAfter $cactusFile > $distance \n";
    my $run = `grep '^cactus$key\$' -A $linesAfter $cactusFile > $distance`;
}
print "Done.\n";

print "The results were successfully written to $folder\n";
