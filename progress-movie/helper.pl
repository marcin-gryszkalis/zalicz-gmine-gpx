#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

# hel 54.5934 18.81235
# bialowieza 52.71348 23.95719
# bieszczady (prawo, dol) 49.01305 22.88744
# rysy 49.18312 20.09347
# trojstyk pl/de/cz 50.87136 14.84048
# plaza pl/de swinoujscie 53.922 14.26632

# | perl -e 'use Geo::Proj4; use Data::Dumper; $proj = Geo::Proj4->new(init => "epsg:2180"); while (<>) { m/([\d\.]+) ([\d\.]+)/; @a = $proj->forward($1,$2); print "$a[0] $a[1]\n" }'

my @a = qw/
487878.871026084 747747.49131381
834665.272920756 550176.540878599
784147.239505127 134558.849871638
579660.928396989 146753.005601486
207461.89654735 342072.278520761
189331.392767789 683432.470182345
/;

# polska.png
my @b = qw/
491 64
950 328
885 883
610 864
110 606
85 150
/;



my @xs = ();
my @ys = ();
my @xd = ();
my @yd = ();
while (my $nx = shift(@a))
{
    my $ny = shift @a;

    push(@xs, $nx);
    push(@ys, $ny);

    $nx = shift @b;
    $ny = shift @b;
    push(@xd, $nx);
    push(@yd, $ny);
}

my ($avdx, $avdy, $avox, $avoy);
my $c = 0;
for my $i (0..4)
{
    for my $j ($i+1..5)
    {
        my $x1 = $xs[$i];
        my $x2 = $xs[$j];
        my $xx1 = $xd[$i];
        my $xx2 = $xd[$j];

        my $y1 = $ys[$i];
        my $y2 = $ys[$j];
        my $yy1 = $yd[$i];
        my $yy2 = $yd[$j];

# y1 * dy + oy = Y1
# y2 * dy + oy = Y2
#
# (y1 - y2) * dy = Y1 - Y2;
#
# dy = (Y1 - Y2) / (y1 - y2);
# oy = Y1 - y1 * dy;


        my $dx = ($xx1 - $xx2) / ($x1 - $x2);
        my $ox = $xx1 - $x1 * $dx;

        my $dy = ($yy1 - $yy2) / ($y1 - $y2);
        my $oy = $yy1 - $y1 * $dy;

        $dx = 1/$dx;
        $dy = 1/$dy;
        print "dx = $dx ox = $ox | dy = $dy oy = $oy\n";

        $avdx += $dx;
        $avdy += $dy;
        $avox += $ox;
        $avoy += $oy;

        $c++;
   }
}

$avdx /= $c;
$avdy /= $c;
$avox /= $c;
$avoy /= $c;

print "AVERAGE:\n
x_div = %d
x_offset = %d

y_div = %d
y_offset = %d
", int $avdx, int $avox, int $avdy, int $avoy;

