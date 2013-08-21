use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Data::Debug',
    AUTHOR              => q{David Weintraub <david@weintraub.name>},
    VERSION_FROM        => 'lib/Data/Debug.pm',
    ABSTRACT_FROM       => 'lib/Data/Debug.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Data-Debug-*' },
);
