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

has 'title' => (
    is  => 'rw',
    isa => 'Str',
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
