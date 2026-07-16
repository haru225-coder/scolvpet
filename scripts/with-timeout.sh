#!/bin/sh
set -eu

if [ "$#" -lt 2 ]; then
  printf 'usage: %s SECONDS COMMAND [ARGS...]\n' "$0" >&2
  exit 2
fi

seconds="$1"
shift
case "$seconds" in
  ''|*[!0-9]*)
    printf 'timeout must be a positive integer: %s\n' "$seconds" >&2
    exit 2
    ;;
esac

# macOS ships Perl while Linux CI normally has GNU timeout; use either without
# adding a repository dependency just for build-command cancellation.
if command -v perl >/dev/null 2>&1; then
  exec perl -e '
    use POSIX qw(setpgid);
    my ($seconds, @command) = @ARGV;
    my $pid = fork();
    die "fork failed: $!\n" unless defined $pid;
    if ($pid == 0) {
      setpgid(0, 0);
      exec @command or die "exec failed: $command[0]: $!\n";
    }
    my $timed_out = 0;
    $SIG{ALRM} = sub {
      $timed_out = 1;
      kill "TERM", -$pid;
      sleep 1;
      kill "KILL", -$pid;
    };
    alarm $seconds;
    waitpid($pid, 0);
    alarm 0;
    exit 124 if $timed_out;
    exit 128 + ($? & 127) if $? & 127;
    exit $? >> 8;
  ' "$seconds" "$@"
fi

if command -v gtimeout >/dev/null 2>&1; then
  exec gtimeout --signal=TERM --kill-after=1s "${seconds}s" "$@"
fi

if command -v timeout >/dev/null 2>&1; then
  exec timeout --signal=TERM --kill-after=1s "${seconds}s" "$@"
fi

printf 'no timeout implementation found; install Perl, gtimeout, or timeout\n' >&2
exit 127
