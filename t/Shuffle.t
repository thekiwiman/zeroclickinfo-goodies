#!/usr/bin/env perl

use strict;
use warnings;
use Test::Deep;
use Test::More;
use DDG::Test::Goodie;

zci answer_type => "shuffle";
zci is_cached   => 0;

sub build_structured_answer {
    my $items = shift;
    my @items = @$items;
    my $show = "[@{[join ', ', @items]}]";
    return "$show",
        structured_answer => {

            data => {
                title    => re(qr/^\[.+?\]$/),
                items    => bag(@items),
                subtitle => "Shuffle: $show",
            },

            templates => {
                group => "text",
            }
        };
}

sub build_test { test_zci(build_structured_answer(@_)) }

ddg_goodie_test(
    [qw( DDG::Goodie::Shuffle )],
    # Different types of brackets
    'shuffle [1, 2]' => build_test([1, 2]),
    'shuffle (1, 2)' => build_test([1, 2]),
    'shuffle {1, 2}' => build_test([1, 2]),
    # In words
    'shuffle 1 and 2 and 3'  => build_test([1, 2, 3]),
    'shuffle 1, 2, and 3'    => build_test([1, 2, 3]),
    'shuffle 1 and 2, and 3' => build_test([1, 2, 3]),
    # Ranges
    'shuffle (1..3)'   => build_test([1, 2, 3]),
    'shuffle a..c'     => build_test(['a', 'b', 'c']),
    'shuffle 1..30'    => build_test([1..30]), # Max items with range
    'shuffle 1..31'    => undef, # Too many range items
    'shuffle 1+7..8'   => undef,
    'shuffle die..die' => undef,
    # Trailing form
    '[1, 2] shuffled' => build_test([1, 2]),
    # Nothing to shuffle
    'shuffle []'  => undef,
    'shuffle [1]' => undef,
    'shuffle'     => undef,
);

done_testing;
