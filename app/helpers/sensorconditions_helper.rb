module SensorconditionsHelper
  def buildOperatorSelectTag sensor, condition
    options = ["< (lower than)", "<"], ["> (higher than)", ">"], ["= (equals)", "="]
    if condition.blank?
      select_tag "operators[#{h(sensor)}]", options_for_select(options, :selected => "<")
    else
      condition.operator.blank? ? condition = "<" : condition = condition.operator
      select_tag "operators[#{h(sensor)}]", options_for_select(options, :selected => condition)
    end
  end
end
