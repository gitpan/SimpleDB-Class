package Foo;
our $VERSION = '0.0100';



use Moose;
extends 'SimpleDB::Class';

__PACKAGE__->load_namespaces();

1;

