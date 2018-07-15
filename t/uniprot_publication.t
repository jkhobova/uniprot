use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::Publication;

print $Bin."\n";
BEGIN { use_ok 'Uniprot::Publication' }

done_testing();
