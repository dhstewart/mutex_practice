require_relative '../setup.rb'

class App < Roda
  plugin :json, content_type: 'application/json'
  plugin :json_parser

  mutex = Mutex.new

  Thread.new do
    route do |r|
      # GET / request
      r.root do
        r.redirect "/donate"
      end

      # Right now we only have one charity, and users can only donate one dollar
      # at a time, so our API is pretty simple
      # /donate branch
      r.on 'donate' do
        # /donate request
        r.is do
          r.post do
            mutex.synchronize do
              DonationProcessor.new.donate { sleep 5 }
              response.status = 201
              'post done'
            end
          end
        end
      end

      r.get 'total_donated' do
        r.is do
          puts "Total Donated: #{Charity.first.donated_dollars}"
        end
      end
    end
  end.join
end

run App.freeze.app
