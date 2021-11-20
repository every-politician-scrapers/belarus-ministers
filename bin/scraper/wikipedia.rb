#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class RemoveSmallText < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('small').remove
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  decorator RemoveSmallText
  decorator WikidataIdsDecorator::Links

  field :ministers do
    member_entries.map { |ul| fragment(ul => Officeholder).to_h }
  end

  private

  def member_entries
    table.xpath('.//tr[td]')
  end

  def table
    noko.xpath('//table[.//th[contains(.,"Пасада")]]').first
  end
end

class Officeholder < Scraped::HTML
  field :office do
    tds[1].css('a').map { |link| link.attr('wikidata') }.first
  end

  field :officeBY do
    tds[1].text.tidy
  end

  field :person do
    tds[2].css('a').map { |link| link.attr('wikidata') }.first
  end

  field :personBY do
    tds[2].text.tidy
  end

  private

  def tds
    noko.css('td')
  end
end

url = 'https://be.wikipedia.org/wiki/%D0%A1%D0%B0%D0%B2%D0%B5%D1%82_%D0%9C%D1%96%D0%BD%D1%96%D1%81%D1%82%D1%80%D0%B0%D1%9E_%D0%A0%D1%8D%D1%81%D0%BF%D1%83%D0%B1%D0%BB%D1%96%D0%BA%D1%96_%D0%91%D0%B5%D0%BB%D0%B0%D1%80%D1%83%D1%81%D1%8C'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

wdids = data.flat_map { |row| row.values_at(:office, :person) }.compact.reject(&:empty?).uniq
lines = wdids.each_slice(50).map do |slice|
  res = `wd label -l en #{slice.join(' ')}`
  res.lines
end
labels = lines.flatten.map { |line| line.chomp.split(' ', 2) }.to_h

header = "office,officeBY,person,personBY,officeEN,personEN\n"
rows = data.map do |row|
  row.merge(
    {
      officeEN: labels[row[:office]],
      personEN: labels[row[:person]],
    }
  ).values.to_csv
end

abort 'No results' if rows.count.zero?
puts header + rows.join
