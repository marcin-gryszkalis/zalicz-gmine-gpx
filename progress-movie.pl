#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);
use FindBin qw($Bin);
use Config::INI::Reader;
use Imager;
use Imager::Fill;
use Geo::ShapeFile;
use Geo::ShapeFile::Point;
use Geo::ShapeFile::Shape;
use Geo::Proj4;
use Geo::Gpx;


   # 14  ffmpeg -r 10 -i '%09d.png' -c:v libx264 -vf fps=30 -pix_fmt yuv420p out.mp4
   # 15  mpv out.mp4

my $proj = Geo::Proj4->new(init => "epsg:2180") or die;

print STDERR "reding config\n";
die unless -f "$Bin/progress-movie.ini";
my $cfg = Config::INI::Reader->read_file("$Bin/progress-movie.ini");
my $mcfg = $cfg->{$cfg->{config}->{map}};

# prepare Imager:
# my $fill = Imager::Fill->new(hatch => "check4x4", combine => "normal");
my $fill = Imager::Fill->new(solid => $mcfg->{poly_color}, combine => "normal");
my $transparentfill = Imager::Fill->new(type => "opacity", other => $fill, opacity => 0.5);
my $font = Imager::Font->new(file=>"$Bin/progress-movie/southrnn.ttf");

print STDERR "loading gminy\n";
my $shapefile = Geo::ShapeFile->new('gminy');

my $shpmap;
foreach my $id (1..$shapefile->shapes())
{
    my %db = $shapefile->get_dbf_record($id);
    $shpmap->{$db{jpt_kod_je}} = $id;
}

print STDERR "loading zg-teryt map\n";
my $tzg;
my $zgt;
open(my $mf, "zgid-teryt-map.txt") or die $!;
while (<$mf>)
{
    chomp;
    my @m = split/:/;
    $tzg->{$m[1]} = $m[0];
    $zgt->{$m[0]} = $m[1];
}
close ($mf);

my $img = Imager->new;
$img->read(file => "progress-movie/".$mcfg->{file}) or die $img->errstr;

$img->string(x => $mcfg->{name_x}, y => $mcfg->{name_y},
             string => $cfg->{config}->{name},
             font => $font,
             size => $mcfg->{name_size},
             aa => 1,
             color => $mcfg->{name_color});


print STDERR "parsing all reports\n";

my $src = "all-reports.txt";

my $visited;
my $ii = 0;
my $h;
open(my $sf, $src) or die $!;
while (<$sf>)
{
    chomp;
    next unless /^(\d+)\s+(\S+)\s+(\S.*\.gpx)/;

    my $zgid = $1;
    my $zgdate = $2;
    my $gpxfn = "$Bin/gpx/$3";


    my $shape = $shapefile->get_shp_record($shpmap->{$zgt->{$zgid}});

    my @xs; # track
    my @ys;

    for my $parti (1 .. $shape->num_parts)
    {
        my $part = $shape->get_part($parti);
        my @xsar = ();
        my @ysar = ();
        for my $pt (@$part)
        {
            # my @p = $proj->forward($pt->{X}, $pt->{Y});
            my @p = ($pt->{X}, $pt->{Y});
    #        $p[0] = int($p[0]);
    #        $p[1] = int($p[1]);

            my $x = int(($p[0] / $mcfg->{x_div}) + $mcfg->{x_offset});
            my $y = int(($p[1] / $mcfg->{y_div}) + $mcfg->{y_offset});
    #        print "POLY $pt->{X} $pt->{Y} -- $p[0] $p[1] -- $x $y\n";

            push(@xsar, $x);
            push(@ysar, $y);
        }

        # $img->polygon(x => \@xs, y => \@ys, aa=>1, filled => 1, color => $mcfg->{poly_color});
        $img->polygon(x => \@xsar, y => \@ysar, aa=>1, filled => 1, fill => $transparentfill);
    }
    $img->polyline(x => \@xs, y => \@ys, aa=>1, color => $mcfg->{track_color}); # redraw track (to have it above poly)

    my @metrics = $font->bounding_box(string => $zgdate, size => $mcfg->{text_size}, canon => 1);
    my $w = $metrics[2];
    my $h = $metrics[3];
    # print "metrics: w($w) h($h)\n";
    # y - is baseline
    $img->box(color=> $mcfg->{text_bg}, filled=>1,
        xmin=> $mcfg->{text_x} - 4, ymin=> $mcfg->{text_y} - $h - 4,
        xmax=> $mcfg->{text_x} + $w + 4, ymax=> $mcfg->{text_y} + 4);

    $img->string(x => $mcfg->{text_x}, y => $mcfg->{text_y},
                 string => $zgdate,
                 font => $font,
                 size => $mcfg->{text_size},
                 aa => 1,
                 color => $mcfg->{text_color});


    my $dfn = sprintf "progress-movie-out/%09d.png", $ii;
    $img->write(file => $dfn) or die $img->errstr;

    $ii++;

    next if $visited->{$gpxfn};
    $visited->{$gpxfn} = 1;

    @xs = (); # new track, reset
    @ys = ();

    print STDERR "loading gpx ($gpxfn)\n";
    open(my $gpxf, "<", $gpxfn ) or die $!;
    my $gpx = Geo::Gpx->new(input => $gpxf);

    my $gpxname = $gpx->name();
    if (!defined $gpxname)
    {
        $gpxname = $gpxfn;
        $gpxname =~ s{.*/}{};
        $gpxname =~ s{\.gpx}{}i;
    }

    printf STDERR "tracing: %s\n", $gpxname;

    my $visited;
    my $prevtime = 0;
    my $i = 1;
    my $iter = $gpx->iterate_trackpoints();
    while (my $pt = $iter->())
    {
        next if $pt->{time} - $prevtime < $cfg->{config}->{timedelta};
        $prevtime = $pt->{time};

        my @p = $proj->forward($pt->{lat}, $pt->{lon});
        $p[0] = int($p[0]);
        $p[1] = int($p[1]);

        my $x = int(($p[0] / $mcfg->{x_div}) + $mcfg->{x_offset});
        my $y = int(($p[1] / $mcfg->{y_div}) + $mcfg->{y_offset});
        print "$pt->{lat} $pt->{lon} -- $p[0] $p[1] -- $x $y\n";
        push(@xs, $x);
        push(@ys, $y);

        # $img->setpixel(x => $x, y => $y, color => $mcfg->{track_color});

        # my @f = $shapefile->shapes_in_area ($p[0], $p[1], $p[0], $p[1]);

        # # print STDERR Dumper \@f;
        # for my $id (@f)
        # {
        #     next if exists $visited->{$id};

        #     my $shape = $shapefile->get_shp_record($id);
        #     my $point = Geo::ShapeFile::Point->new(X => $p[0], Y => $p[1]);
        #     next unless $shape->contains_point($point);

        #     my $d = POSIX::strftime("%F", localtime $pt->{time});
        #     my %db = $shapefile->get_dbf_record($id);
        #     my $zgid = $tzg->{$db{jpt_kod_je}} // '----';
        #     printf "%3d %4s %6s %7s %10s %s\n", $i++, $zgid, $db{jpt_opis}, $db{jpt_kod_je}, $d, $db{jpt_nazwa_};
        #     $visited->{$id} = 1;
        # }
    }

    $img->polyline(x => \@xs, y => \@ys, aa=>1, color => $mcfg->{track_color});

    $dfn = sprintf "progress-movie-out/%09d.png", $ii;
    $img->write(file => $dfn) or die $img->errstr;

    $ii++;
#    last if $ii > 10;
}


