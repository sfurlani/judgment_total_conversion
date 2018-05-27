#!/bin/bash

echo "Make Sure there is a newline at the end of all your files, or else it won't grab the item"

echo "Also make sure your entity names do not include '_'"

function getname {
    local cat=$1 item=$2 kind=$3
    retname="${cat}_${item}_${kind}"
}

function getval {
    getname $1 $2 $3
    retval=$(printf '%s' "${!retname}")
}

filenames=("Skills_Override.txt" "Professions_Override.txt" "SkillLists_Override.txt" "Items.txt")
# "Objects.txt" "Enemies.txt"

valuenames=()

for filename in "${filenames[@]}"; do
echo ""
count=0
while read line; do
# Empty or Comment, Continue
[[ "$line" == \#* ]] && continue
[ -z "$line" ] && continue
[[ ! "$line" =~ [^[:space:]] ]] && continue

IFS='.' read -r cat entity item ignore <<<"$line"

# Check if it's an entity that needs a name
[[ "$cat" == "crafting" ]] && continue
[[ ! "$entity" == "entity" ]] && continue

getval $cat $item "name" 

# continue if we already set it
[[ ! -z $retval ]] && continue
let "count++"
declare "${retname}=${item} temp"
valuenames+=("${retname}")
getval $cat $item "name"
# echo "${retname} $retval"
echo -ne "\e[0K\r$filename count: ${count}"

done < "$filename" # lines in files
done # files


echo -ne "\nReading current Texts File to prevent overwrite"

while read line; do
# Empty or Comment, Continue
[[ "$line" == \#* ]] && continue
[ -z "$line" ] && continue
[[ ! "$line" =~ [^[:space:]] ]] && continue

IFS='.' read -r cat item kindtext <<<"$line"
IFS='=' read -r kind text <<<"$kindtext"
getname $cat $item $kind 
declare "${retname}=${text}"

if [[ ! " ${valuenames[@]} " =~ " ${retname} " ]]; then
    valuenames+=("${retname}")
fi

done < Texts.txt

totalvalues="${#valuenames[@]}"
echo -ne "\n\nTotal Values: ${totalvalues}\n"
IFS=$'\n' sorted=($(sort <<<"${valuenames[*]}"))

# Final Print
echo "Writing to Texts file"
echo "" > Texts.txt # empty
exec 3<> Texts.txt
count=0
for name in "${sorted[@]}"; do

IFS='_' read -r cat item kind <<<"$name"
if [[ ! "$cat" == "$curcat" ]]; then
    echo "" >&3
    echo "# ==============================" >&3
    echo "# $cat" >&3
    echo "# ==============================" >&3
    curcat="$cat"
fi
getval $cat $item $kind

let "count++"
echo "${cat}.${item}.${kind}=${retval}" >&3
echo -ne "\e[0K\rWriting: ${count}/${totalvalues}"

done # Names

echo "" >&3

exec 3>&-

echo -ne "\nDone!"

unset IFS
