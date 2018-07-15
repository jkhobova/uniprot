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
my $file  = Uniprot::File->new(name => $uniprot_file);

if ($analysis && $analysis eq 'sequence') {
    my ($header, $sequence) = $file->get_sequence;

    $output = $header. join '', @$sequence;

} elsif ($analysis && $analysis eq 'list-mutations') {
    my $mutations = $file->get_mutations;

    $output = "Mutations:\n\n";
    $output .= join '',
        map { "$_) ".$mutations->{$_}->title."\n" }
        sort { $a <=> $b}
            keys %$mutations;

} elsif ($mutation_id) {
    my $mutation = $file->get_mutations($mutation_id);

    $output = "\n".$mutation->title."\n";

} elsif ($mutation_id_pubs) {
    my $mutation_publications = $file->get_mutations;
    $output .= join "\n",
        map { $_->pubmed }
        @{$mutation_publications->{$mutation_id_pubs}->publications};

    $output = 'none' unless $output;

} elsif ($mutation_id_pubs_url) {
    my $mutation_publications = $file->get_mutations;

    $output .= join "\n",
        map { $_->url }
        @{$mutation_publications->{$mutation_id_pubs_url}->publications};

    $output = 'none' unless $output;

} elsif ($mutated_seq_id) {
    my $sequence = $file->get_mutated_sequence($mutated_seq_id);

    $output = $sequence;

} else {
    die "Nothing to analyse yet or invalid combination of arguments\n";
}

print $output."\n";


