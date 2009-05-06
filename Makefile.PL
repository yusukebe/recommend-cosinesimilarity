use strict;
use inc::Module::Install;

name('libRecommend-CosineSimilarity');
all_from('lib/Recommend/CosineSimilarity.pm');

requires( 'Mouse' );
requires( 'MouseX::AttributeHelpers' );

build_requires( 'Test::More' );

auto_include;
WriteAll;
