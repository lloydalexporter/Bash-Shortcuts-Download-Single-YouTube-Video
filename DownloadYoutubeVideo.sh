#!/bin/bash

# Script for downloading youtube videos, meant for use with Siri Shortcuts.



# ! - Constants - ! #
YouTubeCmd='/opt/homebrew/bin/youtube-dl'
ffmpegCmd='/opt/homebrew/bin/ffmpeg'
downloadsFolder="/Users/$(whoami)/Downloads"



# Check if the correct binaries are installed.
[[ -f "$YouTubeCmd" ]] || { printf "\nYouTube-DL needs to be installed for this script to run.\nVisit \"https://formulae.brew.sh/formula/youtube-dl\" for more info.\n\n"; exit; }
[[ -f "$ffmpegCmd" ]] || { printf "\nffmpeg needs to be installed for this script to run.\nVisit \"https://formulae.brew.sh/formula/ffmpeg\" for more info.\n\n"; exit; }



# Check if we have any parameter supplied.
if [ $# -eq 0 ]; then
    # We don't have any parameters supplied: Ask until we do.
    videoURL=
	while [[ $videoURL == "" ]]
	do
		echo
        echo Enter the YouTube URL below:
		videoURL=
		read -p "" videoURL
        # If the input is a YouTube link, then continue, else we loop again.
        if [[ "$videoURL" != *"youtu.be"* ]] | [[ "$videoURL" != *"youtube.com"* ]]; then
            echo
            echo This URL is not a youtube video.
            videoURL=
        fi
	done
else
    # We do have a parameter supplied:
    videoURL="$1"
    # If the input is a YouTube link, then continue, else exit.
    if [[ "$videoURL" != *"youtu.be"* ]] | [[ "$videoURL" != *"youtube.com"* ]]; then
        echo
        echo Not a youtube video, try again with a correct link.
        exit 0
    fi
fi

# Get video title and format it.
videoTitle=$($YouTubeCmd -f bestvideo+bestaudio "$videoURL" -o "%(title)s.%(ext)s" --get-title)
videoTitle=$(echo $videoTitle | sed 's/["/]//g')

# Set videoDownload Directory.
videoDirectory="$downloadsFolder/$videoTitle"

# Download the youtube video.
$($YouTubeCmd -k -f bestvideo+bestaudio "$videoURL" -o "$videoDirectory/$videoTitle.%(ext)s") #& wait

# Get the videos full title.
videoFullTitle=$(ls "$videoDirectory" | grep -e "$videoTitle")

# Check if the video is already an MP4 file, if not then convert it to one.
if test $(ls "$videoDirectory" | grep -E "$videoTitle" | wc -l) -eq 2; then
    echo "Two files need combining: $(ls "$videoDirectory" | head -1) and $(ls "$videoDirectory" | tail -1)"
    $ffmpegCmd -i "$videoDirectory/$(ls "$videoDirectory" | head -1)" -i "$videoDirectory/$(ls "$videoDirectory" | tail -1)" "$videoDirectory/$videoTitle.mp4" #& wait
elif [[ -f "$videoDirectory/$videoTitle.mp4" ]]; then
    var=''
else
    $ffmpegCmd -i "$videoDirectory/$videoFullTitle" "$videoDirectory/$videoTitle.mp4" #& wait
fi

# Move the MP4 video file to the Downloads folder.
/bin/mv "$videoDirectory/$videoTitle.mp4" "$downloadsFolder/$videoTitle.mp4" #& wait

# Remove the directory with any undeleted files.
/bin/rm -dr "$videoDirectory" #& wait

echo Done