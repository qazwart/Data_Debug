#! /usr/bin/env perl

use strict;
use warnings;
use lib  qw(lib);
use feature qw(say);
use Data::Debug;

{
open my $error_fh, ">", \my $error_log;
local *STDERR = *$error_fh;

#my $error = Foo->new(3);
my $error = Data::Debug->new(3);

$error->Message( "This is a test" );
if ( $? ) {
    say "Error in printing message";
}

no warnings;
say qq(My message was "$error_log".);
use warnings;
}

package Foo;
use Carp;

our $VERSION = "1.0";

use constant {
    OBJECT		=> "IO::Handle",
    DEFAULT_PREFIX	=> "DEBUG:",
    NON_OBJECT		=> "GLOB",
    DEFAULT_FH		=> \*STDERR,
    DEFAULT_INDENT	=> 4,
};
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
