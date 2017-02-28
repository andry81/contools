#!/bin/perl

# Author:   Andrey Dibrov (andry at inbox dot ru)

# SaR => Search and Replace.
#
# Perl version required: 5.6.0 or higher (for "@-"/"@+" regexp variables).
#
# Format: sar.pl [<Options>] <SearchPattern> [<ReplacePattern>] [<Flags>]
#         [<RoutineProlog>] [<RoutineEpilog>]
# Script searches in standard input text signatures, matches/replaces them by
# predefined text with regexp variables (\0, \1, ..., \254, \255) and prints
# result dependent on options.
# Command arguments:
#   <Options>: Options, defines basic behaviour of script.
#     [Optional,Fixed]
#     Format: [m | s]
#     m - Forces "match" behaviour, when script prints only matched text without
#         any substitution.
#     s - Forces "substitution" behaviour, when script prints result of
#         substitution.
#     If no options defined, when script chooses which type of behaviour use by
#     presence of <ReplacePattern> argument. See "description".
#   <SearchPattern>: Search pattern string.
#     [Required,Fixed]
#   <ReplacePattern>: Replace pattern string.
#     [Optional,Fixed]
#     Used only in "substitution" behaviour, but can be used in "match" behaviour
#     when execution activated by flags 'e' or 'x'. In case of "match" behaviour
#     execution of replace string internally emulated by substitution.
#   <Flags>:
#     [Optional,Fixed]
#     Format: [i][g][m][e | x]
#     i - Case flag. Case-insensitive search.
#     g - Global flag. Continue search after first match/match last.
#     m - Treat string as multiple lines. Enabling regexp characters - "^" and
#         "$" match begin and end of each line in string, otherwise these
#         characters match begin string and EOF.
#     s - Treat string as single line. Enabling regexp character - "." match any
#         character in string, even "carrage return" or "line feed", otherwise
#         match only line characters (any character except "carrage return" and
#         "line feed").
#     e - Execute and substitute flag. Execute <ReplacePattern> and apply
#         substitution for executed result.
#         Example #1:
#           ./sar.pl s '(123)' 'my $A=$1; $A++; print $A; $1;' 'ge'
#           For each match, prints "124" and replace matched string by result
#           of execution, e.g. by "$1" ("123").
#           After all matches was done, prints input text with applied
#           replacement(s).
#         Example #2:
#           ./sar.pl s '(123)' '$user::A++; print $user::A; $user::A;' 'ge' 'user::$A=$1'
#           For each match, prints a number beginning from 124
#           (123+<number of match>) and replace matched string by result of
#           execution, e.g. by "user::$A" (where "user" is variable scope).
#           After all matches was done, prints input text with applied
#           replacement(s).
#         If "match" behaviour is on, then have the same behaviour as flag 'x'.
#     x - Execute only flag. Execute <ReplacePattern> without substitution.
#         Example #1:
#           ./sar.pl m '(123)' 'my $A=$1; $A++; print $A' 'gx'
#           For each match, prints "124". After all matches was done, nothing
#           prints any more.
#         Example #2:
#           ./sar.pl m '(123)' '$user::A++; print $user::A' 'gx' 'user::$A = $1'
#           For each match, prints a number beginning from 124
#           (123+<number of match>) (where "user" is variable scope).
#           After all matches was done, nothing prints any more.
#   <RoutineProlog>:
#     [Optional,Fixed]
#     Execution routine which executes before all match/substitution if text
#     matched. Enabled only when defined flag 'e' or flag 'x'.
#   <RoutineEpilog>:
#     [Optional,Fixed]
#     Execution routine which executes after all matches/substitutions if text
#     matched. Enabled only when defined flag 'e' or flag 'x'.
# Argument legend:
#   "Required" - value required.
#   "Optional" - value optional.
#   "Fixed" - position of value in argument list is fixed.
# Description:
#   If required arguments are empty, then prints input string if "substitution"
#   behaviour is on, otherwise nothing prints.
#   If replace string is empty and options doesn't defined, then instead
#   substitution used text match only.
#   In "match" behaviour if match was successful, matched text is printed and
#   returns 0, otherwise prints nothing and returns non 0.
#   When "substitution" behaviour is on, script checks execution flag.
#   If execution flag not defined, then script prints input text with
#   applied replacements and returns 0, otherwise prints input text and returns
#   non 0.
#   If execution flag is defined, then script executes replace string in each
#   match, after prints input text with applied replacements (only for flag 'e'),
#   and returns 0, otherwise prints input text and returns non 0.
#

