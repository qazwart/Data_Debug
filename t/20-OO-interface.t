#! /usr/bin/env perl
#
use strict;
use warnings;
use Test::More;
use lib qw(../lib);
use Data::Dumper;
use feature qw(say);

BEGIN { use_ok( 'Data::Debug'  ) }

#
# GENERAL TESTING
#
diag "Testing the Object Oriented interface of Data::Debug";
diag "Basic method tests";

my $debug = new_ok "Data::Debug"
    or BAIL_OUT "Cannot create Data::Debug object";

can_ok $debug, qw( Version Debug_level File_handle Indent Prefix Print_line_number Message )
    or BAIL_OUT "Created Data::Debug object can't handle all methods";

eval { $debug->Indent(2.3); };

ok $@, "Checking for handling bad indent level exception";
ok $debug->Indent(3), "Checking to set Indent"; 
is $debug->Indent, " " x 3, "Checking if Indent was set";
undef $debug;

#
# TESTING USING STDERR
#
my $error_log;
{
    my $debug = new_ok( "Data::Debug" )
	or BAIL_OUT "Could not create 'Data::Debug' object.";
    diag "Running all tests with STDERR file handle";

    ok open ( my $error_fh, ">", \$error_log ),
	"Opening STDERR as a file handle for testing.",
     or BAIL_OUT("Cannot open file handle needed for testing.");

    local *STDERR  = *$error_fh;

    run_tests( $debug );
}
eval_tests( $error_log );

#
# TESTING USING IO:FILE
#
SKIP: {
    eval { require IO::File; };
    skip qq(IO::File not installed. Skipping IO::File tests), 5 if $@;

    my $debug = new_ok( "Data::Debug" ) 
	or BAIL_OUT "Could not create 'Data::Debug' object.";

    my $io_error_log;
    my @arguments = ( \$io_error_log, "w" );
    my $fh = new_ok "IO::File", \@arguments
	or BAIL_OUT "Could not created required IO::File object.";

    ok $debug->File_handle($fh), "Setting debugging to IO::File object";
    run_tests( $debug );
    $fh->close;
    eval_tests( $io_error_log );
}


sub run_tests {
    my $test		= shift;

    $test->Message( qq(No message should print) );
    $test->Debug_level( 5 );
    $test->Message( qq(This message should print with line number) );
    $test->Print_line_number( 0 );
    $test->Message(  qq(This message should print with out a line number.) );
    $test->Prefix( ">" );
    $test->Message( qq(This message should start with ">".) );

    for my $level ( (1..10) ) {  #Only five lines should print
	$test->Message( qq(This is debug level $level.), $level );
    }

    #
    # Try with different indent level
    #
    $test->Indent( 2 );
    for my $level ( (1..10) ) {  #Only five lines should print
	$test->Message( qq(This is debug level $level.), $level );
    }
    $test->Indent( 0 );
    $test->Prefix( "" );
    for my $level ( (1..10) ) {  #Only five lines should print
	$test->Message( qq(This is debug level $level.), $level );
    }
}

sub eval_tests {
    my $error_log	= shift;
    my @lines = split "\n", $error_log;
    my $line = shift @lines;
    diag "Error level is zero. No message should print";
    unlike $line, qr/No message should print/, "Checking to make sure nothing prints if debug is off";
    unshift @lines, $line;	#Put it back

    diag "Setting Debug level to 1";
    like (
	shift @lines,
	qr/^DEBUG: This message should print with line number at .*20-.*?\.t line \d+.$/,
	qq(Checking default usage of debug statement),
    );

    diag "Turning off line number printing";
    is (
	shift @lines,
	"DEBUG: This message should print with out a line number.",
	"Checking debug statement without printing line number",
    );

    diag "Setting Prefix to '>'";
    is ( shift @lines,
	qq(> This message should start with ">".),
	"Checking with different prefix",
    );

    diag "Setting Debug level to 5";
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
	isnt $line, $debug_output, "Level 6 should have never printed";
	unshift @lines, $line;	#Put it back
    };
    diag "Setting Indent to '2'";
    subtest "Now testing indent levels." => sub {
	plan tests => 5;
	for my $level ( (1..5) ) {
	    my $line = shift @lines;
	    my $debug_output = "> " . "  " x ($level - 1) . "This is debug level $level.";
	    is $line, $debug_output;
	}
    };
    diag "Turning off Indent and Prefix";
    subtest "Now turning indent level and prefix turned off." => sub {
	plan tests => 5;
	for my $level ( (1..5) ) {
	    my $line = shift @lines;
	    my $debug_output = "This is debug level $level.";
	    is $line, $debug_output;
	}
    };
}
done_testing 25;
