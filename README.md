# rss2kindle

This script takes converts a list of RSS feeds (stored in a YAML file)
to PDF formatted to be read on a Kindle.

## Usage

    Usage: rss2kindle [options] yamlfile
        -m, --mail [ADDRESS]             Email results
        -d, --directory [DIR]            Set output directory
            --context [FILE]             Set context binary
            --pandocdir [DIR]            Path for pandoc binary
            --logfile [FILE]             Set logfile


## Format of yamlfile

    title : News
    file  : news.tex
    age   : 1  # Only use feeds that appeared `age` days ago
    feeds :
        hindu : http://www.thehindu.com/?service=feeder
        bbc-news : http://feeds.bbci.co.uk/news/rss.xml
    ---
    title : Comics
    file  : comics.tex
    age   : 3
    feeds :
        xkcd :      http://xkcd.com/atom.xml
        phd-comics: http://www.phdcomics.com/gradfeed_justcomics.php
        geek-and-poke: http://feeds.feedburner.com/GeekAndPoke
        dilbert  : http://feed.dilbert.com/dilbert/daily_strip
