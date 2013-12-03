
=begin
require "rubygems"
require "braintree"
require "awesome_print"
require "json"
=end


#Mike Barnet with braintree: 312.257.2356
#what goes inside config/initializers/braintree.rb
Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "8r9rgh86r35v6dpd"
Braintree::Configuration.public_key = "kvt5jjxkm99yt55b"
Braintree::Configuration.private_key = "b0a52c8b0f6bf1ee361d78a6dbe061f5"


#code that is inside rails controller handling transaction info
#if it's stored on brain tree then just use the guid to reuse this card

#it's mapped to a User (has many) payment methods (cards)

#otherwise just fill in each time


->() {
  result = Braintree::Transaction.sale(
    :amount => "7.77",
    :credit_card => {
      #:number => "5105105105105100",
      :number => "4111111111111111",
      :expiration_date => "05/14"
    }
  )
}

  result = Braintree::Transaction.sale(
    :amount => "8.01",
    :order_id => "order id",
    :credit_card => {
      :number => "5105105105105100",
      :expiration_date => "05/2012",
      :cvv => "111"
    },
    :customer => {
      :first_name => "__FIRST_NAME__",
      :last_name => "__LAST_NAME__",
      :company => "MakerSquare",
      :website => "http://www.themakersquare.com",
      :email => "__YOUR_EMAIL__@foo.com"
    }
  )


->() {
result = Braintree::Transaction.sale(
  :amount => "8.01",
  :order_id => "order id",
  :credit_card => {
    :number => "5105105105105100",
    :expiration_date => "05/2012",
    :cardholder_name => "YOUR_NAME_GOES_HERE",
    :cvv => "111"
  },
  :customer => {
    :first_name => "Drew",
    :last_name => "Smith",
    :company => "Braintree",
    :phone => "312-555-1234",
    :fax => "312-555-1235",
    :website => "http://www.example.com",
    :email => "drew@example.com"
  },
  :billing => {
    :first_name => "Paul",
    :last_name => "Smith",
    :company => "Braintree",
    :street_address => "1 E Main St",
    :extended_address => "Suite 403",
    :locality => "Chicago",
    :region => "Illinois",
    :postal_code => "60622",
    :country_code_alpha2 => "US"
  },
  :shipping => {
    :first_name => "Jen",
    :last_name => "Smith",
    :company => "Braintree",
    :street_address => "1 E 1st St",
    :extended_address => "Suite 403",
    :locality => "Bartlett",
    :region => "Illinois",
    :postal_code => "60103",
    :country_code_alpha2 => "US"
  },
  :options => {
    :submit_for_settlement => true
  }
)
}




#status received

#sale transaction
response = ->(result) {
  if result.success?
    ap result
    puts "success!: #{result.transaction.id}"
  elsif result.transaction
    puts "Error processing transaction:"
    puts "  code: #{result.transaction.processor_response_code}"
    puts "  text: #{result.transaction.processor_response_text}"
  else
    p result.errors
  end
}

response[result]

#nice trick to spelunk the gem source code 
#RICHARD SCHNEEMAN
#https://github.com/schneems
class Braintree::Transaction
  method(:credit).source_location
end


#credit/refund
#appears to only work in production mode 
#yields 403 ... this is for advanced usage
#needs to allow transaction to be settled after 2am from tech support 
->() {
  refund = Braintree::Transaction.credit(
    :amount => "7.77",
    :credit_card => {
      #:number => "5105105105105100",
      #:expiration_date => "05/2012"
      :number => "4111111111111111",
      :expiration_date => "05/14"
    }
  )
}#[]

#response[refund]
#=end
#void
#result = Braintree::Transaction.void("6dg94m")

#ajaxiy braintree poller to display on the 
#overview projector while the exercise is in session
#to give a real time affect on all transactions 
#arriving to your brain tree account
search_results = Braintree::Transaction.search do |search|
  search.status.in(
    Braintree::Transaction::Status::Authorized,
    Braintree::Transaction::Status::SubmittedForSettlement
  )
end

search_results.map {|transaction|
#<id: nil, first_name: nil, last_name: nil, email: nil, company: nil, website: nil, phone: nil, fax: nil
  x = {:first_name => transaction.customer_details.first_name,
       :last_name => transaction.customer_details.last_name,
       :email => transaction.customer_details.email,
       :time => transaction.created_at
  }
}[0..10].to_json


#Xml.hash_from_xml('<xml><person><name>Rob</name></person></xml>')

pp JSON.parse('{"gantt":{"dragonwrench.com":[{"duration":2,"start_time":"2013-11-29T16:47:21-06:00"}],"frankmusician.com":[{"duration":2,"start_time":"2013-11-29T16:47:21-06:00"}],"wardlawoffice.co":[{"duration":2,"start_time":"2013-11-29T22:47:20Z"}]},"range":["2013-11-28T22:32:02Z","2013-11-30T22:32:02Z"],"hours":["2013-11-28T22:00:00-06:00","2013-11-29T22:00:00-06:00"],"size":4}')




