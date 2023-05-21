#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);
use FindBin qw($Bin);

use LWP::UserAgent;
use Term::ReadKey;
use IO::Socket::SSL;

my $src = "all-reports.txt";

my $h;
open(my $sf, $src) or die $!;
while (<$sf>)
{
    chomp;
    next unless /^(\d+)\s+(\S+)/;

    my $zgid = $1;
    my $zgdate = $2;
    push(@{$h->{$zgdate}}, $zgid);
}

# print STDERR Dumper $h;

my $ua = LWP::UserAgent->new(requests_redirectable => ['GET', 'POST']);
$ua->cookie_jar({}); # temp jar

$ua->ssl_opts(
    SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE,
    verify_hostname => 0
);

my $r = $ua->get('http://zaliczgmine.pl/');
die $r->status_line unless $r->is_success;

ReadMode 'normal'; 
print "zaliczgmine.pl username: ";
my $zguser = ReadLine 0;
chomp $zguser;
ReadMode 'noecho';
print "zaliczgmine.pl password: ";
my $zgpass = ReadLine 0;
chomp $zgpass;
ReadMode 'normal'; 
print "\n";

my $p;

$p->{'data[User][username]'} = $zguser;
$p->{'data[User][password]'} = $zgpass;
$r = $ua->post('http://zaliczgmine.pl/users/login', $p);
die $r->status_line unless $r->is_success;

my $html = $r->decoded_content;
die "cannot login" unless $html =~ /<title>(\S+)\s*\((\d+)/;
my $v1 = $2;

my $visited;
for my $l (split/[\r\n]/, $html)
{
    next unless $l =~ m{<td><a href="/communes/view/(\d+)};
    $visited->{$1} = 1;
}
my $v2 = scalar keys %$visited;

die "visited mismatch $v1 <> $v2" unless $v1 == $v2; 

print STDERR "user: $zguser ($v1)\n";

# print STDERR $r->decoded_content
for my $d (keys %$h)
{
    $p = ();
    $p->{'_method'} = 'POST';
    $p->{'data[UsersCommune][sender]'} = 'map'; 

    my @dt = split/-/,$d;
#    $p->{'data[UsersCommune][date][year]'} = $dt[0];
#    $p->{'data[UsersCommune][date][month]'} = $dt[1];
#    $p->{'data[UsersCommune][date][day]'} = $dt[2];
    $p->{'data[UsersCommune][commune_add_date][year]'} = $dt[0];
    $p->{'data[UsersCommune][commune_add_date][month]'} = $dt[1];
    $p->{'data[UsersCommune][commune_add_date][day]'} = $dt[2];

    my $c = 0;
    my @gs = ();
    my @gjson = ();
    for my $g (@{$h->{$d}})
    {
        next if exists $visited->{$g};
        $c++;
#        $p->{'data[UsersCommune][commune_id]'} = $g;
#        $p->{'data[UsersCommune]['.$g.']'} = '1';
        push(@gs, $g);
        push(@gjson, qq{"$g":"a"});
}
        
    $p->{'data[UsersCommune][updateData]'} = "{".join(",",@gjson)."}";
    next unless $c > 0;

#    print STDERR Dumper $p;
#    exit;

    print STDERR "processing: $d - ".join(",", @gs)."\n";

#        $ua->post('http://zaliczgmine.pl/users_communes/add', $p);
        $ua->post('http://zaliczgmine.pl/users_communes/addmulti', $p);
        die $r->status_line unless $r->is_success;

# print STDERR $r->decoded_content;
# exit;

#    }

}

# 2021-10-03

# _method: POST
# data[UsersCommune][sender]: map
# data[UsersCommune][updateData]: {"61":"a"}
# data[UsersCommune][commune_add_date][month]: 10
# data[UsersCommune][commune_add_date][day]: 01
# data[UsersCommune][commune_add_date][year]: 2021

