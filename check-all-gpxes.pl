#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);
use FindBin qw($Bin);

my $source_dir = "gpx";
my $dest_dir = "reports";
 
while (<$source_dir/*.gpx>)
{
    my $sn = $_;
    s/.gpx/.txt/;
    s/^$source_dir/$dest_dir/;
    my $dn = $_;
    
    next if -f $dn and -s $dn;

    print STDERR "processing: $sn -> $dn\n";

    open(my $sf, "-|", "$Bin/gpx2gminy.pl", $sn) or die $!;
    open(my $df, ">", $dn) or die $!;

    while (<$sf>) 
    { 
        print $df $_;
        print STDERR $_;
    }

    close($sf);
    close($df);
}
