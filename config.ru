require_relative 'setup.rb'

class App < Roda
  plugin :json, content_type: 'application/json'
  plugin :json_parser

  route do |r|
    # GET / request
    r.root do
      r.redirect "/donate"
    end

    r.on 'donate' do
      # /donate request
      r.is do
        r.post do
          DonationProcessor.new.donate
          response.status = 201
          'post done'
        end
      end
    end

    r.get 'total_donated' do
      r.is do
        puts "Total Donated: #{Charity.first.donated_dollars}"
      end
    end
  end
end

run App.freeze.app
