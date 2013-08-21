#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok('Data::Debug') || print "Bail out!\n";
}

diag("Testing Data::Debug $Data::Debug::VERSION, Perl $], $^X");
