# coding: utf-8

Encoding.default_external = Encoding::UTF_8

require "bundler"
Bundler.require(:default, :web)

require_relative "db"

UNIT_TOKYO = 30.02
UNIT_ENEOS = 25.75

get "/" do
  @mona_jpy_bid_low = 7.0
  @mona_jpy_bid_high = 8.0
  @gpu_watts = 120
  gpu_threshold = 0.07

  @earnings = Earning.desc(:created_at).limit(360)

  now = Time.now

  # 月
  month_gpu_earnings = Earning
    .where(:created_at.gte => now - 1.months)
    .and(:hour.gte => gpu_threshold)

  # 週
  week_gpu_earnings = Earning
    .where(:created_at.gte => now - 1.weeks)
    .and(:hour.gte => gpu_threshold)

  # 日
  day_gpu_earnings = Earning
    .where(:created_at.gte => now - 1.days)
    .and(:hour.gte => gpu_threshold)

  @balance = {
    :month => calc_balance(month_gpu_earnings, 24 * 30, @mona_jpy_bid_low, @gpu_watts),
    :week => calc_balance(week_gpu_earnings, 24 * 7, @mona_jpy_bid_low, @gpu_watts),
    :day => calc_balance(day_gpu_earnings, 24, @mona_jpy_bid_low, @gpu_watts),
  }

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

  def calc_balance(earnings, full_hours, mona_jpy, gpu_watts)
    work_hours = earnings.size()
    profit_mona = work_hours > 0 ?
      earnings.map{ |e| e.hour }.inject(:+) :
      0
    work_rate = work_hours.to_f / full_hours
    electric_bill_tokyo = electric_bill(gpu_watts, work_hours, UNIT_TOKYO)
    electric_bill_eneos = electric_bill(gpu_watts, work_hours, UNIT_ENEOS)

    {
      :work_hours => work_hours,
      :work_percent => 100.0 * work_rate,
      :profit_mona => profit_mona,
      :profit_yen => profit_mona * mona_jpy,
      :electric_bill_tokyo => electric_bill_tokyo,
      :electric_bill_eneos => electric_bill_eneos,
      :full_profit_yen => profit_mona * mona_jpy / work_rate,
      :full_electric_bill_eneos => electric_bill_eneos / work_rate,
    }
  end
end
