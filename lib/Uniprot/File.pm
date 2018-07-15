package Uniprot::File;

use Moose;
use Uniprot::Mutation;

has 'name' => (is => 'rw');

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

Returns header and the primary sequence of the file.
$header, \@sequence

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
    return $header, \@sequence;
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
            my $mutation = Uniprot::Mutation->new(title => $3.$1.$4);
            $mutations{++$number} = $mutation;

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
        die "Invalid mutation number\n" unless exists $mutations{$id};
        return $mutations{$id};
    }
    return \%mutations;
}

=head2 get_mutated_sequence ($id)

Generates the protein sequence with the mutation present.
$id is the number of the mutation we want to retun the mutated sequence for
Returns a scalar, the protein sequence with the mutation present.

=cut

sub get_mutated_sequence {
    my ($self, $id) = @_;

    my ($header, $sequence) = $self->get_sequence;
    my $mutation = $self->get_mutations($id)->title;

    # joining sequence array into a variable and removing all spaces
    # to replace certain character with a mutated variant

    my $sequence_line = join '', @$sequence;
    $sequence_line =~  s/\s+//g;

    $mutation =~ /(\d+)(\w+)$/;

    # replacing, offset starts from 0
    substr $sequence_line, $1-1, 1, $2;

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
