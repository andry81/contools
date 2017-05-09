#!/bin/perl

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Description
#   Script indexes standard input stream by line print time, offset from begin
#   of stream and size of line.

# Command arguments: [-a] <FilePath> [<TimeScale>]
#   -a - Append to <FilePath>, instead create new file.
#   <FilePath> - File which stores indexing data.
#   <TimeScale> - Resolution of time:
#     100       -  1s,
#     1000      - (Default) 100ms,
#     10000     - 10ms,
#     100000    - 1ms,
#     1000000   - 100mks,
#     10000000  - 10mks,
#     100000000 - 1mks,
#     etc.

# Examples:
# 1. #!/bin/sh
#    function foo()
#    {
#      echo 1
#      sleep 1
#      echo 12
#      echo 12 >&2
#      echo 123
#      echo 123 >&2
#      echo 1234
#      echo 1234 >&2
#      sleep 1
#      echo 12345
#      echo 123456
#      echo 12345 >&2
#      echo 123456 >&2
#    }
#
#    # 2-phase redirection
#    {
#    {
#      foo
#    } 2>&1 >&6 | perl ./pipetimes.pl -a "$ErrIndexFilePath" | tee -a "$ErrFilePath" >&2
#    } 6>&1 | perl ./pipetimes.pl -a "$OutIndexFilePath" | tee -a "$OutFilePath"
#
#    # 3-phase redirection
#    {
#    {
#    {
#      foo
#    } 2>&1 >&6 | perl ./pipetimes.pl -a "$ErrIndexFilePath" | tee -a "$ErrFilePath" >&7 2>/dev/null
#    } 6>&1 | perl ./pipetimes.pl -a "$OutIndexFilePath" | tee -a "$OutFilePath"
#    } 7>&2

use strict;
#use warnings;

my $fileName = $ARGV[0];
if(!defined($fileName) || length($fileName) < 1)
{
  exit 1;
}

my $timeScale;
my $openMode = '>';
if($fileName eq '-a')
{
  $fileName = $ARGV[1];
  $openMode = '>>';

  $timeScale = $ARGV[2];
}
else
{
  $timeScale = $ARGV[1];
}

if(!defined($fileName) || length($fileName) < 1)
{
  exit 2;
}

if(!defined($timeScale) || length($timeScale) < 1)
{
  $timeScale = 1000;
}

open(fileHandle,$openMode,$fileName) || die "pipetimes.pl: error: Can't open user output file\n";

use Time::HiRes qw(clock_gettime clock_getres CLOCK_REALTIME);

$| = 1;

my $strBuffer;
my $pipeTime = 0;
my $pipeCharsRead = 0;
my $overallCharsRead = 0;

my $timeRes = clock_getres(CLOCK_REALTIME);
if($timeRes == -1)
{
  exit 3;
}
if($timeRes < 1)
{
  $timeRes = int(1/$timeRes);
}

while($strBuffer = <STDIN>)
{
  $pipeTime = clock_gettime(CLOCK_REALTIME);
  $pipeCharsRead = length($strBuffer);
  print fileHandle sprintf("%X",($pipeTime/$timeRes)*$timeScale)," $overallCharsRead $pipeCharsRead\n";
  if($pipeCharsRead > 0)
  {
    print $strBuffer;
    $overallCharsRead += $pipeCharsRead;
  }
}
