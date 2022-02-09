#!/bin/bash

# Script for downloading youtube videos, meant for use with Siri Shortcuts.
# GitHub Link -> https://github.com/lloydalexporter/Bash-Shortcuts-Download-Single-YouTube-Video
# Shortcut Link -> 


# ! - Constants - ! #
YouTubeCmd='/opt/homebrew/bin/youtube-dl'
ffmpegCmd='/opt/homebrew/bin/ffmpeg'
downloadsFolder="/Users/$(whoami)/Downloads"


# Check if the correct binaries are installed.
[[ -f "$YouTubeCmd" ]] || { printf "\nYouTube-DL needs to be installed for this script to run.\nVisit \"https://formulae.brew.sh/formula/youtube-dl\" for more info.\n\n"; exit; }
[[ -f "$ffmpegCmd" ]] || { printf "\nffmpeg needs to be installed for this script to run.\nVisit \"https://formulae.brew.sh/formula/ffmpeg\" for more info.\n\n"; exit; }


# Check if we have any parameter supplied.
if [ $# -eq 0 ]; then
    # No parameters were supplied.
    echo
    echo Run this shortcut with the desired Safari YouTube window open.
    exit 1
else
    # A parameter was supplied.
    videoURL="$1"
    # If the input is a YouTube link, then continue, else exit.
    if [[ "$videoURL" != *"youtu.be"* ]] | [[ "$videoURL" != *"youtube.com"* ]]; then
        echo
        echo This is not a YouTube video, try again with a correct link.
        exit 1
    fi
fi


# Get video title and format it.
videoTitle=$( "$YouTubeCmd" -f bestvideo+bestaudio "$videoURL" --no-playlist -o "%(title)s.%(ext)s" --get-title )
videoTitle=$( echo $videoTitle | sed 's/["/]//g' )
videoTitle=$( echo $videoTitle | sed "s/[.']//g" )


# Set video directory.
videoDirectory="$downloadsFolder/$videoTitle"

echo 45

# Download the youtube video.
VideoDownload=$($YouTubeCmd -k -f bestvideo+bestaudio "$videoURL" --no-playlist -o "$videoDirectory/$videoTitle.%(ext)s") #& wait

echo 50

# Check if the video is already an MP4 file, if not then convert it to one.
if test $( ls "$videoDirectory" | grep -E "$videoTitle" | wc -l ) -eq 2; then
    echo IF
    fileA=$( ls "$videoDirectory" | head -1 ) # Get the name of the first file.
    fileB=$( ls "$videoDirectory" | tail -1 ) # Get the name of the second file.
    # echo "Two files need combining: $fileA and $fileB"
    $ffmpegCmd -i "$videoDirectory/$fileA" -i "$videoDirectory/$fileB" "$videoDirectory/$videoTitle.mp4" #& wait
elif [[ -f "$videoDirectory/$videoTitle.mp4" ]]; then
    var=''
else
    videoFullTitle=$( ls "$videoDirectory" | grep -e "$videoTitle" )
    "$ffmpegCmd" -i "$videoDirectory/$videoFullTitle" "$videoDirectory/$videoTitle.mp4" #& wait
fi

exit
sleep 1

# Move the MP4 video file to the Downloads folder.
videoMP4=$( ls "$videoDirectory" | grep '^[^.]*.[^.]*$' )
echo $videoMP4

/bin/mv "$videoDirectory/$videoTitle.mp4" "$downloadsFolder" #& wait
echo "$videoDirectory/$videoTitle.mp4" "$downloadsFolder"

# Remove the directory with any undeleted files.
#/bin/rm -dr "$videoDirectory" #& wait

# echo Done