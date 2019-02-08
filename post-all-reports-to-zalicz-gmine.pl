#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);
use FindBin qw($Bin);

use LWP::UserAgent;
use Term::ReadKey;

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

print STDERR Dumper $h;

my $ua = LWP::UserAgent->new(requests_redirectable => ['GET', 'POST']);
$ua->cookie_jar({}); # temp jar

my $r = $ua->get('http://zaliczgmine.pl/');
die $r->status_line unless $r->is_success;

ReadMode 'normal'; 
print "zaliczgmine.pl username: ";
my $zguser = ReadLine 0;
chomp $zguser;
print "\n";
ReadMode 'noecho';
print "zaliczgmine.pl password: ";
my $zgpass = ReadLine 0;
chomp $zgpass;
print "\n";
ReadMode 'normal'; 

my $p;

$p->{'data[User][username]'} = $zguser;
$p->{'data[User][password]'} = $zgpass;
$r = $ua->post('http://zaliczgmine.pl/users/login', $p);
die $r->status_line unless $r->is_success;

# print STDERR $r->decoded_content
for my $d (keys %$h)
{
    $p = ();
    $p->{'data[UsersCommune][sender]'} = 'map'; 

    my @dt = split/-/,$d;
#    $p->{'data[UsersCommune][date][year]'} = $dt[0];
#    $p->{'data[UsersCommune][date][month]'} = $dt[1];
#    $p->{'data[UsersCommune][date][day]'} = $dt[2];
    $p->{'data[UsersCommune][commune_add_date][year]'} = $dt[0];
    $p->{'data[UsersCommune][commune_add_date][month]'} = $dt[1];
    $p->{'data[UsersCommune][commune_add_date][day]'} = $dt[2];


    for my $g (@{$h->{$d}})
    {
#        $p->{'data[UsersCommune][commune_id]'} = $g;
        $p->{'data[UsersCommune]['.$g.']'} = '1';
}
     print Dumper $p;
#        $ua->post('http://zaliczgmine.pl/users_communes/add', $p);
        $ua->post('http://zaliczgmine.pl/users_communes/addmulti', $p);
        die $r->status_line unless $r->is_success;

# print STDERR $r->decoded_content;
# exit;

#    }

}

