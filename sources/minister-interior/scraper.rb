#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

require 'open-uri/cached'

class RemoveOldBeWiki < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('a[title^="be-x-old"]').remove
    end.to_s
  end
end

class OfficeholderList < OfficeholderListBase
  decorator RemoveOldBeWiki
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  # TODO: make this easier to override
  def holder_entries
    noko.xpath("//h3[contains(.,'Министры')][1]//following-sibling::ul[1]//li[a]")
  end

  class Officeholder < OfficeholderBase
    def raw_combo_date
      noko.text[/\((.*?)\)/, 1].gsub(/^з /, '')
    end

    def combo_date?
      true
    end

    def item
      name_cell.attr('wikidata')
    end

    def name
      nake_cell.text.tidy
    end

    def name_cell
      # Dates are links, so we want the last link that doesn't start with a number
      noko.css('a').reject { |link| link.text[/^\d/] }.last
    end

    def empty?
      noko.text.scan(/(\d{4})/).flatten.last.to_i < 2000
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
