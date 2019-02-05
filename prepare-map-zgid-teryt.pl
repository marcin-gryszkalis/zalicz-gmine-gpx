#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);

use Geo::ShapeFile;
use Geo::ShapeFile::Point;
use Geo::Proj4;
use Geo::Gpx;

use LWP::Simple;

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

for my $zgid (0..2479)
{
    next if exists $zgt->{$zgid};

    my $i = 1;
    my $h = get("http://zaliczgmine.pl/communes/view/$zgid");
    next unless $h =~ m/L.polygon/;
    $h =~ s/.*L.polygon\((.*?)\).*/$1/s;
    $h = eval $h;
      
    my $m;
    
    while (my $pt = pop @$h) 
    {
        my @p = $proj->forward($pt->[0], $pt->[1]);
    
        my @f = $shapefile->shapes_in_area($p[0], $p[1], $p[0], $p[1]);
    
        for my $id (@f)
        {
            my $shape = $shapefile->get_shp_record($id);
            my $point = Geo::ShapeFile::Point->new(X => $p[0], Y => $p[1]);
            next unless $shape->contains_point($point);
    
            my %db = $shapefile->get_dbf_record($id);
            printf "%4d %3d %6d %7s %s\n", $zgid, $i++, $id, $db{jpt_kod_je}, $db{jpt_nazwa_};
    
            $m->{$db{jpt_kod_je}}++;
        }
    
#         last if $i > 20;
    }

    my @mss = sort { $m->{$b} <=> $m->{$a} } keys %$m;
    # print STDERR Dumper $m;
    
    open(my $mf, ">>zgid-teryt-map.txt") or die $!;
    print "$zgid:$mss[0]\n";
    print $mf "$zgid:$mss[0]\n";
    close($mf);
}
