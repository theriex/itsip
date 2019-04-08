# itsip
iTunes&reg; Situational Playlist Generator

To install, double click Install.applescript

Purpose:
-------

Automatic creation of playlists for common "just need some music" situations, using tracks from your library based on your categorizations.  This automation is not intended as a substitute for hand curated playlists like you might want for romantic situations, having new friends over for dinner the first time, or other situations where a miscategorized track could turn into a long remembered topic of conversation or worse.  What itsip provides is a way to get back into your collection without having to scroll through a massive track list or put up with automatic suggestions that don't have enough variety.

Using itsip:
-----------

After installing, you will need to categorize and rate all your tracks.  That can take a long time, but if you want to pull tracks based on your impressions then you need to record what your impressions are.  Think of it as a good reason to go back through your library.  The only shortcut here is that if you trust someone else's tastes, and they will send you a transfer file, then you can load their impressions into your library.  Doing a full pass through your entire collection may seem daunting, but it's worth it.  If you are not sure about itsip, the scripts should start to get useful after you have a couple of hundred diverse tracks categorized so you can start to see the benefits at that point.

You use itsip by running one of the itsip scripts from the iTunes app script menu.  The main scripts are:

  - **itsipCategorize** prompts which keywords should be associated with the currently playing track, how often the track may be selected, and any comments you have.  The playlist metadata data is saved into the track comment.

  - **itsipPlaylist** creates or rebuilds a playlist according to your keyword and rating specifications. 

  - **itsipExport** copies the tracks from a playlist into a folder of your choice along with an .m3u file.  Primarily useful for porting a playlist to an Android phone or a memory stick.

Supporting scripts:

  - **itsipSettings** reads *itsipConfig.txt* to figure out what the category codes are that should be used to categorize tracks for retrieval.

  - **itsipTransfer** writes rating, volume adjustment, and comment data for all of your songs out to *itsipTransfer.dat*, or reads from *itsipTransfer.dat* to import settings into iTunes.

  - **itsipUpload** uploads your favorite tracks from a selected playlist to membic.com.  This script, and the *TrackWalker.applescript* in the hack directory are probably reasonable starting points for any scripts you want to write yourself.

  - **itsipDelete** walks all your tracks and prompts to delete anything that's one star or less. 


How itsip works:
---------------

The fundamental data for itsip is situational appropriateness coding.  You say whether a track is appropriate for the office, or a social occasion, or whatever, then you can select music appropriate for that situation with the option of simultaneously excluding music that is also appropriate for travel, or workout, or whatever.  The situational coding, plus a frequency indicating how often you want to listen to a particular track, and a minimum star rating, is enough to build an acceptable playlist.  The hard part is choosing the situational codes.

Good situation coding is crucial, because you don't want to go through and rate each of the thousands of tracks in your library and then find out what you did isn't going to work well for building the playlists you want.  You also don't want a lot of categories since you will have to consider each category for every track, and consider the categories again when you are generating a playlist.  The default categories have been refined by me over years of use, but if they do not reflect your needs then you can edit itsipConfig.txt and redefine them.

The frequency and situational codes are saved in a bracket expression prepended to the comments for the track.

Usage tips:
----------

You might find it handy to set up a keyboard shortcut to itsipCategorize so you can quickly jump to updating categorization information for the currently playing track without having to select from the script menu.  To bind command-; (one of the few keys not already mapped by default):

  * Open System Preferences | "Keyboard" | "Shortcuts" | "App Shortcuts"

  * Click '+' to add a new shortcut

  * Select iTunes as the application, itsipCategorize as the menu title, and command-; as the keyboard shortcut.

The comment text for any track can be updated directly through iTunes (like you do for the star rating and the volume adjustment), just be careful not to mess up the encoded keyword/frequency information in the square brackets preceding the actual comment text.


Developer notes:
---------------

Double click any .applescript file to bring it up in the script editor.  Other editors like Emacs can read .applescript files, but it's best to use the native editor.  Scripts import other scripts by name expecting a .scpt file.  To make a .scpt file for any script, choose export from the native editor file menu.

Command line tools like osascript work, but beware of character encodings in a command line environment.

An AppleScript dialog box allows one input field and up to 3 buttons.  That limitation makes for a pretty chatty interface when the interactions are beyond trivial.  The alternative is building a full app, with all the versioning compatibility and other overhead.  No clear path yet.

Everything on the Mac is an object, so access via nested tell blocks.  For details about what can be accessed, go to File | Open Dictionary in the script editor, then choose iTunes or whatever.  Suites contain commands (C with a circle) and classes (C with a square), classes contain properties (P) and elements (E).
