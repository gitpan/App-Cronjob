
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "wrap up programs to be run as cron jobs",
  "AUTHOR" => "Ricardo Signes <rjbs\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "App-Cronjob",
  "EXE_FILES" => [
    "bin/cronjob"
  ],
  "LICENSE" => "perl",
  "NAME" => "App::Cronjob",
  "PREREQ_PM" => {
    "Digest::MD5" => 0,
    "Email::Sender::Simple" => "0.091661",
    "Email::Simple" => 0,
    "Email::Simple::Creator" => 0,
    "Fcntl" => 0,
    "Getopt::Long::Descriptive" => 0,
    "IPC::Run3" => 0,
    "Log::Dispatchouli" => 0,
    "String::Flogger" => 0,
    "Sys::Hostname::Long" => 0,
    "Text::Template" => 0,
    "Time::HiRes" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Test::More" => "0.96"
  },
  "VERSION" => "1.200002",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Digest::MD5" => 0,
  "Email::Sender::Simple" => "0.091661",
  "Email::Simple" => 0,
  "Email::Simple::Creator" => 0,
  "Fcntl" => 0,
  "Getopt::Long::Descriptive" => 0,
  "IPC::Run3" => 0,
  "Log::Dispatchouli" => 0,
  "String::Flogger" => 0,
  "Sys::Hostname::Long" => 0,
  "Test::More" => "0.96",
  "Text::Template" => 0,
  "Time::HiRes" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



