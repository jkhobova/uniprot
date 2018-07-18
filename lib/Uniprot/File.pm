package Uniprot::File;

use Moose;
use Uniprot::Mutation;
use Uniprot::ProteinSequence;

has 'name' => (is => 'rw');

has seq => (
    is => 'ro',
    isa => 'Any',
    lazy => 1,
    builder => "_build_seq",
);

sub _build_seq {
    my $self = shift;

    my $seq = Uniprot::ProteinSequence->new();
    return $seq;

}

=head1 

B<Name>

Uniprot::File

B<Description>

This class reads a uniprot text file and parses it.

B<Methods>

=cut

=head2 validate_file

Validates file format by the header.

=cut

sub validate_file {
    my $self = shift;

    open FILE, '<', $self->name or die "Could not open file ".$self->name.": $!";
    my $header = <FILE>;
    close FILE;

    die "Does not look like a flat file containing uniprot data\n" unless ($header =~ /^ID\s+/);
}

=head2 get_sequence

Returns object ProteinSequence object.
- header
- sequence

=cut

sub get_sequence {
    my $self = shift;

    $self->validate_file();

    open FILE, '<', $self->name or die "Could not open file ".$self->name.": $!"; 

    my $header;
    my @sequence=();    

    while (my $line = <FILE>) {
        if ($line =~ /^SQ\s+SEQUENCE/) {
            $header = $line;
        }
        elsif ( $line =~ /^\s+([\w+\s]+)/ ) {
            push @sequence, $1;
        }
    }
    close FILE;

    $self->seq->header($header);
    $self->seq->sequence(\@sequence);

    return $self->seq;
}

=head2 get_mutations

Searches for mutations in the uniprot file and returns all the single amino acid mutations.
Search keyword 'FT VARIANT'.
Instantiates Mutation object and write it into hash

my %mutations = (
1 => Uniprot::Mutation obj1(title => 'abc'),
2 => Uniprot::Mutation obj2(title => 'def')
...
)

Returns hashref containing those mutations.

=cut

sub get_mutations {
    my ($self, $id) = @_;

    $self->validate_file();

    open FILE, '<', $self->name or die "Could not open file ".$self->name.": $!"; 

    my %mutations = ();
    my $number = 0;

    while (my $line = <FILE>) {
        chomp $line;

        # searching for mutation first line
        # FT   VARIANT      54     54       V -> M (in CMD1G; affects interaction

        if ( $line =~ /^FT\s+VARIANT\s+(\d+)\s+(\d+)\s+(\w)\W+(\w)/ ) {

            my $mutation = Uniprot::Mutation->new(
                wild_amino_acid => $3,
                position => $1,
                mutated_amino_acid => $4,
            );
            $mutations{++$number} = $mutation;
            $self->seq->add_mutation($mutation);

            my $pubmed_num = 0;
            while (my $next_line = readline(FILE)) {
                last if ($next_line =~ /FTId/ && !$pubmed_num);
                if ($next_line =~ /^FT\s+{?ECO:\d+\WPubMed:(\d+)}?([.,])/){
                    $pubmed_num++; # at least one publication exists

                    $mutation->add_publication($1);

                    last if $2 eq '.';
                }
            }
        }
    }
    close FILE;

    if ($id) {
        die "Invalid mutation number\n" unless $self->seq->mutations->[$id-1];
        return $self->seq->get_mutation($id-1);
    }
    return $self->seq->mutations;
}

=head2 parse_mutated_sequence ($id)

Generates the protein sequence with the mutation present.
$id is the number of the mutation we want to retun the mutated sequence for
Returns a scalar, the protein sequence with the mutation present.

=cut

sub parse_mutated_sequence {
    my ($self, $id) = @_;

    my $sequence_obj = $self->get_sequence;
    my $mutation_obj = $self->get_mutations($id);

    # to do: move the below code to Uniprot::ProteinSequence mutated_sequence()
    # debug it there and uncomment this line containing return
    #return $self->seq->mutated_sequence($id);

    # joining sequence array into a variable and removing all spaces
    # to replace certain character with a mutated variant

    my $sequence_line = join '', @{$sequence_obj->sequence};

    $sequence_line =~  s/\s+//g;

    # replacing primary with mutated amino acid, offset starts from 0
    substr $sequence_line, $mutation_obj->position-1, 1, $mutation_obj->mutated_amino_acid;

    # format it back to what it was before, i.e spaces and new lines
    # new lines first

    $sequence_line =~ s/\G.{60}\K/\n/sg;
    my @sequence = split '\n', $sequence_line;

    my @sequence_split_segments =();
    foreach (@sequence) {
        my $line_with_segments = join ' ', $_ =~ /(.{10})/sg;
        push @sequence_split_segments, $line_with_segments;
    }

    return join "\n", @sequence_split_segments;
}

1;
