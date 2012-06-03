require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'htmlentities'
require 'pandoc-ruby'

class RssFeed
    attr_accessor :title, :description, :url
    attr_accessor :entries
    def clean!
        @title       = PandocRuby.new(@title).to_context
        @description = PandocRuby.new(@description).to_context

        @entries = @entries.map do |rss_item|
            entry = RssEntry.new

            entry.content = rss_item.content rescue rss_item.description
            # Sometimes content is empty
            entry.content = rss_item.description if entry.content.empty?

            entry.title   = PandocRuby.html(rss_item.title).to_context
            entry.content = PandocRuby.html(entry.content).to_context
            entry
        end
    end
end

class RssEntry
    attr_accessor :title, :content
end

class FeedParser
    attr_reader :id, :url

    def initialize id, url
        @id  = id
        begin 
            @url = open(url)
        rescue Exception => e
            puts "Cannot read #{url}: #{e.message}"
            @url = nil
        end
    end

    def fetch age=1
        return nil if @url.nil?

        # SimpleRSS generates a lot of warnings related to UTF. So, we disable warnings
        verbose_level = $VERBOSE
        $VERBOSE = nil

        rss = FeedNormalizer::FeedNormalizer.parse @url
        return nil if rss.nil?

        rss.clean!

        parsed = RssFeed.new
        parsed.title        = rss.title rescue nil
        parsed.description  = rss.description rescue nil
        parsed.url          = rss.url

        date_threshold = DateTime.now - age
        parsed.entries = rss.entries.reject{ |rss_item| date(rss_item) < date_threshold }

        $VERBOSE = verbose_level
        return parsed.clean!
    end

    private 
    def date rss_item
        date = DateTime.parse rss_item.date_published rescue nil
        if date.nil? 
            date = DateTime.parse rss_item.last_updated rescue nil
        end
        if date.nil?
            date = DateTime.now 
        end
        return date
    end
end

class FeedFormatter
    attr_reader :feed_hash

    def initialize feed_hash
        @feed_hash = feed_hash
    end

    def format title="Rss Feeds"
        start = %<
        \\usemodule[rssfeed]
        \\starttext
        \\starttitle[title={#{title}}]
            \\placelist[chapter]
        \\stoptitle
        >  

        stop = %<
        \\stoptext
        >

        formatted_entries = ""
        @feed_hash.each_pair do |id, feed|
            feed.each do |entry|
                formatted_entries << format_entry(id, entry)
            end
        end

        return start + formatted_entries + stop

    end

    private
    def format_entry id, entry
        # The title may contain `#`, which gets translated to
        # \type{#}, but that does not work inside a title.
        # So, we set the title in asciimode
        %<
        \\startasciimode
        \\startchapter[title={#{entry.title}}][name={#{id}}]
        \\stopasciimode
        #{entry.content}
        \\stopchapter
        >
    end
end
