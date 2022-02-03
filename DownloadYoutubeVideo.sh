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

/bin/sleep 3 && echo "About to get title"
# Get video title and format it.
videoTitle=$(/opt/homebrew/bin/youtube-dl -f bestvideo+bestaudio "$videoURL" -o "%(title)s.%(ext)s" --get-title)
videoTitle=$(echo $videoTitle | sed 's/["/]//g')

/bin/sleep 3 && echo "Getting directories"
# Set videoDownload Directory.
downloadsFolder="/Users/$(whoami)/Downloads"
videoDirectory="$downloadsFolder/$videoTitle"

/bin/sleep 3 && echo "Downloading the YT video"
# Download the youtube video.
/opt/homebrew/bin/youtube-dl -f bestvideo+bestaudio "$videoURL" -o "$videoDirectory/$videoTitle" & wait

/bin/sleep 3 && echo "Getting the video title"
# Get the videos full title.
videoFullTitle=$(ls "$videoDirectory" | grep -e "$videoTitle")

/bin/sleep 3 && echo "converting"
# Check if the video is already an MP4 file, if not then convert it to one.
#test -f "$videoDirectory/$videoTitle.mp4" || echo $('/opt/homebrew/bin/ffmpeg' -i "$videoDirectory/$videoFullTitle" "$videoDirectory/$videoTitle.mp4") & wait

/bin/sleep 3 && echo "moving"
# Move the MP4 video file to the Downloads folder.
/bin/mv "$videoDirectory/$videoTitle.mp4" "$downloadsFolder" & wait

/bin/sleep 3 && echo "removing"
# Remove the directory with any undeleted files.
# /bin/rm -dr "$videoDirectory" & wait

/bin/sleep 3 && echo "Done"