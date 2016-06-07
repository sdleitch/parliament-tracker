# This file will be loaded when the server/console starts
# and it will initialize a scrape of the Parliament website, etc.
# It is recurive and will schedule another scrape for the next day.

require File.join(Rails.root, "lib", "parliament_scraper.rb")

# ParliamentScraper.scrape if Delayed::Job.count < 1
