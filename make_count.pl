#!/usr/bin/perl

use strict;

($#ARGV+2) >=3 || die 
"Usage: make_count.pl n1 n2
       Output intergers from n1 to n2 (inclusive)\n";



my $n1=$ARGV[0];
my $n2=$ARGV[1];


foreach my $i ($n1..$n2)
{
  print "$i\n";
}
