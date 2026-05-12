module TimezoneHelper
  def timezone_label
    I18n.locale == :en ? "Brasília Time (GMT-3)" : "Brasília (GMT-3)"
  end
end
