#!/usr/bin/perl -w
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
$chr = $ARGV[2];

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

foreach my $f (@files) {
	chomp($f);$f =~ s/\r//;
	my @g = split /\_/,$f;
        my $p = $g[0];
        next if exists $data{$p};
        $data{$p} = 1;
	$pp = "$gatkout"."$p"."\.dir"."/";  # path for tophat
	my $ppl = "$pp"."log.HaplotypeCaller.txt";     # log file
	my $inbam = "-I ".$gatkout.$p."\.dir"."/".$p."\_Aligned.sortedByCoord.out.RE.bam";
	push @bams,$inbam;
}
#my @bams = ("-I CK.SN.Sort.bam","-I AC.SN.Sort.bam");
open(IN,$chr);
my $i=0;
system "mkdir VCFs.dir";
sleep 0.1;
my $vcfout = "VCFs.dir/";
while(<IN>){
	$i++;
	#my $j = $i % scalar(@nodes);
        #my $node = $nodes[$j];
        #print "$node\n";
	chomp;s/\r//;
	my @g = split/\t/,$_;
	my $chr =$g[0];
	my $sh = $vcfout."HaplotypeCaller.$g[0].sh";
	my $vcf = $vcfout."All.Raw.$chr.vcf";
	my $bam = join(" ",@bams);
	open (OUT,">$sh");
        #print OUT "\#\$ \-S \/bin\/bash\n\#\$ \-j y \-V\n\#\$ \-cwd\n\#\$ \-l h\_vmem\=170G\n\#\$ -q all.q\n\#\$ -l h=$node\n";
	print OUT "\#\$ \-S \/bin\/bash\n\#\$ \-j y \-V\n\#\$ \-cwd\n\#\$ \-l h\_vmem\=50G\n\#\$ -q all.q\n";
        sleep 0.1;
        print OUT "time1=`date \"+%Y-%m-%d %H:%M:%S\"` \necho S7_HaplotypeCaller for $chr starts\ at \$time1  >> $log\n";
        print OUT "#Main Command Line\n########\n";
	print OUT "java -Djava.io.tmpdir=$tmp -jar $GATK -T HaplotypeCaller -R $genome $bam -o $vcf -L $chr -dontUseSoftClippedBases -stand_call_conf 20.0 -stand_emit_conf 20.0 -mbq 20 -mmq 20 -nct 30\n";
	print OUT "########\n";
        print OUT "time2=`date \"+%Y-%m-%d %H:%M:%S\"`\n";
        print OUT "end_dat=`date -d \"\$time2\" +%s` \nstart_dat=`date -d \"\$time1\" +%s` \ninter_s=`expr \$end_dat - \$start_dat` \ninter_m=`expr \$inter_s / 60` \necho S7_HaplotypeCaller for $chr completes at \$time2 and consumed \$inter_m minutes >> $log \n";
	close OUT;
        system "chmod 700 $sh";
        system "qsub $sh";
        sleep 0.2;
	sleep 0.2;
	print "java -Djava.io.tmpdir=$tmp -jar $GATK -T HaplotypeCaller -R $genome $bam -o $vcf -L $chr -dontUseSoftClippedBases -stand_call_conf 20.0 -stand_emit_conf 20.0 -mbq 20 -mmq 20  -nct 30\n";
}	
close IN;
