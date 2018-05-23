# Copies txt files to mod directory

output="C:/Program Files (x86)/Steam/steamapps/common/Judgment/Mods"
modfolder="MTC"
verbose=0
delete=0

function usage {
  echo "
    Usage:
     -o:   Mod folder for Judgment. Default: '{PATH_TO_STEAM}/steamapps/common/Judgment/Mods'
     -m:   Mod Folder name. Default: `MTC`
     -d:   Delete old mod folder first
     -h:   Prints this help message
     "
}

while getopts :o:m:dv option
do
 case "${option}"
 in
 o) output="$option";;
 m) modfolder="$option";;
 d) delete=1;;
 v) verbose=1;; 
 *) usage; exit 0;;
 esac
done

function print_verbose {
  if [[ "$verbose" -eq 1 ]]; then
    echo "$1"
  fi
}

if [ ! -d "$output" ]; then
  echo "Output directory not found: '$output'"
  exit 1
else
  print_verbose "Output Directory Found: '$output'"
fi

path="$output/$modfolder"

# Delete Old Folder
if [[ "$delete" -eq 1 ]]; then
  if [ -d "$path" ]; then
    echo "Deleting Old Mod Folder: '$path'"
    rm -rf "$path"
  fi
fi

if [ ! -d "$path" ]; then
  print_verbose "Creating Mod Folder: '$path'"
  mkdir "$path"  
fi

# Copy Files Over
print_verbose "Copying JSON"
cp "ModConfig.json" "$path"

for file in *.txt; do
    [ -f "$file" ] || break
    print_verbose "Copying File: '$file'"
    cp "$file" "$path"
done


sprite_path="$path/Sprites"
if [ ! -d "$sprite_path" ]; then
  mkdir "$sprite_path"
fi

for file in Sprites/*; do
    [ -f "$file" ] || break
    print_verbose "Copying Image: '$file'"
    cp "$file" "$sprite_path"
done

# Done
print_verbose "---"
echo "Finished Copying Mod to: '$path'"
