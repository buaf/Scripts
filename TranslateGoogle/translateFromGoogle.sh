#!/bin/bash


if (( $# != 3 ))
then
	echo "Example: $0 \"en\" \"ru\" \"Example text\"";
	exit
#else
#	for i; do 
#		printf "\nInput: $i"; 
#	done
fi

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

inputLanguage=$1; 
outputLanguage=$2;
data=$(rawurlencode "$3");
text=${data//":a;N;$!ba;s/\n/ /g"/ }

#printf "\n\nTranslated text:$text\n\n";

executeQuery="http://translate.google.com/translate_a/t?client=p&text=$text&hl=$inputLanguage&sl=$inputLanguage&tl=$outputLanguage&ie=UTF-8&oe=UTF-8&multires=1&prev=btn&ssel=0&tsel=0&sc=1"

#printf "Execute query:$executeQuery"

translateJson=$(curl -A "Mozilla/5.0" "$executeQuery");

#printf "\n===============================================================================\n\n";

#echo "Google returned json:$translateJson";


translateRegex="\"trans\":\"[^\"]+\"";
if [[ $translateJson =~ $translateRegex ]]; then
    match="<strong>${BASH_REMATCH}</strong>"
    deleteOne=${match//\"/}
    deleteTwo=${deleteOne//\:/}
    echo ${deleteTwo//"trans"/}	  
fi


echo "<ul>"
wordRegex="\"word\":\"[^\"]+";
translateArray=(${translateJson//{/ })
for i in "${!translateArray[@]}"
do
	piece=${translateArray[i]}
	if [[ $piece =~ $wordRegex ]]; then
        	match="${BASH_REMATCH}"
                deleteOne=${match//\"/}
                deleteTwo=${deleteOne//\:/}
                echo "<li>${deleteTwo//"word"/}</li>"	 
        fi
done
echo "</ul>"


