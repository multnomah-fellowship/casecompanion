# frozen_string_literal: true

class CrimesImportStatusUpdater
  def initialize(destination:)
    @destination = destination
  end

  def track_status(step_name)
    status = 'Success'
    start_time = Time.now
    yield
    end_time = Time.now
  rescue => ex
    status = "Error: #{ex.message}"
    raise ex
  ensure
    @destination.save_status_update(step_name, status, start_time, end_time)
  end
end
