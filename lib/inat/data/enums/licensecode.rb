# frozen_string_literal: true

require 'extra/enum'

class LicenseCode < Enum

  items :'cc0',
        :'cc-by',
        :'cc-by-nc',
        :'cc-by-nd',
        :'cc-by-sa',
        :'cc-by-nc-nd',
        :'cc-by-nc-sa'

  freeze
end
