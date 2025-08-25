require 'rails_helper'

RSpec.describe PdfDocumentBlueprint do
    it 'рендерит URL' do
        doc = PdfDocument.create!(watermark: 'W')
        doc.file.attach(io: StringIO.new('%PDF-1.4 test'), filename: 'x.pdf', content_type: 'application/pdf')


        json = JSON.parse(PdfDocumentBlueprint.render(doc, view: :with_url))
        expect(json['url']).to be_present
    end
end
