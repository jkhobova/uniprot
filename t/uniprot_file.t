use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::File;

print $Bin."\n";
BEGIN { use_ok 'Uniprot::File' }

my $file = Uniprot::File->new(name=>'aaa');
isa_ok($pub, 'Uniprot::Publication');

# to be implemented

done_testing();
