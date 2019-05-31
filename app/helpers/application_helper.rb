module ApplicationHelper
  def bar_name
    settings = YAML.load_file(Rails.root.to_s + "/config/settings.yml")
    bar_name = settings["bar_name"]
    return bar_name
  end
end
