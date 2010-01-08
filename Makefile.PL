
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



WriteMakefile(
  DISTNAME  => 'App-Cronjob',
  NAME      => 'App::Cronjob',
  AUTHOR    => "Ricardo\ Signes\ \<rjbs\@cpan\.org\>",
  ABSTRACT  => "wrap\ up\ programs\ to\ be\ run\ as\ cron\ jobs",
  VERSION   => '1.100080',
  EXE_FILES => [ "bin\/cronjob" ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Email::Simple::Creator" => '0',
    "ExtUtils::MakeMaker" => '6.11',
    "Time::HiRes" => '0',
    "Email::Sender::Simple" => '0.091661',
    "Log::Dispatchouli" => '0',
    "Digest::MD5" => '0',
    "IPC::Run3" => '0',
    "Getopt::Long::Descriptive" => '0',
    "Email::Simple" => '0',
    "Text::Template" => '0',
    "String::Flogger" => '0',
    "Errno" => '0',
    "Sys::Hostname::Long" => '0',
  },
  test => {TESTS => 't/*.t'}
);



