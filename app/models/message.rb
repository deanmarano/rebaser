class Message < ActiveRecord::Base
  serialize :body
  serialize :hash
  after_create :parse_json_fields

  def is_pr?
    self.body['pull_request'].present?
  end

  def parse_json_fields
    [:headers, :body].each do |field|
      begin
        if self.send(field).class == String
          self.send(field.to_s + "=", JSON.parse(self.send(field)))
        end
      rescue JSON::ParserError => e
        puts "failed to parse #{field} - #{e.message}"
      end
    end
    save
  end
end
