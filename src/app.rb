require "dotenv"
Dotenv.load()

require "cuba"
require "cuba/safe"
require "sequel"
require "json"
require_relative "./controllers/book.controller"
require_relative "./controllers/client.controller"
require_relative "./controllers/borrowing.controller"
require_relative "./db/db"

include DBConnection
include BookController
include ClientController
include BorrowingController

Cuba.use Rack::Session::Cookie, :secret => ENV["CUBA_SESSION_SECRET"]
Cuba.plugin Cuba::Safe

dataset = DB['select * from book'].each do |row| 
  puts row[:book_title]
end

#TODO: investigar models de sequel

Cuba.define do
  on get do
    on "books" do
      searchQuery, limit, page = req.params.values_at("searchQuery", "limit", "page")
      books = findBooks(searchQuery, limit, page)

      parsedBooks = books.to_a.to_json
      res.json(parsedBooks)
    end

    on "clients" do
      searchQuery, limit, page = req.params.values_at("searchQuery", "limit", "page")
      clients = findClients(searchQuery, limit, page)

      parsedClients = clients.to_a.to_json
      res.json(parsedClients)
    end

    on "borrowings" do
      clientEmail, limit, page = req.params.values_at("clientEmail", "limit", "page")
      borrowings = findBorrowings(clientEmail, limit, page)

      parsedborrowings = borrowings.to_a.to_json
      res.json(parsedborrowings)
    end


    on root do
      res.write "TODO"
    end
  end

  on post do
    on "borrowings" do
      bodyParams = JSON.parse( req.body.read )
      clientId, bookId, durationInDays = bodyParams.values_at("clientId", "bookId", "durationInDays")

      insertedSuccessfully = registerBorrowing(clientId, bookId, durationInDays)
      if(insertedSuccessfully)
        res.write "DONE"
      else
        res.write "ERROR"
      end
    end
  end

  on patch do
    on "borrowings/:id" do |borrowingId|
      updatedSuccessFully = returnBorrowedBook(borrowingId)
      if(updatedSuccessFully)
        res.write "DONE"
      else
        res.write "ERROR"
      end
    end
  end
end