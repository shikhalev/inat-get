# frozen_string_literal: true

require_relative '../ddl'
require_relative '../entity'
require_relative 'user'

class Flag < Entity

  table :flags

  field :flag, type: String, required: true
  field :created_at, type: Time
  field :updated_at, type: Time
  field :user, type: User, index: true
  field :resolved, type: Boolean, index: true
  field :resolver, type: User, index: true
  field :comment, type: String

end

DDL::register Flag