use strict;
#use warnings;

# System variables and functions to be available internally for script.
@sys::numVars = ();
$sys::breakSearch = 0;

sub sys::trim($);
sub sys::ltrim($);
sub sys::rtrim($);

# Perl trim function to remove whitespace from the start and end of the string.
sub sys::trim($)
{
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

# Left trim function to remove leading whitespace.
sub sys::ltrim($)
{
  my $string = shift;
  $string =~ s/^\s+//;
  return $string;
}

# Right trim function to remove trailing whitespace
sub sys::rtrim($)
{
  my $string = shift;
  $string =~ s/\s+$//;
  return $string;
}

# Beginning of main script.

my $buffer = "";
my $subBuffer;
#open FILE, "" or die $!;
my $isEof = eof(STDIN);
my $charsRead = 0;
while(!$isEof) {
  $charsRead = read(STDIN,$subBuffer,65536);
  if($charsRead < 65536) {
    $isEof = 1;
  }
  $buffer .= $subBuffer;
}
$subBuffer = "";

#$buffer = "debug string\n";

if(!defined($buffer) || length($buffer) == 0) {
  exit 1;
}

my $optionsStr = defined($ARGV[0]) ? $ARGV[0] : "";
my $matchStr = defined($ARGV[1]) ? $ARGV[1] : "";
if(length($matchStr) == 0) {
  print($buffer);
  exit 1;
}

my $replaceStr = defined($ARGV[2]) ? $ARGV[2] : "";
my $flagsStr = defined($ARGV[3]) ? $ARGV[3] : "";
my $execPrologStr = defined($ARGV[4]) ? $ARGV[4] : "";
my $execEpilogStr = defined($ARGV[5]) ? $ARGV[5] : "";

#Use "substitution" behaviour.
my $doMatchOnly = 0;
if(index($optionsStr,'m') != -1 ||
  index($optionsStr,'s') == -1 && length($replaceStr) == 0) {
  #Use "match" behaviour.
  $doMatchOnly = 1;
}

my $rexFlags = "";
if(index($flagsStr,'i') != -1) {
  $rexFlags .= 'i';
}
if(index($flagsStr,'g') != -1) {
  $rexFlags .= 'g';
}
if(index($flagsStr,'m') != -1) {
  $rexFlags .= 'm';
}
my $doMultiLine2 = 0;
if(index($flagsStr,'s') != -1) {
  $rexFlags .= 's';
}

my $doEvaluate = 0;
my $doExecuteOnly = 0;
if(index($flagsStr,'x') != -1) {
  $rexFlags .= 'e';
  $doExecuteOnly = 1;
  $doEvaluate = 1;
} elsif(index($flagsStr,'e') != -1) {
  $rexFlags .= 'e';
  $doEvaluate = 1;
}

my $regexpMatched = 0;
my $regexpLastOffset = -1;
my $regexpMatchOffset = -1;
my $regexpNextOffset = 0;

=head
String escape function for regexp expressions.
Returns escaped string.
=cut
sub escapeString#($str,$escapeChars = "/\$@")
{
  my($str,$escapeChars) = @_;
  if(!defined($escapeChars)) {
    $escapeChars = "/\$@";
  }

  my $numeric = "0123456789";
  my $strBuffer = "";

  my $strLen = length($str);
  for(my $i = 0; $i < $strLen; $i++) {
    my $char = substr($str,$i,1);
    if(!defined($char) || length($char) == 0) {
      next;
    }

    my $escCharOffset = index($escapeChars,$char);
    if($escCharOffset != -1) {
      $strBuffer .= "\\";
    }
    $strBuffer .= $char;
  }

  return $strBuffer;
}

=head
Numeric variables expand and escape function.
Returns expanded and escaped string, otherwise only escaped string.
=cut
sub expandString#($str,@numVars,$numVarValueLimit = 256)
{
  my($str,@numVars,$numVarValueLimit) = @_;
  if(!defined($numVarValueLimit) || length($numVarValueLimit) < 1) {
    $numVarValueLimit = 256;
  }

  my $maxNumVarLen = length("".$numVarValueLimit);

  my $numeric = "0123456789";
  my $isEscSeq = 0;
  my $numVar = "";
  my $numVarBuffer = "";
  my $strBuffer = "";
  my $strLen = length($str);
  for(my $i = 0; $i < $strLen; $i++) {
    # Process pending numeric variable.
    if(length($numVarBuffer) >= $maxNumVarLen) {
      if($numVarBuffer <= $numVarValueLimit) {
        # Append not empty value from @numVars.
        $strBuffer .= $numVars[$numVarBuffer];
      }
      $numVarBuffer = "";
      $isEscSeq = 0;
    }

    # Processing next character.
    my $char = substr($str,$i,1);
    if(!defined($char) || length($char) == 0) {
      next;
    }
    if($char eq '\\') {
      # Escape sequence character.
      if(!$isEscSeq) {
        $isEscSeq = 1;
      } else {
        # Process pending numeric variable.
        if(length($numVarBuffer) > 0) {
          if($numVarBuffer <= $numVarValueLimit) {
            # Append not empty value from @numVars.
            $strBuffer .= $numVars[$numVarBuffer];
          }
          $numVarBuffer = "";
        } else {
          # append escape sequence character as ordinary character.
          $strBuffer .= "\\";
          $isEscSeq = 0;
        }
      }
      next;
    }
    my $isNumOffset = index($numeric,$char);
    if($isNumOffset != -1) {
      if(!$isEscSeq) {
        # Not escape character.
        $strBuffer .= $char;
      } else {
        # Read numeric escape sequence until "$maxNumVarLen".
        $numVarBuffer .= $char;
      }
      next;
    }
    # Process pending numeric variable.
    if(length($numVarBuffer) > 0) {
      if($numVarBuffer <= $numVarValueLimit) {
        # Append not empty value from @numVars.
        $strBuffer .= $numVars[$numVarBuffer];
      }
      $numVarBuffer = "";
      $isEscSeq = 0;
    }
    if($isEscSeq) {
      $strBuffer .= '\\';
      $isEscSeq = 0;
    }
    $strBuffer .= $char;
  }

  # Process last numeric variable.
  if(length($numVarBuffer) > 0) {
    if($numVarBuffer <= $numVarValueLimit) {
      # Append not empty value from @numVars.
      $strBuffer .= $numVars[$numVarBuffer];
    }
    $numVarBuffer = "";
    $isEscSeq = 0;
  }

  return $strBuffer;
}

=head
String match function.
Returns array of regexp variables ($0, $1, etc).
If string was matched, then result flag returned in $regexpMatched
variable, otherwise $regexpMatched would empty.
=cut
sub matchString#($str,$strMatch,$rexFlags = "")
{
  my($str,$strMatch,$rexFlags) = @_;
  if(!defined($rexFlags)) {
    $rexFlags = "";
  }
  
  if(!defined($str) || length($str) == 0) {
    return "";
  }

  my $evalFlagOffset = index($rexFlags,'e');
  my $filteredRexFlags = $evalFlagOffset != -1 ?
    substr($rexFlags,0,$evalFlagOffset).substr($rexFlags,$evalFlagOffset+1) : $rexFlags;

  my $globalFlagOffset = index($rexFlags,'g');
  my $sysVarRegexpMatchOffset;
  my $sysVarRegexpNextOffset;
  if($globalFlagOffset != -1) {
    $sysVarRegexpMatchOffset = '$-[$#-]';
    $sysVarRegexpNextOffset = '$+[$#+]';
  } else {
    $sysVarRegexpMatchOffset = '$-[0]';
    $sysVarRegexpNextOffset = '$+[0]';
  }

  my $numVar0;
  my $numVar1;
  my @numVars;
  my $evalStr = '@numVars = ($str =~ m/$strMatch/'.$filteredRexFlags.');'."\n".
    '$numVar0 = $&;'."\n".
    '$numVar1 = $1;'."\n".
    '$regexpMatchOffset = (defined('.$sysVarRegexpMatchOffset.') ? '.$sysVarRegexpMatchOffset.' : 0);'."\n".
    '$regexpNextOffset = (defined('.$sysVarRegexpNextOffset.') ? '.$sysVarRegexpNextOffset.' : 0);'."\n";

  $regexpLastOffset = $regexpMatchOffset;
  eval($evalStr);

  if($#numVars == -1) {
    $numVars[0] = $numVar0;
    $regexpMatched = 0;
  } elsif($#numVars == 0) {
    if(!defined($numVar1)) {
      $numVars[0] = $numVar0;
    } else {
      unshift(@numVars,$numVar0);
    }
    $regexpMatched = 1;
  } else {
    unshift(@numVars,$numVar0);
    $regexpMatched = 1;
  }

  return @numVars;
}

=head
Simple string substitution.
Returns result of substitution.
=cut
sub substString#($str,$toSearch,$toReplace,$rexFlags = "")
{
  my($str,$toSearch,$toReplace,$rexFlags) = @_;
  if(!defined($rexFlags)) {
    $rexFlags = "";
  }

  if(!defined($str) || length($str) == 0) {
    return "";
  }

  my $evalStr;
  my $evalFlagOffset = index($rexFlags,'e');

  my $globalFlagOffset = index($rexFlags,'g');
  my $sysVarRegexpMatchOffset;
  if($globalFlagOffset != -1) {
    $sysVarRegexpMatchOffset = '$-[$#-]';
  } else {
    $sysVarRegexpMatchOffset = '$-[0]';
  }

  if($evalFlagOffset == -1) {
    $evalStr =
      '$str =~ s/$toSearch/$toReplace/'.$rexFlags.';'."\n".
      '$regexpMatchOffset = (defined('.$sysVarRegexpMatchOffset.') ? '.$sysVarRegexpMatchOffset.' : 0);'."\n".
      '$regexpNextOffset = length($str)-(defined($'."'".') ? length($'."'".') : 0);'."\n";
  } else {
    $evalStr =
      '$str =~ s/$toSearch/'.$toReplace.'/'.$rexFlags.';'."\n".
      '$regexpMatchOffset = (defined('.$sysVarRegexpMatchOffset.') ? '.$sysVarRegexpMatchOffset.' : 0);'."\n".
      '$regexpNextOffset = length($str)-(defined($'."'".') ? length($'."'".') : 0);'."\n";
  }

  $regexpLastOffset = $regexpMatchOffset;
  eval($evalStr);

  return $str;
}

my $searchEscapeChars = "/";
my $replaceEscapeChars = "/";

=head
Evaluate search pattern.
=cut
sub evaluateSearchPattern#($doMatchOnly,$doEvaluate,$doExecuteOnly,$str,$toSearch,$toReplace,$execProlog,$execEpilog,$rexFlags = "")
{
  my($doMatchOnly,$doEvaluate,$doExecuteOnly,$str,$toSearch,$toReplace,$execProlog,$execEpilog,$rexFlags) = @_;
  if(!defined($rexFlags)) {
    $rexFlags = "";
  }

  my $evalStr = "";
  my $resultStr;

  my $prevStr = "";
  my $nextStr = $str;
  my $newStr = "";
  my $expandStr;
  my $expandStrLen;

  my $globalFlagOffset = index($rexFlags,'g');
  my $filteredRexFlags = $globalFlagOffset != -1 ?
    substr($rexFlags,0,$globalFlagOffset).substr($rexFlags,$globalFlagOffset+1) : $rexFlags;

  if($doMatchOnly) {
    @sys::numVars = matchString($nextStr,$matchStr,(!$doEvaluate ? $rexFlags : $filteredRexFlags));
    if(!defined($regexpMatched) || length($regexpMatched) == 0 || $regexpMatched == 0) {
      return 2;
    }
    $resultStr = $sys::numVars[0];
    if(defined($execProlog) && length($execProlog) > 0) {
      $evalStr .= $execProlog.';'."\n";
    }
    $prevStr = substr($nextStr,0,$regexpMatchOffset);
    $nextStr = $regexpMatchOffset < length($nextStr) ? substr($nextStr,$regexpMatchOffset) : "";
    if(!$doEvaluate) {
      if(defined($resultStr) && length($resultStr) > 0) {
        $evalStr .= 'print($resultStr);'."\n";
      }
    } else {
      if(length($nextStr) > 0) {
        $evalStr .= 'substString($nextStr,$toSearch,$toReplace,$rexFlags);'."\n";
      }
      if(!$doExecuteOnly) {
        if(defined($resultStr) && length($resultStr) > 0) {
          $evalStr .= 'print($resultStr);'."\n";
        }
      }
    }
    if(defined($execEpilog) && length($execEpilog) > 0) {
      $evalStr .= $execEpilog.';'."\n";
    }
  } else {
    @sys::numVars = matchString($nextStr,$toSearch,$filteredRexFlags);
    if(!defined($regexpMatched) || length($regexpMatched) == 0 || $regexpMatched == 0) {
      if(!$doEvaluate || !$doExecuteOnly) {
        print($str);
      }
      return 2;
    }
    if(defined($execProlog) && length($execProlog) > 0) {
      $evalStr .= $execProlog.';'."\n";
    }
    $evalStr .=
      '$prevStr = substr($nextStr,0,$regexpMatchOffset);'."\n".
      '$nextStr = $regexpMatchOffset < length($nextStr) ? substr($nextStr,$regexpMatchOffset) : "";'."\n".
      'if(!$doEvaluate) {'."\n".
      '  $expandStr = expandString($toReplace,@sys::numVars);'."\n".
      '} else {'."\n".
      '  $expandStr = $toReplace;'."\n".
      '}'."\n".
      '$nextStr = substString($nextStr,$toSearch,$expandStr,$filteredRexFlags);'."\n".
      '$sys::breakSearch = $sys::breakSearch ? 1 : !(defined($nextStr) && length($nextStr) > 0);'."\n".
      'while(!$sys::breakSearch) {'."\n".
      '  $prevStr .= substr($nextStr,0,$regexpNextOffset);'."\n".
      '  $nextStr = $regexpNextOffset < length($nextStr) ? substr($nextStr,$regexpNextOffset) : "";'."\n".
      '  @sys::numVars = matchString($nextStr,$toSearch,$filteredRexFlags);'."\n".
      '  $sys::breakSearch = !(defined($regexpMatched) && length($regexpMatched) != 0 &&'."\n".
      '    $regexpMatched != 0 && ($regexpLastOffset < $regexpMatchOffset || $regexpMatchOffset < $regexpNextOffset));'."\n".
      '  if(!$sys::breakSearch) {'."\n".
      '    $prevStr .= substr($nextStr,0,$regexpMatchOffset);'."\n".
      '    $nextStr = $regexpMatchOffset < length($nextStr) ? substr($nextStr,$regexpMatchOffset) : "";'."\n".
      '    if(!$doEvaluate) {'."\n".
      '      $expandStr = expandString($toReplace,@sys::numVars);'."\n".
      '    } else {'."\n".
      '      $expandStr = $toReplace;'."\n".
      '    }'."\n".
      '    $nextStr = substString($nextStr,$toSearch,$expandStr,$filteredRexFlags);'."\n".
      '    $sys::breakSearch = $sys::breakSearch ? 1 : !(defined($nextStr) && length($nextStr) > 0);'."\n".
      '  }'."\n".
      '}'."\n".
      '$newStr = (defined($prevStr) ? $prevStr : "").(defined($nextStr) ? $nextStr : "");'."\n".
      'if(!$doExecuteOnly) {'."\n".
      '  if(length($newStr) > 0) {'."\n".
      '    print($newStr);'."\n".
      '  }'."\n".
      '}'."\n";
    if(defined($execEpilog) && length($execEpilog) > 0) {
      $evalStr = $execEpilog.';'."\n";
    }
  }

  if(defined($evalStr) && length($evalStr) > 0) {
    eval($evalStr);
  }

  return 0;
}

my $resultStr;

# Escape match string for safer execution.
$matchStr = escapeString($matchStr,$searchEscapeChars);

if($doEvaluate) {
  $replaceStr = escapeString($replaceStr,$replaceEscapeChars);
}

my $resultCode = evaluateSearchPattern($doMatchOnly,$doEvaluate,$doExecuteOnly,
  $buffer,$matchStr,$replaceStr,$execPrologStr,$execEpilogStr,$rexFlags);

exit $resultCode;
