# This file will be loaded when the server/console starts
# and it will initialize a scrape of the Parliament website, etc.
# It is recurive and will schedule another scrape for the next day.

require File.join(Rails.root, "lib", "parliament_scraper.rb")

# Look into this:
# IS there a way to check is a certain job is scheduled
# instead of simply no jobs? e.g. run IF no TOP LEVEL scrape scheduled
if Delayed::Job.all.length == 0
  ParliamentScraper.scrape
end
