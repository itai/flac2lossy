#!/usr/bin/perl
# File:         single_flac_to_mp3.pl
# Author:       Itai Fiat <itai.fiat@gmail.com>
# Revision:     2009-05-04
#
# Converts a single FLAC file to MP3, preserving tags. Appears to support
# Unicode.
# 
# Requires perl, flac, lame.
# Also requires CPAN modules Audio::FLAC::Header and IPC::Run. If you're using
# Ubuntu, these can be had by installing the following packages:
#   libaudio-flac-header-perl
#   libipc-run-perl

use warnings;
use strict;
use Audio::FLAC::Header;
use IPC::Run qw(run);

($#ARGV+1==2) || die("Usage: $0 <source FLAC file> <dest. MP3 file>\n");

my $flac_file=$ARGV[0];
my $mp3_file=$ARGV[1];

my $flac_header = Audio::FLAC::Header->new($flac_file);
my $tags = $flac_header->tags();
my $artist = $tags->{ARTIST};
my $album = $tags->{ALBUM};
my $title = $tags->{TITLE};
my $genre = $tags->{GENRE};
my $track_number = $tags->{TRACKNUMBER};
my $total_tracks = $tags->{TRACKTOTAL};
my $comment = $tags->{COMMENT};
my $year;
$year = $1 if ($tags->{DATE}=~/(\d{4})-\d{2}-\d{2}/);

my @lame_id3;
push(@lame_id3, "--tt", $title) if $title;
push(@lame_id3, "--ta", $artist) if $artist;
push(@lame_id3, "--tl", $album) if $album;
push(@lame_id3, "--ty", $year) if $year;
push(@lame_id3, "--tc", $comment) if $comment;
push(@lame_id3, "--tn", $total_tracks?"$track_number/$total_tracks":$track_number) if $track_number;
push(@lame_id3, "--gr", "$genre") if $genre;

my @flac_options = ('-c', '-d', $flac_file);
my @lame_options = ('-m', 'j', '-q', '0', '--vbr-new', '-V', '0', '-s', '44.1', "-", $mp3_file);

my @flac_command = ('flac', @flac_options);
my @lame_command = ('lame', @lame_options, @lame_id3);
run \@flac_command, "|", \@lame_command;

