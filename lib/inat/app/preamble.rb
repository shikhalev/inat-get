# frozen_string_literal: true

module AppPreamble

  private def do_clean_requests
    # NEED: implement
  end

  private def do_clean_observations
    # NEED: implement
  end

  private def do_clean_orphans
    # NEED: implement
  end

  private def do_clean_all
    # NEED: implement
  end

  private def preamble!
    config[:preamble].each do |name|
      self.send "do_#{name}"
    end
  end

end
