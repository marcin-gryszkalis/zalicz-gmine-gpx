#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Geo::Proj4;

my $proj = Geo::Proj4->new(proj => "merc",
   ellps => "clrk66", lon_0 => -96)
     or die "parameter error: ".Geo::Proj4->error. "\n";
 
printf "libVersion: %s\n", $proj->libVersion();
printf "Geo::Proj4: %s\n", $Geo::Proj4::VERSION;

$proj = Geo::Proj4->new("+proj=merc +ellps=clrk66 +lon_0=-96")
     or die "parameter error: ".Geo::Proj4->error. "\n";
 
$proj = Geo::Proj4->new(init => "epsg:28992");
 
my ($x, $y) = $proj->forward(-10,10);
print Dumper $x,$y;
 
$proj = Geo::Proj4->new(init => "epsg:26985") or die;
my ($lat, $lon) = $proj->inverse(401717.80, 130013.88);
print Dumper $lat,$lon;
 

