#!/bin/bash

DEST=~/shared
SRC=~/Downloads
FORMAT="Android 720p30"

for f in ${@}; do
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

	if [[ $(grep -e '264' "$f" | wc -c) -gt 0 ]]; then
		HandBrakeCLI --preset "$FORMAT" -i "$f" -o "$outfile"
	elif [[ $(grep -e '265' "$f" | wc -c) -gt 0 ]]; then
		HandBrakeCLI --preset "$FORMAT" -i "$f" -o "$outfile"
	else
		ffmpeg -i "$f" -c copy "$outfile"
	fi

	sleep 4
	rm -f "$f"
	curl --insecure -T "$outfile" --user 'chris:$n00ker36' ftp://192.168.1.9
	mv -f "$outfile" /media/chris/
done
