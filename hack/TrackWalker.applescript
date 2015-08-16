property newline : "
"

-- Convert legacy comment format to new style
on fixTrackComment(cmt)
	-- not already in converted form and have old style code section
	-- display dialog "before: " & cmt
	if cmt does not start with "[f" and (offset of "[" in cmt) > 0 then
		set fv to "30"
		set codes to ""
		if (offset of "freq:" in cmt) > 0 then
			set startoffset to ((offset of "freq:" in cmt) + 5)
			set endoffset to ((offset of "]" in cmt) - 1)
			set fqc to (characters startoffset through endoffset of cmt) as text
			set fv to fqc as integer
		end if
		if (offset of "Wakeup" in cmt) > 0 then
			set codes to codes & "C"
		end if
		if (offset of "Travel" in cmt) > 0 then
			set codes to codes & "T"
		end if
		if (offset of "Office" in cmt) > 0 then
			set codes to codes & "O"
		end if
		if (offset of "Workout" in cmt) > 0 then
			set codes to codes & "W"
		end if
		if (offset of "Dance" in cmt) > 0 then
			set codes to codes & "D"
		end if
		if (offset of "Social" in cmt) > 0 then
			set codes to codes & "S"
		end if
		set pcom to (reverse of (characters of cmt)) as text
		set endoffset to (offset of "]" in pcom) - 1
		if endoffset > 1 then
			set pcom to characters 1 through endoffset of pcom
			set pcom to ((reverse of pcom) as text)
		else
			set pcom to ""
		end if
		if length of pcom > 0 and pcom does not start with " " then
			set pcom to " " & pcom
		end if
		set cmt to "[f" & fv & "k" & codes & "]" & pcom
		-- display dialog "converted: " & cmt
	end if
	-- display dialog "after: " & cmt
	return cmt
end fixTrackComment

tell application "iTunes"
	repeat with ct in every track
		set convtxt to my fixTrackComment(comment of ct)
		set (comment of ct) to convtxt
	end repeat
end tell
