# frozen_string_literal: true

require 'extra/enum'

module INat::Data::Types; end

class INat::Data::Types::LicenseCode < Enum

  items :'cc0',
        :'cc-by',
        :'cc-by-nc',
        :'cc-by-nd',
        :'cc-by-sa',
        :'cc-by-nc-nd',
        :'cc-by-nc-sa',
        :'pd'

  freeze
end
