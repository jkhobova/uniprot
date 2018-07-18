package Uniprot::Mutation;

=head1

B<Name>

Uniprot::Mutation

B<Description>

This class reads a uniprot text file and parses it.

B<Synopsis>

use Uniprot::Mutation;

my $mutation = Uniprot::Mutation->new(title => 'Name');
my $publications = $mutation->publications();

B<Methods>

=cut

use Moose;
use Uniprot::Publication;

has 'wild_amino_acid' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'mutated_amino_acid' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'position' => (
    is => 'rw',
    isa => 'Num',
    required => 1,
);

has 'title' => (
    is  => 'rw',
    isa => 'Str',
    lazy_build => 1,
);

has 'publications' => (
    traits => ['Array'],
    is  => 'rw',
    isa => 'ArrayRef',
    default => sub {
        my ($self, $number) = @_;

        return $$self->{publications}[$number] if $number;
        return \@{$self->{publications}};
    },
);

sub _build_title {
    my $self = shift;
    return $self->wild_amino_acid . $self->position. $self->mutated_amino_acid;
}

=head2 add_publication ( $pubmed )

Instantiates a new publication object and pushes it into array of publications.
They can be returned by publications()

=cut

sub add_publication {
    my ($self, $pubmed) = @_;

    my $publication = Uniprot::Publication->new( pubmed => $pubmed );

    push @{$self->{publications}}, $publication;
}

1;
