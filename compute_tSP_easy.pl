#!/usr/bin/perl

use strict;

($#ARGV+2)==7 || die 
"Usage: compute_tSP_easy.pl files.txt colY colX colDate withInter=1/0 freq=0/1/2
       Compute tSP for y~ x, based on yearly or qtrly frequency
       withInter: 1= with intercept, 0=no intercept
       freq: 0=yearly, 1=qtrly, 2=monthly\n";


my $filename=$ARGV[0];

my $colY=$ARGV[1];
my $colX=$ARGV[2];

my $colDate=$ARGV[3];
my $isInter=$ARGV[4];
my $freq=$ARGV[5];



my $regCmd="reg_by_key_no_inter_R.pl";
if($isInter==1)
{
  $regCmd="reg_by_key_R.pl";
}


my $freqCmd="myYear.pl";
if($freq==1) # qtrly
{
  $freqCmd="myYearQuarter.pl";
}
if($freq==2) # monthly
{
  $freqCmd="myYearMon.pl";
}



 my $cmd0="
head -1 $filename |mygetcols.pl $colX
";
 my $res0=`$cmd0`;
 chomp($res0);
my $indName=$res0;


 my $cmd01="
head -1 $filename |mygetcols.pl $colY
";
 my $res01=`$cmd01`;
 chomp($res01);
my $yName=$res01;



my $isVerbose=1;

my $cmd="
  cat $filename|mygetcols.pl $colY $colX $colDate |$freqCmd 1 3 > /tmp/tmp_data.txt.key
  $regCmd /tmp/tmp_data.txt.key 1 2 4 > /tmp/results.txt
  #tsp
  fgrep -v by /tmp/results.txt >/tmp/a1
  cat /tmp/results.txt|fgrep by|mygetcols.pl 1 3 >/tmp/h
  getstats_fast.pl /tmp/a1 1|fgrep b1|gawk '{print \$0,\$4/\$5*sqrt(\$6), $isInter}' >/tmp/b
  paste -d\" \" /tmp/h /tmp/b|myAddHeader.sh \"Y~X freq beta min max mean std count tSP isInter\" |myFormatAuto.pl 1
";
system("$cmd");





__END__

  cat data_LTInds_CN.txt|mygetcols.pl 4 10 1|myYear.pl 1 3 > /tmp/tmp_data.txt.key
  reg_by_key_no_inter_R.pl /tmp/tmp_data.txt.key 1 2 4 > /tmp/results.txt

  #tsp
  fgrep -v by /tmp/results.txt >a1
  cat /tmp/results.txt|fgrep by|mygetcols.pl 1 3 >h
  getstats_fast.pl a1 1|fgrep b1|gawk '{print $0,$4/$5*sqrt($6)}' >b
  paste -d" " h b|myAddHeader.sh "Y~X Freq IND min max mean std count tSP"|myFormatAuto.pl 1


