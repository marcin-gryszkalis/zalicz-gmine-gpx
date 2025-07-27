#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);
use FindBin qw($Bin);
use Parallel::Loops;

my $source_dir = "gpx";
my $dest_dir = "reports";

my $maxProcs = 8;
my $pl = Parallel::Loops->new($maxProcs);

my %returnValues;

$pl->share( \%returnValues );
my @gpxs;

for (<$source_dir/*.gpx>)
{
    my $sn = $_;
    s/.gpx/.txt/;
    s/^$source_dir/$dest_dir/;
    my $dn = $_;

    next if -f $dn and -s $dn;

    push(@gpxs, $sn)
}

$pl->foreach(\@gpxs, sub {

    my $sn = $_;
    s/.gpx/.txt/;
    s/^$source_dir/$dest_dir/;
    my $dn = $_;

    return if -f $dn and -s $dn;

    print STDERR "processing: $sn -> $dn\n";

    my $res;

    open(my $sf, "-|", "$Bin/gpx2gminy.pl", $sn) or die $!;
    open(my $df, ">", $dn) or die $!;

    while (<$sf>)
    {
        print $df $_;
        $res .= $_;
    }

    close($sf);
    close($df);

    print STDERR $res;

#    $returnValues{$_} = sqrt($_);
});


