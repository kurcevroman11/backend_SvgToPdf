class PdfDocumentBlueprint < Blueprinter::Base
  identifier :id
  fields :watermark, :created_at

  view :with_url do
    field :url do |obj|
      obj.file.url
    end
  end
end
