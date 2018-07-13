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

=head2 parse ( key )

Dispatcher. Allows to extract particular data from a uniprot file based on the passed key value.

Param: $key
s - gets a sequance, m - gets a list of mutations

=cut

sub parse {
    my ($self, $key) = @_;

    if ($key eq 's') {
        return $self->_get_sequence;
    } elsif ($key eq 'm') {
        return $self->_get_mutations;
    } else {
        die "Incorrect key for Uniprot::File parser $!\n";
    }
}

=head2 _get_sequence

Returns the primary sequence of the file.

=cut

sub _get_sequence {
    my $self = shift;

    open FILE, '<', $self->name or die "Could not open file ".$self->name.": $!"; 

    my $header = <FILE>;
        
    my @sequence=();    
    while (my $line = <FILE>) {
        if ( $line =~ /^\s+([\w+\s]+)/ ) {
            push @sequence, $1; 
        }

    }
    close FILE;
    return $header."\n". join ' ', @sequence;
}

=head2 _get_mutations

Searches for mutations in the uniprot file and returns all the single amino acid mutations.
Search keyword 'FT VARIANT'.
Instantiates Mutation object and write it into hash

my %mutations = (1 => Uniprot::Mutation obj1, 2 => Uniprot::Mutation2 ...)

Returns hashref containing those mutations.

=cut


sub _get_mutations {
    my $self = shift;

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
    return \%mutations;
}

1;
