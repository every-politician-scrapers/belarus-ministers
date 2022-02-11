#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Акруга'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[_ name constituency].freeze
    end

    def startDate
      '2016-09-11'
    end

    def endDate
      '2019-12-06'
      nil
    end

    #TODO: party + constituency
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
