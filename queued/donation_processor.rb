class DonationProcessor
  def charity
    Charity.first
  end

  def donate(&block)
    yield if block_given?
    update_charity
  end

  private

  def update_charity
    donated_before = charity.donated_dollars
    puts "amount raised before donation: #{donated_before}"
    charity.update(donated_dollars: donated_before + 1)
    # puts "params #{r.params}!"
    donated_after = charity.donated_dollars
    puts "amount raised: #{donated_after}"
  end
end
