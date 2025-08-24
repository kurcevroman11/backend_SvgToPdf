RSpec.describe 'api/v1/pdfs', type: :request do
  path '/api/v1/pdfs' do
    post 'Генерация PDF из SVG' do
      tags 'PDF'
      consumes 'multipart/form-data'

      parameter name: :svg,
                in: :formData,
                type: :string,
                format: :binary,
                required: true,
                description: 'SVG файл'

      parameter name: :watermark,
                in: :formData,
                type: :string,
                required: false,
                description: 'Текст водяного знака'

      response '201', 'PDF успешно создан' do
        let(:svg) { Rack::Test::UploadedFile.new('spec/fixtures/sample.svg', 'image/svg+xml') }
        let(:watermark) { 'Test Watermark' }
        run_test!
      end

      response '400', 'Неверные параметры' do
        let(:svg) { nil }
        run_test!
      end
    end
  end
end
