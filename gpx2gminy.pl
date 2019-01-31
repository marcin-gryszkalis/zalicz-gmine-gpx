#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

use Geo::ShapeFile;
use Geo::Proj4;
use Geo::Gpx;


my $timedelta = 10 * 60;

my $proj = Geo::Proj4->new(init => "epsg:2180") or die;

print STDERR "loading gminy\n";
my $shapefile = Geo::ShapeFile->new('gminy');

print STDERR "loading gpx\n";
open(my $gpxf, "<", $ARGV[0] // die "specify gpx" ) or die $!;
my $gpx = Geo::Gpx->new(input => $gpxf);

print STDERR "tracing\n";

my $visited;
my $prevtime = 0;
my $iter = $gpx->iterate_trackpoints();
while (my $pt = $iter->()) 
{

    next if $pt->{time} - $prevtime < $timedelta;
    $prevtime = $pt->{time};

    my @p = $proj->forward( $pt->{lat}, $pt->{lon});
    # print STDERR Dumper \@p;

    my @f = $shapefile->shapes_in_area ($p[0], $p[1], $p[0], $p[1]);

    for my $id (@f)
    {
        next if exists $visited->{$id};
  
        my %db = $shapefile->get_dbf_record($id);
        printf "%6d %8s %8s %8s %s\n", $id, $db{jpt_opis}, $db{jpt_kod_je}, $db{jpt_kj_i01}, $db{jpt_nazwa_};
        print "$pt->{lat} $pt->{lon} :: $p[0] $p[1]\n";
        $visited->{$id} = 1;
    }
}

