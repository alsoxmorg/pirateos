#!/opt/suckless/bin/mksh

# Color codes
BLUE='\033[1;34m'
GREEN='\033[1;32m'
PINK='\033[1;35m'
RESET='\033[0m'

# Accept optional directory argument
DIR="${1:-.}"

# Loop over files in specified directory
for f in "$DIR"/*; do
    name="${f##*/}"  # strip path for printing

    if [ -d "$f" ]; then
        print "${BLUE}${name}/${RESET}"
    elif [ -x "$f" ] && [ ! -d "$f" ]; then
        print "${GREEN}${name}*${RESET}"
    else
        case "$name" in
            *.jpg|*.jpeg|*.png|*.bz2|*.ff.bz2)
                print "${PINK}${name}${RESET}"
                ;;
            *)
                print "$name"
                ;;
        esac
    fi
done
