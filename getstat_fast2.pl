#!/usr/bin/perl

use strict;

($#ARGV+2) ==4 || die
"Usage: getstat_fast.pl file.txt isHeader colX
       Output: xName min max mean std\n";

my $filename=$ARGV[0];
open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";

my $isHeader=$ARGV[1];

my $colX=$ARGV[2];


my $inf = 9**9**9;
my $neginf = -9**9**9;

my $min=$inf;
my $max=$neginf;
my $mean;
my $std;
my $xsum=0;
my $x2sum=0;

my @xs;
my $xName;
my @line;
my $count=0;
while(<INFILE>)
{
    chomp($_);
    @line =split;
    my $str=$_;

    $count++;
    if($count==1)
    {
      $xName=$line[$colX-1];
      next;
    }

    my $x=$line[$colX-1];


   #print "count=$count\n";
   $xsum+=$x;
   $x2sum+=($x*$x);
   if($x<$min){$min=$x;}
   if($x>$max){$max=$x;}

    #push(@xs,$x);
}
close(INFILE);

if($isHeader)
{
  $count-=1;
}

my $var=0; # if only one ob
if($count >1)
{ 
   $var=($x2sum-$xsum*$xsum/$count)/($count-1);
}
$std=sqrt($var);
$mean=$xsum/$count;

print "colName min max mean std count\n";
printf "$xName $min $max %.7f %.7f $count\n",$mean,$std;


__END__


my @y = 0..5;
print join(' ',@y),"\n";
my $y = pdl @y;
# a simple function
my $stdv = $y->stdv_unbiased ;
print "std=$stdv\n";

see here:

http://pdl-stats.sourceforge.net/Basic.htm#stdv
