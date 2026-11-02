/*
====================================================
        SAILORS DATABASE PROJECT
        SQL Server 2022
====================================================
*/

-- STEP 1: Create database if it does not exist
USE master;
GO

IF DB_ID('SailorsProject') IS NULL
BEGIN
    CREATE DATABASE SailorsProject;
END;
GO

USE SailorsProject;
GO

/*
====================================================
        STEP 2: CREATE TABLES
====================================================
*/

IF OBJECT_ID('dbo.Sailors', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sailors (
        sid INT PRIMARY KEY,
        sname VARCHAR(50),
        rating INT,
        age DECIMAL(4,1)
    );
END;
GO

IF OBJECT_ID('dbo.Boats', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Boats (
        bid INT PRIMARY KEY,
        bname VARCHAR(50),
        color VARCHAR(20)
    );
END;
GO

IF OBJECT_ID('dbo.Reserves', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reserves (
        sid INT,
        bid INT,
        day DATE,
        PRIMARY KEY (sid, bid),
        FOREIGN KEY (sid) REFERENCES dbo.Sailors(sid),
        FOREIGN KEY (bid) REFERENCES dbo.Boats(bid)
    );
END;
GO

/*
====================================================
        STEP 3: INSERT DATA
====================================================
*/

IF NOT EXISTS (SELECT 1 FROM dbo.Sailors)
BEGIN
    INSERT INTO dbo.Sailors (sid, sname, rating, age)
    VALUES
    (22, 'Dustin', 7, 45),
    (29, 'Brutus', 1, 33),
    (31, 'Lubber', 8, 55),
    (32, 'Andy', 8, 25),
    (58, 'Rusty', 10, 35),
    (64, 'Horatio', 7, 35),
    (71, 'Zorba', 10, 16),
    (74, 'Horatio', 9, 35),
    (85, 'Art', 3, 25),
    (95, 'Bob', 3, 63);
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Boats)
BEGIN
    INSERT INTO dbo.Boats (bid, bname, color)
    VALUES
    (101, 'Interlake', 'blue'),
    (102, 'Interlake', 'red'),
    (103, 'Clipper', 'green'),
    (104, 'Marine', 'red');
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Reserves)
BEGIN
    INSERT INTO dbo.Reserves (sid, bid, day)
    VALUES
    (22, 101, '1998-10-10'),
    (22, 102, '1998-10-10'),
    (22, 103, '1998-10-08'),
    (22, 104, '1998-10-07'),
    (31, 102, '1998-11-10'),
    (31, 103, '1998-11-06'),
    (31, 104, '1998-11-12'),
    (64, 101, '1998-09-05'),
    (64, 102, '1998-09-08'),
    (74, 103, '1998-09-08');
END;
GO

/*
====================================================
        STEP 4: CHECK DATABASE DATA
====================================================
*/

SELECT * FROM dbo.Sailors;
SELECT * FROM dbo.Boats;
SELECT * FROM dbo.Reserves;
GO

/*
====================================================
        QUESTION 1
        Sailors who reserved a red boat,
        ordered by age ascendingly.
====================================================
*/

SELECT DISTINCT
    S.sname,
    S.age
FROM dbo.Sailors AS S
JOIN dbo.Reserves AS R
    ON S.sid = R.sid
JOIN dbo.Boats AS B
    ON R.bid = B.bid
WHERE B.color = 'red'
ORDER BY S.age ASC;
GO

/*
====================================================
        QUESTION 2
        Sailors who reserved two different boats
        on the same day.
====================================================
*/

SELECT DISTINCT
    S.sid,
    S.sname
FROM dbo.Sailors AS S
JOIN dbo.Reserves AS R1
    ON S.sid = R1.sid
JOIN dbo.Reserves AS R2
    ON S.sid = R2.sid
WHERE R1.day = R2.day
  AND R1.bid <> R2.bid;
GO

/*
====================================================
        QUESTION 3
        Sailor(s) who reserved the most boats.
====================================================
*/

SELECT TOP 1 WITH TIES
    S.sid,
    S.sname,
    COUNT(DISTINCT R.bid) AS total_boats_reserved
FROM dbo.Sailors AS S
JOIN dbo.Reserves AS R
    ON S.sid = R.sid
GROUP BY S.sid, S.sname
ORDER BY COUNT(DISTINCT R.bid) DESC;
GO

/*
====================================================
        QUESTION 4
        Sailors who reserved both red and green boats.
====================================================
*/

SELECT
    S.sid,
    S.sname
FROM dbo.Sailors AS S
JOIN dbo.Reserves AS R
    ON S.sid = R.sid
JOIN dbo.Boats AS B
    ON R.bid = B.bid
WHERE B.color IN ('red', 'green')
GROUP BY S.sid, S.sname
HAVING COUNT(DISTINCT B.color) = 2;
GO

/*
====================================================
        QUESTION 5
        Sailors who reserved all boats.
====================================================
*/

SELECT
    S.sid,
    S.sname
FROM dbo.Sailors AS S
JOIN dbo.Reserves AS R
    ON S.sid = R.sid
GROUP BY S.sid, S.sname
HAVING COUNT(DISTINCT R.bid) = (
    SELECT COUNT(*)
    FROM dbo.Boats
);
GO

/*
====================================================
        END OF SAILORS PROJECT
====================================================
*/