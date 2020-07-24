#!/usr/bin/env ruby

require 'csv'

RATINGS_TABLE =
  {'+1' => '<i class="fas fa-thumbs-up"></i>',
   '+2' => '<i class="fas fa-thumbs-up"></i> <i class="fas fa-thumbs-up"></i>',
   '+3' => '<i class="fas fa-star"></i>',
   ''   => '',
   '-1' => '<i class="fas fa-thumbs-down"></i>',
   '-2' => '<i class="fas fa-thumbs-down"></i> <i class="fas fa-thumbs-down"></i>',
   '-3' => '<i class="fas fa-poop"></i>'
}

book_metadata = {}
CSV.foreach('_data/books-metadata.csv', headers: true) do |row|
  key = "#{row['Author']}: #{row['Title']}"
  book_metadata[key] = {
    rating: RATINGS_TABLE[row['Rating']]
  }
  if (!row['ASIN'].empty?) && (row['ASIN'] != 'ASIN')
    book_metadata[key][:asin] = row['ASIN']
  end
end

CSV.open('_data/books-read.csv', 'wb', write_headers: true, headers: ['Rating','Title','Author','Date Read']) do |output_csv|
  CSV.foreach(ARGV[0], headers: true) do |row|
    if (row['Date Read'].nil? || row['Date Read'].empty?) && (row['Exclusive Shelf'] == 'read') && (!row['Date Added'].empty?)
      # set date read to date added
    end
    if (!row['Date Read'].nil?) && (!row['Date Read'].empty?)
      key = "#{row['Author']}: #{row['Title']}"
      row['Title'].tr!('*','')
      row['Title'].strip!
      real_isbn = row['ISBN'].tr('="','')
      real_isbn = book_metadata[key][:asin] if book_metadata[key][:asin]
      markdown_link = "*#{row['Title']}*"
      unless real_isbn.empty?
        markdown_link = "[*#{row['Title']}*](https://www.amazon.com/gp/product/#{real_isbn}/?tag=ryanfb-20)"
      end
      output_csv << [book_metadata[key][:rating], markdown_link, row['Author'], row['Date Read'].tr('/','-')]
    end
  end
end
