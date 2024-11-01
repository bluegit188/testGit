#!/usr/bin/perl

use File::Basename;
use strict;


my $DEBUG=0;

(($#ARGV+2)==3 || ($#ARGV+2)==5) || die
"Usage: portara_plot_fut.pl SYM isAdj=0/1 [opt: startDate endDate]
        portara_plot_fut.pl ES 1 20180808 20231010
        Plot close prices of a given future\n";

my $sym=$ARGV[0]; # portara text file
my $isAdj =$ARGV[1];

my $startDate=19000101;
my $endDate=30000101;

if (($#ARGV+2)==5)
{
   $startDate =$ARGV[2];
   $endDate =$ARGV[3];
}

    my $cmd="
cat /home/jgeng/RawData/portara/JunfCC/CCFixRTH/$sym.txt |gawk '{print \$1,\$5}' |myRmOutliersSimple.pl 0 1 $startDate $endDate 1 > /tmp/c.txt
datesXmgr.pl /tmp/c.txt 1 |mygetcols.pl 1 3 2 > /tmp/$sym.txt.plot
echo \"title \\\"$sym\\\"\" > /tmp/title.txt
xmgrByDate  -batch /tmp/title.txt /tmp/$sym.txt.plot&
";

if($isAdj==1)
{
$cmd="
cat /home/jgeng/RawData/portara/JunfCC/CCFixRTH/$sym.txt |gawk '{print \$1,\$5-\$12}'  |myRmOutliersSimple.pl 0 1 $startDate $endDate 1 > /tmp/c.txt
datesXmgr.pl /tmp/c.txt 1 |mygetcols.pl 1 3 2 > /tmp/$sym.txt.plot
echo \"title \\\"$sym\\\"\" > /tmp/title.txt
xmgrByDate  -batch /tmp/title.txt /tmp/$sym.txt.plot&
";

}

    #print "$cmd\n";
    system("$cmd");



__END__

cat /home/jgeng/RawData/portara/JunfCC/CCFixRTH/ES.txt |gawk '{print $1,$5-$12}' > /tmp/c.txt

datesXmgr.pl /tmp/c.txt 1 |mygetcols.pl 1 3 2 > /tmp/c.txt.plot
xmgrByDate /tmp/c.txt.plot






--cmd:
time cat /mnt/wbox1/portara/Futures/Continuous\ Contracts/Intraday\ Database/1\ Minute\ 24Hr/EU.001 | sed s/,/\ /g|fgrep -v DATE|gawk '{if($1>=20150115 && $1<=20150115){print $1,$2,$7}}' > /tmp/tmpVol.txt
# 35 sec
cat /tmp/tmpVol.txt|myPortaraAddMissingMinutes.pl 1 2 3|mygetcols.pl 1 2 6 >/tmp/tmpVolNorm.txt 
timesXmgr.pl /tmp/tmpVolNorm.txt 2 0|mygetcols.pl 1 4 2 3  >/tmp/tmpForplot.txt
xmgrByTime /tmp/tmpForplot.txt&


