#!/usr/bin/perl

use File::Basename;
use strict;


my $DEBUG=0;

($#ARGV+2)==2 || die
"Usage: portara_get_YOC_GAPs_FOC_FGAPs_multi.pl list_sym
       Compute ooP1D and YOC/GAP rets
       Output: SYM DATE ooF1D FOC FGAP OO1 YOC GAP OO2 OC2 GAP2\n";

my $filename=$ARGV[0]; # portara text file


    my $cmd1="
#cmd:
#xvars
portara_get_ooRets_multi.pl $filename  0|mygetcols.pl 1 2 3 >/tmp/ooP1Ds.txt
portara_get_ooRets_multi.pl $filename 3|mygetcols.pl 1 2 3 >/tmp/OCs.txt
portara_get_ooRets_multi.pl $filename 2|mygetcols.pl 1 2 3 >/tmp/GAPs.txt
combine_match2.pl /tmp/ooP1Ds.txt /tmp/OCs.txt >/tmp/a1
combine_match2.pl /tmp/a1 /tmp/GAPs.txt >/tmp/a2
cat /tmp/a2|mygetcols.pl 1 2 3 6 9  >/tmp/tmp_xvars.txt
get_prev_row.pl /tmp/tmp_xvars.txt 1 1|mygetcols.pl 1 2 3 4 5 8 9 10|fgrep -v DATE|myAddHeader.sh \"SYM DATE OO1 YOC GAP OO2 OC2 GAP2\" > /tmp/tmp_xvars_2D.txt
#yvars:
#cmd:
portara_get_ooRets_multi.pl $filename  1|mygetcols.pl 1 2 3 >/tmp/ooF1Ds.txt
portara_get_ooRets_multi.pl $filename 16|mygetcols.pl 1 2 3 >/tmp/FOCs.txt
portara_get_ooRets_multi.pl $filename 17|mygetcols.pl 1 2 3 >/tmp/FGAPs.txt
combine_match2.pl /tmp/ooF1Ds.txt /tmp/FOCs.txt >/tmp/a1
combine_match2.pl /tmp/a1 /tmp/FGAPs.txt >/tmp/a2
cat /tmp/a2|mygetcols.pl 1 2 3 6 9 > /tmp/tmp_yvars
#combine
combine_match2.pl /tmp/tmp_yvars /tmp/tmp_xvars_2D.txt|myrmcols.pl 6 7
";
   # print "$cmd1\n";
    system("$cmd1");










__END__


--cmd:
time cat /mnt/wbox1/portara/Futures/Continuous\ Contracts/Intraday\ Database/1\ Minute\ 24Hr/EU.001 | sed s/,/\ /g|fgrep -v DATE|gawk '{if($1>=20150115 && $1<=20150115){print $1,$2,$7}}' > /tmp/tmpVol.txt
# 35 sec
cat /tmp/tmpVol.txt|myPortaraAddMissingMinutes.pl 1 2 3|mygetcols.pl 1 2 6 >/tmp/tmpVolNorm.txt 
timesXmgr.pl /tmp/tmpVolNorm.txt 2 0|mygetcols.pl 1 4 2 3  >/tmp/tmpForplot.txt
xmgrByTime /tmp/tmpForplot.txt&


