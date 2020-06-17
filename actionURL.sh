#!/bin/bash

# cases that handles fetching the URL them self
case "$1" in
    instapapermobilizer )
        sh mobilize.sh
        ;;
    markdownlink )
        sh createLink.sh "markdown"
        ;;
    htmllink )
        sh createLink.sh
        ;;
    *)
        # all other options need the URL, so lets fetch it
        THEURL=$(sh getURL.sh)
        # if no url then just exit
        if [ -z "$1" ]
            then
            echo "Unable to find a URL"
            exit
        fi

        case "$1" in

        com.droplr.droplr-mac )
            # shorten link with Droplr       
            if [[ $(ps aux | grep "Droplr" | egrep -cv "grep|actionurl.sh") -lt 1  ]]
                then
                open -gb "$1"
                sleep 3
            fi
                osascript -e "tell application \"Droplr\" to shorten \"$THEURL\""
                echo "Drop"
            ;;
        pbcopy )
            # copy to clipboard
            echo "$THEURL" | pbcopy;
            ;;
        gmail )
            # compose a new Gmail mail with the url in as text
            open "https://mail.google.com/mail/?view=cm&fs=1&body=$THEURL"
            ;;
        firefox )
            # Open Firefox with URL
            open -a '/Applications/Firefox.app' $THEURL
            ;;
        *)
            # all other applications can be opened from bash
            open -b "$1" "$THEURL"
            ;;
    esac

    ;;
esac
# reload the application cache
sh cacheApps.sh
