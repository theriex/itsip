property wdtitle : "itsipTransfer"
property datfilename : ""
property tabchar : "	"
property newline : "
"

on initDatfileName()
	tell application "Finder"
		set datfilename to (container of (path to me) as text) & "itsipTransfer.dat"
	end tell
end initDatfileName


on splitString(txt, delim)
	set orgdelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set txtelems to every text item of txt
	set AppleScript's text item delimiters to orgdelim
	return txtelems
end splitString


on joinArray(elems, delim)
	set orgdelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set val to elems as string
	set AppleScript's text item delimiters to orgdelim
	return val
end joinArray


on oneLineText(txtval)
	set retval to txtval
	if txtval contains newline then
		set va to splitString(txtval, newline)
		set retval to joinArray(va, "|")
	end if
	return retval
end oneLineText


on dumpTrackData()
	try
		set wf to open for access datfilename with write permission
		set eof wf to 0
		tell application "iTunes"
			repeat with ctrk in every track
				set tnme to ((name of ctrk) as Çclass utf8È)
				set tart to ((artist of ctrk) as Çclass utf8È)
				set talb to ((album of ctrk) as Çclass utf8È)
				set tcmt to ((comment of ctrk) as Çclass utf8È)
				if tnme contains tabchar then
					set ptxt to "Remove bad tab character from track name:"
					set dlgresult to display dialog ptxt default answer tnme
					set name of ctrk to ((text returned of dlgresult) as Çclass utf8È)
					set tnme to ((name of ctrk) as Çclass utf8È)
				end if
				if tart contains tabchar then
					set ptxt to "Remove bad tab character from track artist:"
					set dlgresult to display dialog ptxt default answer tart
					set artist of ctrk to ((text returned of dlgresult) as Çclass utf8È)
					set tart to ((artist of ctrk) as Çclass utf8È)
				end if
				if talb contains tabchar then
					set ptxt to "Remove bad tab character from track album:"
					set dlgresult to display dialog ptxt default answer talb
					set album of ctrk to ((text returned of dlgresult) as Çclass utf8È)
					set talb to ((album of ctrk) as Çclass utf8È)
				end if
				if tcmt contains tabchar then
					set ptxt to "Remove bad tab character from track comment:"
					set dlgresult to display dialog ptxt default answer tcmt
					set comment of ctrk to ((text returned of dlgresult) as Çclass utf8È)
					set tcmt to ((comment of ctrk) as Çclass utf8È)
				end if
				set tcmt to ((my oneLineText(tcmt)) as Çclass utf8È)
				set datline to tnme & tabchar & tart & tabchar & talb & tabchar & (year of ctrk) & tabchar & (rating of ctrk) & tabchar & (volume adjustment of ctrk) & tabchar & tcmt & newline
				write datline as Çclass utf8È to wf
			end repeat
		end tell
		close access wf
	on error errStr number errorNumber
		try
			close access wf
		end try
		error errStr number errorNumber
		return false
	end try
end dumpTrackData


on identFieldsMatch(tinfo, artist, album, year)
	if (length of (srcartist of tinfo)) > 0 then
		set fval to (srcartist of tinfo) as Çclass utf8È
		set tval to artist as Çclass utf8È
		if fval is not equal to tval then
			return false
		end if
	end if
	if (length of (srcalbum of tinfo)) > 0 then
		set fval to ((srcalbum of tinfo) as Çclass utf8È)
		set tval to (album as Çclass utf8È)
		if fval is not equal to tval then
			return false
		end if
	end if
	if (length of (srcyear of tinfo) > 0) and (year > 0) and ((srcyear of tinfo) as integer) is not equal to year then
		return false
	end if
	return true
end identFieldsMatch


on updateTrackInfo(tinfo, overwrite)
	tell application "iTunes"
		try
			set srchres to (search playlist "Music" for (srcname of tinfo) only songs)
			repeat with trk in srchres
				-- display dialog "testing " & (name of trk)
				if my identFieldsMatch(tinfo, (artist of trk), (album of trk), (year of trk)) then
					set statmsg to "found " & (name of trk) & " - " & (artist of trk)
					if overwrite or ((rating of trk) is equal to 0) then
						set updrat to ((srcrating of tinfo) as integer)
						set statmsg to statmsg & newline & "rating set to " & updrat
						set (rating of trk) to updrat
					end if
					if overwrite or ((volume adjustment of trk) is equal to 0) then
						set updva to ((srcvoladj of tinfo) as integer)
						set statmsg to statmsg & newline & "volume adjust set to " & updva
						set (volume adjustment of trk) to updva
					end if
					if overwrite or (((comment of trk) as Çclass utf8È) is equal to "") then
						set statmsg to statmsg & newline & (srccomment of tinfo)
						set (comment of trk) to (srccomment of tinfo)
					end if
					-- display dialog statmsg
				end if
			end repeat
		on error errStr number errorNumber
			error errStr & " tinfo: " & joinArray(tinfo, "	")
		end try
	end tell
end updateTrackInfo


on loadTrackData(overwrite)
	set fh to (open for access file datfilename)
	set fc to (read fh for (get eof fh) as Çclass utf8È)
	close access fh
	set datlines to splitString(fc, newline)
	set linum to 0
	repeat with datline in datlines
		try
			if length of datline ³ 1 then
				set linum to linum + 1
				set trkfields to splitString(datline, tabchar)
				updateTrackInfo({srcname:item 1 of trkfields, srcartist:item 2 of trkfields, srcalbum:item 3 of trkfields, srcyear:item 4 of trkfields, srcrating:item 5 of trkfields, srcvoladj:item 6 of trkfields, srccomment:item 7 of trkfields}, overwrite)
			end if
		on error errStr number errorNumber
			error errStr & " datline: " & datline
		end try
	end repeat
end loadTrackData


on dumpOrLoad()
	initDatfileName()
	set ptxt to "Write or read itsipTransfer.dat. This can take a while (~2000 tracks/minute write, ~500 tracks/minute read). There will be a completion message when the script is done running. Select what you want to do:" & newline
	set acts to {"Write track data", "Read default track data", "Read and overwrite"}
	set listchoice to choose from list acts with prompt ptxt with title wdtitle
	if listchoice is false then
		return false
	else if (listchoice as text) is equal to ((item 1 of acts) as text) then
		dumpTrackData()
		display dialog "Tracks written to ~/Library/iTunes/Scripts/itsipTransfer.dat"
	else if (listchoice as text) is equal to ((item 2 of acts) as text) then
		loadTrackData(false)
		display dialog "Default track categorization data loaded."
	else if (listchoice as text) is equal to ((item 3 of acts) as text) then
		loadTrackData(true)
		display dialog "Track categorizations read completed."
	end if
end dumpOrLoad

-- Main script
dumpOrLoad()

