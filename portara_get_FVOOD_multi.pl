#!/usr/bin/perl

use File::Basename;
use strict;


my $DEBUG=0;

($#ARGV+2)==2 || die
"Usage: portara_get_FVOOD_multi.pl list_sym.txt
       Compute forecasted volatility in USD
       FVOOD=FVOOL*fx=(FVOO*pv)*fx=FVOO*pv*fx
       Output: SYM DATE ooDif FVOO FVOOL FVOOD DENOM PV PVUSD fxRate fxDate\n";


#header
print "SYM DATE ooDif FVOO FVOOL FVOOD DENOM PV PVUSD fxRate fxDate\n";

my $filename=$ARGV[0]; # list_sym
open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";

my @line; 
while(<INFILE>)
{
    #chomp the new line at the end
    chomp($_);
    @line =split;

    my $sym=$line[0];
    my $cmd1="
    portara_get_FVOOD.pl $sym|fgrep -v DATE";
   # print "$cmd1\n";
    system("$cmd1");


}
close(INFILE);









__END__


--cmd:
time cat /mnt/wbox1/portara/Futures/Continuous\ Contracts/Intraday\ Database/1\ Minute\ 24Hr/EU.001 | sed s/,/\ /g|fgrep -v DATE|gawk '{if($1>=20150115 && $1<=20150115){print $1,$2,$7}}' > /tmp/tmpVol.txt
# 35 sec
cat /tmp/tmpVol.txt|myPortaraAddMissingMinutes.pl 1 2 3|mygetcols.pl 1 2 6 >/tmp/tmpVolNorm.txt 
timesXmgr.pl /tmp/tmpVolNorm.txt 2 0|mygetcols.pl 1 4 2 3  >/tmp/tmpForplot.txt
xmgrByTime /tmp/tmpForplot.txt&


