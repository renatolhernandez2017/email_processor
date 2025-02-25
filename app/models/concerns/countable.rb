# app/models/concerns/countable.rb
module Countable
  extend ActiveSupport::Concern

  class_methods do
    def count_records
      all.count
    end
  end
end
