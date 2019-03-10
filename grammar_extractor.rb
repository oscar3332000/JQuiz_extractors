#! /usr/bin/env ruby

require 'rubygems'
require 'nokogiri' 
require 'open-uri'


spinner = Enumerator.new do |e|
  loop do
    e.yield '|'
    e.yield '/'
    e.yield '-'
    e.yield '\\'
  end
end

if ARGV.size == 0
    p "html address"
end


page = Nokogiri::HTML(open(ARGV[0]).read)   
puts page.class   # => Nokogiri::HTML::Document

p "Step 1: obtaining the links from the grammar webpage"

list = page.css('p').css("a[target=_blank]")
file = open('out.csv', 'w')

#hash = Hash.new()
printf "Step 2 extracting examples from each link"

list.each do |link|

 if link['href'].include? ".jpg" or link['href'].include? ".pdf"
     next
 end
 #p link['href']
 page2 = Nokogiri::HTML(open(link['href']).read) 
 list2 = page2.css('p')
 list2.each do | item |
     printf("\rStep 2: extracting examples from each link %s", spinner.next)
     str = item.text
     c = 0
     #p item
     if str.count("\n") == 2
        arr = str.split("\n")
        if arr.size == 3
            file.puts arr[0] + "\t" + arr[2] + "[" +link.text + "]" + "\t" + arr[1]
            c+=1
        end
     end
     break if c > 4
 end
 
end

file.close

p "Done"
