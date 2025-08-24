require 'prawn'
require 'prawn-svg'

class GeneratePdfFromSvg
    CM_IN_PT = 28.3465 # 1 см в типографских пунктах


    def self.call(svg_io:, watermark:, page_size: 'A4')
        new(svg_io:, watermark:, page_size:).call
    end


    def initialize(svg_io:, watermark:, page_size: 'A4')
        @svg_io = svg_io
        @watermark = watermark
        @page_size = page_size
    end


    def call

        pdf = Prawn::Document.new(page_size: @page_size)
        # Подключаем шрифт DejaVuSans для UTF-8
        font_path = Rails.root.join('app', 'assets', 'fonts', 'ttf', 'DejaVuSans.ttf')
        if File.exist?(font_path)
            pdf.font_families.update('DejaVuSans' => { normal: font_path.to_s })
            pdf.font('DejaVuSans')
        end


        # Поля: по 1 см до и 1 см после контента (итого 2 см от края до внутренней рамки)
        inner_margin = 2 * CM_IN_PT # 2 см от краёв страницы для области контента
        outer_offset = 1 * CM_IN_PT # внешняя «граница» на 1 см за рамкой

        content_left   = pdf.bounds.left   + inner_margin
        content_right  = pdf.bounds.right  - inner_margin
        content_top    = pdf.bounds.top    - inner_margin
        content_bottom = pdf.bounds.bottom + inner_margin

        content_width  = content_right - content_left
        content_height = content_top - content_bottom

        pdf.bounding_box([content_left, content_top], width: content_width, height: content_height) do
            svg_data = @svg_io.respond_to?(:read) ? @svg_io.read : @svg_io.to_s

            Prawn::Svg::Interface.new(
                svg_data,
                pdf,
                at: [0, content_height],
                width: content_width,
                height: content_height,
                enable_web: false
            ).draw
        end


        # 2) Рамка вокруг контента (внутренняя рамка)
        pdf.stroke do
            pdf.rectangle [content_left, content_top], content_width, content_height
        end


        # 3) Доп. «область после» — внешняя окантовка на 1 см за рамкой
        outer_left   = [pdf.bounds.left,   content_left  - outer_offset].max
        outer_right  = [pdf.bounds.right,  content_right + outer_offset].min
        outer_top    = [pdf.bounds.top,    content_top   + outer_offset].min
        outer_bottom = [pdf.bounds.bottom, content_bottom - outer_offset].max

        outer_width  = outer_right - outer_left
        outer_height = outer_top   - outer_bottom

        pdf.dash(3)
        pdf.stroke do
            pdf.rectangle [outer_left, outer_top], outer_width, outer_height
        end
        pdf.undash

        # 5) Watermark (полупрозрачный текст по диагонали)
        pdf.fill_color '000000'
        pdf.transparent(0.1) do
            pdf.rotate(45, origin: [pdf.bounds.width / 2, pdf.bounds.height / 2]) do
                pdf.text_box(
                    @watermark,
                    size: 64,
                    align: :center,
                    valign: :center,
                    at: [0, pdf.bounds.height / 4],
                    width: pdf.bounds.width
                )
            end
        end

        pdf_io = StringIO.new(pdf.render)
        pdf_io.rewind
        pdf_io
    end
end