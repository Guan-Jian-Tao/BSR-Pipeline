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


#####Step 1: make folder for STAR#####

	print "Make dir for $starout\n";
	system "mkdir $starout"; #make indiv folder
	foreach my $f (@files) {
		chomp($f);$f =~ s/\r//;
		my @g = split /\_/,$f;
		my $p = $g[0];next if exists $data{$p};
		$data{$p} = 1;
		$pp = "$starout"."$p"."\.dir"."/";
		print "Make dir for $pp\n";
		$cmd = "mkdir $pp";
		system ($cmd); #make STAR out folder for all samples
		sleep 0.5;
	}
	print "Folders are made\n";
my %data;

#####Step 2 STAR MAP#####

	foreach my $f (@files) {
		chomp($f);$f =~ s/\r//;
		my @g = split /\_/,$f;
		my $p = $g[0];
		next if exists $data{$p};
		$data{$p} = 1;
		$pp = "$starout"."$p"."\.dir"."/";  # path for tophat
		my $ppl = "$pp"."log.STAR.txt";     # log file
		my $fq1 = $pathraw.$p."_1_clean.fq.gz";
		my $fq2 = $pathraw.$p."_2_clean.fq.gz"; 
		my $out = $starout.$p."\.dir"."/".$p."_";
		my $sh = $starout.$p."\.dir"."/"."S1.STAR.$p.sh";
		my $RG = "ID:$p.ID SM:$p LB:$p.LB PL:ILLUMINA";
		open (OUT,">$sh");
                print OUT "\#\$ \-S \/bin\/bash\n\#\$ \-j y \-V\n\#\$ \-cwd\n\#\$ \-l h\_vmem\=50G\n\#\$ -q all.q\n";
		sleep 0.1;
                print OUT "time1=`date \"+%Y-%m-%d %H:%M:%S\"` \necho S1_STAR for $p starts\ at \$time1  >> $log\n";
                print OUT "#Main Command Line\n########\n";
		print OUT "STAR --runThreadN 50 --outFilterMismatchNmax 2 --genomeDir $index --outFilterMultimapNmax 1 --alignMatesGapMax 1000000 --alignIntronMax 1000000 --alignIntronMin 1 --outFilterType BySJout --outFileNamePrefix $out --readFilesCommand gunzip -c --outSAMattributes NM MD AS XS --outSAMtype BAM SortedByCoordinate --readFilesIn $fq1 $fq2 --outSAMattrRGline $RG \n";
		print OUT "########\n";
                print OUT "time2=`date \"+%Y-%m-%d %H:%M:%S\"`\n";
                print OUT "end_dat=`date -d \"\$time2\" +%s` \nstart_dat=`date -d \"\$time1\" +%s` \ninter_s=`expr \$end_dat - \$start_dat` \ninter_m=`expr \$inter_s / 60` \necho S1_STAR for $p completes at \$time2 and consumed \$inter_m minutes >> $log \n";
		close OUT;
                system "chmod 700 $sh";
                system "qsub $sh";
                sleep 0.2;
		#system "(STAR --runThreadN 20 --outFilterMismatchNmax 2 --genomeDir $genome --outFilterMultimapNmax 1 --alignMatesGapMax 1000000 --alignIntronMax 4000000 --alignIntronMin 1 --outFilterType BySJout --outFileNamePrefix $out --twopassMode Basic --readFilesCommand gunzip -c --outSAMattributes NM MD AS XS --outSAMtype BAM SortedByCoordinate --readFilesIn $fq1 $fq2 --outSAMattrRGline $RG > $ppl 2>&1 &)";
		#system "(STAR --runThreadN 20 --outFilterMismatchNmax 4 --genomeDir $genome --outFilterMultimapNmax 1 --alignMatesGapMax 1000000 --alignIntronMax 4000000 --alignIntronMin 1 --outFilterType BySJout --outFileNamePrefix $out --twopassMode Basic --readFilesCommand gunzip -c --outSAMattributes NM MD AS XS --outSAMtype BAM SortedByCoordinate --readFilesIn $fq1 $fq2 > $ppl 2>&1 &)";
		print "STAR --runThreadN 50 --outFilterMismatchNmax 2 --genomeDir $index --outFilterMultimapNmax 1 --alignMatesGapMax 1000000 --alignIntronMax 1000000 --alignIntronMin 1 --outFilterType BySJout --outFileNamePrefix $out --readFilesCommand gunzip -c --outSAMattributes NM MD AS XS --outSAMtype BAM SortedByCoordinate --readFilesIn $fq1 $fq2 --outSAMattrRGline $RG \n";
		sleep 0.2;
	}
