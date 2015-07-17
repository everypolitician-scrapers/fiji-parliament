#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def party_info(text)
  if text =~ /Fiji First/i
    return [ "Fiji First", "FF" ]
  elsif text =~ /SODELPA/
    return [ "Social Democratic Liberal Party" , "SODELPA" ]
  elsif text =~ /NATIONAL FEDERATION PARTY/
    return [ "National Federation Party" , "NFP" ]
  else
    warn "Unknown party: #{text}"
  end
end

def scrape_list(url)
  noko = noko_for(url)

  noko.xpath('.//td[img]').each do |td|
    party, party_id = party_info ( td.xpath('preceding::strong[1]').text )
    data = { 
      name: td.text.gsub(/[[:space:]]+/, ' ').strip,
      image: td.css('img/@src').text,
      party: party,
      party_id: party_id,
      term: '2014',
      source: url,
    }
    data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
    # puts data
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('http://www.parliament.gov.fj/Members/Parliamentery-Parties.aspx')
