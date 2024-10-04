#!/usr/bin/perl

use File::Basename;
use strict;


my $DEBUG=0;

 ($#ARGV+2)==5  || die
"Usage: plot_tenor_volume_cn_3cym.pl SYM 2021K 2021M 2021M
       Plot volumes for specified tenor file for CN ETH files.
       For example, SYM=NI, ym=2021K 2021M 2021Z\n";

my $sym=$ARGV[0];

my $ym1=$ARGV[1];
my $ym2=$ARGV[2];
my $ym3=$ARGV[3];

my $file1="/home/jgeng/RawData/lc5m/ETHTenors/$sym/${sym}_${ym1}.txt";
my $file2="/home/jgeng/RawData/lc5m/ETHTenors/$sym/${sym}_${ym2}.txt";
my $file3="/home/jgeng/RawData/lc5m/ETHTenors/$sym/${sym}_${ym3}.txt";


# get the data
    my $cmd="
cat $file1 |mygetcols.pl 1 6 > /tmp/vol.txt.1
datesXmgr.pl /tmp/vol.txt.1  1|fgrep -v DATE|mygetcols.pl 1 3 > /tmp/forplot_vol.txt.1
cat $file2 |mygetcols.pl 1 6 > /tmp/vol.txt.2
datesXmgr.pl /tmp/vol.txt.2  1|fgrep -v DATE|mygetcols.pl 1 3 > /tmp/forplot_vol.txt.2
cat $file3 |mygetcols.pl 1 6 > /tmp/vol.txt.3
datesXmgr.pl /tmp/vol.txt.3  1|fgrep -v DATE|mygetcols.pl 1 3 > /tmp/forplot_vol.txt.3
#xmgr part
cat /home/jgeng/bin/batch_tenor_3lines.txt | sed s/SYM/$sym/  | sed s/YM1/$ym1/g| sed s/YM2/$ym2/g| sed s/YM3/$ym3/g  > /tmp/batch_tenor_3cym.txt
xmgrByDate  -batch /tmp/batch_tenor_3cym.txt &
";


#    print "$cmd\n";
    system("$cmd");




__END__

READ BLOCK "file2.dat"
BLOCK xy "1:2"
BLOCK xy "1:3"
BLOCK xy "1:4"
BLOCK xy "1:5"
READ BLOCK "file2.dat"
BLOCK xy "1:2"
BLOCK xy "1:3"
BLOCK xy "1:4"
BLOCK xy "1:5"
BLOCK xy "1:6"



--cmd:

portara_get_ooRets.pl DX 5 |mygetcols.pl 2 1 3 | myConstraintSimple.pl 3 -4 4 > /tmp/ccP1D.txt.DX
portara_get_ooRets.pl CL 5 |mygetcols.pl 2 1 3 | myConstraintSimple.pl 3 -4 4 > /tmp/ccP1D.txt.CL
combine_match1.pl /tmp/ccP1D.txt.DX /tmp/ccP1D.txt.CL|mygetcols.pl 1 3 6|fgrep -v DATE|gawk '{print "AAA",$0}'|myAddHeader.sh "SYM DATE DX CL" > /tmp/ccP1D.txt.DX.CL
get_rolling_corr_fast.pl /tmp/ccP1D.txt.DX.CL 3 4 100|mygetcols.pl 2 5 > /tmp/corP1D_100D.txt.DX.CL
datesXmgr.pl /tmp/corP1D_100D.txt.DX.CL 1|fgrep -v DATE|mygetcols.pl 1 3 > /tmp/forplot_corP1D_100D.txt.DX.CL
echo "title \"Rolling corrP100D for DX vs CL\"" > /tmp/title.txt
xmgrByDate  -batch /tmp/title.txt /tmp/forplot_corP1D_100D.txt.DX.CL















xmgrByDate  -autoscale none -timestamp -param /home/jgeng/wli.par  -batch xmgr.batch -nosafe ^C

1037  datesXmgr.pl a 1|mygetcols.pl 1 8 >b
 1038  xmgrByDate b&
 1039  more b
 1040  xmgrByDate b
 1041  more b
 1042  more b|cat
 1043  extract_CorrTimeSeries_from_corrMatrix_bySyms.pl DX CL 19800101 20160202 100 >a
 1044  datesXmgr.pl a 1|mygetcols.pl 1 8 >b
 1045  xmgrByDate b
 1046  pico aaa
 1047  xmgrByDate  -batch aaa b
 1048  bg
 1049  history 
 1050  more ~/bin/extract_CorrTimeSeries_from_corrMatrix_bySyms.pl
