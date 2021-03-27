#!/bin/perl
#
# Git Upload...
#
# 1/ Replace all symbolic links with hard links
# 2/ upload files into a GIT repository
# 3/ Restore symbolic links again.
#
# Only the list of symbolic links given in the DATA section are effected.
#
use strict;

# the relative location of files being included in git repository
my $source_prefix="../real_project/";

# note start of data
my $data_start=tell(DATA);

# Link all files needed for upload
while ( <DATA> ) {
  s/#.*$//;         # ignore comments
  s/\s+$//;         # remove end of line spaces
  next if /^$/;     # skip blank lines
  my($file, $source) = split;

  unlink($file);
  link("$source_prefix$source", $file)
     or warn("failed to find: $source");
}

system("git add -A");
system("git commit -a -m 'Software Export Update'");
system("git push");

# rewind data section
seek DATA, $data_start, 0;

# unlink all files that have now been uploaded
while (<DATA>) {
  s/#.*$//;         # ignore comments
  s/\s+$//;         # remove end of line spaces
  next if /^$/;     # skip blank lines
  my($file, $source) = split;

  unlink($file);
  symlink("$source_prefix$source", $file);
  #  or warn("failed to find: $source");
}

__DATA__

### Example symbolic links (to replace and restore)
  script.pl.txt            scripts/script
  data_file.txt            lib/data_file.dat

# this file is not a symlink as a it slightly modified
# but listed to keep a record of its original source
# config_example.txt       extra/config
