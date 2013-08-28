#! /usr/bin/env perl
#

package Data::Debug;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(debug);

use Carp;

use constant {
    OBJECT		=> "IO::Handle",
    NON_OBJECT		=> "GLOB",
    DEFAULT_PREFIX	=> "DEBUG:",
    DEFAULT_FH		=> \*STDERR,
    DEFAULT_INDENT	=> 4,
};

#
# Non-object oriented methods
#
our $VERSION 		= 1.0;
our $level 		= 0;
our $indent		= DEFAULT_INDENT;
our $prefix		= DEFAULT_PREFIX;
our $print_line_number	= 1;

sub debug ($;$) {
    my $message 	= shift;
    my $debug_level	= shift;

    my $indent_level = " " x $indent;
    if ( not defined $debug_level ) {
	$debug_level = 1;
    }
    return if ( $debug_level > $level );

    #
    # Find line number. I hate myself for this...
    #
    my $line_number = "";
    if ( $print_line_number ) {
	eval { croak qq(Oh, what is my calling line number?); };
	( $line_number = $@ ) =~ s/.* at / at /;
    }

    #
    # Figure what you have to print
    #
    my $print_prefix = $prefix ? $prefix . " " : "";
    my $print_string;
    $print_string  = $print_prefix;		#Prefix to print
    $print_string .= $indent_level x ($debug_level - 1);	#Indent
    $print_string .= $message;			#Message to print
    $print_string .= $line_number;		#Line Number (if desired)
    chomp $print_string;
    $print_string .= "\n";
    #
    # Print to STDERR whether you like it or not
    #
    print STDERR $print_string;
}

sub new {
    my $class		= shift;
    my $debug_level	= shift;

    my $self = {};
    bless $self, $class;

    $self->Debug_level($debug_level);
    return $self;
}

sub Version {
    return $VERSION;
}

sub Debug_level {
    my $self		= shift;
    my $debug_level	= shift;

    if ( defined $debug_level ) {
	if ( $debug_level =~ /^\d+$/ ) {  #Must be an integer
	    $self->{DEBUG_LEVEL} = $debug_level;
	}
	else {
	    croak qq(Global debug level must be an integer);
	}
    }
    if ( not defined $self->{DEBUG_LEVEL} ) {
	$self->{DEBUG_LEVEL} = 0;
    }
    return $self->{DEBUG_LEVEL};
}

sub File_handle {
    my $self		= shift;
    my $file_handle	= shift;

    if ( defined $file_handle ) {
	if ( ref $file_handle eq NON_OBJECT
		or $file_handle->isa( OBJECT ) ) {
	    $self->{FILE_HANDLE} = $file_handle;
	}
	else {
	    croak qq(Must pass a file handle to the File_handle method);
	}
    }
    return $self->{FILE_HANDLE};
}


sub _File_handle_type {
    my $self		= shift;
    my $param		= shift;

    if ( defined $param ) {
	croak qq(You naughty spawn. This is a PRIVATE method);
    }

    my $file_handle = $self->File_handle;

    if ( defined $file_handle and $file_handle->isa( OBJECT ) ) {
	return OBJECT;
    }
    else {
	return NON_OBJECT;
    }
}

sub Indent {
    my $self		= shift;
    my $indent		= shift;

    if ( defined $indent ) {
	if ( $indent !~ /^\d+$/ ) {
	    croak qq(Indent level must be an integer);
	}
	$self->{INDENT} = " " x $indent;
    }
    if ( not exists $self->{INDENT} ) {
	$self->{INDENT} = " " x DEFAULT_INDENT;
    }
    return $self->{INDENT};
}

sub Prefix {
    my $self		= shift;
    my $prefix		= shift;

    if ( defined $prefix ) {
	$self->{PREFIX} = $prefix;
    }
    if ( not exists $self->{PREFIX} ) {
	$self->{PREFIX} = DEFAULT_PREFIX;
    }
    return $self->{PREFIX};
}

sub Print_line_number {
    my $self		= shift;
    my $flag		= shift;

    if ( defined $flag ) {
	$self->{PRINT_LINE_NUM} = $flag;
    }
    if ( not exists $self->{PRINT_LINE_NUM} ) {
	$self->{PRINT_LINE_NUM} = 1;	#Default prints line numbers
    }
    return $self->{PRINT_LINE_NUM};
}

sub Message {
    my $self		= shift;
    my $message		= shift;
    my $debug_level	= shift;

    if ( not defined $debug_level ) {
	$debug_level = 1;
    }
    if ( not $debug_level =~ /^\d+$/ ) {
	croak qq(Second parameter for Message (debug level) must be an integer or null);
    }

    #
    # First: Check whether or not to print
    #

    if ( not defined $self->Debug_level
	    or $debug_level > $self->Debug_level ) {
	return;
    }

    #
    # Find line number. I hate myself for this...
    #
    my $line_number = "";
    if ( $self->Print_line_number ) {
	eval { croak qq(Oh, what is my calling line number?); };
	( $line_number = $@ ) =~ s/.* at / at /;
    }

    #
    # Figure what you have to print
    #
    my $prefix = $self->Prefix ? $self->Prefix . " " : "";
    my $print_string;
    $print_string  = $prefix;			#Prefix to print
    $print_string .= $self->Indent x ($debug_level - 1);  #Indent
    $print_string .= $message;			#Message to print
    $print_string .= $line_number;		#Line Number (if desired)
    chomp $print_string;
    $print_string .= "\n";

    #
    # Print message: Object Oriented or plain 'ol Print statement?
    #

    my $file_handle = $self->File_handle;
    if ( not defined $file_handle ) {
	$file_handle = DEFAULT_FH;
    }
    if ( $self->_File_handle_type eq "OBJECT" ) {
	$file_handle->print($print_string);
    }
    else {
	print {$file_handle} $print_string;
    }
}
1;

