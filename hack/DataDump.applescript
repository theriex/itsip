property newline : "
"

on writeTrackData(wf)
	tell application "iTunes"
		repeat with ct in every track
			set dd to "itunesTrackId: " & ((id of ct) as string) & newline
			set dd to dd & "artist: " & ((artist of ct) as Çclass utf8È) & newline
			set dd to dd & "album: " & ((album of ct) as Çclass utf8È) & newline
			set dd to dd & "tracknum: " & ((track number of ct) as string) & newline
			set dd to dd & "title: " & ((name of ct) as Çclass utf8È) & newline
			set dd to dd & "rating: " & ((rating of ct) as string) & newline
			set dd to dd & "played: " & ((played date of ct) as string) & newline
			set dd to dd & "comment: " & (comment of ct) & newline
			set dd to dd & newline
			write dd as Çclass utf8È to wf starting at eof
		end repeat
	end tell
end writeTrackData


try
	tell application "Finder"
		set locpath to container of (path to me) as text
	end tell
	set fname to locpath & "itsipDataDump.txt"
	set wf to open for access fname with write permission
	set eof wf to 0
	writeTrackData(wf)
	close access wf
on error errStr number errorNumber
	try
		close access wf
	end try
	error errStr number errorNumber
	return false
end try
