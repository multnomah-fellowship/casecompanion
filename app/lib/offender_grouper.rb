class OffenderGrouper
  def initialize(offenders)
    @offenders = offenders
  end

  def each_group
    @_grouped ||= group_offenders
    @_grouped.each
  end

  def total_results
    @_grouped ||= group_offenders
    @_grouped.length
  end

  private

  def group_offenders
    @offenders
      .group_by { |o| o[:sid] }
      .map do |sid, results|
        # sanity check that all the results have the same dob
        if results.map { |o| o[:dob] }.uniq.length > 1
          Raven.capture_message("DOB for SID #{sid} results not all identical!")
        end

        first, middle, last, dob = results[0].values_at(:first, :middle, :last, :dob)
        aliases = results[1..-1].map do |r|
          format_name(r[:first], r[:middle], r[:last])
        end

        {
          sid: sid,
          full_name: format_name(first, middle, last),
          dob: dob,
          aliases: aliases,
        }
    end
  end

  def format_name(first, middle, last)
    [first, middle, last].map(&:presence).compact.map(&:capitalize).join(' ')
  end
end
