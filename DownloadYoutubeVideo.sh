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
videoTitle=$(/opt/homebrew/bin/youtube-dl -f bestvideo+bestaudio "$videoURL" -o "%(title)s.%(ext)s" --get-title)
videoTitle=$(echo $videoTitle | sed 's/["/]//g')

# Set videoDownload Directory.
downloadsFolder="/Users/$(whoami)/Downloads"
videoDirectory="$downloadsFolder/$videoTitle"

# Download the youtube video.
$('/opt/homebrew/bin/youtube-dl' -k -f bestvideo+bestaudio "$videoURL" -o "$videoDirectory/$videoTitle.%(ext)s") & wait

# Get the videos full title.
videoFullTitle=$(ls "$videoDirectory" | grep -e "$videoTitle")

# Check if the video is already an MP4 file, if not then convert it to one.
if test $(ls "$videoDirectory" | grep -E "m4a|webm" | wc -l) -eq 2 ; then
    '/opt/homebrew/bin/ffmpeg' -i "$videoDirectory/$(ls "$videoDirectory" | grep 'm4a')" -i "$videoDirectory/$(ls "$videoDirectory" | grep 'webm')" "$videoDirectory/$videoTitle.mp4" & wait
elif [[ -f "$videoDirectory/$videoTitle.mp4" ]]; then
    var=
else
    '/opt/homebrew/bin/ffmpeg' -i "$videoDirectory/$videoFullTitle" "$videoDirectory/$videoTitle.mp4" & wait
fi

# Move the MP4 video file to the Downloads folder.
/bin/mv "$videoDirectory/$videoTitle.mp4" "$downloadsFolder/$videoTitle.mp4" & wait

# Remove the directory with any undeleted files.
/bin/rm -dr "$videoDirectory" & wait