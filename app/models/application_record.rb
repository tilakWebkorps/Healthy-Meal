# frozen_string_literal: true

# its inbuild man
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
