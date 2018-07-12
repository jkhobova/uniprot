use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";

is(1, -e "$Bin/../bin/uniprot_analyser.pl", "Script exists");

done_testing();
