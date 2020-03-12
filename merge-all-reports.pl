#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);
use FindBin qw($Bin);

my $source_dir = "reports";
my $dest = "all-reports.txt";

my $h;
my $n;
my $sfn;
while (<$source_dir/*.txt>)
{
    my $sn = $_;

    print STDERR "processing: $sn\n";

    open(my $sf, $sn) or die $!;

    while (<$sf>)
    {
        chomp;

#   6 2294 827177 3021021 2018-07-05 Puszczykowo
        next unless /^\s*\d+\s+(\d+)\s+\d+\s+\d+\s+(\S+)\s+(.*)/;
        my $zgid = $1;
        my $zgdate = $2;
        my $zgname = $3;

        next if exists $h->{$zgid} && $h->{$zgid} lt $zgdate; # exists and older

        $h->{$zgid} = $zgdate;
        $n->{$zgid} = $zgname;
        $sn =~ s/\.txt/.gpx/;
        $sfn->{$zgid} = $sn;
    }
    close($sf);

    open(my $df, ">", $dest) or die $!;
    for my $zgid (sort { $h->{$a} cmp $h->{$b} } keys %$h)
    {
        print $df "$zgid $h->{$zgid} $sfn->{$zgid} # $n->{$zgid}\n";
    }
    close($df);
}
