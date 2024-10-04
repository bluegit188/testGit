#!/usr/bin/perl

use strict;

($#ARGV+2)==2 || die 
"Usage: auto_batch.pl file.txt\n";


# open file an dput column specified into a hash
my $filename=$ARGV[0];
open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";



my @line; 
while(<INFILE>)
{
    #chomp the new line at the end
    chomp($_);
    @line =split;


    my $sym = $line[0];
    $sym=~s/^\s+//; # remove leading spaces
    $sym=~s/\s+$//; # remove trailing spaces


    print "$sym\n";

    my $cmd="
time portara_plot_tick_avgCumVol_24Hr_easy.pl $sym 20140301 20150301 1
time portara_get_open_close_times_from1min24h.pl $sym

";
    print "$cmd\n";
    system("$cmd");


}
close(INFILE);


__END__


 my $cmd="wc test.txt| head -1 |mygetcols.pl 1";
 my $res=`$cmd`;
 chomp($res);

