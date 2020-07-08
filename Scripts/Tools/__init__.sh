#!/bin/bash

# init script search logic
for i in ".." "../.."; do
  for j in "__init__/__init__.sh" "__init__.sh"; do
    tkl_normalize_path "$BASH_SOURCE_DIR/$i/$j" -a && \
    [[ "$RETURN_VALUE" != "$BASH_SOURCE_FILE" && -e "$RETURN_VALUE" ]] && { tkl_include "$BASH_SOURCE_DIR/$i/$j" "$@"; return $?; }
  done
done

return 255
