require 'exchangerate-api'

class FindOpportunitiesJob < ApplicationJob
  queue_as :default

  def perform()
    response = RestClient.get 'https://v6.exchangerate-api.com/v6/1098f03436a94e89a0844b1e/latest/USD'
    puts response.body
    puts 'The FindOpportunitiesJob just executed! Hooray!'
    
    # self.set(wait_until: Time.now + (60 * 60 * 24)).perform_later
  end
end
