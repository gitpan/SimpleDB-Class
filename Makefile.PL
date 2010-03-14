
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'SimpleDB::Class',
                       'DISTNAME' => 'SimpleDB-Class',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.11'
                                               },
                       'AUTHOR' => 'JT Smith <RIZEN@cpan.org>',
                       'BUILD_REQUIRES' => {},
                       'ABSTRACT' => 'An Object Relational Mapper (ORM) for the Amazon SimpleDB service.',
                       'EXE_FILES' => [],
                       'VERSION' => '1.0200',
                       'PREREQ_PM' => {
                                        'DateTime' => '0',
                                        'XML::Simple' => '0',
                                        'DateTime::Format::Strptime' => '0',
                                        'Digest::SHA' => '0',
                                        'Crypt::SSLeay' => '0.57',
                                        'Test::Deep' => '0',
                                        'MooseX::ClassAttribute' => '0',
                                        'Moose' => '0.93',
                                        'URI' => '0',
                                        'Memcached::libmemcached' => '0.3102',
                                        'Time::HiRes' => '1.9719',
                                        'Sub::Name' => '0.04',
                                        'Test::More' => '0',
                                        'Exception::Class' => '0',
                                        'MooseX::Types' => '0.20',
                                        'Clone' => '0.31',
                                        'Module::Find' => '0',
                                        'UUID::Tiny' => '0',
                                        'JSON' => '2.16',
                                        'LWP' => '5.834'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



