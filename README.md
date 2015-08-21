# itsip
iTunes&reg; Situational Playlist Generator

Purpose:
-------

Automatic creation of playlists for common "just need some music"
situations, using tracks from your own library and based on your own
categorizations.  This automation is not intended as a substitute for
hand curated playlists like you might want for romantic situations,
having new friends over for dinner the first time, or other situations
where a miscategorized track could turn into a long remembered topic
of conversation or worse.  What itsip provides is a way to get back
into your collection without having to scroll through a massive track
list or put up with automatic suggestions that don't have enough
variety.

Using itsip:
-----------

After installing, you will need to categorize and rate all your
tracks.  That can take a long time, but if you want to pull tracks
based on your impressions then you need to record what your
impressions are.  The only shortcut here is that if you trust someone
else's tastes, and they will send you a transfer file, then you can
load their impressions into your library.  But even if you leverage
someone else's ratings to start, you will need to get used to the idea
of classifying tracks yourself.  Doing a full pass through your entire
collection may be daunting, but improving access to your library is
worth the time.  If you want to get a feel for itsip, the scripts
should start to get useful after you have a couple of hundred
significantly diverse tracks categorized. 

You use itsip by running one of the itsip scripts from the iTunes app
script menu:

  - **itsipCategorize** prompts you for which keywords should be
    associated with the currently playing track, how often the track
    may be selected, and any comments you have.  This core playlist
    source data is saved in the track comment.  The keywords are
    defined in *itsipConfig.txt* which is read by the *itsipSettings*
    helper script.

  - **itsipPlaylist** creates or rebuilds a playlist according to your
    keyword and rating specifications.  If you specify your membic
    email and password in *itsipConfig.txt*, then membics for your
    favorite tracks will be automatically created/updated by a call
    through to *itsipUpload* when you rebuild the list.

  - **itsipExport** copies the tracks from a playlist into a folder of
    your choice along with an .m3u file.  Primarily useful for porting
    a playlist to an Android phone or a memory stick.

  - **itsipTransport** writes rating, volume adjustment, and comment
    data for all of your songs out to itsipTransport.dat, or reads
    from itsipTransport.dat to import settings into iTunes.


How itsip works:
---------------

The fundamental data for itsip is situational appropriateness coding.
You say whether a track is appropriate for the office or gym or
whatever, and then you can select music appropriate for the gym and
decide whether you simultaneously want to exclude music that is also
appropriate for dance or whatever.  The situational coding, plus a
frequency indicating how often you want to listen to a particular
track, and a minimum star rating, is enough to build an acceptable
playlist.  The hard part is choosing the situational codes.

Good situation coding is crucial, because you don't want to go through
and rate each of the thousands of tracks in your library and then find
out what you did isn't going to work well for building the playlists
you want.  You also don't want a lot of categories since you will have
to consider each category for every track, and consider the categories
again when you are generating a playlist.  The default categories have
been refined by me over years of use, but if they do not reflect your
needs then you can edit itsipConfig.txt and redefine them.

The frequency and situational codes are saved in a bracket expression
prepended to the comments for the track.

Usage tips:
----------

You might find it handy to set up a keyboard shortcut to
itsipCategorize so you can quickly jump to updating categorization
information for the currently playing track without having to select
from the script menu.  To bind command-; (one of the few keys not
already mapped by default):

  * Open System Preferences | "Keyboard" | "Shortcuts" | "App Shortcuts"

  * Click '+' to add a new shortcut

  * Select iTunes as the application, itsipCategorize as the menu
    title, and command-; as the keyboard shortcut.

The comment text for any track can be updated directly through iTunes
(like you do for the star rating and the volume adjustment), just be
careful not to mess up the encoded keyword/frequency information in
the square brackets preceding the actual comment text.


Developer notes:
---------------

Double click any .applescript file to bring it up in the script
editor.  Emacs will read it, but best to use the native editor.
Scripts import other scripts by name expecting a .scpt file.  To make
a .scpt file for any script, choose export from the file menu.

Command line tools like osascript are great, but beware of character
encodings in a command line environment.

An AppleScript dialog box allows one input field and up to 3 buttons.

Everything on the Mac is an object, so access via nested tell blocks.
For details about what can be accessed, go to File | Open Dictionary
in the script editor, then choose iTunes or whatever.  Suites contain
commands (C with a circle) and classes (C with a square), classes
contain properties (P) and elements (E).
