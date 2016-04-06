# coding: utf-8

require "mongoid"

class Earning
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :total, type: Float

  field :hour, type: Float
  field :day, type: Float
  field :week, type: Float
  field :month, type: Float
  field :year, type: Float

  index({ created_at: 1 }, { name: "created_at_index" })
end

Mongoid.load!("mongoid.yml", ENV["ENV"] || :development)

if !ENV["ENV"]
  Mongoid.logger.level = Logger::DEBUG
  Moped.logger.level = Logger::DEBUG
end

Earning.create_indexes
