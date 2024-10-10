#!/usr/bin/perl

use strict;
use Scalar::Util  qw(looks_like_number);

($#ARGV+2)==4 || die 
"Usage: myFloatRoundingInPlace.pl isHeader colX numDigits
       Make given column value rounded to n digits after decimal points
       Smart: elimiaate extra zeros, e.g, keep 42.3 vs 42.300000; default is to keep 6 digits after decimal\n";


my $isHeader=$ARGV[0];

my $colX=$ARGV[1];

my $N=$ARGV[2];


my $count=0;
my @line;
while(<STDIN>)
{
    #chomp the new line at the end
    chomp($_);
    $count++;
    my $str=$_;

    if($isHeader && $count==1)
    {
      print "$str\n";
      next;
    }


    @line =split;
    my $x = $line[$colX-1];

    # do roundoff on numbers, keep 6 digits after decimal
    if( looks_like_number( $x ))
    {
      #print "number: $x\n";
      $x= nearest_junf(-6, $x);
      #print "    rounded: $x\n";
    }
    #else
    #{
    #  print "Not number: $x\n";
    #}

    $line[$colX-1]=sprintf("%.${N}s",$x);

    print join(" ",@line),"\n";

}
close(INFILE);

sub nearest_junf()
# emulate Math::Round's nearest function, but elimiate extra zeros from $.4f notation
# input: -4, 3.56789 (max to 4th decimal digits
# output: 3.568
#
#more examples: -4
#0         -> 0
#0.1       -> 0.1
#0.11      -> 0.11
#0.111     -> 0.111
#0.1111111 -> 0.1111
{
    my ($pow10, $x) = @_;
    my $a = 10 ** $pow10;

    return (int($x / $a + (($x < 0) ? -0.5 : 0.5)) * $a);
}
