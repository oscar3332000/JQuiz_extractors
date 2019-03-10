#! /usr/bin/env ruby

require 'mechanize'


class String
 def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
 end
end
  

def engine word
   
    agent = Mechanize.new
    page = agent.get('https://www.edrdg.org/cgi-bin/wwwjdic/wwwjdic?1C')

    form = page.form('inp')
    word.strip!
    word.delete!('\n')
    form.dsrchkey = word
    page = agent.submit(form)

    item = page.search("label").first #do |item|
        
        item = item.text
        
        if item.include? "m('"
            
            if item.include? "【"
                meaning = item.string_between_markers "】", "\t"
                kanji = item.string_between_markers ";\n", "【"
                kana = item.string_between_markers "【","】"
                
                if kanji == nil or meaning == nil
                    return nil
                end
                
                kanji.delete! "【"
                kanji.delete! "(P);"
                meaning.strip!
                kanji.strip!
                kana.strip!
                kanji = kanji.split
                return kanji[0], meaning, kana
            else
                item = item.string_between_markers ";\n", "\t"
                pos = item.index "("
                if pos
                    kana = item[0..pos-1]
                    meaning = item[pos...-1]
                    return kana, meaning, kana
                end
                
            end
    end
    
end

def main
    
    if ARGV.size == 0
        p "list of words in kanji"
        exit
    end
    
    file = open(ARGV[0], "r")
    
    if !file
        exit
    end
    
    file = file.readlines
    
    if file.count == 0
        exit
    end
    
    save = open(ARGV[0] + ".csv", 'w')
    
    file.each do |line|
        
        p line
        if !line.empty?
            res = engine line
            if res
                save.puts res[0] + "\t" + res[1] + "\t" + res[2]
            end
        end
        
    end
    
    save.close

end


main
