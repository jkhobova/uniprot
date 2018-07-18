use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::ProteinSequence;
use Uniprot::Mutation;

BEGIN { use_ok 'Uniprot::ProteinSequence' }

#
# tests Uniprot::ProteinSequence class
#

my $ps = Uniprot::ProteinSequence->new();

isa_ok($ps, 'Uniprot::ProteinSequence');

my $mutation = Uniprot::Mutation->new(
    wild_amino_acid => 'V',
    position => 2,
    mutated_amino_acid => 'M',
);

$ps->add_mutation($mutation);
is (ref $ps->mutations, 'ARRAY', 'mutation has been added');
is($ps->mutations->[0]->{position}, 2, 'position is correct');

done_testing();
