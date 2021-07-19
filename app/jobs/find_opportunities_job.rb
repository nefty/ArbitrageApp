require 'rest-client'
require 'json'

class FindOpportunitiesJob < ApplicationJob
  queue_as :default

  def perform()
    api_key = ENV["EXCHANGERATE_API_KEY"]
    api_url = "https://v6.exchangerate-api.com/v6/1098f03436a94e89a0844b1e"

    # get_currencies(api_url)
    # get_currency_pairs(api_url)

    g = EdgeWeightedDigraph.new

    source_currency = BaseCurrency.find_by(code: 'USD')
    search = BellmanFordSP.new(g, source_currency)
    if search.negative_cycle?
      opportunity = Opportunity.create
      puts '==NEGATIVE CYCLE FOUND=='
      stake = 1000.0
      puts "There are #{search.cycle.length} trades in this cycle"
      search.cycle.each_with_index do |currency_pair, index|
        print "#{stake} #{currency_pair.base_currency.code} = " 
        stake *= currency_pair.exchange_rate
        puts "#{stake} #{currency_pair.quote_currency.code}"
        currency_pair_object = CurrencyPair.find_by(base_currency: currency_pair.base_currency, quote_currency: QuoteCurrency.find(currency_pair.quote_currency.id))
        Trade.create(order: index, opportunity: opportunity, currency_pair: currency_pair_object)
      end
    end

    puts 'The FindOpportunitiesJob just executed! Hooray!'

    # self.set(wait_until: Time.now + (60 * 60 * 24)).perform_later
  end

  private

  class DirectedEdge
    attr_reader :base_currency
    attr_reader :quote_currency
    attr_reader :exchange_rate
    attr_reader :exchange_rate_prime

    def initialize(base_currency, quote_currency, exchange_rate)
      @base_currency = base_currency
      @quote_currency = quote_currency
      @exchange_rate = exchange_rate
      # Transform the exchange rate to a form usable for finding negative cycle
      @exchange_rate_prime = -Math.log(exchange_rate)
    end
  end

  class EdgeWeightedDirectedCycle
    attr_reader :cycle

    def initialize(g)
      @marked = {}
      @on_stack = {}
      @edge_to = {}
      g.currencies.each do |currency|
        dfs(g, currency) if !@marked[currency.id]
      end
    end

    def dfs(g, currency)
      @on_stack[currency.id] = true
      @marked[currency.id] = true

      g.adj[currency.id].each do |currency_pair|
        # puts "Currency Pair---"
        # puts currency_pair

        # quote_currency = BaseCurrency.find(currency_pair.quote_currency.id)
        quote_currency = currency_pair.quote_currency
        
        # puts "Quote Currency---"
        # puts quote_currency

        return if @cycle

        if !@marked[quote_currency.id]
          # puts "#{quote_currency.code} not marked"
          @edge_to[quote_currency.id] = currency_pair
          dfs(g, quote_currency)        
        elsif @on_stack[quote_currency.id]
          @cycle = []

          f = currency_pair

          # puts "f base currency #{f.base_currency}"
          while f.base_currency.id != quote_currency.id
            @cycle.push f
            f = @edge_to[f.base_currency.id]
          end
          @cycle.push f
        end

      end

      @on_stack[currency.id] = false
    end
  end

  class EdgeWeightedDigraph
    attr_reader :adj
    attr_reader :currencies

    def initialize()
      @adj = {}
      @currencies = BaseCurrency.all 
      @currencies.each do |base_currency|
        currency_pairs = CurrencyPair.where(base_currency:base_currency)
        pair_list = []
        currency_pairs.each do |currency_pair|
          pair_list.push DirectedEdge.new(base_currency,
                                          currency_pair.quote_currency,
                                          currency_pair.exchange_rate)
        end
        @adj[base_currency.id] = pair_list
      end
    end

    def outdegree(currency)
      @adj[currency.id].length
    end

    # This only works because we have a complete digraph, so
    # indegree(currency) == outdegree(currency)
    def indegree(currency)
      outdegree(currency)
    end
  end

  class BellmanFordSP
    attr_reader :dist_to
    attr_reader :edge_to
    attr_reader :cycle

    def initialize(g, source_currency)
      # Number of calls to relax()
      @cost = 0

      @edge_to = {}

      # Distance of shortest source -> vertex path
      @dist_to = {} 
      g.currencies.each do |currency|
        @dist_to[currency.id] = Float::INFINITY
      end

      @dist_to[source_currency.id] = 0.0

      # Bellman-Ford algorithm
      @queue = []
      @on_queue = {}
      @queue.push source_currency.id
      @on_queue[source_currency.id] = true

      while (@queue and !self.negative_cycle?)
        currency_id = @queue.shift
        @on_queue[currency_id] = false
        relax(g, currency_id)
      end
    end

    def relax(g, currency)
      g.adj[currency].each do |currency_pair|
        bc = currency_pair.base_currency
        # qc = BaseCurrency.find(currency_pair.quote_currency.id)
        qc = currency_pair.quote_currency
        erp = currency_pair.exchange_rate_prime
        if @dist_to[qc.id] > @dist_to[bc.id] + erp
          @dist_to[qc.id] = @dist_to[bc.id] + erp
          @edge_to[qc.id] = currency_pair
          if !@on_queue[qc.id]
            @queue.push qc.id
            @on_queue[qc.id] = true
          end
        end
        @cost += 1
        if @cost % g.currencies.length == 0
          find_negative_cycle g
          return if negative_cycle?
        end
      end
    end

    def negative_cycle?
      @cycle != nil
    end

    def find_negative_cycle(g)
      finder = EdgeWeightedDirectedCycle.new(g)
      @cycle = finder.cycle
    end

  end

  def get_currencies(api_url)
    # If there is no currency in the database, GET the list of currencies from API
    unless BaseCurrency.find_by(code: 'USD')
      response = RestClient.get "#{api_url}/codes"
      currencies = JSON.parse(response)
      currencies['supported_codes'].each do |currency|
        currency_code = currency[0]
        currency_name = currency[1]
        BaseCurrency.create(name: currency_name, code: currency_code)
        QuoteCurrency.create(name: currency_name, code: currency_code)
      end
    end
  end

  def get_currency_pairs(api_url)
    pairs_exist = CurrencyPair.find_by(base_currency: BaseCurrency.find_by(code: 'USD'),
                                quote_currency: QuoteCurrency.find_by(code: 'GBP'))
    exchange = Exchange.first
    BaseCurrency.all.each do |base_currency|
      result = RestClient.get "#{api_url}/latest/#{base_currency.code}"
      rates = JSON.parse(result)
      rates['conversion_rates'].each do |currency_code, exchange_rate|
        quote_currency = QuoteCurrency.find_by(code: currency_code)
        if pairs_exist
          pair = CurrencyPair.find_by(base_currency: base_currency,
                                      quote_currency: quote_currency)
          pair.update(exchange_rate: exchange_rate)
        else
          CurrencyPair.create(exchange: exchange, base_currency: base_currency,
                              quote_currency: quote_currency,
                              exchange_rate: exchange_rate)
        end
      end
    end
  end
end
