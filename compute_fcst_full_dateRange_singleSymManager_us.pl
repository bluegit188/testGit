#!/usr/bin/perl

use strict;
use Date::Calc qw(Add_Delta_Days);
use POSIX;
use threads;

($#ARGV+2) ==5 || die
"Usage: compute_fcst_full_dateRange_singleSymManager_us.pl SYM(ES) 20220401 20220430 N(8)
       Compute historical fcsts_full (all inds) for a given symbol+dateRange, use do it with multi-threads
       N= break dates into N blocks and each block is one process\n";


my $sym=$ARGV[0];

my $startDate=$ARGV[1];
my $endDate=$ARGV[2];

my $N=$ARGV[3];

#print "$sym starDate=$startDate endDate=$endDate\n";

# 1). get dates
my @datesVec=();
getWeekdaysVec(\@datesVec,$startDate,$endDate);
my $NDays=$#datesVec+1;

#print join("\n",@datesVec),"\n";



# create blocks
my $NFold=$N;
my $blockSize= ceil($NDays/$NFold);

print "$sym starDate=$startDate endDate=$endDate NFolds=$N NDays=$NDays, blockSize=$blockSize\n";

# loop folds
my  @threads=();
foreach my $i (1..$N)
{

    my $locStart=$blockSize*($i-1);
    if($locStart >$NDays-1)
    {
      next;
    }
    my $locEnd=$locStart+$blockSize-1;

    if($locEnd >=$NDays-1)
    {
       $locEnd=$NDays-1;
    }

    my $locStartDate=$datesVec[$locStart];
    my $locEndDate=$datesVec[$locEnd];

    #print "$sym start=$locStartDate end=$locEndDate\n";

   my $thrID = threads->create (
                                 sub {
                                        #contents
    my $cmd="compute_fcst_full_dateRange_us.pl $sym $locStartDate $locEndDate  > tmp_log.txt.$sym.$locStartDate.$locEndDate";
    print "cmd= $cmd\n";
    system("$cmd");

                                      }
                                );

    push(@threads,$thrID);
    #$thrID->join(); # uncommenting this will make it a sequential code, join will block next execution

}



# This tells the main program to keep running until all threads have finished.
foreach my $id (@threads)
{
     #print "thread=$id\n";
     my @ReturnData=$id->join(); # wait for thread to exit, and receive results if any
}




sub getWeekdaysVec()
# return a vector of dates, excluding weekends, inclusive
{
    my ($refVec,$startDate, $endDate) = @_;

    my $date=$startDate;

    while($date<= $endDate)
    {
       #print "$date\n";
       my $dow=get_day_of_week_fast($date);
       if($dow != 0 && $dow!=6) # non-weekends
       {
          push(@$refVec,$date);
       }

       my $YYYY=int($date/10000);
       my $MMDD=$date%10000;
       my $MM=int($MMDD/100);
       my $DD=$MMDD%100;
       #-- add 60 days to November 4th, 1985
       my ($newY, $newM, $newD) = Add_Delta_Days($YYYY, $MM, $DD,1);

       $date=sprintf("%4d%02d%02d",$newY,$newM,$newD);

    }
}


sub get_day_of_week_fast
#20150213
# return DOW: Sun=0, Mon=1, Tue=2, ...
{
   my ($date) = @_;

   my $YYYY=int($date/10000);
   my $MMDD=$date%10000;
   my $MM=int($MMDD/100);
   my $DD=$MMDD%100;

   my $k=$DD;
   my $m=$MM-2;
   if($m<=0){$m+=12;}

   # order of below 2 steps are important, otherwise, 2000 won't work.
   if($MM==1 || $MM==2)
   {
     $YYYY-=1;
   }
   my $Y=$YYYY%100; #

   my $C=int($YYYY/100);

   return ( $k+int(2.6*$m-0.2)-2*$C+$Y+int($Y/4)+int($C/4) )%7;

}



__END__

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

