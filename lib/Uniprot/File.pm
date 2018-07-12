package Uniprot::File;

use Moose;

has 'name' => (is => 'rw');

=head1 

B<Name>

Uniprot::File

B<Description>

This class reads a uniprot text file and parses it.

B<Methods>

=cut

=head2 parse ( key )

Allows to extract particular data from a uniprot file based on the passed key value.

Param: $key
s - gets a sequance, lm - gets a list of mutations

=cut

sub parse {
    my ($self, $key) = @_;

    if ($key eq 's') {
        return $self->_get_sequence;
    } elsif ($key eq 'lm') {
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

=head2 _get_sequence

Returns all the mutations of the file.
FT   VARIANT      54     54       V -> M (in CMD1G; affects interaction

=cut


sub _get_mutations {
    my $self = shift;

    open FILE, '<', $self->name or die "Could not open file ".$self->name.": $!"; 

    my %mutations = ();
    my $number = 0;

    while (my $line = <FILE>) {
        chomp $line;

        if ( $line =~ /^FT\s+VARIANT\s+(\d+)\s+(\d+)\s+(\w)\W+(\w)/ ) {
            $mutations{++$number} = $3.$1.$4;
        }
    }
    close FILE;
    return \%mutations;
}

1;
