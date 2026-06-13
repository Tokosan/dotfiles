# Copies the path of given directory or file to the system or X Windows clipboard.
# Copy current directory if no parameter.
function copypath {
  # If no argument passed, use current directory
  local file="${1:-.}"

  # If argument is not an absolute path, prepend $PWD
  [[ $file = /* ]] || file="$PWD/$file"

  # Copy the absolute path without resolving symlinks
  # If clipcopy fails, exit the function with an error
  print -n "${file:a}" | wl-copy || return 1

  echo ${(%):-"%B${file:a}%b copied to clipboard."}
}


function cdir {
  if [[ -d "$1" ]]; then
    cd "$1"
  else
    mkdir -p "$1" && cd "$1"
  fi
} 

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

