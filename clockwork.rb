# coding: utf-8

require "bundler"
Bundler.require

require "logger"

require_relative "db"

class Work
  def self.crawl
    config = YAML.load_file('config.yml')

    agent = Mechanize.new
    # agent.log = Logger.new(STDOUT)

    agent.get("https://asicpool.info/index.php?page=login")
    form = agent.page.forms.first
    form["username"] = config["username"]
    form["password"] = config["password"]
    form.submit

    agent.get("https://asicpool.info/index.php?page=account&action=earnings")
    doc = Nokogiri::HTML(agent.page.body)
    earnings = parse_earnings(doc)

    # pp earnings

    Earning.create(
      total: earnings[:summary][:credit],
      hour: earnings[:sorted_by_time][:last_hour][:credit],
      day: earnings[:sorted_by_time][:last_day][:credit],
      week: earnings[:sorted_by_time][:last_week][:credit],
      month: earnings[:sorted_by_time][:last_month][:credit],
      year: earnings[:sorted_by_time][:last_year][:credit],
      )
  end

  def self.parse_earnings(doc)
    tables = doc.css('table')
    raise if tables.size != 2

    {
      :summary => parse_summary(tables[0]),
      :sorted_by_time => parse_sorted_by_time(tables[1]),
    }
  end

  def self.parse_summary(table)
    keys = %w!credit debit_ap fee tx_fee!.map(&:to_sym)
    values = table.css("td.right").map{ |e| e.inner_text.to_f }
    raise if keys.size != values.size

    Hash[*keys.zip(values).flatten]
  end

  def self.parse_sorted_by_time(table)
    keys = %w!credit bonus debit_ap debit_mp donation fee tx_fee!.map(&:to_sym)
    categories = %w!last_hour last_day last_week last_month last_year!.map(&:to_sym)
    ret = {}

    rows = table.css("tbody > tr")
    rows.each do |row|
      values = row.css("td").map{ |col| col.inner_text.strip }
      values.shift

      category = categories.shift
      raise if !category
      raise if keys.size != values.size

      ret[category] = Hash[*keys.zip(values).flatten]
    end

    ret
  end
end

module Clockwork
  def self.crawl
    Work.crawl
  end

  handler do |job|
    self.send(job.to_sym)
  end

  every(1.hour, "crawl", :at => "**:00")
  # every(30.second, "crawl")
end

# debug
# Work.crawl()
