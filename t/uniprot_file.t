use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::File;

BEGIN { use_ok 'Uniprot::File' }

my $file = Uniprot::File->new(name=>'aaa');
isa_ok($file, 'Uniprot::File');

is (ref $file->seq, 'Uniprot::ProteinSequence','instantiated ProteinSequence obj');

done_testing();
