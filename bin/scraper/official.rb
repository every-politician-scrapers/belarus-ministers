#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MinisterList < CabinetMemberList
  class Minister < CabinetMemberList::Member
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

  class Ministers < CabinetMemberList::Members
    def member_items
      super.reject { |mem| mem.name.to_s.empty? }
    end

    def member_container
      noko.css('.option_3').xpath('.//text()[contains(.,"Minister")]')
    end

    def member_class
      Minister
    end
  end
end

class DeputyList < CabinetMemberList
  class Deputy < CabinetMemberList::Member
    def name
      noko.css('p').text.tidy
    end

    def position
      noko.css('a img/@alt').text.tidy
    end
  end

  class Deputies < CabinetMemberList::Members
    def member_container
      noko.css('.ul_text_page li')
    end

    def member_class
      Deputy
    end
  end
end

file_dpms = Pathname.new 'html/deputypm.html'
deputypms = EveryPoliticianScraper::FileData.new(file_dpms, klass: DeputyList::Deputies).csv

file_mins = Pathname.new 'html/official.html'
# TODO: extend CSV method to allow skipping the header row
ministers = EveryPoliticianScraper::FileData.new(file_mins, klass: MinisterList::Ministers).send(:rows)

puts deputypms
puts ministers
