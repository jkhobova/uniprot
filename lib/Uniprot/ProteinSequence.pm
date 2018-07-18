package Uniprot::ProteinSequence;

use Moose;

has 'mutations' => (
    traits => ['Array'],
    is  => 'rw',
    isa => "ArrayRef[HashRef]",
    default => sub { [] }
);

has 'sequence' => (
    isa => 'ArrayRef',
    is  => 'rw',
);

has 'header' => (
    isa => 'Str',
    is => 'rw',
);

# to do: sorry, didn't get enough time to debug this and start using it
sub mutated_sequence {
    my ($self, $mutation_number ) = @_;

    # now it takes $mutation_list as a scalar. TO be implemented to take an array
    my $sequence = $self->sequence;
    my $sequence_line = join '', @{$self->sequence};

    $sequence_line =~  s/\s+//g;

    # replacing primary with mutated amino acid, offset starts from 0

    my $mutation = $self->mutations->[$mutation_number];
    substr $sequence_line, $mutation->position, 1, $mutation->mutated_amino_acid;

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

sub get_mutation {
    my ($self, $number) = @_;

    my $mutation = $self->mutations->[$number];
    return $mutation;
}

sub add_mutation {
    my ($self, $mutation_obj) = @_;

    return undef unless $mutation_obj;
    push @{$self->mutations}, $mutation_obj;
}


1;