__END__

=pod

=head1 NAME

Test::Debug

=head1 SYNOPSIS

Function Interface

    use Text::Debug qw(debug);	#Not exported automatically

    $Text::Debug::level = 4;	#Turn on debugging messages

    debug "This is my debug message";
    debug "This is a level 2 message", 2;
    debug "This won't print", 5;

Object Oriented Interface

    use Test::Debug;

    my $debug = Test::Debug->new(4);	#Debug level;

    $debug->Message( qq(This is a level 1 message) );
    $debug->Message( qq(This is a level 2 message) 2 );
    $debug->Message( "This won't print", 5 );

=head1 DESCRIPTION

Sometimes the quickest way to debug something is to install a few
debugging statements that print out to show you what the code is doing.

The purpose of this module is to provide a simple way to do this:

    use Test::Debug qw(debug);
    ...
    debug qq(Attempting to contant "$server" on "$port");

    Run your program, and you'll never see this statement print out.
    That's because you didn't set the debug level:

    use Test::Debug qw(debug);
    ...
    $Test::Debug::level = 1;
    ...
    debug qq(Attempting to contant "$server" on "$port");

Now, it will print out. Doing this means you don't have to clean up
your code to get rid of debugging statements. You simply set
C<$Test::Debug::level> to C<0>.

This module has a concept of I<debugging levels>. A debug statement
won't print out unless the global debug level is higher than the debug
statement's level. 

=head1 FUNCTION INTERFACE

=head2 Module Variables

=over 4

=item $Test::Debug::level

Sets the debug level. By default C<$Test::Debug::level> is set to zero
which means no debug statments  will print. Otherwise, only debug
messages at the level of C<$Test::Debug::level> or lower will print.

=item $Test::Debug::indent

Sets the number of spaces to indent at each level. Each level will
indent by this many spaces times that level (minus 1).

=item $Test::Debug::prefix

Sets the prefix of the Debug statement. Each debug message will be
preceded by this prefix. By default, it is set to C<DEBUG:>.
You can set it to a null string to turn off prefixes.

=item $Test::Debug::print_line_number

Whether or not to append the line number to the end of the statement. By
default, debug messages will print with the line number. Setting
C<$Test::Debug::print_line_number> to C<0> will turn off line number
printing.

=back

=head2 Functions

=over 4

=item debug

The only function that's exported, and you must export it yourself. This
is prototyped, so you can simply type:

    debug "This is my debug message";

much the way you can do with C<say>, C<print>, C<die>, etc. This will
print on debug level 1. Adding a second parameter will allow you to
specify the debug level:

    debug "This is a level 3 statement", 3;

=back

=head1 OBJECT INTERFACE

=head2 Constructor

=over 4

=item new

Creates a new C<Test::Debug> object. This stores your configuration
for your debug messages

The C<new> constructor can take a single parameter, the debug level. If
it is set to zero, no debugging messages will print. If set to one or
higher, the debug messages at that level or below will print.

By default, no debugging messages will print unless you pass in a
debugging level higher than 0.

=back

=head2 Methods

=over 4

=item Version

Returns the version number of this package. Takes no parameters.

=item Debug_level

Debugging level. If set to C<0>, no debugging messages will print.
Otherwise, debuggine messages at or below that Debugging level will
print.

=item File_handle

The file handle where you want your debugging messages to print. This
can either take a reference to a glob, or a L<IO::Handle> object.

    $debug->File_handle(\*STDERR);	#The default

    open ERRORS, ">$error_file";

    debug->File_handle(\*ERRORS);	#Passing a glob reference

    open my $errors, ">", $error_file;

    debug->File_handle( $errors );	#Passing a glob again.

    use IO::File;

    my $fh = IO::File->new( $error_file, "w");

    $debug->File_handle( $fh );		#Passing in a IO::Handle object

By default, messages will print out to C<STDERR>.

=item Indent

The amount of spaces to indent at each level.

=item Prefix

The prefix to print on each line. By default, the prefix is C<DEBUG:>.
If you make this a null string, no prefix will print.

=item Print_line_number

Print the line number at the end of the string. By default, the line
number will print where the debug statement is located will print on
each line. Setting this to zero will turn this off. Setting it to
non-zero will turn this on.

=item Message

The message you want to print. This takes two parameters. The first is
required and is the message. The second is the debug level and is
optional. If you don't pass the debug level, it will assume a debug
level of C<1>.

    $debug->Message( qq(This is a debug level of one) );
    $debug->Message( qq(This is a debug level of one),1 );  #Same as above

=back

=head1 AUTHOR

David Weintraub
L<mailto:david@weintraub.name>

=head1 COPYRIGHT

Copyright (c) 2013 by David Weintraub. All rights reserved. This
program is covered by the open source BMAB license.

The BMAB (Buy me a beer) license allows you to use all code for whatever
reason you want with these three caveats:

=over 4

=item 1.

If you make any modifications in the code, please consider sending them
to me, so I can put them into my code.

=item 2.

Give me attribution and credit on this program.

=item 3.

If you're in town, buy me a beer. Or, a cup of coffee which is what I'd
prefer. Or, if you're feeling really spendthrify, you can buy me lunch.
I promise to eat with my mouth closed and to use a napkin instead of my
sleeves.

=back

=cut
