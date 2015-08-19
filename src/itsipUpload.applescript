property wdtitle : "itsipUpload"
property catscript : null
property tdata : null
property haveFavorites : false
property newline : "
"

on loadScript(scrname)
	tell application "Finder"
		set locpath to container of (path to me) as text
	end tell
	set scrobj to load script (alias (locpath & scrname & ".scpt"))
	return scrobj
end loadScript


on isFavoriteTrack(ctrk)
	if (rating of ctrk) ³ 80 and length of (comment of ct) ³ 40 then
		return true
	end if
	return false
end isFavoriteTrack


on escapeEmbeddedDoubleQuotes(srctxt)
	set AppleScript's text item delimiters to "\""
	set txtelems to every text item of srctxt
	set AppleScript's text item delimiters to "\\\""
	set restxt to txtelems as string
	return restxt
end escapeEmbeddedDoubleQuotes


on writeTrackData(wf, ctrk, isFirstTrack)
	set tdata to catscript's parseTrackData(comment of ctrk)
	set keywordcsv to catscript's keywordListFromCodesText(ptdcodes of tdata)
	if not isFirstTrack then
		write ", " to wf
	end if
	write "{\"revtype\":\"music\", \"rating\":" & (rating of ctrk) & ", \"keywords\":\"" & keywordcsv & "\", \"text\":\"" & escapeEmbeddedDoubleQuotes(ptdcmt of tdata) & "\", \"artist\":\"" & escapeEmbeddedDoubleQuotes(artist of ctrk) & "\", \"album\":\"" & escapeEmbeddedDoubleQuotes(album of ctrk) & "\", \"year\":\"" & (year of ctrk) & "\"}" to wf
end writeTrackData


on writePythonUploadScript(wdconf, pldef, tempfolderstr, upname)
	set fname to tempfolderstr & upname & ".py"
	try
		set wf to (open for access fname with write permission)
		set eof wf to 0
		write "#!/usr/bin/env python" & newline to wf
		write "# -*- coding: utf-8 -*-" & newline to wf
		write "# Upload music membics from favorites in " & plname & newline to wf
		write "# This file was written from AppleScript " & (current date) & newline to wf
		write "import urllib, json, subprocess" & newline to wf
		write "tracks = [" to wf
		tell application "iTunes"
			set isFirstTrack to true
			repeat with ctrk in (every track of user playlist (plname of pldef))
				if isFavoriteTrack(ctrk) then
					writeTrackData(wf, ctrk, isFirstTrack)
					set isFirstTrack to false
				end if
			end repeat
		end tell
		write "]" & newline to wf
		write "trackdata = json.dumps(tracks)"
		write "data = \"email=" & (membicemail of wdconf) & "&password=" & (membicpassw of wdconf) & "&revsjson=\" + urllib.quote(trackdata)"
		write "subprocess.call([\"curl --data \\\"\" + data + \"\\\" https://membicsys.appspot.com/batchupload\"], shell=True)" & newline to wf
		close access wf
	on error errStr number errorNumber
		try
			close access wf
		end try
		display dialog "Writing " & fname & " failed."
		error errStr number errorNumber
		return false
	end try
end writePythonUploadScript


on runPythonUploadScript(wdconf, pldef, tempfolderstr, upname)
	set fname to tempfolderstr & upname & ".py"
	set outname to tempfolderstr & upname & ".out"
	set command to "/usr/bin/python " & (quoted form of (POSIX path of fname)) & " &> " & (quoted form of (POSIX path of outname)) & " &"
	set result to do shell script command
	display dialog "favorites upload result: " & result
end runPythonUploadScript


on writeAndRunUploadScript(wdconf, pldef)
	-- temp files typically in ~/Library/Caches/TemporaryItems
	set tempfolderstr to ((path to temporary items from user domain) as string)
	set upname to "itsipMembicUpload"
	writePythonUploadScript(wdconf, pldef, tempfolderstr, upname)
	runPythonUploadScript(wdconf, pldef, tempfolderstr, upname)
end writeAndRunUploadScript


on uploadFavorites(wdconf, pldef)
	set catscript to loadScript("itsipCategorize")
	set email to (membicemail of wdconf)
	if ((offset of "@" in email) is equal to 0) or ((offset of "@example.com" in email) > 0) then
		return false
	end if
	set haveFavorites to false
	try
		tell application "iTunes"
			repeat with ctrk in (every track of user playlist (plname of pldef))
				if isFavoriteTrack(ctrk) then
					set haveFavorites to true
					exit repeat
				end if
			end repeat
		end tell
	end try
	if haveFavorites then
		writeAndRunUploadScript(wdconf, pldef)
	end if
end uploadFavorites


-- Main script
display dialog "You need to update a playlist to upload favorites from last time."

