package Uniprot::Publication;

=head1

B<Name>

Uniprot::Publication

B<Description>

This class builds the Publication object.
Attributes:  pubmed id and url.
Pubmed param should be passed on object instantiation.
Url for a pubmed is a concatenation of default url and pubmed id.

=cut

use Moose;

has 'pubmed' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    trigger => \&_generate_url,
);

has 'url' => (
    is => 'ro',
    isa => 'Str',
);

sub _generate_url {
    my $self = shift;

    $self->{url} = $self->{pubmed}
        ? 'https://www.ncbi.nlm.nih.gov/pubmed/?term='.$self->{pubmed}
        : '';
}

1;
