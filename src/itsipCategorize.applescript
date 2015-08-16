property wdtitle : "itsipCategorize"
property idata : {tref:null, tname:"", trat:0, tcmt:""}
property tdata : null
property selkeys : null
property confscript : null
property newline : "
"

on loadScript(scrname)
	tell application "Finder"
		set locpath to container of (path to me) as text
	end tell
	set scrobj to load script (alias (locpath & scrname & ".scpt"))
	return scrobj
end loadScript


on safeIntVal(val)
	set retval to 0
	try
		set retval to (val as integer)
	end try
	return retval
end safeIntVal


on strTrim(val)
	repeat while val starts with " "
		set val to (characters 2 through (length of val) of val) as text
	end repeat
	return val
end strTrim


on parseTrackData(comment)
	script ptd
		-- unrated tracks have rating 0.  
		-- field names chosen to not conflict with iTunes
		property tdata : null
		on parseTrack(comment)
			set tdata to {ptdrat:0, ptdvol:0, ptdfreq:0, ptdcodes:"", ptdcmt:""}
			set cmt to comment
			-- display dialog "cmt: " & cmt
			if cmt does not start with "[" then
				set ptdcmt of tdata to cmt
				return
			end if
			set idx to 1
			set pch to ""
			set pval to ""
			repeat while idx ² length of cmt
				set ch to character idx of cmt
				if (offset of ch in "rvfk]") > 0 then
					if length of pval > 0 then
						if pch is equal to "r" then
							set ptdrat of tdata to safeIntVal(pval)
						else if pch is equal to "v" then
							set ptdvol of tdata to safeIntVal(pval)
						else if pch is equal to "f" then
							set ptdfreq of tdata to safeIntVal(pval)
						else if pch is equal to "k" then
							set ptdcodes of tdata to pval
						end if
					end if
					set pch to ch
					set pval to ""
				else
					set pval to pval & ch
				end if
				if ch is equal to "]" then
					set ptdcmt of tdata to strTrim((characters (idx + 1) through (length of cmt) of cmt) as string)
					exit repeat
				end if
				set idx to idx + 1
			end repeat
		end parseTrack
	end script
	ptd's parseTrack(comment)
	return ptd's tdata
end parseTrackData


on keywordListFromCodesText(codestxt)
	script klfct
		property keylist : null
		on makeKeywordList(codes)
			set keylist to {}
			set catcodes to (catcodes of confscript's wdconf)
			set catlabels to (catlabels of confscript's wdconf)
			repeat with code in codes
				set declidx to 1
				repeat while declidx ² length of catcodes
					if (code as text) is equal to ((item declidx of catcodes) as text) then
						copy item declidx of catlabels to end of keylist
						exit repeat
					end if
					set declidx to declidx + 1
				end repeat
			end repeat
		end makeKeywordList
	end script
	klfct's makeKeywordList(characters of codestxt)
	return klfct's keylist
end keywordListFromCodesText


on keylabelsToKeycodesText(keylabels)
	set catcodes to (catcodes of confscript's wdconf)
	set catlabels to (catlabels of confscript's wdconf)
	set ctxt to ""
	repeat with keylabel in keylabels
		set declidx to 1
		repeat while declidx ² length of catcodes
			if (keylabel as text) is equal to ((item declidx of catlabels) as text) then
				set ctxt to ctxt & item declidx of catcodes
				exit repeat
			end if
			set declidx to declidx + 1
		end repeat
	end repeat
	return ctxt
end keylabelsToKeycodesText


-- note the track we will be working with. The player may move to the next
-- song while the script is running, so set the tref and work with that
on getCurrentTrackInfo()
	-- reinit the reference values in case no current track anymore
	set tref of idata to null
	set tname of idata to ""
	set trat of idata to 0
	set tcmt of idata to ""
	-- get the current track values
	tell application "iTunes"
		if not (exists current track) then
			return false
		end if
		set tref of idata to current track
		set tname of idata to (get name of (tref of idata))
		set trat of idata to (get rating of (tref of idata))
		set tcmt of idata to (get comment of (tref of idata))
	end tell
	return true
end getCurrentTrackInfo


on promptForKeys()
	set ptxt to "Choose keywords that describe \"" & (tname of idata) & "\""
	set listchoice to choose from list (catlabels of confscript's wdconf) with prompt ptxt default items selkeys with title wdtitle with multiple selections allowed and empty selection allowed
	if listchoice is false then
		return false
	end if
	set selkeys to listchoice
	return true
end promptForKeys


on promptForComment()
	set ptxt to "Additional comment for \"" & (tname of idata) & "\""
	set dlgresult to display dialog ptxt default answer (ptdcmt of tdata)
	set ptdcmt of tdata to text returned of dlgresult
	return true
end promptForComment


on promptForFrequency()
	set ptxt to "How often should " & (tname of idata) & " be selected?"
	set freqkeys to (freqkeys of confscript's wdconf)
	set freqdays to (freqdays of confscript's wdconf)
	set seltxt to item 1 of freqkeys
	set selidx to 1
	repeat with freqday in freqdays
		if ((ptdfreq of tdata) as number) is equal to (freqday as number) then
			set seltxt to item selidx of freqkeys
			exit repeat
		end if
		set selidx to selidx + 1
	end repeat
	set listchoice to choose from list freqkeys with prompt ptxt default items {seltxt} with title wdtitle
	if listchoice is not false then
		set seltxt to item 1 of listchoice
		set freqidx to 1
		repeat with freqkey in freqkeys
			if (seltxt as text) is equal to (freqkey as text) then
				set (ptdfreq of tdata) to item freqidx of freqdays
				exit repeat
			end if
			set freqidx to freqidx + 1
		end repeat
	end if
	return true
end promptForFrequency


on assembleTrackData(tdata)
	return "[f" & (ptdfreq of tdata) & "k" & (ptdcodes of tdata) & "] " & (ptdcmt of tdata)
end assembleTrackData


on updateTrackInfo()
	set (ptdrat of tdata) to (trat of idata)
	set (ptdcodes of tdata) to keylabelsToKeycodesText(selkeys)
	set comtxt to assembleTrackData(tdata)
	tell application "iTunes"
		set comment of (tref of idata) to comtxt
		set rating of (tref of idata) to (trat of idata)
	end tell
end updateTrackInfo


-- Main script
if getCurrentTrackInfo() then
	set confscript to loadScript("itsipSettings")
	confscript's loadConfig()
	set tdata to parseTrackData(tcmt of idata)
	set selkeys to keywordListFromCodesText(ptdcodes of tdata)
	if promptForKeys() and promptForComment() and promptForFrequency() then
		updateTrackInfo()
	end if
end if
