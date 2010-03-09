package Foo::Parent;
our $VERSION = '1.0101';

use Moose;
extends 'SimpleDB::Class::Item';

__PACKAGE__->set_domain_name('foo_parent');
__PACKAGE__->add_attributes(title=>{isa=>'Str'});
__PACKAGE__->has_many('domains', 'Foo::Domain', 'parentId');

1;

