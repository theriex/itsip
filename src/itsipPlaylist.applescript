property wdtitle : "itsipPlaylist"
property upldscript : null
property revscript : null
property confscript : null
property wdconf : null
property playlistdefs : null
property uncatplname : "itsip uncategorized"
property newline : "
"

on loadScript(scrname)
	tell application "Finder"
		set locpath to container of (path to me) as text
	end tell
	set scrobj to load script (alias (locpath & scrname & ".scpt"))
	return scrobj
end loadScript


on getListDefsFileMacName()
	tell application "Finder"
		set macpathstr to (container of (path to me) as text) & "itsipPlaylistDefs.dat"
	end tell
	return macpathstr
end getListDefsFileMacName


on loadPlaylistDefs()
	set playlistdefs to {}
	try
		set fname to getListDefsFileMacName()
		set playlistdefs to (read file fname as list)
	end try
end loadPlaylistDefs


on writePlaylistDefs()
	try
		set fname to getListDefsFileMacName()
		set wf to open for access fname with write permission
		set eof wf to 0
		write playlistdefs to wf starting at eof as list
		close access wf
	on error errStr number errorNumber
		try
			close access wf
		end try
		error errStr number errorNumber
		return false
	end try
end writePlaylistDefs


on selectRemovePlaylists()
	set ptxt to "Choose itsip playlist to delete"
	set plnames to {}
	repeat with pldef in playlistdefs
		set end of plnames to (plname of pldef)
	end repeat
	set plname to choose from list plnames with prompt ptxt with title wdtitle
	if plname is false then
		return false
	end if
	set plname to plname as text
	set newlist to {}
	set oldlist to playlistdefs
	-- have to go by index to avoid references via old list..
	repeat with i from 1 to count oldlist
		set defname to plname of oldlist's item i
		if plname is not equal to defname then
			set end of newlist to oldlist's item i
		end if
	end repeat
	set playlistdefs to newlist
end selectRemovePlaylists


on selectOptions(pldef)
	set ptxt to "Choose keywords that must be in the description of the selected tracks."
	set listchoice to choose from list (catlabels of wdconf) with prompt ptxt default items (filtopts of pldef) with title wdtitle with multiple selections allowed and empty selection allowed
	if listchoice is false then
		return false
	end if
	set (filtopts of pldef) to listchoice
	set notopts to {}
	repeat with keyw in (catlabels of wdconf)
		if (filtopts of pldef) does not contain keyw then
			set end of notopts to keyw
		end if
	end repeat
	set ndflts to {}
	repeat with notopt in (notopts of pldef)
		if (filtopts of pldef) does not contain notopt then
			set end of ndflts to notopt
		end if
	end repeat
	set ptxt to "Choose keywords that must NOT be in the description of the selected tracks."
	set listchoice to choose from list notopts with prompt ptxt default items ndflts with title wdtitle with multiple selections allowed and empty selection allowed
	if listchoice is false then
		return false
	end if
	set (notopts of pldef) to listchoice
	return true
end selectOptions


on selectMinRating(pldef)
	--     100,    90-99,   80-89,   70-79,  60-69,  50-59, 40-49, 30-39, 20-29, 10-19, 0-9
	set levels to {"★★★★★", "★★★★½", "★★★★", "★★★½", "★★★", "★★½", "★★", "★½", "★", "½"}
	set ratidx to (11 - ((minrat of pldef) div 10))
	if ratidx > 10 then
		set ratidx to 10
	end if
	set ptxt to "Minimum rating for tracks in playlist"
	set listchoice to choose from list levels with prompt ptxt default items {(item ratidx of levels)} with title wdtitle
	if listchoice is not false then
		set seltxt to item 1 of listchoice
		set ratidx to 0
		repeat with levtxt in levels
			set ratidx to (ratidx + 1)
			if ((levtxt as text) is equal to (seltxt as text)) then
				exit repeat
			end if
		end repeat
	end if
	set (minrat of pldef) to ((11 - ratidx) * 10)
	return true
end selectMinRating


on setPlaylistName(pldef)
	set ptxt to "Name of playlist"
	set dlgresult to display dialog ptxt default answer (plname of pldef)
	set plname of pldef to text returned of dlgresult
	return true
end setPlaylistName


on verifyPlaylistDefinition(pldef)
	selectOptions(pldef)
	selectMinRating(pldef)
	setPlaylistName(pldef)
end verifyPlaylistDefinition


on selectPlaylist()
	set newlistname to "- Create New Playlist -"
	set clearlistname to "- Delete Playlist -"
	set uncatlistname to "- Uncategorized Tracks -"
	set plnames to {newlistname}
	repeat with pldef in playlistdefs
		set end of plnames to (plname of pldef)
	end repeat
	set end of plnames to clearlistname
	set end of plnames to uncatlistname
	set ptxt to "Choose itsip playlist to update"
	set plname to choose from list plnames with prompt ptxt with title wdtitle
	if plname is false then
		return false
	end if
	set plname to plname as text
	set currpldef to null
	if plname is equal to clearlistname then
		selectRemovePlaylists()
	else if plname is equal to uncatlistname then
		set currpldef to {plname:uncatplname, minrat:0, trkoff:0}
	else -- creating a list or using an existing one
		if plname is equal to newlistname then
			set currpldef to {plname:"", filtopts:{}, notopts:{}, minrat:0, trkoff:0}
			set end of playlistdefs to currpldef
		else
			repeat with pldef in playlistdefs
				set defname to (plname of pldef) as text
				if plname is equal to defname then
					set currpldef to pldef
				end if
			end repeat
		end if
		verifyPlaylistDefinition(currpldef)
	end if
	writePlaylistDefs()
	return currpldef
