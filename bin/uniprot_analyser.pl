#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Uniprot::File;

use Getopt::Long qw(GetOptions);

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
        if (!$uniprot_file
            || ($analysis && ($analysis eq 'sequence' || $analysis eq 'list-mutations')));

my $output = '';
my $file  = Uniprot::File->new(name => $uniprot_file);

if ($analysis && $analysis eq 'sequence') {
    $output = "Sequence:\n\n".$file->parse('s');

} elsif ($analysis && $analysis eq 'list-mutations') {
    my $mutations = $file->parse('lm');

    $output = "Mutations:\n\n";
    $output .= join '',
        map { "$_) $mutations->{$_}\n" } 
        sort { $a <=> $b}
            keys %$mutations;

} elsif (defined $mutation_id) {
    my $mutations = $file->parse('lm');

    die "Invalid mutation number\n" unless exists $mutations->{$mutation_id};
    $output = $mutations->{$mutation_id}."\n";

}

print $output."\n";


