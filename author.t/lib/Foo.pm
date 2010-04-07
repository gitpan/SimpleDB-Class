package Foo;
our $VERSION = '1.0400';

use Moose;
extends 'SimpleDB::Class';

__PACKAGE__->load_namespaces();

1;

