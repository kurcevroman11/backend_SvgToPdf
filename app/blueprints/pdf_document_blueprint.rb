class PdfDocumentBlueprint < Blueprinter::Base
  identifier :id
  fields :watermark, :created_at

  view :with_url do
    field :url do |obj, options|
      # options[:host] можно передавать при рендере
      host = options[:host] || ENV['APP_HOST']
      Rails.application.routes.url_helpers.rails_blob_url(obj.file, host: host, only_path: false)
    end
  end
end