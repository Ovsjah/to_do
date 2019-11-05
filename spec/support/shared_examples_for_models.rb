shared_examples 'emails' do |emails, validator, adj|
  emails.each do |email|
    it "is #{adj} #{email}" do
      subject.email = email
      expect(subject).to(send(validator))
    end
  end
end
