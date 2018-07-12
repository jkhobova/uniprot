use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::File;

print $Bin."\n";
BEGIN { use_ok 'Uniprot::File' }

done_testing();
