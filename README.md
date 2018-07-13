# uniprot

INTRODUCTION

This is command line utility that parses the uniprot file, lists the mutations,
and their relative publications and returns back a full mutated sequence.

REQUIREMENTS

CPAN modules:
  * Moose
  * Test::More

USAGE

bin/uniprot_analyser.pl --uniprot Q8WZ42.txt --analysis sequence
bin/uniprot_analyser.pl --uniprot Q8WZ42.txt --analysis list-mutations
bin/uniprot_analyser.pl --uniprot Q8WZ42.txt --get-mutation 1
bin/uniprot_analyser.pl --uniprot Q8WZ42.txt --get-mutation-publications 1
bin/uniprot_analyser.pl --uniprot Q8WZ42.txt -get-mutation-publications-urls 20

TESTING

cd uniprot
prove -lvr t/*.t
