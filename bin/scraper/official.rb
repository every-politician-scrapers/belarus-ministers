#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      noko.text.split('–').last.tidy
    end

    def position
      ministry.sub('Ministry', 'Minister').split('(').first.tidy
    end

    def ministry
      noko.xpath('preceding-sibling::b[1]').text.tidy
    end
  end

  class Members
    def member_items
      super.reject { |mem| mem.name.to_s.empty? }
    end

    def member_container
      noko.css('.option_3').xpath('.//text()[contains(.,"Minister")]')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
