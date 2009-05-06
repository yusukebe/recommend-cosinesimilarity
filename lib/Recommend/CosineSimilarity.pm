package Recommend::CosineSimilarity;

use strict;
use warnings;
use Mouse;
use MouseX::AttributeHelpers;

our $VERSION = '0.01';

has 'center_value' => ( is => 'rw', isa => 'Int', default => 0 );
has 'vectors' => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef',
    default   => sub { [] },
    provides  => { push => 'add_vector' },
);

__PACKAGE__->meta->make_immutable();
no Mouse;

sub inner_prod {
    my ( $self, $vec_a, $vec_b ) = @_;
    my $val = 0;
    for my $key ( keys %{$vec_a} ){
        $val += $vec_a->{$key} * $vec_b->{$key} if $vec_b->{$key};
    }
    return $val;
}

sub vec_abs {
    my ( $self, $vec ) = @_;
    my $val = 0;
    for my $x ( values %{$vec} ){
        $val += $x * $x if $x;
    }
    return $val;
}

sub val_shift {
    my ( $self, $vec ) = @_;
    my %hash = %{$vec};
    for my $key ( keys %hash ){
        $hash{$key} = $hash{$key} - $self->center_value if $hash{$key};
    }
    return \%hash;
}

sub cosine_similarity {
    my ( $self, $vec_a, $vec_b ) = @_;
    $vec_a = $self->val_shift($vec_a);
    $vec_b = $self->val_shift($vec_b);
    my $nume = $self->inner_prod( $vec_a, $vec_b );
    my $deno = $self->vec_abs( $vec_a ) * $self->vec_abs( $vec_b );
    return $deno ? $nume / $deno : 0;
}

sub find_most_similar {
    my ( $self, $vector_data ) = @_;
    my $max_sim = 0;
    my $sim_vector;
    for my $vector ( @{ $self->vectors } ) {
        my $sim = $self->cosine_similarity( $vector_data, $vector->{data} );
        if ( $sim > $max_sim ) {
            $max_sim = $sim;
            $sim_vector = $vector;
        }
    }
    return $sim_vector;
}

sub recommend_items {
    my ( $self, $vector_data, $names ) = @_;
    my $sim_data = $self->find_most_similar($vector_data)->{data};
    my @items    = ();
    for my $key ( keys %$sim_data ) {
        if ( !$vector_data->{$key} && grep( $key, @$names ) ) {
            push( @items, { name => $key, value => $sim_data->{$key} } );
        }
    }
    @items = sort { $b->{value} <=> $a->{value} } @items;
    return \@items;
}

1;

__END__

=head1 NAME

Recommend::CosineSimilarity - Simple Recommendation Engine using Cosine Similarity

=head1 SYNOPSIS

  use Recommend::CosineSimilarity;

  my $user1 = { apple  => 2, orange => 3, banana => 3, cherry => 2, };
  my $user2 = { apple  => 2, orange => 3, melon  => 2, cherry => 1, };
  my $user3 = { orange => 1, cherry => 3, };
  my @names = qw/apple orange banana melon cherry peach/;

  my $engine = Recommend::CosineSimilarity->new( { center_value => 2 } );
  $engine->add_vector( { key => 'user2', data => $user2 } );
  $engine->add_vector( { key => 'user3', data => $user3 } );
  print $engine->find_most_similar( $user1 )->{key} . "\n";
  print $engine->recommend_items( $user1, \@names )->[0]->{name} . "\n";


=head1 DESCRIPTION

Recommend::CosineSimilarity is implementation of recommendation engine using cosine similarity.

=head1 AUTHOR

Yusuke Wada E<lt>yusuke at kamawada.comE<gt>

=head1 SEE ALSO

WEB+DB PRESS vol.49 pp121 - pp127

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
