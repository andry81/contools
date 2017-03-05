# for first line, initialize Buffer Space with default string: "."
1 {
  # copy Pattern Space to Buffer Space
  h
  # replace 1t line of Pattern Space by "."
  s/.*/./
  # exchange Pattern Space with Buffer Space
  x
}

# for strings beginning by #-character (comments and header values before xpath list)
/^#/ {
  # header value: File : "<BasePath>"
  /^#[[:space:]]*File:[[:space:]]*"\?\([^"]*\)"\?/ {
    # append Pattern Space to Buffer Space
    H
    # extract <BasePath>
    s/^#[[:space:]]*File:[[:space:]]*"\?\([^"]*\)"\?/\1/

    # if 1t line of Pattern Space is empty, then set "." to 1t line of Pattern Space
    /./ !{
      s/^$/./
    }

    # append Pattern Space to Buffer Space
    H
    # copy Buffer Space to Pattern Space
    g
    # remove first 2 lines from Pattern Space
    s/.*\n.*\n\(.*\)/\1/
    # exchange Pattern Space with Buffer Space
    x
    # remove 1t and 3d lines from Pattern Space
    s/.*\n\(.*\)\n.*/\1/
  }

  # print Pattern Space
  p
}

# for strings beginning not by #-character (including empty strings)
/^#/ !{
  # for empty string
  /./ !{
    # print Pattern Space
    p
  }

  # for not empty string
  /./ {
    # append Pattern Space to Buffer Space
    H
    # copy Buffer Space to Pattern Space
    g
    # append 2d line to 1t line with "|" character between
    s/\n/|/

    # convert some characters in 1t line of Pattern Space
    s@\\@/@g
    #s@:@/@g

    # print Pattern Space
    p
    # copy Buffer Space to Pattern Space
    g
    # remove 2d line from Pattern Space
    s/\(.*\)\n.*/\1/
    # copy Pattern Space to Buffer Space
    h
    # delete Pattern Space and branch to beginning
    d
  }
}
