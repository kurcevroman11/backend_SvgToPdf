class PdfDocumentBlueprint < Blueprinter::Base
    identifier :id
    fields :watermark, :created_at
    view :with_url do
        field :url do |obj, options|
            Rails.application.routes.url_helpers.rails_blob_url(obj.file, only_path: false)
        end
    end
end