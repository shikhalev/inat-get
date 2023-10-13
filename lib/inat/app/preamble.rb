# frozen_string_literal: true

module AppPreamble

  private def do_clean_requests
    # TODO: implement
  end

  private def do_clean_observations
    # TODO: implement
  end

  private def do_clean_orphans
    # TODO: implement
  end

  private def do_clean_all
    # TODO: implement
  end

  private def preamble!
    config[:preamble].each do |name|
      self.send "do_#{name}"
    end
  end

end
