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

-- Таблица для хранения типов фраз
CREATE TABLE TypePhrase  
(
    IDt INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Type PRIMARY KEY,  
    TypeName NVARCHAR(255) NOT NULL
)

-- Таблица для хранения фраз
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

-- Таблица для хранения фраз дня
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
VALUES ('Напутствия'),
       ('Похвала'),
       ('Глупости')

INSERT Phrases (Content, PDate, Rate, Votes, TypeID)  
VALUES ('Пусть у тебя будет много свободного времени.', GETDATE(), 0, 0, 1),
       ('Пусть тебе всегда будут сниться интересные сны.', GETDATE(), 0, 0, 1),
       ('Пусть твоя зарплата будет больше 50 тысяч.', GETDATE(), 0, 0, 1),
       ('Ты будешь успешен, я точно знаю.', GETDATE(), 0, 0, 1),
       ('Следуй за белым кроликом.', GETDATE(), 0, 0, 1),
       ('Не занудствуй.', GETDATE(), 0, 0, 1),
       ('Береги здоровье, делай зарядку.', GETDATE(), 0, 0, 1),
       ('Ты - красавчег!', GETDATE(), 0, 0, 2),
       ('Никого не слушай, ты лучше всех.', GETDATE(), 0, 0, 2),
       ('Как ты только всё успеваешь?!', GETDATE(), 0, 0, 2),
       ('Арам-зам-зам, арам-зам-зам', GETDATE(), 0, 0, 3),
       ('Чек, пожалуйста!', GETDATE(), 0, 0, 3),
       ('Апчхи!!!', GETDATE(), 0, 0, 3)

GO

----------------------------------------------------------------------------------------------------------------------------------
-- Триггер, отменяющий вставку фразы дня для заданного имени, если таковая уже существует
-- Если фразы дня для заданного имени нет, то она заводится, причём выбор фразы случайный из списка фраз-напутсвий
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
-- Тестовый пример для проверки работы триггера
--DECLARE @n nvarchar(255) = 'Дима', @d date = '26-07-21'
--INSERT DayPhrase (Name, Day, PhraseID) VALUES (@n, @d, 1)

----------------------------------------------------------------------------------------------------------------------------------
-- Тригер для изменения рейтинга фразы. На основе прошлого рейтинга, количества голосов и новой поступившей оценке вычисляет 
-- новое значение рейтинга и добавляет к количеству голосов единицу. Если поступившая оценка не в пределах от 1 до 5, операция отменяется.
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
-- Тестовый пример для проверки работы триггера
--DECLARE @mark float = 1, @id int = 1
--UPDATE Phrases 
--   SET Rate = @mark
-- WHERE IDp = @id
-- SELECT Rate FROM Phrases WHERE IDp = @id

----------------------------------------------------------------------------------------------------------------------------------
-- Проверки некоторых используемых сервером селекторов и команд

--SELECT IDp, Content, PDate, Rate, TypeID, TypeName FROM Phrases AS a JOIN TypePhrase b ON a.TypeID = b.IDt ORDER BY IDp DESC

--SELECT IDt, TypeName FROM TypePhrase

--DECLARE @n nvarchar(255) = 'Дима', @d datetime = '26-07-21 00:01'
--SELECT TOP 1 Content FROM DayPhrase AS a JOIN Phrases b ON a.PhraseID = b.IDp WHERE (Name = @n) AND (Day = CAST(@d as date))

--DECLARE @text nvarchar(255) = 'Пусть всё будет хорошо.', @type int = 1, @date datetime = '26-07-21'
--INSERT Phrases (Content, PDate, Rate, Votes, TypeID) VALUES (@text, @date, 0, 0, @type)
--SELECT * FROM Phrases WHERE IDp > 9