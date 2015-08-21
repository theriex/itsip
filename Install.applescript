--            ^
--            |
--
-- Click the play button to run this script (assuming you opened this file in 
-- in the Script Editor).
--
--
--

-- This install file compiles the source .applescript into .scpt files and copies
-- them to ~/Library/iTunes/Scripts/ for direct access from iTunes (find them off
-- the little scroll icon in the menu).

property snames : {"itsipCategorize", "itsipExport", "itsipPlaylist", "itsipSettings", "itsipTransfer", "itsipUpload"}
property locdir : ""
property itsdir : ""
property newline : "
"

on compileAndCopyScriptsToLibrary()
	repeat with sname in snames
		set cmd to "osacompile -o " & locdir & sname & ".scpt " & locdir & sname & ".applescript"
		do shell script cmd
		set cfile to (quoted form of (locdir & sname & ".scpt"))
		set cmd to "cp " & cfile & " " & itsdir
		do shell script cmd
	end repeat
end compileAndCopyScriptsToLibrary


-- the project itsipConfig.txt is read only and always takes precedence over anything 
-- that was previously placed into the Library.  Other .dat files are updated by 
-- scripts as they are run, and it is not helpful for the "release" versions in the 
-- Library to get overwritten by the "development" versions in the src directory, so
-- these are not copied over automatically.
on copyConfigDatToLibrary()
	set cfile to (quoted form of (locdir & "itsipConfig.txt"))
	set cmd to "cp " & cfile & " " & itsdir
	do shell script cmd
end copyConfigDatToLibrary


on displayCompletion()
	display dialog "Script files installed to " & itsdir
end displayCompletion


on setupAndInstallFiles()
	tell application "Finder"
		set locdir to container of (path to me) as text
	end tell
	set locdir to (POSIX path of locdir) & "src/"
	set itsdir to (POSIX path of ((path to home folder as text) & "Library:iTunes:Scripts:"))
	-- verify the target directory exists, creating it if needed
	set command to "mkdir -p " & (quoted form of itsdir)
	do shell script command
	compileAndCopyScriptsToLibrary()
	copyConfigDatToLibrary()
	displayCompletion()
end setupAndInstallFiles


-- Main script
setupAndInstallFiles()

