#!/usr/bin/perl

use strict;

($#ARGV+2 >= 2)|| die "Usage: make_class.pl Class_name
       Automatcially create Class_name.h and Class_name.cpp files\n";


my $cname=$ARGV[0];
my $cnameUC=uc($cname);

my $cppfile="$cname.cpp";
my $hfile="$cname.h";

###  .h file

open(OUT1,">$hfile") ||die "Cannot open $hfile: $!\n";

print OUT1 "#ifndef JUNFEI_","$cnameUC","_H\n";
print OUT1 "#define JUNFEI_","$cnameUC","_H\n";
print OUT1 "\n";

print OUT1 "#include <vector>","\n";
print OUT1 "#include <string>","\n";
print OUT1 "#include <cmath>","\n";
print OUT1 "#include <map>","\n"; 
print OUT1 "#include <iostream>","\n";
print OUT1 "#include <iomanip>","\n";
print OUT1 "#include <fstream>","\n";
print OUT1 "#include <iostream>","\n";
print OUT1 "#include <cstdio>","\n";
print OUT1 "#include <cstdlib>","\n";
print OUT1 "#include <algorithm>" ,"\n";
print OUT1 "#include <cassert>" ,"\n";


print OUT1 "\n\n";
print OUT1 "using namespace std;" ,"\n";
print OUT1 "\n";


my $date=`date '+%Y%m%d'`;
chomp($date);
my $temp="/* $hfile
 *
 * This class is to ...
 * 
 * \@Junfei Geng, $date
 * */



class $cname
{
  public:
    $cname();                             // constructor
    ~$cname();                            // destructor

    
    int  size() const{return mySize;}        // return size
    void  print();

  private:

    int    mySize;                      // number of records
 

};

\#endif

 ";


print OUT1 "$temp\n";


close(OUT1);




### .cpp file

open(OUT2,">$cppfile") ||die "Cannot open $cppfile: $!\n";

print OUT2 "\#include \"$cname.h\"\n";
print OUT2 "\n";                    
print OUT2 "\n";                    

my $temp2="
$cname\:\:$cname()
{
    mySize=0;
}


$cname\:\:~$cname()
{
   // to do
}

void $cname\:\:print()
{
    // to do
}
";

print OUT2 "$temp2\n";

close(OUT2);


