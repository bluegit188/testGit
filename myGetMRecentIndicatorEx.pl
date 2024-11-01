#!/usr/bin/perl

use strict;
use Date::Calc qw(Add_Delta_Days);


 ($#ARGV+2)==3  || die 
"Usage: myGetMRecentIndicatorEx.pl colDate colX
       Input must have header
       Given a dated indicator(could be partial dates), generate a complete indicator file with full calendar dates
       The date range is from the earliest date in data to today
       Output format: DATENew ...indLine...\n";


my $colDate=$ARGV[0];
my $colX=$ARGV[1];


my  $isHeader=1; # required

my @allLines;
my @datesX;
my @Xs;
my @line;
my $count=0;

while(<STDIN>)
{

    #chomp the new line at the end
    chomp($_);
    $count++;
    my $str=$_;

    if($count==1 && $isHeader==1)
    {
      print "DATENew $str\n";
      next;
    }


    @line =split;
    my $x = $line[$colX-1];
    my $date = $line[$colDate-1];

    push(@Xs,$x);
    push(@datesX,$date);
    push(@allLines,$str);

}

# get first date and last date
my $startDate=$datesX[0];
my $endDate=get_today_date();
#print "startDate=$startDate endDate=$endDate\n";

my @datesVec;
getDatesVec(\@datesVec,$startDate,$endDate);
#print join("\n",@datesVec),"\n";


## now, loop each day in datesVec, and find most recent available indicator value
my $startLoc=-1; # unknown start loc
foreach my $i (0..$#datesVec)
{

   my $curDate=$datesVec[$i]; # cur date under consideration

   my $loc=-1;

   if($curDate <= $datesX[0]) # ignore if date is earlier than first ind Date
   {
           next;
   }

   #print "$sym $date0 startLoc=$startLoc\n";
   $loc=fine_loc_most_recent_date_ex_fast(\@datesX,$curDate,$startLoc);
   #print "loc=$loc\n";

   if($loc == -1)
   {
     print "what?\n"; # shouldn't reach here
   }
   else
   {
       my $indLine=$allLines[$loc];
       print "$curDate $indLine\n";


       $startLoc=$loc;

   }


}


sub getDatesVec()
# return a vector of dates,  inclusive
{
    my ($refVec,$startDate, $endDate) = @_;

    my $date=$startDate;

    while($date<= $endDate)
    {
       #print "$date\n";
       push(@$refVec,$date);

       my $YYYY=int($date/10000);
       my $MMDD=$date%10000;
       my $MM=int($MMDD/100);
       my $DD=$MMDD%100;
       #-- add 60 days to November 4th, 1985
       my ($newY, $newM, $newD) = Add_Delta_Days($YYYY, $MM, $DD,1);

       $date=sprintf("%4d%02d%02d",$newY,$newM,$newD);

    }
}

sub get_today_date
# get today date: 20151015
{
   #my ($x, $y) = @_;
   my $cmd="date \"+\%Y\%m\%d\"";
   my $res=`$cmd`;
   chomp($res);
   return $res;
}

sub fine_loc_most_recent_date_ex
# input: a dates vec, an user date=dateUser
# output: find the loc of a dateX, such that dateUser > dateX ( not dateUser >=dateX)
{

   my ($refDates,$dateUser) = @_;

   my $i;
   my $match_idx=-1;
   for ($i = 0; $i <= $#$refDates; $i++)
   {
      my $curDate=$$refDates[$i];
      my $nextDate;
      if($i == $#$refDates)
      {
         $nextDate=999999999; # set as a really big number
      }
      else
      {
         $nextDate =$$refDates[$i+1];
      }

      if ($dateUser > $curDate && $dateUser <= $nextDate)
      {
         $match_idx = $i;    # save the index
         last;
       }
   }

   return $match_idx;

}


sub fine_loc_most_recent_date_ex_fast
# this is a faster verion: but need to provide a startingLoc （ set to -1 if unknown)
# input: a dates vec, an user date=dateUser
# output: find the loc of a dateX, such that dateUser > dateX ( not dateUser >=dateX)
{

   my ($refDates,$dateUser, $startLoc) = @_;

   my $first=0;
   my $size= $#$refDates+1;
   if($startLoc >0 && $startLoc < $size  ) # must be a valid startLoc
   {
      $first=$startLoc;
   }

   my $i;
   my $match_idx=-1;
   for ($i = $first; $i < $size; $i++)
   {
      my $curDate=$$refDates[$i];
      my $nextDate;
      if($i >= $size-1)
      {
         $nextDate=999999999; # set as a really big number
      }
      else
      {
         $nextDate =$$refDates[$i+1];
      }

      if ($dateUser > $curDate && $dateUser <= $nextDate)
      {
         $match_idx = $i;    # save the index
         last;
       }
   }

   return $match_idx;

}

