class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  def render_404
    render template: "errors/not_found", status: 404, layout: "application", content_type: "text/html"
  end
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
