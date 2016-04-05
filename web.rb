# coding: utf-8

require "bundler"
Bundler.require(:default, :web)

require_relative "db"

get "/" do
  @earnings = Earning.desc(:created_at).limit(360)

  slim :index
end
