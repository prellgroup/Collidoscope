#This script will help “clean up” pdb files that contain split #occupancies and heteroatoms as well as delete charges, because these can #otherwise cause problems in Collidoscope.
#To use it, type “pdbcleaner.pl inputfilepath outputfilepath” at the #command line or terminal prompt.


#!/usr/bin/perl -w

use strict;
use warnings;

sub  trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

my $inputfile = $ARGV[0];
my $outputfile = $ARGV[1];

open(my $fi, '<', $inputfile) or die "Could not open file '$inputfile' $!";
open(my $fo, '>', $outputfile) or die "Could not open file '$outputfile' $!";

#This loop looks at each line that starts with “ATOM” and copies it
#to the outputfile, trimming off anything after column 65 (i.e.,
#it trims off any charges that were in the input file.

while(my $line = <$fi>) {
    my @chars = split("", $line);
    if ($line =~ /^ATOM/) {
	my $atmname = trim(join('', @chars[12..15]));
        my @atmletters = split("", $atmname);
        my $atm = @atmletters[0];
        my $row = join('', @chars[0..65]);
	print $fo "$row           $atm  \n";
        }
    }

print $fo "END";

close $fi;
close $fo;

