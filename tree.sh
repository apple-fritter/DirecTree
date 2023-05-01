#!/bin/bash

print_tree() {
  local prefix="$1"
  local dir="$2"
  local indent="$3"
  
  # Print the current directory
  echo "${indent}${prefix} ${dir}"
  
  # Iterate through the contents of the directory
  local contents=()
  while IFS= read -r -d $'\0' entry; do
    contents+=("$entry")
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0)
  
  local count=1
  local total=${#contents[@]}
  
  for item in "${contents[@]}"; do
    local name=$(basename "$item")
    local is_last=$((count == total))
    
    if [[ -d "$item" ]]; then
      # If it's a directory, recursively print its contents
      local next_prefix=$([[ "$is_last" == 1 ]] && echo "└───" || echo "├───")
      local next_indent=$([[ "$is_last" == 1 ]] && echo "    " || echo "│   ")
      
      print_tree "$next_prefix" "$item" "$indent$next_indent"
    else
      # If it's a file, print its name
      local file_prefix=$([[ "$is_last" == 1 ]] && echo "└───" || echo "├───")
      echo "${indent}${file_prefix} ${name}"
    fi
    
    ((count++))
  done
}

# Set the default working directory to /
root_dir="${1:-/}"

# Get the directory path of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Generate the file tree
output_file="${script_dir}/tree.txt"
print_tree "" "$root_dir" "" > "$output_file"

echo "File tree saved to: $output_file"
