#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);

use Geo::ShapeFile;
use Geo::ShapeFile::Point;
use Geo::Gpx;

# min time between checked points
my $timedelta = 60;

# no buffering
select(STDOUT); $| = 1;

print STDERR "loading gminy shapes\n";
my $shapefile = Geo::ShapeFile->new('shp/gminy');
printf STDERR "shapes: %d\n", $shapefile->shapes();

my $gpxfn = $ARGV[0] // die "specify gpx";
print STDERR "loading gpx: $gpxfn\n";
my $gpx = Geo::Gpx->new(input => $gpxfn);

my $gpxname = $gpx->name();
if (!defined $gpxname)
{
    $gpxname = $gpxfn;
    $gpxname =~ s{.*/}{};
    $gpxname =~ s{\.gpx}{}i;
}

printf STDERR "tracing: %s\n", $gpxname;

printf "%3s %-4s %-10s %s\n", '#', 'zgid', 'date', 'nazwa';
my $visited;
my $prevtime = 0;
my $i = 1;
my $iter = $gpx->iterate_trackpoints();
while (my $pt = $iter->())
{
    next if $pt->{time} - $prevtime < $timedelta;
    $prevtime = $pt->{time};

    my @p = ($pt->{lat}, $pt->{lon});

    my @f = $shapefile->shapes_in_area($p[0], $p[1], $p[0], $p[1]);

    for my $id (@f)
    {
        next if exists $visited->{$id};

        my $shape = $shapefile->get_shp_record($id);
        my $point = Geo::ShapeFile::Point->new(X => $p[0], Y => $p[1]);
        next unless $shape->contains_point($point);

        my $d = POSIX::strftime("%F", localtime $pt->{time});
        my %db = $shapefile->get_dbf_record($id);

        my $zgid = $db{ID};
        printf "%3d %4s %10s %s\n", $i++, $zgid, $d, $db{NAME};
        $visited->{$id} = 1;
    }
}

