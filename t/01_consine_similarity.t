use strict;
use warnings;
use Test::More qw( no_plan );
use Perl6::Say;
use Recommend::CosineSimilarity;

my $user1 = {
    apple  => 2,
    orange => 3,
    banana => 3,
    cherry => 2,
};

my $user2 = {
    apple  => 2,
    orange => 3,
    melon  => 2,
    cherry => 1,
};

my $user3 = {
    orange => 1,
    cherry => 3,
};

my @names = qw/apple orange banana melon cherry peach/;
my $engine = Recommend::CosineSimilarity->new( { center_value => 2 } );
is( 0.25, $engine->cosine_similarity( $user1, $user2 ), 'cosine_similarity' );
$engine->add_vector( { key => 'user2', data => $user2 } );
$engine->add_vector( { key => 'user3', data => $user3 } );
is('user2', $engine->find_most_similar( $user1 )->{key}, 'find_most_similar');
is('melon', $engine->recommend_items( $user1, \@names )->[0]->{name}, 'recommed_items' );