end selectPlaylist


on playedRecently(lastplay, tdata)
	set freq to (ptdfreq of tdata) as number
	-- no playback frequency means never select it automatically
	if freq is equal to 0 then
		return true
	end if
	if freq is greater than 0 and lastplay is not missing value then
		set availdate to lastplay + (freq * days)
		if (current date) is less than availdate then
			return true
		end if
	end if
	return false
end playedRecently

on isCategorizedTrack(tdata)
	try
		if length of (ptdcodes of tdata) > 0 then
			return true
		end if
	end try
	return false
end isCategorizedTrack


on isEligiblePlaylistTrack(pldef, ctrk, tdata)
	if (plname of pldef) is equal to uncatplname then
		return not isCategorizedTrack(tdata)
	end if
	set keywordmash to (revscript's keywordListFromCodesText(ptdcodes of tdata)) as text
	set haveRequiredKeyword to false
	set haveForbiddenKeyword to false
	repeat with kwlabel in (filtopts of pldef)
		if keywordmash contains kwlabel then
			set haveRequiredKeyword to true
			exit repeat
		end if
	end repeat
	if haveRequiredKeyword then
		repeat with kwlabel in (notopts of pldef)
			if keywordmash contains kwlabel then
				set haveForbiddenKeyword to true
				exit repeat
			end if
		end repeat
	end if
	if not haveRequiredKeyword or haveForbiddenKeyword then
		return false
	end if
	return true
end isEligiblePlaylistTrack


on copyMatchingTracks(plen, tids, pldef)
	set dstart to current date
	set toff to (trkoff of pldef)
	set skipquantum to 20 -- don't just play all tracks in order
	set skipping to random number from 0 to skipquantum
	set prevartist to "nobody"
	set tcnt to 0
	set tcopied to 0
	tell application "iTunes"
		repeat with ct in every track
			set tcnt to tcnt + 1
			if tcnt is greater than or equal to toff then
				set toff to toff + 1
				set skipping to skipping - 1
				if skipping is less than or equal to 0 and artist of ct is not equal to prevartist and (rating of ct) is greater than or equal to (minrat of pldef) then
					try
						set tdata to revscript's parseTrackData(comment of ct)
						set playedrecent to my playedRecently(played date of ct, tdata)
						set iseligible to my isEligiblePlaylistTrack(pldef, ct, tdata)
					on error errStr number errorNumber
						display dialog "Unparseable track data from \"" & (name of ct) & "\": " & (comment of ct) & ". Error: " & errStr
					end try
					if not playedrecent and iseligible then
						try
							duplicate ct to user playlist (plname of pldef)
							set end of tids to (id of ct)
							set tcopied to tcopied + 1
							set skipping to skipquantum
							set prevartist to (artist of ct)
						on error errStr number errorNumber
							display dialog "Error: " & errStr
						end try
					end if
				end if
			end if
			if tcopied is greater than or equal to plen then
				exit repeat
			end if
		end repeat
	end tell
	set dend to current date
	-- display dialog "start: " & dstart & newline & "  end: " & dend & newline & "toff: " & toff & newline & "tcopied: " & tcopied
	set (trkoff of pldef) to toff
	return tcopied
end copyMatchingTracks


on verifyDefaultsAndNoteSelected(pldef)
	tell application "iTunes"
		repeat with ct in every track of user playlist (plname of pldef)
			set tdata to revscript's parseTrackData(comment of ct)
			set comment of ct to revscript's assembleTrackData(tdata)
			-- avoid selecting this track for a different list
			set played date of ct to current date
		end repeat
	end tell
end verifyDefaultsAndNoteSelected


on updatePlaylistTracks(pldef)
	set tids to {}
	tell application "iTunes"
		repeat with ct in every track of user playlist (plname of pldef)
			set end of tids to (id of ct)
		end repeat
		delete every track of user playlist (plname of pldef)
		set view of front window to user playlist (plname of pldef)
	end tell
	-- display dialog "Updating tracks, trkoff: " & (trkoff of pldef)
	-- display dialog "tids: " & tids
	set plen to 80
	set tcopied to copyMatchingTracks(plen, tids, pldef)
	if tcopied is less than plen then
		set (trkoff of pldef) to random number from 0 to 50
		set plrem to plen - tcopied
		copyMatchingTracks(plrem, tids, pldef)
	end if
	-- display dialog "Writing updated track offset: " & (trkoff of pldef)
	writePlaylistDefs()
	verifyDefaultsAndNoteSelected(pldef)
end updatePlaylistTracks


on updatePlaylist(pldef)
	if pldef is equal to null or pldef is equal to false then
		return
	end if
	upldscript's uploadFavorites(wdconf, pldef)
	set haveExistingPlaylist to false
	tell application "iTunes"
		try
			set pl to user playlist (plname of pldef)
			set haveExistingPlaylist to true
		end try
	end tell
	if not haveExistingPlaylist then
		set tn to (plname of pldef)
		set tprops to {name:tn}
		tell application "iTunes"
			make new user playlist with properties tprops
		end tell
	end if
	tell application "iTunes"
		repeat with ctrk in (every track of user playlist (plname of pldef))
			set played date of ctrk to current date
		end repeat
	end tell
	updatePlaylistTracks(pldef)
end updatePlaylist


-- Main script
set confscript to loadScript("itsipSettings")
confscript's loadConfig()
set wdconf to confscript's wdconf
set upldscript to loadScript("itsipUpload")
set revscript to loadScript("itsipCategorize")
set revscript's confscript to confscript
loadPlaylistDefs()
updatePlaylist(selectPlaylist())
