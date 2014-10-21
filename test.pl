# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use warnings; # always
use strict;   # always

use Test::Simple tests => 553;
use Data::Page::Tied;
ok(1, "Loaded module"); # If we made it this far, we're ok.

my $name;

foreach my $line (<DATA>) {
  chomp $line;
  next if $line =~ /^\s*$/;

  if ($line =~ /^\s*# ?(.+)/) {
      $name = $1;
      next;
    }

  my @vals = split /\s+/, $line;
#  warn $line;

  my $page = Data::Page::Tied->new(@vals[0,1,2]);
  my $tied = Data::Page::Tied->new([1..$vals[0]], @vals[1,2]);
  my @ary;
  my $handler = tie @ary => 'Data::Page::Tied', [1..$vals[0]], @vals[1,2];

#  warn "         First page: ", $page->first_page, "\n";
#  warn "          Last page: ", $page->last_page, "\n";
#  warn "First entry on page: ", $page->first, "\n";
#  warn " Last entry on page: ", $page->last, "\n";

  ok($vals[3] == $page->first_page, "$name: page, first page");
  ok($vals[4] == $page->last_page, "$name: page, last page");
  ok($vals[5] == $page->first, "$name: page, first");
  ok($vals[6] == $page->last, "$name: page, last");

  ok($vals[3] == $tied->first_page, "$name: tied, first page");
  ok($vals[4] == $tied->last_page, "$name: tied, last page");
  ok($vals[5] == $tied->first, "$name: tied, first");
  ok($vals[6] == $tied->last, "$name: tied, last");

  ok(
    ($vals[8] eq 'undef') ?
      (not defined $tied->entry($vals[7])) :
      ($vals[8] == $tied->entry($vals[7])),
    "$name: tied, entry, $vals[7], $vals[8]"
  );
  ok(
    ($vals[8] eq 'undef') ?
      (not defined $tied->set_entry($vals[7])) :
      ($vals[8] == $tied->set_entry($vals[7])),
    "$name: tied, set_entry, $vals[7], $vals[8]"
  );

  ok(scalar @ary == $vals[0], "$name: tied ary, scalar context");

  ok(
    ($vals[8] eq 'undef') ?
      (not defined $ary[$vals[7]]) :
      ($vals[8] == $ary[$vals[7]]),
    "$name: tied ary, fetch, $vals[7], $vals[8]"
  );
  ok(
    ($vals[8] eq 'undef') ?
      ($ary[$vals[7]] = 'defined') :
      ($ary[$vals[7]] = $vals[8] + 1),
    "$name: tied ary, store, $vals[7], $vals[8] + 1"
  );
  ok(
    ($vals[8] eq 'undef') ?
      (defined $ary[$vals[7]] && $ary[$vals[7]] eq 'defined') :
      ($vals[8] + 1== $ary[$vals[7]]),
    "$name: tied ary, fetch, $vals[7], $vals[8] + 1"
  );

  ok($#ary = $vals[0] + 1, "$name: tied ary, storesize");
  ok($handler->total_entries() == $vals[0] + 2, "$name: tied ary handler, total_entries");

}

my $tied = Data::Page::Tied->new(['a' .. 'z'], 10, 1);

ok($tied->set_entries_per_page(5) == 5, 'set_entries_per_page(5)');
ok($tied->entries_per_page() == 5, 'entries_per_page()');
ok($tied->set_entries_per_page(2) == 2, 'set_entries_per_page(2)');
ok($tied->entries_per_page() == 2, 'entries_per_page()');

ok($tied->set_current_page(5) == 5, 'set_current_page(5)');
ok($tied->current_page() == 5, 'current_page()');
ok($tied->set_current_page(2) == 2, 'set_current_page(2)');
ok($tied->current_page() == 2, 'current_page()');


__DATA__
# Initial test
50 10 1    1 5 1 10	1 2
50 10 2    1 5 11 20	2 3
50 10 3    1 5 21 30	40 41
50 10 4    1 5 31 40	-1 50
50 10 5    1 5 41 50	50 undef

# Under 10
1 10 1    1 1 1 1	1 undef
2 10 1    1 1 1 2	1 2
3 10 1    1 1 1 3	0 1
4 10 1    1 1 1 4	-1 4
5 10 1    1 1 1 5	1 2
6 10 1    1 1 1 6	6 undef
7 10 1    1 1 1 7	1 2
8 10 1    1 1 1 8	1 2
9 10 1    1 1 1 9	1 2
10 10 1    1 1 1 10	-2 9

# Over 10
11 10 1    1 2 1 10	1 2
11 10 2    1 2 11 11	1 2
12 10 1    1 2 1 10	1 2
12 10 2    1 2 11 12	1 2
13 10 1    1 2 1 10	1 2
13 10 2    1 2 11 13	1 2

# Under 20
19 10 1    1 2 1 10	1 2
19 10 2    1 2 11 19	1 2
20 10 1    1 2 1 10	1 2
20 10 2    1 2 11 20	1 2

# Over 20
21 10 1    1 3 1 10	1 2
21 10 2    1 3 11 20	1 2
21 10 3    1 3 21 21	1 2
22 10 1    1 3 1 10	1 2
22 10 2    1 3 11 20	1 2
22 10 3    1 3 21 22	1 2
23 10 1    1 3 1 10	1 2
23 10 2    1 3 11 20	1 2
23 10 3    1 3 21 23	1 2




