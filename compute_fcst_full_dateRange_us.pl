#!/usr/bin/perl

use strict;

($#ARGV+2) ==4 || die
"Usage: compute_fcst_full_dateRange_us.pl  SYM(ES) 20220401 20220430
       Compute historical fcsts_full (all inds) for a given symbol +dateRange (single thread)
       \n";



my $sym=$ARGV[0];

my $dir="/home/jgeng/RawData/portara/JunfCC/CCFixRTH/";
my $filename="$dir"."$sym".".txt";
#open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";

my $startDate=$ARGV[1];
my $endDate=$ARGV[2];

#1). reads in fixed RTH file
my @allRows=read_file($filename); # note, no header for file
#print join("\n",@allRows),"\n";

my @OOs;
#regular std
#0=today, 1=yest, 2=day before yest
my @line;
foreach my $i (0..$#allRows)
{

    my $lineStr=$allRows[$i];

    @line =split(' ',$lineStr); #' ' is correct to remove one or more white spaces

    #tc=trade counts
    my($date,$open,$high,$low,$close,$tc,$vol,$oi,$sym,$ym,$spd,$cumSpd)=@line;

    if($date< $startDate || $date > $endDate)
    {
      next;
    }

    # adjust cumSpd
    # $open-=$cumSpd;$high-=$cumSpd;$low-=$cumSpd;$close-=$cumSpd;

    #my $cmd="bt1_fcst_prod_v96_full $date $sym $open $spd 0 > Logs/bySym/fcst_log.txt.$date.$sym &";
    my $cmd="
bt1_fcst_prod_v96_full $date $sym $open $spd 0 > Logs/bySym/fcst_log.txt.$date.$sym
";

    #print "$date $sym open=$open spd=$spd\n";
    print "cmd= $cmd\n";
    system("$cmd");

}






sub read_file
# input: filename
# return: ref to array of rows
{
   my ($filename)=@_;

   open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";
   my @allRows=(<INFILE>);
   chomp@allRows; # remove new lines at each row
   close(INFILE);
   return @allRows;
}


sub min
#input: x1, x2
# output: smaller one
{
  my ($x1,$x2) = @_;

  if($x1<=$x2)
  {
    return $x1;
  }

  return $x2;
}

sub max
#input: x1, x2
# output: bigger one
{
  my ($x1,$x2) = @_;

  if($x1 >= $x2)
  {
    return $x1;
  }

  return $x2;
}

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


sub get_std
#one pass
{
   my ($refX ) = @_;
   my $count=$#$refX+1;
   if($count<1){return 0;}

   #print "count=$count\n";
   my $xsum=0;
   my $x2sum=0;
   foreach my $x (@$refX)
   {
     $xsum+=$x;
     $x2sum+=($x*$x);
   }
   my $var=0; # count=1
   if($count >1)
   {
     $var=($x2sum-$xsum*$xsum/$count)/($count-1);
   }
   return sqrt($var);
}


__END__


#modify array in place
my @a=(2,3,4,5);
foreach(@a)
{ $_ -= 1; }
print "a=",join(" ",@a),"\n";

