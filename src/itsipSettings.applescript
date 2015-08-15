property wdtitle : "itsipSettings"
property wdconf : null
property newline : "
"

on splitString(txt, delim)
	set orgdelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set txtelems to every text item of txt
	set AppleScript's text item delimiters to orgdelim
	return txtelems
end splitString


on getConfigFileMacName()
	tell application "Finder"
		set macpathstr to (container of (path to me) as text) & "itsipConfig.txt"
	end tell
	return macpathstr
end getConfigFileMacName


on parseCategory(catval)
	set attrval to my splitString(catval, " - ")
	copy item 1 of attrval to end of catcodes of wdconf
	copy item 2 of attrval to end of catlabels of wdconf
end parseCategory


on parseConfigLine(linum, tl)
	-- display dialog "parseConfigLine " & linum & ": " & tl
	if tl does not start with "#" and tl contains ":" then
		set attrval to my splitString(tl, ": ")
		set attr to item 1 of attrval
		set val to item 2 of attrval
		if attr is equal to "category" then
			parseCategory(val)
		else
			if attr is equal to "defaultfrequency" then
				set defaultfrequency of wdconf to (val as integer)
			else if attr is equal to "membicemail" then
				set membicemail of wdconf to val
			else if attr is equal to "membicpassw" then
				set membicpassw of wdconf to val
			else
				display dialog "Unknown config attribute: " & attr
			end if
		end if
	end if
end parseConfigLine


on loadConfig()
	try
		set fname to getConfigFileMacName()
		set fh to (open for access file fname)
		set fc to (read fh for (get eof fh) as Çclass utf8È)
		close access fh
		set txtlines to my splitString(fc, newline)
		set wdconf to {defaultfrequency:7, membicemail:"", membicpassw:"", catcodes:{}, catlabels:{}}
		set linum to 0
		repeat with tl in txtlines
			set linum to linum + 1
			parseConfigLine(linum, tl)
		end repeat
	end try
end loadConfig


on describeConfig()
	loadConfig()
	display dialog "catcodes: " & (catcodes of wdconf) & newline & "catlabels: " & (catlabels of wdconf) & newline & "default frequency: " & (defaultfrequency of wdconf) & newline & "membic email: " & (membicemail of wdconf)
end describeConfig


-- Main script
describeConfig()
