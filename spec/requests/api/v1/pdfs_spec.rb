require 'rails_helper'


RSpec.describe 'POST /api/v1/pdfs', type: :request do
    include Rails.application.routes.url_helpers

    let(:svg_body) do
        <<~SVG
            <svg xmlns="http://www.w3.org/2000/svg" width="200" height="100">
                <rect x="10" y="10" width="180" height="80" fill="#4caf50" />
                <text x="100" y="55" font-size="20" text-anchor="middle" fill="#fff">Hello</text>
            </svg>
        SVG
    end


    it 'создаёт PDF и возвращает сериализованный ответ с URL' do
        file = Tempfile.new(['sample', '.svg'])
        file.write(svg_body)
        file.rewind


        post '/api/v1/pdfs', params: { svg: Rack::Test::UploadedFile.new(file.path, 'image/svg+xml'), watermark: 'Тестовый Водяной Знак' }


        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)


        expect(json['id']).to be_present
        expect(json['url']).to be_present


        # Проверка, что файл реально существует в ActiveStorage
        doc = PdfDocument.find(json['id'])
        expect(doc.file).to be_attached
    ensure
        file.close!
    end


    it 'возвращает 400 при отсутствии svg' do
        post '/api/v1/pdfs', params: { watermark: 'X' }
        expect(response).to have_http_status(:bad_request)
    end
end