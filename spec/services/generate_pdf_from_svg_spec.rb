require 'rails_helper'
require 'pdf/reader'

RSpec.describe GeneratePdfFromSvg do
    let(:svg) do
        <<~SVG
            <svg xmlns="http://www.w3.org/2000/svg" width="300" height="150">
                <circle cx="75" cy="75" r="50" fill="#2196f3" />
            </svg>
        SVG
    end


    it 'генерирует валидный PDF и включает watermark' do
        io = described_class.call(svg_io: StringIO.new(svg), watermark: 'Watermark Z')


        Tempfile.create(['result', '.pdf']) do |f|
            f.binmode
            f.write(io.read)
            f.rewind


            reader = PDF::Reader.new(f.path)
            all_text = reader.pages.map { |p| p.text }.join("\n")
            expect(all_text).to include('Watermark Z')
        end
    end
end