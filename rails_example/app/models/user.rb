# frozen_string_literal: true

class User < ApplicationRecord
  def adult?
    age >= 18
  end
end
