function escquote (val) {
    return val.replace("\"", "\\\"");
}

function filecomp (val) {
    val = escquote(val);
    return val.replace("/", "_");
}

function setDataFromComment (dat, val) {
    //e.g. [f365kCWSOT] Better than the pop radioplay version.
    dat.fq = "P";  //Programmable
    dat.al = 49;
    dat.el = 49;
    dat.kws = "";
    dat.nt = "";
    val = val || "";
    val = val.trim();
    if(val) {
        if(val.startsWith("[f")) {
            var idx = val.indexOf("]");
            var scs = val.slice(2, idx);
            val = val.slice(idx + 2);
            scs = scs.split("k");
            var freq = Number(scs[0]);
            if(freq >= 90) { dat.fq = "B"; }   //Back-burner
            if(freq >= 180) { dat.fq = "Z"; }  //Resting
            if(freq >= 360) { dat.fq = "0"; }  //Overplayed
            var keycodes = scs[1];
            dat.kws = [];
            if(keycodes.indexOf("C") >= 0) {  //Chill
                dat.el = 15; }  //lower energy level
            if(keycodes.indexOf("W") >= 0) {  //Workout
                dat.el = 90;    //high energy level
                dat.kws.push("Workout"); }
            if(keycodes.indexOf("T") >= 0) {  //Travel
                dat.al = 65; }  //probably higher reqd attention unless Social
            if(keycodes.indexOf("S") >= 0) {  //Social
                dat.al = 15; }  //probably lower required attention level
            if(keycodes.indexOf("D") >= 0) {  //Dance
                dat.el = Math.max(dat.el, 65);  //Above avg unless Workout
                dat.kws.push("Dance"); }
            if(keycodes.indexOf("O") >= 0) {  //Office
                dat.kws.push("Office"); }
            dat.kws = dat.kws.join(","); }
        dat.nt = val; }
}

function readDumpRecord(rec, songid, dat) {
    var attrvals = rec.split("\n").slice(1);
    attrvals.forEach(function (av) {
        var delidx = av.indexOf(": ");
        var attr = av.slice(0, delidx);
        var val = av.slice(delidx + 2);
        if(val) {
            switch(attr) {
            case "artist":
                songid.artist = filecomp(val);
                dat.ar = val;
                break;
            case "album":
                songid.album = filecomp(val);
                dat.ab = val;
                break;
            case "tracknum":
                if(val.length < 2) {
                    val = "0" + val; }
                songid.track = val;
                break;
            case "title":
                songid.title = filecomp(val);
                dat.ti = val;
                break;
            case "rating":
                dat.rv = Math.round(Number(val) / 10);
                break;
            case "comment":
                setDataFromComment(dat, val);
                break;
            case "played": break;
            default:
                console.log("Unknown field: " + attr + ": " + val); }} });
}

var fs = require("fs");
fs.readFile("itsipDataDump.txt", {encoding:"utf8"}, function (err, text) {
    var digdat = {songs:{}};
    var recs = text.split("itunesTrackId: ");
    recs.forEach(function (rec) {
        var songid = {};
        var dat = {};
        readDumpRecord(rec, songid, dat);
        songid = songid.artist + "/" + songid.album + "/" + songid.track + " " +
            songid.title + ".mp3";
        digdat.songs[songid] = dat; });
    fs.writeFile("digdatITunesDump.json", JSON.stringify(digdat), 
                 {encoding:"utf8"}, function (err) {
                     if(err) {
                         throw err; } });
});
