use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::Publication;

BEGIN { use_ok 'Uniprot::Publication' }

my $pub = Uniprot::Publication->new(pubmed=>123);
isa_ok($pub, 'Uniprot::Publication');

$pub->pubmed(123);
is ($pub->pubmed,123,'pubmet generated');
is ($pub->url, 'https://www.ncbi.nlm.nih.gov/pubmed/?term=123','url generated');

done_testing();
