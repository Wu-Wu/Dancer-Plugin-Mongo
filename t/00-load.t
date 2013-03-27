use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok 'MongoDB';
    use_ok 'Dancer::Plugin::Mongo';
}

diag 'Testing Dancer::Plugin::Mongo and MongoDB';

done_testing;
