# coding: utf-8

Encoding.default_external = Encoding::UTF_8

require "bundler"
Bundler.require(:default, :web)

require_relative "db"

get "/" do
  @mona_jpy_bid_low = 7.0
  @mona_jpy_bid_high = 8.0
  @gpu_watts = 120
  unit_tokyo = 30.02
  unit_eneos = 25.75
  gpu_threshold = 0.07

  @earnings = Earning.desc(:created_at).limit(360)

  now = Time.now

  # 月
  month_gpu_earnings = Earning
    .where(:created_at.gte => now - 1.months)
    .and(:hour.gte => gpu_threshold)

  @month_work_hours = month_gpu_earnings.size()
  @month_profit_mona = @month_work_hours > 0 ?
    month_gpu_earnings.map{ |e| e.hour }.inject(:+) :
    0
  @month_profit_yen = @month_profit_mona * @mona_jpy_bid_low
  @month_electric_bill_tokyo = electric_bill(@gpu_watts, @month_work_hours, unit_tokyo)
  @month_electric_bill_eneos = electric_bill(@gpu_watts, @month_work_hours, unit_eneos)

  # 週
  week_gpu_earnings = Earning
    .where(:created_at.gte => now - 1.weeks)
    .and(:hour.gte => gpu_threshold)

  @week_work_hours = week_gpu_earnings.size()
  @week_profit_mona = @week_work_hours > 0 ?
    week_gpu_earnings.map{ |e| e.hour }.inject(:+) :
    0
  @week_profit_yen = @week_profit_mona * @mona_jpy_bid_low
  @week_electric_bill_tokyo = electric_bill(@gpu_watts, @week_work_hours, unit_tokyo)
  @week_electric_bill_eneos = electric_bill(@gpu_watts, @week_work_hours, unit_eneos)

  # 日
  day_gpu_earnings = Earning
    .where(:created_at.gte => now - 1.days)
    .and(:hour.gte => gpu_threshold)

  @day_work_hours = day_gpu_earnings.size()
  @day_profit_mona = @day_work_hours > 0 ?
    day_gpu_earnings.map{ |e| e.hour }.inject(:+) :
    0
  @day_profit_yen = @day_profit_mona * @mona_jpy_bid_low
  @day_electric_bill_tokyo = electric_bill(@gpu_watts, @day_work_hours, unit_tokyo)
  @day_electric_bill_eneos = electric_bill(@gpu_watts, @day_work_hours, unit_eneos)

  slim :index
end

helpers do
  def yen(value, digits = 0)
    sprintf("¥%.#{digits}f", value)
  end

  def to_s(value, digits)
    sprintf("%.#{digits}f", value)
  end

  def electric_bill(watt, hours, unit)
    (watt.to_f / 1000) * hours * unit
  end
end
