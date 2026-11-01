# frozen_string_literal: true

#
# A guest or plus one.
#
class Attendee < ApplicationRecord
  include RansackAllowlist

  scope :diet?, -> { where.not(diet: nil) }
  scope :child?, -> { where(child: true) }
end
