#! /usr/bin/env ruby

require 'rubygems'
require 'nokogiri' 
require 'open-uri'


class String
 def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
 end
end


spinner = Enumerator.new do |e|
  loop do
    e.yield '|'
    e.yield '/'
    e.yield '-'
    e.yield '\\'
  end
end


def engine page, file



    list = page.css('div[class="entry clearfix"]')


    list.each do |item|
        
        item = item.text
        
        kana = item.string_between_markers "\n\nKana:", "\nKanji"
        kanji = item.string_between_markers "\nKanji:", "\nRomaji"
        meaning = item.string_between_markers "\nType:", "Example sen"
        
        if kana == nil or kanji == nil or meaning == nil
            next
        end
        
        kanji.strip!
        kana.strip!
        meaning.gsub! /\n/, " "
        meaning.strip!
        meaning = "Type: " + meaning
        
        file.puts kanji + "\t" + meaning + "\t" + kana
        puts kanji + "\t" + meaning + "\t" + kana

    end
    
end

def main
    if ARGV.size == 0
        p "<html address> <number of iterations>"
    end

    times = ARGV[1].to_i

    counter = 1
    file = open('out.csv', 'w')
    while counter <= times

        
        page = Nokogiri::HTML(open(ARGV[0]+"/page/"+ counter.to_s + "/").read)
        begin

            engine page, file
            
            counter +=1
            p "counter: " + counter.to_s
        rescue OpenURI::HTTPError
            $stderr.p "page not available: " +  ARGV[0]+"/page/"+ counter.to_s + "/"
            file.close
            raise
        end
    end
    file.close
end

main
