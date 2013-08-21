#! /usr/bin/env perl
#
use strict;
use warnings;
use lib qw(../lib);
use Test::More;

BEGIN { use_ok( 'Data::Debug', qw(debug),  ) }

diag "Testing the functional interface of Data::Debug";
my $error_log;
{
    # Localize STDERR
    ok open ( my $error_fh, ">", \$error_log ),
	"Opening STDERR as a file handle for testing.",
     or BAIL_OUT("Cannot open file handle needed for testing.");

    local *STDERR  = *$error_fh;

    debug qq(No message should print);
    $Data::Debug::level = 5;
    debug qq(This message should print with line number);
    $Data::Debug::print_line_number = 0;
    debug qq(This message should print with out a line number.);
    $Data::Debug::prefix = ">";
    debug qq(This message should start with ">".);

    for my $level ( (1..10) ) {  #Only five lines should print
	debug qq(This is debug level $level.), $level;
    }

    #
    # Try with different indent level
    #
    $Data::Debug::indent = 2;
    for my $level ( (1..10) ) {  #Only five lines should print
	debug qq(This is debug level $level.), $level;
    }
    $Data::Debug::indent = 0;  #Turn off indenting
    $Data::Debug::prefix = ""; #No prefix
    for my $level ( (1..10) ) {  #Only five lines should print
	debug qq(This is debug level $level.), $level;
    }
}
my @lines = split "\n", $error_log;
my $line = shift @lines;
diag '$Data::Debug::level = 0;';
unlike $line, qr/No message should print/, "Checking to make sure nothing prints if debug is off";
unshift @lines, $line;	#Put it back
diag '$Data::Debug::level = 1;';
like (
    shift @lines,
    qr/^DEBUG: This message should print with line number at .*10-functional-interface.t line \d+.$/,
    qq(Checking default usage of debug statement),
);

diag '$Data::Debug::print_line_numbers = 0;';
is (
    shift @lines,
    "DEBUG: This message should print with out a line number.",
    "Checking debug statement without printing line number",
);
diag '$Data::Debug:prefix = ">";';
is ( shift @lines,
    qq(> This message should start with ">".),
    "Checking with different prefix",
);

diag '$Data::Debug::level = 5;';
subtest "Now testing debug levels. 10 debug statements, but only five will have printed" => sub {
    plan tests => 6;
    for my $level ( (1..5) ) {
	my $line = shift @lines;
	my $debug_output = "> " . "    " x ($level - 1) . "This is debug level $level.";
	is $line, $debug_output, "Testing debug level $level";
    }
    my $line = shift @lines;
    my $level = 6;
    my $debug_output = "> " . "    " x ($level - 1) . "This is debug level $level.";
    isnt $line, $debug_output, "Good: Level 6 didn't print";
    unshift @lines, $line;	#Put it back
};
diag '$Data::Debug::indent = 2;';
subtest "Now testing indent levels." => sub {
    plan tests => 5;
    for my $level ( (1..5) ) {
	my $line = shift @lines;
	my $debug_output = "> " . "  " x ($level - 1) . "This is debug level $level.";
	is $line, $debug_output;
    }
};
diag '$Data::Debug::indent = 0';
subtest "Now turning indent level and prefix turned off." => sub {
    plan tests => 5;
    for my $level ( (1..5) ) {
	my $line = shift @lines;
	my $debug_output = "This is debug level $level.";
	is $line, $debug_output;
    }
};
done_testing 9;
