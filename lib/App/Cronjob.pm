use strict;
use warnings;
package App::Cronjob;
BEGIN {
  $App::Cronjob::VERSION = '1.101230';
}
# ABSTRACT: wrap up programs to be run as cron jobs

use Digest::MD5 qw(md5_hex);
use Errno;
use Fcntl;
use Getopt::Long::Descriptive;
use IPC::Run3 qw(run3);       
use Log::Dispatchouli;
use String::Flogger;
use Sys::Hostname::Long;
use Text::Template;
use Time::HiRes ();


my $TEMPLATE;

my (
  $opt,
  $usage,
  $subject,
  $rcpts,
  $host,
  $sender,
);

sub run {
  ($opt, $usage) = describe_options(
    '%c %o',
     [ 'command|c=s',   'command to run (passed to ``)', { required => 1 }   ],
     [ 'subject|s=s',   'subject of mail to send (defaults to command)'      ],
     [ 'rcpt|r=s@',     'recipient of mail; may be given many times',        ],
     [ 'errors-only|E', 'do not send mail if exit code 0, even with output', ],
     [ 'sender|f=s',    'sender for message',                                ],
     [ 'jobname|j=s',   'job name; used for locking, if given'               ],
     [ 'ignore-errors=s@', 'error types to ignore (like: lock)'              ],
     [ 'lock!',         'lock this job (defaults to true; --no-lock for off)',
                        { default => 1 }                                     ],
  );

  $subject = $opt->{subject} || $opt->{command};
  $subject =~ s{\A/\S+/([^/]+)(\s|$)}{$1$2} if $subject eq $opt->{command};

  $rcpts   = $opt->{rcpt}
          || [ split /\s*,\s*/, ($ENV{MAILTO} ? $ENV{MAILTO} : 'root') ];

  $host    = hostname_long;
  $sender  = $opt->{sender} || sprintf '%s@%s', ($ENV{USER}||'cron'), $host;

  my $lockfile = sprintf '/tmp/cronjob.%s',
                 $opt->{jobname} || md5_hex($subject);

  my $got_lock = 0;

  my $okay = eval {
    die "illegal job name: $opt->{jobname}\n"
      if $opt->{jobname} and $opt->{jobname} !~ m{\A[-_A-Za-z0-9]+\z};

    my $logger  = Log::Dispatchouli->new({
      ident    => 'cronjob',
      facility => 'cron',
    });

    goto LOCKED if ! $opt->{lock};

    my $ok = sysopen my $lock_fh, $lockfile, O_CREAT|O_EXCL|O_WRONLY;
    unless ($ok) {
      if ($!{EEXIST}) {
        if (my $mtime = (stat $lockfile)[9]) {
          my $stamp = scalar localtime $mtime;
          die App::Cronjob::Exception->new(
            lock => "can't lock; locked since $stamp"
          );
        } 

        # We couldn't get mtime, presumably because the file got deleted
        # between the EEXIST and the stat.  Stupid race conditions! -- rjbs,
        # 2009-02-18
        die App::Cronjob::Exception->new(
          lock => "can't lock; was locked already"
        );
      } else {
        die App::Cronjob::Exception->new(
          lock => "couldn't open lockfile $lockfile: $!"
        );
      }
    }

    $got_lock = 1;

    printf $lock_fh "running %s\nstarted at %s\n",
      $opt->{command}, scalar localtime $^T;

    LOCKED:

    $logger->log([ 'trying to run %s', $opt->{command} ]);

    my $start = Time::HiRes::time;
    my $output;

    # XXX: does not throw proper exception
    $logger->log_fatal([ 'run3 failed to run command: %s', $@ ])
      unless eval { run3($opt->{command}, \undef, \$output, \$output); 1; };

    my %waitpid = (
      status => $?,
      exit   => $? >> 8,
      signal => $? & 127,
      core   => $? & 128,
    );

    my $end = Time::HiRes::time;

    my $send_mail = ($waitpid{status} != 0)
                 || (length $output && ! $opt->{errors_only});

    my $time_taken = sprintf '%0.4f', $end - $start;

    $logger->log([
      'job completed with status %s after %ss',
      \%waitpid,
      $time_taken,
    ]);

    if ($send_mail) {
      send_cronjob_report({
        is_fail => (!! $waitpid{status}),
        waitpid => \%waitpid,
        time    => \$time_taken,
        output  => \$output,
      });
    }

    1;
  };

  unlink $lockfile if $got_lock and -e $lockfile;

  exit 0 if $okay;
  my $err = $@;

  if (eval { $err->isa('App::Cronjob::Exception'); }) {
    unless (
      grep { $err->{type} and $_ eq $err->{type} } @{$opt->{ignore_errors}}
    ) {
      send_cronjob_report({
        is_fail => 1,
        output  => \$err->{text},
      });
    }

    exit 0;
  } else {
    $subject = "ERROR: $subject";
    send_cronjob_report({
      is_fail => 1,
      output  => \$err
    });
    exit 0;
  }
}

# read INI from /etc/cronjob
#sub __config {
#}

sub send_cronjob_report {
  my ($arg) = @_;
  my $waitpid = $arg->{waitpid} || { no_result => 'never ran' };

  require Email::Simple;
  require Email::Simple::Creator;
  require Email::Sender::Simple;
  require Text::Template;

  my $body     = Text::Template->fill_this_in(
    $TEMPLATE,
    HASH => {
      command => \$opt->{command},
      output  => $arg->{output},
      time    => $arg->{time} || \'(n/a)',
      waitpid => $waitpid,
    },
  );

  my $subject = sprintf '%s%s', ($arg->{is_fail} ? 'FAIL: ' : ''), $subject;

  my $irt = sprintf '<%s@%s>', md5_hex($subject), $host;

  my $email = Email::Simple->create(
    body   => $body,
    header => [
      To      => join(', ', @$rcpts),
      From    => qq{"cron/$host" <$sender>},
      Subject => $subject,
      'In-Reply-To' => $irt,
    ],
  );

  Email::Sender::Simple->send(
    $email,
    {
      to      => $rcpts,
      from    => $sender,
    }
  );
}

BEGIN {
# Sure, a here-doc would be nicer, but PPI hates here-docs, I use PodPurler,
# and PodPurler uses PPI.  Oh well. -- rjbs, 2009-04-21
$TEMPLATE = <<'END_TEMPLATE'
Command: { $command }
Time   : { $time }s
Status : { String::Flogger->flog([ '%s', \%waitpid ]) }

Output :

{ $output || '(no output)' }
END_TEMPLATE
}

{
  package App::Cronjob::Exception;
BEGIN {
  $App::Cronjob::Exception::VERSION = '1.101230';
}
  sub new {
    my ($class, $type, $text) = @_;
    bless { text => $text, type => $type } => $class;
  }
}

1;

__END__
=pod

=head1 NAME

App::Cronjob - wrap up programs to be run as cron jobs

=head1 VERSION

version 1.101230

=head1 SEE INSTEAD

This library, App::Cronjob, is not well documented.  Its internals may change
substantially until such point as it is documented.

Instead of using the library, you should run the program F<cronjob> that is
installed along with the library.

=head1 AUTHOR

  Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

