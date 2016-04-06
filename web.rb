# coding: utf-8

Encoding.default_external = Encoding::UTF_8

require "bundler"
Bundler.require(:default, :web)

require_relative "db"

get "/" do
  @mona_jpy_bid_low = 7.0
  @mona_jpy_bid_high = 8.0

  @earnings = Earning.desc(:created_at).limit(360)

  slim :index
end

helpers do
  def yen(value, digits = 0)
    sprintf("¥%.#{digits}f", value)
  end

  def to_s(value, digits)
    sprintf("%.#{digits}f", value)
  end
end
