# for first line, initialize Buffer Space with default string: "."
1 {
  # copy Pattern Space to Buffer Space
  h
  # replace 1t line of Pattern Space by "."
  s/[^\r]*/./
  # exchange Pattern Space with Buffer Space
  x
}

# for strings beginning by #-character (comments and header values before xpath list)
/^#/ {
  # header value: `File : "<BasePath>"'
  /^#[[:space:]]*File:[[:space:]]*\"\?\([^\"[:space:]\r]*\)\"\?/ {
    # append Pattern Space to Buffer Space
    H
    # extract <BasePath>
    s/^#[[:space:]]*File:[[:space:]]*\"\?\([^\"[:space:]\r]*\)\"\?/\1/

    # sed workaround for trim spaces and quotes around <BasePath> if previous pattern has failed
    s/^[[:space:]]*\([^[:space:]\r]\)/\1/
    s/\([^[:space:]\r]\)[[:space:]]*\r\?$/\1/
    s/^\"//
    s/\"\r\?$//

    # if 1t line of Pattern Space is empty or has only space/tab characters, then set "." to 1t line of Pattern Space
    /[^[:space:]\r]/ !{
      s/[^\r]*/./
    }

    # append Pattern Space to Buffer Space
    H
    # copy Buffer Space to Pattern Space
    g
    # remove first 2 lines from Pattern Space
    s/[^\r]*\r\?\n[^\r]*\r\?\n\([^\r]*\r\?\)/\1/
    # exchange Pattern Space with Buffer Space
    x
    # remove 1t and 3d lines from Pattern Space
    s/[^\r]*\r\?\n\([^\r]*\r\?\)\n[^\r]*/\1/
  }
}

# for strings beginning not by #-character (including empty strings)
/^#/ !{
  # for not empty string
  /[^\r]/ {
    # for string has not space/tab characters
    /[^[:space:]\r]/ {
      # append Pattern Space to Buffer Space
      H
      # copy Buffer Space to Pattern Space
      g
      # append 2d line to 1t line with "|" character between
      s/\r\?\n/|/

      # escape all findstr regex characters in 1t line of Pattern Space
      s@\\@/@g
      #s@:@/@g
      s/\./\\./g
      s/\[/\\[/g
      s/\]/\\]/g
      s/\^/\\^/g
      s/\$/\\$/g

      # print Pattern Space
      p

      # copy Buffer Space to Pattern Space
      g
      # remove 2d line from Pattern Space
      s/\([^\r]*\)\r\?\n[^\r]*/\1/
      # copy Pattern Space to Buffer Space
      h
      # delete Pattern Space and branch to beginning
      d
    }
  }
}
