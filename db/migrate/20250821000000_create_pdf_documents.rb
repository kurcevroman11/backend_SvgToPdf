class CreatePdfDocuments < ActiveRecord::Migration[7.1]
    def change
        create_table :pdf_documents do |t|
            t.string :watermark, null: false
            t.timestamps
        end
    end
end
