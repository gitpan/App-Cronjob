
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'wrap up programs to be run as cron jobs',
  'AUTHOR' => 'Ricardo Signes <rjbs@cpan.org>',
  'BUILD_REQUIRES' => {
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'App-Cronjob',
  'EXE_FILES' => [
    'bin/cronjob'
  ],
  'LICENSE' => 'perl',
  'NAME' => 'App::Cronjob',
  'PREREQ_PM' => {
    'Digest::MD5' => '0',
    'Email::Sender::Simple' => '0.091661',
    'Email::Simple' => '0',
    'Email::Simple::Creator' => '0',
    'Errno' => '0',
    'Fcntl' => '0',
    'Getopt::Long::Descriptive' => '0',
    'IPC::Run3' => '0',
    'Log::Dispatchouli' => '0',
    'String::Flogger' => '0',
    'Sys::Hostname::Long' => '0',
    'Text::Template' => '0',
    'Time::HiRes' => '0'
  },
  'VERSION' => '1.101660',
  'test' => {
    'TESTS' => 't/*.t'
  }
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



