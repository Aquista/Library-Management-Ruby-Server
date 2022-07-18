module BorrowingController
  require 'sequel'
  require 'json'
  require 'date'
  require_relative "../db/db"
  include DBConnection

  def findBorrowings(clientEmail, limit = 100, offset = 0)
    whereClause = ""
    if(clientEmail)
      whereClause = " WHERE client_email ILIKE '%#{clientEmail}%' "
    end

    return DB.fetch("SELECT * FROM borrowing AS brws 
      JOIN client AS c ON c.client_id = brws.borrowing_client_id
      #{whereClause}
      LIMIT :limit
      OFFSET :offset",
      limit: limit,
      offset: offset      
    )
  end

  def registerBorrowing(clientId, bookId, durationInDays)
    currentDate = Time.now
    dueDate = currentDate + (durationInDays * 24 * 60 * 60)
    puts currentDate
    puts dueDate

    #TODO: avoid duplicate borrowings

=begin Raw SQL alternative
    return DB.run("INSERT INTO borrowing(
      borrowing_client_id,
      borrowing_book_id,
      borrowing_returned,
      borrowing_date,
      borrowing_due_date
    ) VALUES (
      #{clientId},
      #{bookId},
      false,
      '#{currentDate}',
      '#{dueDate}'
    )")
=end
    begin  
      DB.from(:borrowing).insert(
        borrowing_client_id: clientId,
        borrowing_book_id: bookId,
        borrowing_returned: false,
        borrowing_date: currentDate,
        borrowing_due_date: dueDate
      )
      return true
    rescue => e
      return false
    end
  end

  def returnBorrowedBook(borrowingId)
    begin
      DB.from(:borrowing)
      .where(
        borrowing_id: borrowingId
      )
      .update(
        borrowing_returned: true
      )
      return true
    rescue => e
      puts e
      return false
    end

  end

end