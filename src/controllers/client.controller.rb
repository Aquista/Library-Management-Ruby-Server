module ClientController
  require 'sequel'
  require 'json'
  require_relative "../db/db"
  include DBConnection

  def findClients(searchQuery, limit = 100, page = 0)
    offset = page * limit

    if searchQuery 
      return DB.fetch("SELECT * FROM client
        WHERE (SELECT client_firstname || ' ' || client_surname) ILIKE :searchQuery
        OR client_email ILIKE :searchQuery
        LIMIT :limit
        OFFSET :offset",
        searchQuery: "%#{searchQuery}%",
        limit: limit,
        offset: offset      
      )
    else 
      return DB.fetch("SELECT * FROM client LIMIT :limit OFFSET :offset",
        limit: limit,
        offset: offset
      )
    end
  end
end