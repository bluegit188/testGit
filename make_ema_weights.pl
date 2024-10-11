#!/usr/bin/perl

use strict;

($#ARGV+2) ==3 || die
"Usage: make_ema_weights a numLags
       Ema coef: a**0, a**1, a**2,...
       lag ema emaNorm(ie, sum up to one)\n";



my $a=$ARGV[0];
my $numLags=$ARGV[1];

my $sum=0;
foreach my $i (1..$numLags)
{
   my $w=$a**($i-1);
   $sum+=$w;
}

#print "sum=$sum\n";
# in theory, if many lags, sum=1/(1-a)


foreach my $i (1..$numLags)
{
   my $w=$a**($i-1);
   printf "$i %.7f %.7f\n",$w,$w/$sum;
}
