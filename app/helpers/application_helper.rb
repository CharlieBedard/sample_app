module ApplicationHelper

  # Returns a full title for each page. If no page specific title a
  # generic title is supplied
  def full_title(page_title)
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

end
