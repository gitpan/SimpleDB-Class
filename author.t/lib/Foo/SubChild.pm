package Foo::SubChild;
our $VERSION = '1.0101';

use Moose;
extends 'Foo::Child';

__PACKAGE__->add_attributes(tribe=>{isa=>'Str'});

1;
