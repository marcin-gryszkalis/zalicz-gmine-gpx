#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Data::Dumper;
use File::Slurp;
use JSON;

use Geo::Shapefile::Writer;

my $shp = Geo::Shapefile::Writer->new('shp/gminy', 'POLYGON', 
[ 'id' => 'N', 8, 0 ],
[ 'name' => 'C', 100 ]
);

my %gidsh = map { $_ => 1 } (1..2479);

$gidsh{8740} = 1; # 2025 - szczawa
$gidsh{8741} = 1; # 2025 - grabówka

delete $gidsh{603}; # zielona gora, miejski
delete $gidsh{604}; # zielona gora, wiejski
$gidsh{4784} = 1; # zielona gora cala

delete $gidsh{2432}; # ostrowice, zlikwidowana

my $i = 1;
for my $zgid (keys %gidsh)
{

    printf STDERR "%5d %-5d ", $i, $zgid;
    my $zfn = "cache/$zgid.html";
    if (! -f $zfn)
    {
        `curl -L -s -o "$zfn" "https://zaliczgmine.pl/communes/view/$zgid"`;
        sleep(rand(30));
    }
    my @h = read_file($zfn);

    my $label = 'UNKNOWN';
    my $polys = 0;
    my @pax = ();

    for my $hh (@h)
    {
        if ($hh =~ m/L.polygon\((.*?)\).bindLabel\('([^']+)'/)
        {
            my $pp = $1;
            $label = $2;

            my $pa = from_json($pp);

            if (ref $pa->[0]->[0])
            {
                for my $ppa (@$pa)
                {
                    push(@pax, $ppa);
                }
            }
            else
            {
                push(@pax, $pa);
            }

            $polys++;
        }
    }

    die "no polys" unless $polys > 0;

    printf "polys:%d -- %s\n", $polys, $label;

    $shp->add_shape(\@pax, { name => $label, id => $zgid });
    $i++;
}

$shp->finalize();
