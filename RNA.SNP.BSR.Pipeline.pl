use strict;
use warnings;
use POSIX qw(tmpnam);
use Getopt::Long;
use File::Basename;
use File::Path qw(make_path);
use Cwd qw(abs_path);
use List::MoreUtils qw(uniq);
use Time::localtime;

## ======================================
## Usage: see -h
## ======================================

sub usage{
  warn <<END;
  Usage:
  Run by typing: perl RNA.SNP.BSR.Pipeline.pl -exprfile [Experiment file] -logfile [main log file (.txt)] -bam_num [bam files number] -chrlen [chromosome length file] -start_code [Start Code]
    Required params:
	-e|exprfile							[s]	Experiment file
	-l|logfile							[s]	Main Log file (.txt)
	-n|bam_num							[i]	Bam files number
	-c|chrlen							[s]	Chromosome length file (.txt)
	-p|picard							[s]	Picard PATH
	-g|GATK								[s]	GATK PATH
	-s|start_code						[i]	Start Code (1-ordinates)
	start code:
		1			S1_STAR;
		2			S2_Index;
		3			S3_Mark_Duplicates;
		4			S4_SplitN;
		5			S5_TargetCreator;
		6			S6_Realigner;
		7			S7_HaplotypeCaller;
		8			S6_Depth;
    Example: perl RNA.SNP.BSR.Pipeline.pl -exprfile ExperimentalDesign.txt -logfile /wanglab2/guanjt/potBAC/Analysis1.dir/Log.dir/Main.Log.txt -bam_num 8 -chrlen Chr.length.txt -start_code 1
END
  exit;
}
## ======================================
## Get options
## ======================================

my %opt;
%opt = (
	'help'				=> undef,
	'debug'				=> undef,
	'exprfile'		    => undef,
	'logfile'			=> undef,
	'bam_num'			=> undef,
	'chrlen'			=> undef,
	'start_code'		=> undef
);

die usage() if @ARGV == 0;
GetOptions (
  'h|help'				=> \$opt{help},
  'debug'				=> \$opt{debug},
  'e|exprfile=s'			=> \$opt{exprfile},
  'l|logfile=s'			=> \$opt{logfile},
  'n|bam_num=i'			=> \$opt{bam_num},
  'c|chrlen=s'			=> \$opt{chrlen},
  's|start_code=i'		=> \$opt{start_code}
) or die usage();

#check input paramaters
die usage() if $opt{help};
die usage() unless ( $opt{exprfile} );
die usage() unless ( $opt{logfile} );
die usage() unless ( $opt{bam_num} );
die usage() unless ( $opt{chrlen} );
die usage() unless ( $opt{start_code} );

########
#Main Function
########
if (-e $opt{logfile}){
	system "rm $opt{logfile}";
	print "rm $opt{logfile} \n";
}

my $code = 0;

###
$code=1;
if ($opt{start_code} == $code){
print "Start S1_STAR Mapping \n";
print "perl src.dir/S1_STAR.pl $opt{exprfile} $opt{logfile}";
system "perl src.dir/S1_STAR.pl $opt{exprfile} $opt{logfile}";
###

while (&check_done("S1_STAR","complete",$opt{bam_num}) != 1){
	print "S1_STAR is running \n";
	sleep 300;
} 
print "All S1_STAR completed \n";
} 

###
$code=2;
if ($opt{start_code} == $code){
print "Start S2_Index Bam Index \n";
print "perl src.dir/S2_Index.pl $opt{exprfile} $opt{logfile}";
system "perl src.dir/S2_Index.pl $opt{exprfile} $opt{logfile}";
###

while (&check_done("S2_Index","complete",$opt{bam_num}) != 1){
	print "S2_Index is running \n";
	sleep 300;
} 
print "All S2_Index completed \n";
} 

###
$code=3;
if ($opt{start_code} == $code){
print "Start S3_Mark_Duplicates Remove Duplicates \n";
print "perl src.dir/S3_Mark_Duplicates.pl $opt{exprfile} $opt{logfile}";
system "perl src.dir/S3_Mark_Duplicates.pl $opt{exprfile} $opt{logfile}";
###

while (&check_done("S3_Mark_Duplicates","complete",$opt{bam_num}) != 1){
	print "S3_Mark_Duplicates is running \n";
	sleep 300;
} 
print "All S3_Mark_Duplicates completed \n";
} 

###
$code=4;
if ($opt{start_code} == $code){
print "Start S4_SplitN Split Ns \n";
print "perl src.dir/S4_SplitN.pl $opt{exprfile} $opt{logfile}";
system "perl src.dir/S4_SplitN.pl $opt{exprfile} $opt{logfile}";
###

while (&check_done("S4_SplitN","complete",$opt{bam_num}) != 1){
	print "S4_SplitN is running \n";
	sleep 300;
} 
print "All S4_SplitN completed \n";
} 

###
$code=5;
if ($opt{start_code} == $code){
print "Start S5_TargetCreator Create Target \n";
print "perl src.dir/S5_TargetCreator.pl $opt{exprfile} $opt{logfile}";
system "perl src.dir/S5_TargetCreator.pl $opt{exprfile} $opt{logfile}";
###

while (&check_done("S5_TargetCreator","complete",$opt{bam_num}) != 1){
	print "S5_TargetCreator is running \n";
	sleep 300;
} 
print "All S5_TargetCreator completed \n";
} 

###
$code=6;
if ($opt{start_code} == $code){
print "Start S6_Realigner Create Target \n";
print "perl src.dir/S6_Realigner.pl $opt{exprfile} $opt{logfile}";
system "perl src.dir/S6_Realigner.pl $opt{exprfile} $opt{logfile}";
###

while (&check_done("S6_Realigner","complete",$opt{bam_num}) != 1){
	print "S6_Realigner is running \n";
	sleep 300;
} 
print "All S6_Realigner completed \n";
} 

###
$code=7;
if ($opt{start_code} == $code){
print "Start S7_HaplotypeCaller Create Target \n";
print "perl src.dir/S7_HaplotypeCaller_Cluster.pl $opt{exprfile} $opt{logfile} $opt{chrlen}";
system "perl src.dir/S7_HaplotypeCaller_Cluster.pl $opt{exprfile} $opt{logfile} $opt{chrlen}";
###
my $chr_num;
open(IN,$opt{chrlen});
while(<IN>){
	$chr_num++;
}
close IN;
while (&check_done("S7_HaplotypeCaller","complete",$chr_num) != 1){
	print "S7_HaplotypeCaller is running \n";
	sleep 300;
} 
print "All Chromosome S7_HaplotypeCaller completed \n";
} 

###
$code=8;
if ($opt{start_code} == $code){
print "Start S6_Depth Create Target \n";
print "perl src.dir/S6_Depth.pl $opt{exprfile} $opt{logfile}";
system "perl src.dir/S6_Depth.pl $opt{exprfile} $opt{logfile}";
###

while (&check_done("S6_Depth","complete",$opt{bam_num}) != 1){
	print "S6_Depth is running \n";
	sleep 300;
} 
print "All S6_Depth completed \n";

print "SNP Calling is done! Next step is filtering! \n";
} 










########
#Subfunction
########

sub check_done{
	my $key1 = shift;
	my $key2 = shift;
	my $num = shift;
	my $done_times = `egrep $key1 $opt{logfile} | egrep -c $key2`;
	if ($done_times == $num){
		return 1;
	} elsif ($done_times < $num) {
		return 0;
	} else {
		die "The step $key1 has more log terms ($done_times) \n";
	}
}

