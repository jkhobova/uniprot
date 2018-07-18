#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::File;

use Getopt::Long qw(GetOptions);

######################################################################
# Command line utility that reads and parses a uniprot flat file and
# returns different data based on parameters passed. See Usage below
######################################################################

my ($uniprot_file, $analysis, $mutation_id, $mutation_id_pubs, $mutation_id_pubs_url, $mutated_seq_id);

GetOptions(
    'uniprot=s'      => \$uniprot_file,
    'analysis=s'     => \$analysis,
    'get-mutation=i' => \$mutation_id,
    'get-mutation-publications=i'      => \$mutation_id_pubs,
    'get-mutation-publications-urls=i' => \$mutation_id_pubs_url,
    'get-mutated-sequence=i'           => \$mutated_seq_id,    
);

die "Usage: $0 --uniprot FILENAME  --analysis sequence|list-mutations --get-mutation ID
    --get-mutation-publications ID --get-mutation-publications-urls ID  --get-mutated-sequence ID\n" 
        unless $uniprot_file
            || $uniprot_file && ($analysis && ($analysis eq 'sequence' || $analysis eq 'list-mutations'));

my $output = '';
my $parser  = Uniprot::File->new(name => $uniprot_file);

if ($analysis && $analysis eq 'sequence') {
    my $sequence_obj = $parser->get_sequence;

    $output = $sequence_obj->header. join '', @{$sequence_obj->sequence};

} elsif ($analysis && $analysis eq 'list-mutations') {
    my $mutations = $parser->get_mutations;

    my $i=1;

    $output .= join '',
        map { $i++ .")"  . $_->title."\n" }
    @$mutations;

} elsif ($mutation_id) {
    my $mutation = $parser->get_mutations($mutation_id);

    $output = $mutation->title;

} elsif ($mutation_id_pubs) {
    my $publications = $parser->get_mutations($mutation_id_pubs)->publications;

    $output .= join "\n",
        map { $_->pubmed }
        @$publications;

    $output = 'none' unless $output;

} elsif ($mutation_id_pubs_url) {
    my $publications = $parser->get_mutations($mutation_id_pubs_url)->publications;

    $output .= join "\n",
        map { $_->url }
        @$publications;

    $output = 'none' unless $output;

} elsif ($mutated_seq_id) {
    my $sequence = $parser->parse_mutated_sequence($mutated_seq_id);

    $output = $sequence;

} else {
    die "Nothing to analyse yet or invalid combination of arguments\n";
}

print $output."\n";


