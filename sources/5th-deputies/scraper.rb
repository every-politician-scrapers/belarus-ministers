#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'акруга'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[name constituency party].freeze
    end

    def startDate
      '2012-10-18'
    end

    def endDate
      '2016-10-10'
    end

    #TODO: party + constituency
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
