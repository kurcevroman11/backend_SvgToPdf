class PdfDocument < ApplicationRecord
    has_one_attached :file
    has_one_attached :source_svg
    validates :watermark, presence: true
end
