
use strict;
use warnings;



use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'SimpleDB-Class',
  NAME      => 'SimpleDB::Class',
  AUTHOR    => "JT\ Smith\ \<RIZEN\@cpan\.org\>",
  ABSTRACT  => "An\ Object\ Relational\ Mapper\ \(ORM\)\ for\ the\ Amazon\ SimpleDB\ service\.",
  VERSION   => '0.0200',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Net::SSLeay" => '1.35',
    "DateTime" => '0',
    "URI" => '0',
    "Memcached::libmemcached" => '0.3102',
    "XML::Simple" => '0',
    "DateTime::Format::Strptime" => '0',
    "AnyEvent::HTTP" => '1.44',
    "Test::More" => '0',
    "Exception::Class" => '0',
    "Digest::SHA" => '0',
    "UUID::Tiny" => '0',
    "Module::Find" => '0',
    "Test::Deep" => '0',
    "MooseX::ClassAttribute" => '0',
    "Moose" => '0',
  },
  test => {TESTS => 't/*.t'}
);

