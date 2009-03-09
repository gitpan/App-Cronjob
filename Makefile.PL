
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'App-Cronjob',
  NAME      => 'App::Cronjob',
  AUTHOR    => 'Ricardo\ Signes\ \<rjbs\@cpan\.org\>',
  ABSTRACT  => 'wrap up programs to be run as cron jobs',
  VERSION   => '1.000',
  EXE_FILES => [ qw(bin/cronjob) ],
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Email::Simple::Creator" => '0',
    "Email::Sender::Transport::Sendmail" => '0',
    "Fcntl" => '0',
    "Time::HiRes" => '0',
    "Log::Dispatchouli" => '0',
    "Digest::MD5" => '0',
    "IPC::Run3" => '0',
    "Getopt::Long::Descriptive" => '0',
    "Email::Simple" => '0',
    "Sys::Hostname::Long" => '0',
    "Errno" => '0',
    "String::Flogger" => '0',
    "Text::Template" => '0',
  },
);
