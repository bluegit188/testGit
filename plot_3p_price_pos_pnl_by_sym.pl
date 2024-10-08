#!/usr/bin/perl

use File::Basename;
use strict;


my $DEBUG=0;

( ($#ARGV+2)==4  || ($#ARGV+2)==5) || die
"Usage: plot_3p_price_pos_pnl_by_sym.pl startDate endDate SYM [opt: isOpen=1/0]
       Plot price/postion/pnl fo symbol based on bt1Fcst.dm fcst and targetPos/AUM from archived fcsts
       Optional: isOpen=1 to us open prices; deault=0 for close prices\n";


my $startDate=$ARGV[0];
my $endDate=$ARGV[1];

my $sym=$ARGV[2];

my $isOpen=0;
my $closeStr="";
if( $#ARGV+2==5)
{
   $isOpen=$ARGV[3];
   if($isOpen==1)
   {
     $closeStr=":O";
   }
}


my $plotFutCmd="portara_plot_fut.pl";
if($isOpen==1)
{
   $plotFutCmd="portara_plot_fut_open.pl";
}

# get the data
    my $cmd="
#pnl
check_cumPnl_prod_by_date_range_sym_indName_multi_demean.pl $startDate $endDate -0.105:0.105 0 bt1Fcst.dm $sym
cp /tmp/y_x.txt /tmp/pnls.txt
#price
$plotFutCmd $sym 0
cat /tmp/c.txt > /tmp/price.txt
#pos
plot_pos_sizing_targetPos_aumScaled_by_sym.pl $startDate $endDate $sym
cat /tmp/xvar.txt.targetPosScl|mygetcols.pl 2 3 4 5  >/tmp/pos.txt
# adj pnls: some zero pos should have zero pnls
combine_match1.pl /tmp/pos.txt /tmp/pnls.txt|gawk '{print \$5,\$6,\$7,\$8,\$4*\$7}' > /tmp/pnlsAdj.txt 
#combine
combine_match1na_all.pl /tmp/price.txt /tmp/pos.txt /tmp/pnlsAdj.txt |fgrep -v \" NA \"|mygetcols.pl 1 3 7 12|myCum.pl 4 >/tmp/combo_3p
datesXmgr.pl /tmp/combo_3p 1 >/tmp/forplot_3p";
#    print "$cmd\n";
    system("$cmd");

 #get subtitle str
 my $cmd2="
##check stats
cat /tmp/forplot_3p |gawk '{if(\$4>0){print \"long\",\$0}else{if(\$4<0){print \"short\",\$0}else{print \"zeroPos\",\$0}}}' >/tmp/bb
getMeanStdByDate.pl /tmp/bb 0 1 6|gawk '{print \$0,\$4*\$6 }'|mygetcols.pl 1 6 7|myFloatRoundingInPlace.pl 0 3 3|myAddHeader.sh \"Position numDays totalPnl\"|myFormatAuto.pl 1 >/tmp/cc
#get subtitle str
cat /tmp/cc|gawk '{print \$3\"\\\\/\"\$2}'|myTranspose.pl|myrmcols.pl 1|gawk '{print \"pnls\\\\/days: long= \"\$1\"   short= \"\$2\"   noPos=\"\$3}'";
 my $res2=`$cmd2`;
 chomp($res2);
 my $substr=$res2;

#print "substr=$substr\n";

my $cmd3="
## xmgr part
cat /home/jgeng/bin/batch_3pplot.txt | sed s/WWW/$sym$closeStr/  | sed s/START/$startDate/| sed s/END/$endDate/ | sed s/SUBSTR/\"$substr\"/ > /tmp/batch_3pplot.txt
xmgrByDate  -batch /tmp/batch_3pplot.txt &
";

#    print "$cmd3\n";
    system("$cmd3");




__END__


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
