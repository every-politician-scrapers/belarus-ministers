#!/bin/bash

bundle exec ruby bin/scraper/wikipedia.rb > data/wikipedia.csv
# No comparison yet: scraping just to track diffs
