use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::Mutation;

BEGIN { use_ok 'Uniprot::Mutation' }

#
# tests Uniprot::Mutation class
#

my $um = Uniprot::Mutation->new(
    wild_amino_acid => 'V',
    position => 64,
    mutated_amino_acid => 'M'
);

isa_ok($um, 'Uniprot::Mutation', 'built mutation object');
is ($um->title, 'V64M', 'mutation title is correct');

$um->add_publication(123);
is (@{$um->publications}->[0]->pubmed, 123, 'publication is correct');

done_testing();
