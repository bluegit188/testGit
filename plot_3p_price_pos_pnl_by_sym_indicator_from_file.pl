#!/usr/bin/perl

use strict;

($#ARGV+2) ==10 || die 
"Usage: plot_3p_price_pos_pnl_by_sym_indicator_from_file.pl file.txt startDate endDate colSym colDate colY colFcst fmin:fmax SYM
       Compute cummulative pnls for given asset class or given symbols
       stock=argi bond=nfmetal curr=coalsteel phy=petro
       Usage:
       plot_cummulative_pnls.pl file.txt 1 2 3 4 argi
       plot_cummulative_pnls.pl file.txt 1 2 3 4 all
       plot_cummulative_pnls.pl file.txt 1 2 3 4  SNI STW ESX DAX LFT ES NQ
       plot_cummulative_pnls.pl file.txt 1 2 3 4  BC CL NG KC C W SB LC HG GC CT
       plot_cummulative_pnls.pl file.txt 1 2 3 4  TY US LLG GBL GBM CGB
       plot_cummulative_pnls.pl file.txt 1 2 3 4  EC JY CD
\n";


# open file an dput column specified into a hash
my $filename=$ARGV[0];

my $startDate=$ARGV[1];
my $endDate=$ARGV[2];

my $colSym=$ARGV[3];
my $colDate=$ARGV[4];
my $colY=$ARGV[5];
my $colFcst=$ARGV[6];

my $fminmaxStr=$ARGV[7];
my $xmin=-999999;
my $xmax= 999999;
my ($a1,$a2) =split(':',$fminmaxStr);
if($a1 ne "x")
{
  $xmin=$a1;
  $xmax=$a2;
}




my $isOpen=0;
my $closeStr="";
{
   $isOpen=1;
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


my $sym=$ARGV[8];

my @n;
foreach my $i (8..$#ARGV)
{
  my $str=$ARGV[$i];
  my @tokens=split(':',$str);
  if($#tokens==0)
  {
    push(@n,$str);         # the n's
  }
  elsif($#tokens==1)
  {
     foreach my $k ( ($tokens[0])..($tokens[1]))
     {
       push(@n,$k);
     }
  }
  else # with step specified
  {
     my $step=$tokens[2];
     for (my $k= $tokens[0];$k<=$tokens[1];$k+=$step)
     {
       push(@n,$k);
     }
  }
}

my $filterStr=join("|", @n);
$filterStr=$filterStr." ";

$filterStr=~s/\s+$//; # remove trailing spaces
print "str=$filterStr\n";


#### create subset data file
#by syms
my $cmdSub="cat $filename |mygetcols.pl $colSym $colDate $colY $colFcst |myAssetSession_four_aseets_cn.pl 1 1|egrep -w -E -e\"DATE|$filterStr\"|mygetcols.pl 1 2 3 4  >/tmp/subset.txt";


if($n[0] eq "all")
{
  $cmdSub="cat $filename |mygetcols.pl $colSym $colDate $colY $colFcst  >/tmp/subset.txt";
}

#by asset
if($n[0] eq "agri")
{
  $cmdSub="cat $filename |mygetcols.pl $colSym $colDate $colY $colFcst |myAssetSession_four_aseets_cn.pl 1 1|egrep -E -e\"DATE|Agri\"|mygetcols.pl 1 2 3 4  >/tmp/subset.txt";
}


if($n[0] eq "nfmetal")
{
  $cmdSub="cat $filename |mygetcols.pl $colSym $colDate $colY $colFcst |myAssetSession_four_aseets_cn.pl 1 1|egrep -E -e\"DATE|Nfmetal\"|mygetcols.pl 1 2 3 4  >/tmp/subset.txt";
}

if($n[0] eq "petro")
{
  $cmdSub="cat $filename |mygetcols.pl $colSym $colDate $colY $colFcst |myAssetSession_four_aseets_cn.pl 1 1|egrep -E -e\"DATE|Petro\"|mygetcols.pl 1 2 3 4  >/tmp/subset.txt";
}


if($n[0] eq "coalsteel")
{
  $cmdSub="cat $filename |mygetcols.pl $colSym $colDate $colY $colFcst |myAssetSession_four_aseets_cn.pl 1 1|egrep -E -e\"DATE|Coalsteel\"|mygetcols.pl 1 2 3 4  >/tmp/subset.txt";
}


# print "$cmdSub\n";
system("$cmdSub");

my $subfilename="/tmp/subset.txt";


 my $cmd0="
head -1 $filename |mygetcols.pl $colFcst
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




#############################################
###############################################
## below for plotting cumPnl and DOW effect

my $cmda0="
cat /tmp/subset.txt |myRmOutliersSimple.pl 1 2 $startDate $endDate 1 |fgrep -v DATE|gawk '{print \$2,\$1,\$3,\$4}'|myAddHeader.sh \"DATE SYM $yName $indName\"   |myConstraintSimple.pl 4 $xmin $xmax >/tmp/raw_y_x.txt";

#print "$cmda0\n";
system("$cmda0");

#fcsts stats
my $cmd201="
echo \"\#\#Fcsts Stats (raw fcst before demean):\"
getstats_fast.pl /tmp/raw_y_x.txt 1|myFormatAuto.pl 1
";
system("$cmd201");



########################
#demean fcsts and check stats again
my $userMean=0;
my $cmd2012="
cat  /tmp/raw_y_x.txt|myDemeanFcstInPlace.pl 1 4 $userMean |gawk '{ if( NR==1){print \$0,\"pnl\"}else{print \$0,\$3*\$4}}'  > /tmp/y_x.txt
echo \"\#\#Fcsts Stats (demean fcst):\"
getstats_fast.pl /tmp/y_x.txt 1|myFormatAuto.pl 1
";
system("$cmd2012");



#tover
my $cmd20="
compute_fcst_turnover.pl /tmp/y_x.txt 4
";
system("$cmd20");


#comb
my $cmd2="
get_corr_matrix_R.pl /tmp/y_x.txt 0 >/tmp/a0
#cat tmp_correlation.txt |fgrep \"$indName\"|fgrep -v ooF1D|mygetcols.pl 3
cat tmp_correlation.txt |fgrep \"$indName\"|fgrep -v $yName|mygetcols.pl 3
#0.0988
";
 my $res=`$cmd2`;
 chomp($res);
my $corr=$res;

   my $cmd3="
cat   /tmp/y_x.txt |mygetcols.pl 1 2 5 > pls.txt
getMeanStdByDate.pl  /tmp/y_x.txt 1 1 5|gawk '{print \$1,\$4*\$6,\$6}'  |myAddHeader.sh \"DATE PPL count\" > /tmp/ppls.txt
 cat /tmp/ppls.txt|myRange.pl 1 1|mygetcols.pl 3 5| sed s/\\ /:/
";
 my $res3=`$cmd3`;
 chomp($res3);
my $dateRange=$res3;


print "###   Univ= $filterStr y= $yName x= $indName dateRange= $dateRange \n";


   my $cmd32="
datesXmgr.pl /tmp/ppls.txt 1 |fgrep -v DATE|gawk '{print \$1,\$3}'|myCum.pl 2 |mygetcols.pl 1 3 > /tmp/forplot
echo \"title \\\"$filterStr: $yName~$indName cumPnls corr=$corr \\ndateRange=$dateRange\\\"\" > /tmp/title.txt
xmgrByDate  -batch /tmp/title.txt /tmp/forplot  1>/dev/null 2>/dev/null &
echo \"\#\#PPLShp:\"
getstats_fast.pl /tmp/ppls.txt 1|myStatsToShp.sh
";

   #print "$cmd32\n";
   system("$cmd32");

   my $cmd4="
echo \"\#\#Corr:\"
 cp /tmp/y_x.txt  /tmp/y_x.txt.gc
 get_corr_matrix_R.pl /tmp/y_x.txt.gc 0 >/tmp/a
 cat tmp_correlation.txt |myFormatAuto.pl 1

#DOW
echo \"\#\#by DOW\"
cat /tmp/y_x.txt.gc |myDayOfWeek.pl 1 1 >/tmp/a2
getMeanStdByDate.pl /tmp/a2 1 6 5|myStatsToShp.sh
";

   #print "$cmd4\n";
   system("$cmd4");





print "\n\n######## shp by asset ###############\n";
    my $cmd5="
get_portfolioShp_byAsset_new_cn.pl pls.txt
";
  # print "$cmd5\n";
   system("$cmd5");


print "\n\n######## corr by asset ###############\n";
    my $cmd6="
cp /tmp/y_x.txt tmp_y_x.txt
get_corr_by_asset4_R_cn.pl tmp_y_x.txt 2 1 3 4
";
  # print "$cmd6\n";
   system("$cmd6");



print "\n\n######## corr (w/o deman) by asset ###############\n";
    my $cmd6="
cp /tmp/y_x.txt tmp_y_x.txt
get_corr_wo_demean_by_asset4_R_cn.pl tmp_y_x.txt 2 1 3 4
";
  # print "$cmd6\n";
   system("$cmd6");




print "\n\n######## shp by session ###############\n";
    my $cmd5="
get_portfolioShp_bySession_new.pl pls.txt
";
  # print "$cmd5\n";
   system("$cmd5");



print "\n\n######## corr by session ###############\n";
    my $cmd6="
cp /tmp/y_x.txt tmp_y_x.txt
get_corr_by_session_R.pl tmp_y_x.txt 2 1 3 4
";
  # print "$cmd6\n";
   system("$cmd6");


print "\n\n######## shp by year, fcst= $indName ###############\n";
    my $cmd2="
get_portfolioShp_byYear.pl pls.txt
";
# print "$cmd2\n";
   system("$cmd2");

print "\n\n######## shp by symbol, fcst= $indName ###############\n";
    my $cmd3="
get_portfolioShp_bySym.pl pls.txt
";
  # print "$cmd3\n";
   system("$cmd3");




#### This section is for 3p plots

# get the data
    my $xcmd="
#pnl
cp /tmp/y_x.txt /tmp/pnls.txt
# for this version, pnlAdj same as pnls
cp /tmp/pnls.txt /tmp/pnlsAdj.txt
#price
$plotFutCmd $sym 0
cat /tmp/c.txt > /tmp/price.txt
#pos
# for this version, just use fcst as pos
cat /tmp/pnls.txt|gawk '{if(NR==1){print \"DATE tgtPos MIN_MULT tgtPosAdj\"}else{print \$1,\$4,\"1\",\$4}}' >/tmp/pos.txt
#combine
combine_match1na_all.pl /tmp/price.txt /tmp/pos.txt /tmp/pnlsAdj.txt |fgrep -v \" NA \"|mygetcols.pl 1 3 7 12|myCum.pl 4 >/tmp/combo_3p
datesXmgr.pl /tmp/combo_3p 1 >/tmp/forplot_3p";
   # print "$xcmd\n";
    system("$xcmd");

 #get subtitle str
 my $xcmd2="
##check stats
cat /tmp/forplot_3p |gawk '{if(\$4>0){print \"long\",\$0}else{if(\$4<0){print \"short\",\$0}else{print \"zeroPos\",\$0}}}' >/tmp/bb
getMeanStdByDate.pl /tmp/bb 0 1 6|gawk '{print \$0,\$4*\$6 }'|mygetcols.pl 1 6 7|myFloatRoundingInPlace.pl 0 3 3|myAddHeader.sh \"Position numDays totalPnl\"|myFormatAuto.pl 1 >/tmp/cc
#get subtitle str
cat /tmp/cc|gawk '{print \$3\"\\\\/\"\$2}'|myTranspose.pl|myrmcols.pl 1|gawk '{print \" $indName pnls\\\\/days: long= \"\$1\"   short= \"\$2\"   noPos=\"\$3}'";
 my $res2=`$xcmd2`;
 chomp($res2);
 my $substr=$res2;

#print "substr=$substr\n";

my $xcmd3="
## xmgr part
cat /home/jgeng/bin/batch_3pplot.txt | sed s/WWW/$sym$closeStr/  | sed s/START/$startDate/| sed s/END/$endDate/ | sed s/SUBSTR/\"$substr\"/ > /tmp/batch_3pplot.txt
xmgrByDate  -batch /tmp/batch_3pplot.txt &
";

#    print "$xcmd3\n";
    system("$xcmd3");






__END__

# by asset
cat MADIFScls.txt|mygetcols.pl 1 2 3 4|myAssetSession_four_aseets.pl 1 1|egrep -E -e"DATE|Coalsteel"|mygetcols.pl 1 2 3 4 >/tmp/subset.txt

#all
cat MADIFScls.txt|mygetcols.pl 1 2 3 4 >/tmp/subset.txt

#by syms
cat MADIFScls.txt|mygetcols.pl 1 2 3 4|egrep -w -E -e"DATE|ES|NQ" >/tmp/subset.txt
