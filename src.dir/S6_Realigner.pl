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
#@nodes = ("cn-0-0","cn-0-1","cn-0-2","cn-0-3","cn-0-4","cn-0-6","cn-0-7","cn-0-8","cn-0-12","cn-0-14","cn-0-13","cn-0-15","cn-0-18");


#####Step 1 IndelRealigner#####
	$i=0;
	foreach my $f (@files) {
		chomp($f);$f =~ s/\r//;
		 my @g = split /\_/,$f;
                my $p = $g[0];
                next if exists $data{$p};
                $data{$p} = 1;
		$i++;
		#my $j = $i % scalar(@nodes);
                #my $node = $nodes[$j];
		#print "$node\n";
		$pp = "$gatkout"."$p"."\.dir"."/";  # path for tophat
		my $ppl = "$pp"."log.Realiner.txt";     # log file
		my $inbam = $gatkout.$p."\.dir"."/".$p."\_Aligned.sortedByCoord.out.SN.bam";
		my $outinterval = $gatkout.$p."\.dir"."/".$p."\.intervals";
		my $outbam = $gatkout.$p."\.dir"."/".$p."\_Aligned.sortedByCoord.out.RE.bam";
		#print "(java -jar /home/guanjt/software.dir/GenomeAnalysisTK-3.5.dir/GenomeAnalysisTK.jar -T IndelRealigner -R $genomefa -I $inbam -o $outbam  -targetIntervals $outinterval > $ppl 2>&1 &)\n";
		#system "(java -jar /home/guanjt/software.dir/GenomeAnalysisTK-3.5.dir/GenomeAnalysisTK.jar -T IndelRealigner -R $genomefa -I $inbam -o $outbam  -targetIntervals $outinterval > $ppl 2>&1 &)";
		my $sh = $gatkout.$p."\.dir"."/"."S6.Realigner.$p.sh";
                open (OUT,">$sh");
                #print OUT "\#\$ \-S \/bin\/bash\n\#\$ \-j y \-V\n\#\$ \-cwd\n\#\$ \-l h\_vmem\=170G\n\#\$ -q all.q\n\#\$ -l h=$node\n";
		print OUT "\#\$ \-S \/bin\/bash\n\#\$ \-j y \-V\n\#\$ \-cwd\n\#\$ \-l h\_vmem\=50G\n\#\$ -q all.q\n";
                sleep 0.1;
                print OUT "time1=`date \"+%Y-%m-%d %H:%M:%S\"` \necho S6_Realigner for $p starts\ at \$time1  >> $log\n";
                print OUT "#Main Command Line\n########\n";
		print OUT "java -Djava.io.tmpdir=$tmp -jar $GATK -T IndelRealigner -R $genome -I $inbam -o $outbam  -targetIntervals $outinterval \n";
		print OUT "########\n";
                print OUT "time2=`date \"+%Y-%m-%d %H:%M:%S\"`\n";
                print OUT "end_dat=`date -d \"\$time2\" +%s` \nstart_dat=`date -d \"\$time1\" +%s` \ninter_s=`expr \$end_dat - \$start_dat` \ninter_m=`expr \$inter_s / 60` \necho S6_Realigner for $p completes at \$time2 and consumed \$inter_m minutes >> $log \n";
		close OUT;
                system "chmod 700 $sh";
                system "qsub $sh";
                sleep 0.2;
		print "java -Djava.io.tmpdir=$tmp -jar $GATK -T IndelRealigner -R $genome -I $inbam -o $outbam  -targetIntervals $outinterval\n";
		sleep 0.2;
	}
