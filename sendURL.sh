#!/bin/bash

# we want case-insensitive matching
shopt -s nocasematch

# get the url
if [ -z "$1" ]
   then
    THEURL=$(sh getURL.sh nocache)
else
    THEURL=$(sh getURL.sh)
fi

THEURL=$(echo "$THEURL" | sed -e 's/&/&amp;/g')
URLFILEFORMAT=$(echo $THEURL | sed 's/^.*\(\.[^.]*$\)/\1/')
URLPROTOCOL=${THEURL%"://"*}

CACHEFILE=~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL/appCache.db
if [[ ! -f "$CACHEFILE" ]] || [[ $(stat -f "%m" supportedApplications.txt) -gt $(stat -f "%m" "$CACHEFILE") ]]
    then
    # if there is no application cache then create it
    sh cacheApps.sh
fi
# strip leading and tailing whitespace + change whitespace between words to '* ' to prepare for matching
QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')

echo "<?xml version=\"1.0\"?>"
echo "<items>"

# make sure there is a URL to grab
if [[ -z "$THEURL" ]]
    then
    # if no URL then display an error
    echo "<item valid=\"no\">"
    echo "<title>Send URL to...</title>"
    echo "<subtitle>Unable to find a URL!</subtitle>"
    echo "<icon>icon.png</icon>"
    echo "</item>"

# List all available applications
else
    # Copy to clipboard item, on top when no $query
    if [[ "copy" == $QUERY* ]]
        then
        echo "<item arg=\"pbcopy\" autocomplete=\"Copy\">"
        echo "<title>$THEURL</title>"
        echo "<subtitle>Copy URL...</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi

    # Get the apps from the db, but only if the match the query
    DB_QUERY="% "$(echo "$1" | sed -e 's/\*/%/g')"%"
    sqlite3 "$CACHEFILE" "select ID, Name, Path from apps where (NameCaps like '$DB_QUERY' OR NameSplit like '$DB_QUERY' OR Name like '$DB_QUERY') AND (Formats like '%$URLFILEFORMAT%' OR Formats='*')" | while read APP
    do
        APP_PATH=${APP##*"|"}
        APP=${APP%"|"*}
        APP_ID=${APP%"|"*}
        APP_NAME=${APP#*"| "}

        echo "<item arg=\"$APP_ID\" autocomplete=\"$APP_NAME\">
            <title>Send URL to $APP_NAME</title>
            <subtitle>$APP_PATH</subtitle>
            <icon type=\"fileicon\">$APP_PATH</icon>
            </item>"
    done

    if [[ "firefox" == $QUERY* ]]
        then
        echo "<item arg=\"firefox\" autocomplete=\"Firefox\">"
        echo "<title>Send URL to Firefox</title>"
        echo "<subtitle>$THEURL</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi

    # compose gmail message with url
    if [[ "gmail" == $QUERY* ]]
        then
        echo "<item arg=\"gmail\" autocomplete=\"Gmail\">"
        echo "<title>Send URL to Gmail</title>"
        echo "<subtitle>https://mail.google.com/</subtitle>"
        echo "<icon>gmail.png</icon>"
        echo "</item>"
    fi
    
    # Copy to clipboard as html link item
    if [[ " copy as html link" == *\ $QUERY* ]]
        then
        echo "<item arg=\"htmllink\" autocomplete=\"Copy as HTML link\">"
        echo "<title>Copy URL as HTML Link...</title>"
        echo "<subtitle>Create a HTML link tag from the URL</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi

    # Copy to clipboard as markdown link item
    if [[ " copy as markdown link" == *\ $QUERY* ]]
        then
        echo "<item arg=\"markdownlink\" autocomplete=\"Copy as Markdown link\">"
        echo "<title>Copy URL as Markdown Link...</title>"
        echo "<subtitle>Create a Markdown link from the URL</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi

    # Copy to clipboard item, on bottom $query in not empty
    if [[ "copy" != $QUERY* ]]
        then
        echo "<item arg=\"pbcopy\" autocomplete=\"Copy\" >"
        echo "<title>$THEURL</title>"
        echo "<subtitle>Copy URL...</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi
fi

echo "</items>"
shopt -u nocasematch
