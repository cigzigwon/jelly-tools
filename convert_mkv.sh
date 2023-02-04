#!/bin/bash

usage()
{
cat << EOF
usage: $0 PARAM [-f|--format] [-t|--tag] [-h|--help]

This script unzips/converts media (.mkv) in bulk via ffmpeg and HandbrakeCLI.

OPTIONS:
   PARAM        The video source name to find
   -h|--help    Show this message
   -f|--format  Override Handbrake preset format: Android 720p30
   -t|--tag  		Tag the media to move to Jellyfin media dir
EOF
}

PARAM=$1; shift
DEST=~/shared
SRC=~/Downloads
FORMAT="Android 720p30"
TAG="movies"

if [ "$PARAM" == -h ]; then
	usage
	exit
fi

while [ ! $# -eq 0 ]; do
    case "$1" in
        -f | --format)
            if [ "$2" ]; then
                FORMAT=$2
                shift
            else
                echo '--format requires a preset format string'
                exit 1
            fi
            ;;
        -t | --tag)
            if [ "$2" ]; then
                TAG=$2
                shift
            else
                echo '--tag requires a name'
                exit 1
            fi
            ;;
        -h | --help)
            usage
            exit
            ;;
        *)
            usage
            exit
            ;;
    esac
    shift
done

for f in ${PARAM}; do
	# recursive find to exec unrar on files @ is search filter string
	find "$SRC" -type f -name "*${f}*.rar" -exec unrar e {} $DEST \;

	# copy all .mkv files to DEST
	find "$SRC" -type f -name "*${f}*.mkv" -exec cp -f {} $DEST \;
done

# run ffmpeg conversion on all .mkx files in DEST
cd $DEST

# loop and convert to .mp4 container
for f in *.mkv; do
	outfile="${f%.mkv}.mp4"

	if [[ $(grep -a '264' "$f" | wc -c) -gt 0 ]]; then
		HandBrakeCLI --preset "$FORMAT" -i "$f" -o "$outfile"
	elif [[ $(grep -a '265' "$f" | wc -c) -gt 0 ]]; then
		HandBrakeCLI --preset "$FORMAT" -i "$f" -o "$outfile"
	else
		ffmpeg -i "$f" -c copy "$outfile"
	fi

	sleep 4
	rm -f "$f"
    
	# curl --insecure -T "$outfile" --user 'chris:$n00ker36' ftp://192.168.1.9

	# move to Jellyfin media dir
	mv -f "$outfile" "/media/chris/${TAG}"
done

rm -f /media/chris/$TAG/*sample*

if [ "$TAG" == shows ] || [ "$TAG" == kids ]; then
    cd ~/webdev/utils/jellyfin_tools && ./mix.sh $TAG
fi
