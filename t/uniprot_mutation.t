use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::Mutation;

print $Bin."\n";
BEGIN { use_ok 'Uniprot::Mutation' }

#
# tests Uniprot::Mutation class
#

my $um = Uniprot::Mutation->new();

isa_ok($um, 'Uniprot::Mutation');

$um->add_publication(123);
is (@{$um->publications}->[0]->pubmed, 123);

done_testing();
