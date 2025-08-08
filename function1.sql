-- 1. Write a function that returns a list of books with the minimum number of pages issued by a particular publisher.


CREATE FUNCTION dbo.GetBooksWithMinPagesByPublisher (@PublisherId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT b.Id, b.Name, b.Pages, b.YearPress
    FROM dbo.Books b
    WHERE b.Id_Press = @PublisherId
    AND b.Pages = (
        SELECT MIN(b1.Pages)
        FROM dbo.Books b1
        WHERE b1.Id_Press = @PublisherId
    )
);



-- 2. Write a function that returns the names of publishers who have published books with an average number of pages greater than N. The average number of pages is passed through the parameter.

CREATE FUNCTION dbo.GetPublishersByAvgPagesGreaterThanN (@AvgPagesThreshold INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.Name
    FROM dbo.Press p
    WHERE EXISTS
    (
        SELECT 1
        FROM dbo.Books b
        WHERE b.Id_Press = p.Id
        GROUP BY b.Id_Press
        HAVING AVG(b.Pages) > @AvgPagesThreshold
    )
);




-- 3. Write a function that returns the total sum of the pages of all the books in the library issued by the specified publisher.

CREATE FUNCTION dbo.GetTotalPagesByPublisher (@PublisherId INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT SUM(Pages)
            FROM dbo.Books
            WHERE Id_Press = @PublisherId)
END;



-- 4. Write a function that returns a list of names and surnames of all students who took books between the two specified dates.


CREATE FUNCTION dbo.GetStudentsByBookIssueDateRange 
(
    @StartDate DATE, 
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT s.FirstName, s.LastName
    FROM dbo.Students s
    JOIN dbo.S_Cards sc ON s.Id = sc.Id_Student
    WHERE sc.DateOut BETWEEN @StartDate AND @EndDate
)



-- 5. Write a function that returns a list of students who are currently working with the specified book of a certain author.


CREATE FUNCTION dbo.GetStudentsByAuthorBook 
(
    @AuthorId INT, 
    @BookId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT s.FirstName, s.LastName
    FROM dbo.Students s
    JOIN dbo.S_Cards sc ON s.Id = sc.Id_Student
    WHERE sc.Id_Book = @BookId
    AND sc.DateIn IS NULL  
    AND EXISTS (
        SELECT 1
        FROM dbo.Books b
        WHERE b.Id = @BookId
        AND b.Id_Author = @AuthorId
    )
)



-- 6. Write a function that returns information about publishers whose total number of pages of books issued by them is greater than N.



-- 7. Write a function that returns information about the most popular author among students and about the number of books of this author taken in the library.


CREATE PROCEDURE GetMostPopularAuthor
AS
BEGIN
    -- Seçim: Müəlliflər və onların kitablarının sayını hesablayırıq
    SELECT 
        a.Name AS AuthorName, 
        COUNT(b.Id) AS NumberOfBooksTaken
    FROM 
        dbo.Authors a
    JOIN 
        dbo.Books b ON a.Id = b.Author_ID  -- Burada Author_ID sütununu istifadə edirik
    JOIN 
        dbo.BookLoans bl ON b.Id = bl.BookId
    GROUP BY 
        a.Name
    ORDER BY 
        NumberOfBooksTaken DESC
END;



-- 8. Write a function that returns a list of books that were taken by both teachers and students.


CREATE PROCEDURE GetBooksTakenByTeachersAndStudents
AS
BEGIN
    SELECT DISTINCT 
        b.Title AS BookTitle, 
        b.Author AS BookAuthor
    FROM 
        dbo.BookLoans bl
    JOIN 
        dbo.Books b ON bl.BookId = b.Id
    WHERE 
        bl.UserType IN ('Student', 'Teacher')
    GROUP BY 
        b.Title, b.Author
    HAVING 
        COUNT(DISTINCT bl.UserId) > 1;  
END;





-- 9. Write a function that returns the number of students who did not take books.


CREATE PROCEDURE GetStudentsWhoDidNotTakeBooks
AS
BEGIN
    SELECT COUNT(DISTINCT s.UserId) AS StudentsWithoutBooks
    FROM dbo.Students s
    LEFT JOIN dbo.BookLoans bl ON s.UserId = bl.UserId
    WHERE bl.BookId IS NULL;
END;


-- 10. Write a function that returns a list of librarians and the number of books issued by each of them.

CREATE PROCEDURE GetLibrariansAndBooksIssued
AS
BEGIN
    SELECT 
        l.Name AS LibrarianName, 
        COUNT(bl.BookId) AS BooksIssued
    FROM 
        dbo.Librarians l
    JOIN 
        dbo.BookLoans bl ON l.LibrarianId = bl.LibrarianId
    GROUP BY 
        l.Name;
END;
