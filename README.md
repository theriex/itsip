# itsip
iTunes&reg; Situational Playlist Generator

Purpose:
-------

Automatic creation of playlists for common "just need some music"
situations, using tracks from your own library and based on your own
categorizations.  Itsip is not intended as a substitute for hand
curated playlists such as you might use for romantic situations,
having new friends over for dinner the first time etc.  What itsip
provides is a way to get back into your collection without having to
scroll through a massive track list or put up with automatic
suggestions that don't have enough variety.

Using itsip:
-----------

After installing, categorize and rate all your tracks.  That will take
a while, but if you want to pull tracks based on your impressions then
you need to record what your impressions are.  The only shortcut here
is that if you trust someone else's tastes, and they will send you an
import file, then you can load their impressions into your library.
Even with that, you need to get used to the idea of classifying
tracks.  Doing a full pass through your entire collection may be
daunting, but easier access to your library is worth it.  With some
diversity of selection, itsip should start to get useful after a
couple of hundred tracks.

After tracks are categorized, you can generate a new playlist for any
situation simply by selecting what keywords should be included and
what should not.  You can export playlists and associated tracks to a
separate folder, and you can export your ratings and categorizations
to a flat file to move to another computer.

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
again when you are generating a playlist.  The categories have been
refined over years of use, but if they do not reflect your needs then
you can edit the settings and redefine them.

The frequency and situational codes are saved in a bracket expression
prepended to the comments for the track.


