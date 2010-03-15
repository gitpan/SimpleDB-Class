package Foo;
our $VERSION = '1.0300';

use Moose;
extends 'SimpleDB::Class';

__PACKAGE__->load_namespaces();

1;

