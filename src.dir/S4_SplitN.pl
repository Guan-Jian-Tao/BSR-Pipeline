#! /usr/bin/perl -w
$|=1;
###input pathways and stepcodes###### 
$exprfile = $ARGV[0];
$log = $ARGV[1];

&design($exprfile); #kw, raw, all,indiv , ebwt2, gff, genome, step_code
$pathraw = $design{"raw"}; #folder for raw fastq files
$gatkout = $design{"gout"};#folder for each sample GATK out
$starout = $design{"sout"};#folder for each sample STAR out
$genome = $design{"genome"};#Genome dir
$index = $design{"index"};
$picard = $design{"picard"};
$GATK = $design{"GATK"};
$tmp = $design{"tmp"};

@files = `ls  $pathraw`;

#####read configured file#####
sub design{
	my $in = shift;
	open (IN,$in) || die "can not read experimental design\n";
        while (<IN>){
        	chomp;s/\r//;
		if ($_ !~ /^#/){
        		my ($word,$info,) = split (/\t/,$_);
        		$design{$word} = $info;
		} else {next}
        }
	close IN;
}


#####Step 1 SplitN#####

	foreach my $f (@files) {
		chomp($f);$f =~ s/\r//;
		my @g = split /\_/,$f;
                my $p = $g[0];
                next if exists $data{$p};
                $data{$p} = 1;
		$pp = "$gatkout"."$p"."\.dir"."/";  # path for tophat
		my $ppl = "$pp"."log.SplitN.txt";     # log file
		my $inbam = $gatkout.$p."\.dir"."/".$p."\_Aligned.sortedByCoord.out.MD.bam";
		my $outbam = $gatkout.$p."\.dir"."/".$p."\_Aligned.sortedByCoord.out.SN.bam";
		#print "(java -jar /home/guanjt/software.dir/GenomeAnalysisTK-3.5.dir/GenomeAnalysisTK.jar -T SplitNCigarReads -R $genomefa -I $inbam -o $outbam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS > $ppl 2>&1 &)\n";
		#system "(java -jar /home/guanjt/software.dir/GenomeAnalysisTK-3.5.dir/GenomeAnalysisTK.jar -T SplitNCigarReads -R $genomefa -I $inbam -o $outbam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS > $ppl 2>&1 &)";
		my $sh = $gatkout.$p."\.dir"."/"."S4.SplitN.$p.sh";
                open (OUT,">$sh");
                print OUT "\#\$ \-S \/bin\/bash\n\#\$ \-j y \-V\n\#\$ \-cwd\n\#\$ \-l h\_vmem\=50G\n\#\$ -q all.q\n";
		sleep 0.1;
                print OUT "time1=`date \"+%Y-%m-%d %H:%M:%S\"` \necho S4_SplitN for $p starts\ at \$time1  >> $log\n";
                print OUT "#Main Command Line\n########\n";
		print OUT "java -Djava.io.tmpdir=$tmp -jar $GATK -T SplitNCigarReads -R $genome -I $inbam -o $outbam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS \n";
		print OUT "########\n";
                print OUT "time2=`date \"+%Y-%m-%d %H:%M:%S\"`\n";
                print OUT "end_dat=`date -d \"\$time2\" +%s` \nstart_dat=`date -d \"\$time1\" +%s` \ninter_s=`expr \$end_dat - \$start_dat` \ninter_m=`expr \$inter_s / 60` \necho S4_SplitN for $p completes at \$time2 and consumed \$inter_m minutes >> $log \n";
		close OUT;
                system "chmod 700 $sh";
                system "qsub $sh";
                sleep 0.2;
                print "java -Djava.io.tmpdir=$tmp -jar $GATK -T SplitNCigarReads -R $genome -I $inbam -o $outbam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS \n";
		print "Running SplitN for $p \n";
		sleep 0.2;
	}
