
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'App::Cronjob',
                       'DISTNAME' => 'App-Cronjob',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.31'
                                               },
                       'AUTHOR' => 'Ricardo Signes <rjbs@cpan.org>',
                       'BUILD_REQUIRES' => {
                                             'Test::More' => '0'
                                           },
                       'ABSTRACT' => 'wrap up programs to be run as cron jobs',
                       'EXE_FILES' => [
                                        'bin/cronjob'
                                      ],
                       'VERSION' => '1.101230',
                       'PREREQ_PM' => {
                                        'Email::Simple::Creator' => '0',
                                        'Fcntl' => '0',
                                        'Time::HiRes' => '0',
                                        'Email::Sender::Simple' => '0.091661',
                                        'Log::Dispatchouli' => '0',
                                        'Digest::MD5' => '0',
                                        'IPC::Run3' => '0',
                                        'Email::Simple' => '0',
                                        'Getopt::Long::Descriptive' => '0',
                                        'Text::Template' => '0',
                                        'Errno' => '0',
                                        'String::Flogger' => '0',
                                        'Sys::Hostname::Long' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM}; 
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod}; 
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



