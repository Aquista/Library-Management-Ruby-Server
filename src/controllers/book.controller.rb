module BookController
  require 'sequel'
  require 'json'
  require_relative "../db/db"
  include DBConnection

  def findBooks(searchQuery, limit = 100, offset = 0)
    if searchQuery 
      return DB.from(:book)
        .join(:author, author_id: :book_author_id)
        .where(Sequel.ilike(:book_title, "%#{searchQuery}%"))
        .or(Sequel.ilike(:author_firstname, "%#{searchQuery}%"))
        .limit(limit)
        .offset(offset)
    else 
      return DB.from(:book).limit(limit).offset(offset)
    end
  end
end