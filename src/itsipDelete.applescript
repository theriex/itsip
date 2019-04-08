property newline : "
"

on promptToDelete(tname, trat, tfn)
	set dlgtxt to tname & " is " & trat & " out of 100. Delete track and file " & tfn & "?"
	set dp to display dialog dlgtxt buttons {"Cancel", "No", "Yes"} default button 3
	set retval to false
	if button returned of dp is "Yes" then
		set retval to true
	end if
	return retval
end promptToDelete


tell application "iTunes"
	repeat with ct in every track
		set tname to name of ct
		set trat to rating of ct
		set tfn to location of ct
		-- A rating of zero means it's not rated yet.  One star is frequently 32
		if trat > 0 and trat < 40 then
			reveal ct
			set fconf to my promptToDelete(tname, trat, tfn)
			if fconf then
				display dialog "Deleting " & tname
				delete ct
				tell application "Finder" to delete tfn
			end if
		end if
	end repeat
end tell
