USE [master]
GO

IF DB_ID (N'GruzdevSweetPhrases') IS NOT NULL
BEGIN
    ALTER DATABASE [GruzdevSweetPhrases] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [GruzdevSweetPhrases]
END
GO

CREATE DATABASE [GruzdevSweetPhrases]
GO
----------------------------------------------------------------------------------------------------------------------------------
USE [GruzdevSweetPhrases]
GO

-- ������� ��� �������� ����� ����
CREATE TABLE TypePhrase  
(
    IDt INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Type PRIMARY KEY,  
    TypeName NVARCHAR(255) NOT NULL
)

-- ������� ��� �������� ����
CREATE TABLE Phrases  
(
    IDp INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Ph PRIMARY KEY,  
    Content NVARCHAR(255) NOT NULL,
    PDate DATE NOT NULL,
    Rate FLOAT NOT NULL,
    Votes INT NOT NULL,
    TypeID INT NOT NULL
)

ALTER TABLE Phrases ADD CONSTRAINT f1 FOREIGN KEY(TypeID) REFERENCES TypePhrase(IDt)

-- ������� ��� �������� ���� ���
CREATE TABLE DayPhrase  
(
    IDd INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Day PRIMARY KEY,  
    Name NVARCHAR(255) NOT NULL,
    Day DATE NOT NULL,
    PhraseID INT NOT NULL
)

ALTER TABLE DayPhrase ADD CONSTRAINT f2 FOREIGN KEY(PhraseID) REFERENCES Phrases(IDp)

----------------------------------------------------------------------------------------------------------------------------------
INSERT TypePhrase (TypeName)  
VALUES ('����������'),
       ('�������'),
       ('��������')

INSERT Phrases (Content, PDate, Rate, Votes, TypeID)  
VALUES ('����� � ���� ����� ����� ���������� �������.', GETDATE(), 0, 0, 1),
       ('����� ���� ������ ����� ������� ���������� ���.', GETDATE(), 0, 0, 1),
       ('����� ���� �������� ����� ������ 50 �����.', GETDATE(), 0, 0, 1),
       ('�� ������ �������, � ����� ����.', GETDATE(), 0, 0, 1),
       ('������ �� ����� ��������.', GETDATE(), 0, 0, 1),
       ('�� ����������.', GETDATE(), 0, 0, 1),
       ('������ ��������, ����� �������.', GETDATE(), 0, 0, 1),
       ('�� - ���������!', GETDATE(), 0, 0, 2),
       ('������ �� ������, �� ����� ����.', GETDATE(), 0, 0, 2),
       ('��� �� ������ �� ���������?!', GETDATE(), 0, 0, 2),
       ('����-���-���, ����-���-���', GETDATE(), 0, 0, 3),
       ('���, ����������!', GETDATE(), 0, 0, 3),
       ('�����!!!', GETDATE(), 0, 0, 3)

GO

----------------------------------------------------------------------------------------------------------------------------------
-- �������, ���������� ������� ����� ��� ��� ��������� �����, ���� ������� ��� ����������
-- ���� ����� ��� ��� ��������� ����� ���, �� ��� ���������, ������ ����� ����� ��������� �� ������ ����-���������
CREATE TRIGGER day_wishing
ON DayPhrase INSTEAD OF INSERT
AS
IF EXISTS (SELECT *
       	   FROM DayPhrase AS a, inserted AS b
           WHERE (a.Name = b.Name) AND (a.Day = b.Day))
BEGIN
	ROLLBACK TRAN
END
ELSE
BEGIN
    INSERT INTO DayPhrase 
    SELECT Name, Day, (SELECT TOP 1 IDp FROM Phrases WHERE TypeID = 1 ORDER BY NEWID())
    FROM inserted
END
GO
----------------------------------------------------------------------------------------------------------------------------------
-- �������� ������ ��� �������� ������ ��������
--DECLARE @n nvarchar(255) = '����', @d date = '26-07-21'
--INSERT DayPhrase (Name, Day, PhraseID) VALUES (@n, @d, 1)

----------------------------------------------------------------------------------------------------------------------------------
-- ������ ��� ��������� �������� �����. �� ������ �������� ��������, ���������� ������� � ����� ����������� ������ ��������� 
-- ����� �������� �������� � ��������� � ���������� ������� �������. ���� ����������� ������ �� � �������� �� 1 �� 5, �������� ����������.
CREATE TRIGGER refresh_rate
ON Phrases INSTEAD OF UPDATE
AS
DECLARE @new float, @id int, @old float, @cnt int
SELECT @new = Rate, @id = IDp FROM inserted
IF @new < 1 OR @new > 5
BEGIN
	ROLLBACK TRAN
END
ELSE
BEGIN
	SELECT @old = Rate, @cnt = Votes FROM deleted
	UPDATE Phrases 
	   SET Rate = ((@old * @cnt + @new) / (@cnt + 1)), Votes = (@cnt + 1)
	 WHERE IDp = @id
END
GO
----------------------------------------------------------------------------------------------------------------------------------
-- �������� ������ ��� �������� ������ ��������
--DECLARE @mark float = 1, @id int = 1
--UPDATE Phrases 
--   SET Rate = @mark
-- WHERE IDp = @id
-- SELECT Rate FROM Phrases WHERE IDp = @id

----------------------------------------------------------------------------------------------------------------------------------
-- �������� ��������� ������������ �������� ���������� � ������

--SELECT IDp, Content, PDate, Rate, TypeID, TypeName FROM Phrases AS a JOIN TypePhrase b ON a.TypeID = b.IDt ORDER BY IDp DESC

--SELECT IDt, TypeName FROM TypePhrase

--DECLARE @n nvarchar(255) = '����', @d datetime = '26-07-21 00:01'
--SELECT TOP 1 Content FROM DayPhrase AS a JOIN Phrases b ON a.PhraseID = b.IDp WHERE (Name = @n) AND (Day = CAST(@d as date))

--DECLARE @text nvarchar(255) = '����� �� ����� ������.', @type int = 1, @date datetime = '26-07-21'
--INSERT Phrases (Content, PDate, Rate, Votes, TypeID) VALUES (@text, @date, 0, 0, @type)
--SELECT * FROM Phrases WHERE IDp > 9