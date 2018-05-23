# Copies over the Log files to my working directory since I hate having a dozen Explorer windows open

input="C:/Program Files (x86)/Steam/steamapps/common/Judgment/judgment_Data/output_log.txt"
verbose=0
do_open=0

function usage {
  echo "
    Usage:
    -f:  Log File. Default: '{PATH_TO_STEAM}/steamapps/common/Judgment/judgment_Data/output_log.txt'
    -v:  Run Verbosely
    -o:  Open File after Copying
    -h:  Prints this help message
    "
}

while getopts :f:ov option
do
 case "${option}"
 in
 f) input="$option";;
 o) do_open=1;;
 v) verbose=1;;
 *) usage; exit 0;;
 esac
done

function print_verbose {
  if [[ "$verbose" -eq 1 ]]; then
    echo "$1"
  fi
}

if [ ! -f "$input" ]; then
  echo "File Not Found: '$input'"
  exit 1
else
  print_verbose "Found Log File: '$input'"
fi

output="Logs"

if [ ! -d "$output" ]; then
  print_verbose "Creating Log Folder: '$output'"
  mkdir "$output"
fi

timestamp=$(date +%Y-%0m-%0d_%0H-%0M-%0S)
filename="output_log_$timestamp.txt"
path="$output/$filename"
print_verbose "Copying To Output File: '$path'"
cp "$input" "$path"

print_verbose "---"
echo "Copied File: '$filename'"

if [[ "$do_open" -eq 1 ]]; then
    case "$OSTYPE" in
        solaris*) echo "SOLARIS" ;;
        darwin*)  open "$path" ;; 
        linux*)   echo "LINUX" ;;
        bsd*)     echo "BSD" ;;
        msys*)    start "$path" ;;
        *)        echo "unknown: $OSTYPE" ;;
    esac
fi
