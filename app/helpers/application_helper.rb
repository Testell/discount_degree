module ApplicationHelper
  def form_errors(model)
    return unless model.errors.any?

    content_tag :div, id: "error_explanation", class: "mb-3" do
      content_tag(:ul, class: "list-unstyled") do
        model
          .errors
          .full_messages
          .map do |message|
            content_tag(:li) do
              content_tag(:div, message, class: "alert alert-danger", role: "alert")
            end
          end
          .join
          .html_safe
      end
    end
  end
end
