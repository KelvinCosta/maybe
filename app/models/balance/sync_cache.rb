class Balance::SyncCache
  EntryData = Struct.new(:date, :amount, :transaction?, :trade?, :valuation?)
  HoldingData = Struct.new(:date, :amount)

  def initialize(account)
    @account = account
  end

  def get_valuation(date)
    converted_entries.find { |e| e.date == date && e.valuation? }
  end

  def get_holdings(date)
    converted_holdings.select { |h| h.date == date }
  end

  def get_entries(date)
    converted_entries.select { |e| e.date == date && (e.transaction? || e.trade?) }
  end

  # Returns unique dates from all entries and holdings for sparse calculation
  def relevant_dates
    (converted_entries.map(&:date) + converted_holdings.map(&:date)).uniq
  end

  private
    attr_reader :account

    def converted_entries
      @converted_entries ||= account.entries.order(:date).to_a.map do |e|
        converted_entry = e.dup
        converted_entry.amount = converted_entry.amount_money.exchange_to(
      @converted_entries ||= account.entries.order(:date).map do |e|
        amount = e.currency == account.currency ? e.amount : e.amount_money.exchange_to(
          account.currency,
          date: e.date,
          fallback_rate: 1
        ).amount
        converted_entry.currency = account.currency
        converted_entry
        
        EntryData.new(e.date, amount, e.transaction?, e.trade?, e.valuation?)
      end
    end

    def converted_holdings
      @converted_holdings ||= account.holdings.map do |h|
        converted_holding = h.dup
        converted_holding.amount = converted_holding.amount_money.exchange_to(
        amount = h.currency == account.currency ? h.amount : h.amount_money.exchange_to(
          account.currency,
          date: h.date,
          fallback_rate: 1
        ).amount
        converted_holding.currency = account.currency
        converted_holding
        
        HoldingData.new(h.date, amount)
      end
    end
end
