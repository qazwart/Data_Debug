# NAME

Test::Debug

# SYNOPSIS

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

# DESCRIPTION

I find the quickest way of debugging a program is to add a few debugging
statements in your code. However, after you've finished debugging, you
must remove your debugging statements (or, at least nop them). Then, the
next time you have a bug you're trying to track down, you need to add
them back in again.

Then, there are times when you need more _detailed_ information.

I've always wanted an easy way to do debugging in Perl, and never found
a module to my liking. Thus, enter `Data::Debug`.

It's very easy to use:

    use Data::Debug qw(debug);

    ...
    debug qq(Connecting to server "$server" on port "$port");

That's all there is to it. Run your program **and nothing will print
out**. That's by design. `Data::Debug` allows you to create debugging
messages, but won't print them out unless you tell it you're actually
debugging:

    use Data::Debug qw(debug);
    $Data::Debug::level = 1;

    ...
    debug qq(Connecting to server "$server" on port "$port");

Now, this will print something like this:

    DEBUG: Connecting to server "www.foo.com" on port "80" at line blah, blah, blah...

This allows you to put in debugging statements throughout your code, and
your end user will never see them. However, if there's a problem, you
can turn on debugging and start seeing some detailed messages of what's
going on in your program.

`Data::Debug` can have multiple  _debugging levels_. Each debug
statement can take a debug level (default = 1). If `$Data::Debug::level`
is less than the statement's _debugging level_, that statement won't
print. If `$Data::Debug::level` is greater than or equals to the
statement's debugging level, it will print. This statement has a debug
level of `2`:

    debug qq(Sending header packet to server), 2;

`Data::Debug` has both an object oriented interface (the correct way to
run the program) and a functional interface (the one developers will
actually use). 

It's designed to be a fast and simple way to help you debug your
program.

# AUTHOR

David Weintraub
[david@weintraub.name](mailto:david@weintraub.name)

# COPYRIGHT

Copyright &copy; 2013 by David Weintraub. All rights reserved. This
program is covered by the open source BMAB license.

The BMAB (Buy me a beer) license allows you to use all code for whatever
reason you want with these three caveats:

1. If you make any modifications in the code, please consider sending
   them to me, so I can put them into my code.
2. Give me attribution and credit on this program.
3. If you're in town, buy me a beer. Or, a cup of coffee which is what
   I'd prefer. Or, if you're feeling really spendthrify, you can buy me
   lunch.  I promise to eat with my mouth closed and to use a napkin
   instead of my sleeves.

The BMAB license is compatible with the [Perl Artistic
License](http://dev.perl.org/licenses/artistic.html). All terms in the
Artistic license also apply here. If there is any conflict between the
Artistic license and the BMAB license, the Artistic license takes
precedence. Heck, just use the Artistic license, but if you come to
town, do stop by for a beer.
