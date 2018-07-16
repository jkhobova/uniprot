use strict;
use warnings;
use Test::More;
use Test::Exception;

use FindBin qw($Bin);
use lib "$Bin/../lib";

is(1, -e "$Bin/../bin/uniprot_analyser.pl", "Script exists");

# incorrect file format
like(`cd $Bin/../bin/; ./uniprot_analyser.pl --uniprot $Bin/../t/data/other.txt --get-mutated-sequence=1`,
    qr//,'incorrect file format');

# correct file format
like(`cd $Bin/../bin/; ./uniprot_analyser.pl --uniprot $Bin/../t/data/other.txt`,
    qr//, 'invalid arguments');

like(`cd $Bin/../bin/; ./uniprot_analyser.pl --uniprot $Bin/../t/data/Q8WZ42.txt --analysis sequence`,
    qr/MTTQAPTFTQ PLQSVVVLEG STATFEAHIS GFPVPEVSWF RDGQVISTST LPGVQISFSD/, 'primary sequence looks good');

like(`cd $Bin/../bin/; ./uniprot_analyser.pl --uniprot $Bin/../t/data/Q8WZ42.txt --analysis list-mutations`,
    qr/L34315P/, 'lists mutations and the last mutation is present');

like(`cd $Bin/../bin/; ./uniprot_analyser.pl --uniprot $Bin/../t/data/Q8WZ42.txt --get-mutation=1`,
    qr/V54M/, 'lists the first mutation');

like(`cd $Bin/../bin/; ./uniprot_analyser.pl --uniprot $Bin/../t/data/Q8WZ42.txt --get-mutation-publications 1`,
    qr/11846417/, 'lists publication');

like(`cd $Bin/../bin/; ./uniprot_analyser.pl --uniprot $Bin/../t/data/Q8WZ42.txt --get-mutation-publications-urls 1`,
    qr|https://www.ncbi.nlm.nih.gov/pubmed/\?term=11846417|, 'lists publications url');

like(`cd $Bin/../bin/; ./uniprot_analyser.pl --uniprot $Bin/../t/data/Q8WZ42.txt --get-mutated-sequence=1`,
    qr/MTTQAPTFTQ PLQSVVVLEG STATFEAHIS GFPVPEVSWF RDGQVISTST LPGMQISFSD/, 'mutated sequence is correct');

done_testing();
