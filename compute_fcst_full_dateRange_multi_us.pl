#!/usr/bin/perl

use File::Basename;
use strict;


my $DEBUG=0;

($#ARGV+2)==5 || die
"Usage: compute_fcst_full_dateRange_multi_us.pl list_sym startDate endDate N(8)
       Compute historical fcsts_full (all inds) for a given symbol list +dateRange
       It will process one symbol at a time;
       for each symbol, the dates are broken into N batches,
       and each batch is one thread.\n";

my $filename=$ARGV[0]; # portara text file


my $startDate=$ARGV[1];
my $endDate=$ARGV[2];
my $N=$ARGV[3];


# create blocks
my $NFold=$N;


open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";

my @line; 
# loop each symbol
while(<INFILE>)
{
    #chomp the new line at the end
    chomp($_);
    @line =split;

    my $sym=$line[0];



    my $cmd1="
      compute_fcst_full_dateRange_singleSymManager_us.pl $sym $startDate $endDate $N";

    print "$cmd1\n";
    system("$cmd1");
}
close(INFILE);









__END__


my $pid = open my $fh,"-|","sleep 3";
print waitpid(28779,0); # Some other process
print waitpid($pid,0);


--cmd:
time cat /mnt/wbox1/portara/Futures/Continuous\ Contracts/Intraday\ Database/1\ Minute\ 24Hr/EU.001 | sed s/,/\ /g|fgrep -v DATE|gawk '{if($1>=20150115 && $1<=20150115){print $1,$2,$7}}' > /tmp/tmpVol.txt
# 35 sec
cat /tmp/tmpVol.txt|myPortaraAddMissingMinutes.pl 1 2 3|mygetcols.pl 1 2 6 >/tmp/tmpVolNorm.txt 
timesXmgr.pl /tmp/tmpVolNorm.txt 2 0|mygetcols.pl 1 4 2 3  >/tmp/tmpForplot.txt
xmgrByTime /tmp/tmpForplot.txt&


