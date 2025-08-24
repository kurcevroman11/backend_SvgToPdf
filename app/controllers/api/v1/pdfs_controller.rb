class Api::V1::PdfsController < ApplicationController
    include Rails.application.routes.url_helpers

    def create
        svg = params.require(:svg) # ActionDispatch::Http::UploadedFile или текст
        watermark = params[:watermark].presence || 'Watermark'

        # Генерация PDF
        pdf_io = GeneratePdfFromSvg.call(svg_io: svg, watermark: watermark)

        # Создание записи в базе
        doc = PdfDocument.create!(watermark: watermark)

        svg_io = file_io_for(svg)
        doc.source_svg.attach(
            io: svg_io,
            filename: infer_svg_filename(svg),
            content_type: 'image/svg+xml'
        )

        doc.file.attach(
            io: pdf_io,
            filename: "generated_#{SecureRandom.hex(4)}.pdf",
            content_type: 'application/pdf'
        )

        render json: PdfDocumentBlueprint.render(doc, view: :with_url), status: :created

    rescue ActionController::ParameterMissing => e
        render json: { error: e.message }, status: :bad_request
    end

    private

    def file_io_for(svg)
        if svg.is_a?(ActionDispatch::Http::UploadedFile)
            File.open(svg.path)
        else
            StringIO.new(svg.to_s)
        end
    end

    def infer_svg_filename(svg)
        if svg.is_a?(ActionDispatch::Http::UploadedFile)
            svg.original_filename
        else
            "uploaded_#{SecureRandom.hex(4)}.svg"
        end
    end  
end