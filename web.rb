# coding: utf-8

require "bundler"
Bundler.require(:default, :web)

require_relative "db"

get "/" do
  slim :index
end
