#!/usr/bin/perl

use strict;

($#ARGV+2)==2 || die 
"Usage: get_portfolioShp_byDOW.pl pls.txt(header)
       Compute pcShp and portShp by year
       input: DATE SYM PL\n";


# open file an dput column specified into a hash
my $filename=$ARGV[0];

    my $cmd1="
 #pcShp by DOW
 cat $filename |fgrep -v DATE|myDayOfWeek.pl 0 1 >tmp_pls_dow.txt
 getMeanStdByDate.pl tmp_pls_dow.txt 0 4 3|mygetcols.pl 1 4 5 6|myFloatRoundingInPlace.pl 0 2 7|myFloatRoundingInPlace.pl 0 3 7 |gawk '{ if(\$3!=0){print \$1,\$2,\$3,\$2/\$3,\$2/\$3*sqrt(252),\$4}else{print \$1,\$2,\$3,\"0\",0, \$4}}'  >tmp_pcShp_dow.txt
 #port shp by dow
 getMeanStdByDate.pl $filename 1 1 3|gawk '{print \$1,\$4*\$6,\$6}' |myDayOfWeek.pl 0  1 >tmp_ppls_dow.txt
getMeanStdByDate.pl tmp_ppls_dow.txt 0 4 2 |mygetcols.pl 1 4 5 6|myFloatRoundingInPlace.pl 0 2 7|myFloatRoundingInPlace.pl 0 3 7  |gawk '{ if(\$3!=0){print \$1,\$2*252,\$3*sqrt(252),\$2/\$3,\$2/\$3*sqrt(252),\$4 }else{print \$1,\$2*252,\$3*sqrt(252),\"0\",0,\$4}}' >tmp_portShp_dow.txt
 #combine
combine_match1.pl tmp_pcShp_dow.txt tmp_portShp_dow.txt|myrmcols.pl 7|gawk '{if(\$5!=0){print \$0, \$10/\$5}else{print \$0,0}}'|myAddHeader.sh \"DOW pl.mean pl.std pcShp pcShp.pa nObs ppl.mean.pa ppl.std.pa portShp portShp.pa nDays divNum\"|myFormatAuto.pl 1
";

# print "$cmd1\n";
   system("$cmd1");

