#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Data::Dumper;
use POSIX qw(strftime);
use Math::Polygon;

use Geo::ShapeFile;
use Geo::ShapeFile::Point;
use Geo::Proj4;
use Geo::Gpx;

my $proj = Geo::Proj4->new(init => "epsg:2180") or die;

print STDERR "loading gminy\n";
my $shapefile = Geo::ShapeFile->new('gminy');

my $zgt; 
my $tzg;
open(my $mf, "zgid-teryt-map.txt") or die $!;
while (<$mf>) 
{
    my @m = split/:/;
    $tzg->{$m[1]} = $m[0];
    $zgt->{$m[0]} = $m[1];
}
close ($mf);

my $terytnaz;

for my $zgid (1..2479)
{
    next if exists $zgt->{$zgid};

    my $i = 1;

    my $h = `curl -s "http://zaliczgmine.pl/communes/view/$zgid"`;

    next unless $h =~ m/.*L.polygon\((.*?)\).bindLabel\('([^']+)'.*/s;
    my $label = $2;
    $h = $1;
    $h = eval $h;
    
    push(@$h,$h->[0]); # polygon must be closed
    my $poly = Math::Polygon->new(@$h);    
    my $pt = $poly->centroid;
    
    my $m;
    
    my @p = $proj->forward($pt->[0], $pt->[1]);
    
    my @f = $shapefile->shapes_in_area($p[0], $p[1], $p[0], $p[1]);

    my $ms = -1;
    for my $id (@f)
    {
        my $shape = $shapefile->get_shp_record($id);
        my $point = Geo::ShapeFile::Point->new(X => $p[0], Y => $p[1]);
        next unless $shape->contains_point($point);
    
        my %db = $shapefile->get_dbf_record($id);
#        printf "%4d %3d %6d %7s %s\n", $zgid, $i++, $id, $db{jpt_kod_je}, $db{jpt_nazwa_};
        $terytnaz->{$db{jpt_kod_je}} = $db{jpt_nazwa_};
        $ms = $db{jpt_kod_je};

        last;
    }

    open($mf, ">>zgid-teryt-map.txt") or die $!;
    my $status;
    if ($label eq $terytnaz->{$ms}) { $status = 'OK' }
    elsif ($label =~ m/^$terytnaz->{$ms}/) { $status = 'BG'; }
    else { $status = '--'; }

    print STDERR "$status $zgid ($label) -> $ms ($terytnaz->{$ms})\n";
    print $mf "$zgid:$ms:$status:$label:$terytnaz->{$ms}\n";
    close($mf);
}
