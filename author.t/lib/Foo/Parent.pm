package Foo::Parent;
our $VERSION = '0.0001';



use Moose;
extends 'SimpleDB::Class::Domain';

__PACKAGE__->set_name('foo_parent');
__PACKAGE__->add_attributes(title=>{isa=>'Str'});
__PACKAGE__->has_many('domains', 'Foo::Domain', 'parentId');

1;

