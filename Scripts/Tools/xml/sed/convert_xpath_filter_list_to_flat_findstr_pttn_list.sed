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
    # appent Pattern Space to Buffer Space
    H
    # extract <BasePath>
    s/^#[[:space:]]*File:[[:space:]]*"\?\([^"]*\)"\?/\1/

    # if empty, set "." to 1t line of Pattern Space
    /./ !{
      s/^$/./
    }

    # appent Pattern Space to Buffer Space
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
}

# for strings beginning not by #-character (including empty strings)
/^#/ !{
  # for not empty string
  /./ {
    # appent Pattern Space to Buffer Space
    H
    # copy Buffer Space to Pattern Space
    g
    # append 2d line to 1t line with "|" character between
    s/\n/|/

    # escape all findstr regex characters in 1t line of Pattern Space
    s@\\@/@g
    #s@:@/@g
    s/\./\\\./g
    s/\[/\\\[/g
    s/\]/\\\]/g
    s/\^/\\\^/g
    s/\$/\\\$/g

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
