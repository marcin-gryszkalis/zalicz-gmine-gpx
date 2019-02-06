#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Data::Dumper;
use POSIX qw(strftime);
use Math::Polygon;
use List::Util qw(shuffle);
use File::Slurp;

use Geo::ShapeFile;
use Geo::ShapeFile::Point;
use Geo::Proj4;
use Geo::Gpx;

my $proj = Geo::Proj4->new(init => "epsg:2180") or die;

print STDERR "loading gminy\n";
my $shapefile = Geo::ShapeFile->new('gminy');

my $zgt; 
my $zgtfull; 
my $tzg;
open(my $mf, "zgid-teryt-map.txt") or die $!;
while (<$mf>) 
{
    chomp;
    my @m = split/:/;
#    next if $m[2] eq '--'; # skip unmatched names
    $tzg->{$m[1]}++;
    $zgt->{$m[0]} = $m[1];
    $zgtfull->{$m[0]} = $_;
}
close ($mf);
for my $k (keys %$zgt)
{
    if ($tzg->{$zgt->{$k}} > 1)
    {
        delete $zgt->{$k}; # remove matched multiple times, we'll try again
        delete $zgtfull->{$k}; 
    }
}

my $terytnaz;

for my $zgid (1..2479)
{
    next if exists $zgt->{$zgid};
    next if $zgid == 603; # zielona gora, miejski (604 = wiejski)
    next if $zgid == 2432; # ostrowice, zlikwidowana
    my $i = 1;

    my $zfn = "cache/$zgid.html";
    if (! -f $zfn)
    {
        `curl -s -o "$zfn" "http://zaliczgmine.pl/communes/view/$zgid"`;
    }
    my $h = read_file($zfn);

    # next unless $h =~ m/.*polygon0 = L.polygon\((.*?)\).bindLabel\('([^']+)'.*/s;
    next unless $h =~ m/.*L.polygon\((.*?)\).bindLabel\('([^']+)'.*/s;
    my $label = $2;

    my @allp = ();
    for my $l (split/[\r\n]/, $h)
    {
        if ($l =~ m/.*L.polygon\(\[(.*?)\]\).*/)
        {
            push(@allp, $1);
        }
    }

    $h = "[".join(",", @allp)."]";


    $h = eval $h;

    push(@$h,$h->[0]); # polygon must be closed

    my $poly = Math::Polygon->new(@$h);
    $poly->beautify();

    my @pbb = $poly->bbox();
    my @pbb1 = $proj->forward(@pbb[0,1]);
    my @pbb2 = $proj->forward(@pbb[2,3]);
    @pbb = (@pbb1, @pbb2);

    # take random n points from border
    my @hh = shuffle(@$h);
    @hh = @hh[1..64];
    $h = \@hh;
    
    push(@$h, $poly->centroid); # fails in some cases (eg. Poronin)

    my $m = undef;

    while (my $pt = pop @$h) 
    {
        my @p = $proj->forward($pt->[0], $pt->[1]);
    
        my @f = $shapefile->shapes_in_area($p[0], $p[1], $p[0], $p[1]);
#    print STDERR "p($p[0], $p[1]) ";
        for my $id (@f)
        {
            my %db = $shapefile->get_dbf_record($id);
            print STDERR "$label: check($db{jpt_nazwa_} ($db{jpt_kod_je}))\n";
            next if exists $m->{$db{jpt_kod_je}};
            
            my $shape = $shapefile->get_shp_record($id); 
            my @cbb = $shape->bounds();
            
            # compare boundig boxes
            $m->{$db{jpt_kod_je}} = 
                abs($cbb[0] - $pbb[0]) + 
                abs($cbb[1] - $pbb[1]) + 
                abs($cbb[2] - $pbb[2]) + 
                abs($cbb[3] - $pbb[3]);
            
            $terytnaz->{$db{jpt_kod_je}} = $db{jpt_nazwa_};
            print STDERR "$label vs $db{jpt_nazwa_} ($db{jpt_kod_je}) =  $m->{$db{jpt_kod_je}}\n";
        }
    }
    
    my @mss = sort { $m->{$a} <=> $m->{$b} } keys %$m;
    my $ms = $mss[0];

    my $status;
    if ($label eq $terytnaz->{$ms}) { $status = 'OK' }
    elsif ($label =~ m/^$terytnaz->{$ms}/) { $status = 'BG'; }
    else { $status = '--'; }

    print STDERR "$status $zgid ($label) -> $ms ($terytnaz->{$ms})\n";

    $zgtfull->{$zgid} = "$zgid:$ms:$status:$label:$terytnaz->{$ms}";
    
    open($mf, ">zgid-teryt-map.txt") or die $!;
    for my $k (sort { $a <=> $b } keys %$zgtfull)
    {
        print $mf "$zgtfull->{$k}\n";
    }
    close($mf);
}
