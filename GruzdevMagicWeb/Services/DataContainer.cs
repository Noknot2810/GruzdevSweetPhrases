
//
// Описание универсального класса для работы с базой данных
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace GruzdevSweetPhrases.Services
{
    public class DataContainer
    {
        SqlConnection Connection;

        public DataContainer()
        {
            Connection = new SqlConnection("Server=.\\SQLEXPRESS;Database=GruzdevSweetPhrases;Trusted_Connection=True;");
            Connection.Open();
        }

        // Функция для закрытия соединения (закрытие в деструкторе приводит к ошибкам)
        public void closeConnection(){
            Connection.Close();
        }

        ~DataContainer()
        {
        }

        /// <summary>
        /// Функция для получения списка всех фраз
        /// </summary>        
        public List<Phrase> GetPhrases()
        {
            List<Phrase> result = new List<Phrase>();
            using (SqlCommand command = Connection.CreateCommand())
            {
                command.CommandText = "SELECT IDp, Content, PDate, Rate, TypeID, TypeName, Votes FROM Phrases AS a JOIN TypePhrase b ON a.TypeID = b.IDt ORDER BY IDp DESC";

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        result.Add(
                            new Phrase
                            {
                                Id = reader.GetInt32(0),
                                Content = reader.GetString(1),
                                PubDate = reader.GetDateTime(2),
                                Rate = Convert.ToSingle(reader.GetDouble(3)),
                                Type = reader.GetInt32(4),
                                TypeName = reader.GetString(5),
                                Votes = reader.GetInt32(6)
                            });
                    }
                }
            }
            return result;
        }

        /// <summary>
        /// Функция для получения списка всех разделов
        /// </summary>        
        public List<PType> GetTypes()
        {
            List<PType> result = new List<PType>();
            using (SqlCommand command = Connection.CreateCommand())
            {
                command.CommandText = "SELECT IDt, TypeName FROM TypePhrase";
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        result.Add(
                            new PType
                            {
                                Id = reader.GetInt32(0),
                                Name = reader.GetString(1)
                            });
                    }
                }
            }
            return result;
        }

        /// <summary>
        /// Функция для получения напутствия для заданного имени в конкретный день. Если для этого имени нет напутствия в этот день, оно предварительно создаётся
        /// </summary>
        public string NewWish(string name, DateTime today)
        {
            string result;
            using (SqlCommand command = Connection.CreateCommand())
            {
                command.CommandText = "INSERT DayPhrase (Name, Day, PhraseID) VALUES (@n, @d, 1)";
                command.Parameters.AddWithValue("@n", name);
                command.Parameters.AddWithValue("@d", today);
                try
                {
                    command.ExecuteNonQuery();
                }
                catch{}
            }

            using (SqlCommand command = Connection.CreateCommand())
            {
                command.CommandText = "SELECT TOP 1 Content FROM DayPhrase AS a JOIN Phrases b ON a.PhraseID = b.IDp WHERE (Name = @n) AND (Day = CAST(@d as date))";
                command.Parameters.AddWithValue("@n", name);
                command.Parameters.AddWithValue("@d", today);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    reader.Read();
                    result = reader.GetString(0);
                }
            }
            return result;
        }

        /// <summary>
        /// Функция для обновления рейтинга фразы с учётом полученной от пользователя оценки. Функция возвращает новый рейтинг.
        /// </summary>
        public float RefreshRate(string mark, string id)
        {
            float result;
            using (SqlCommand command = Connection.CreateCommand())
            {
                command.CommandText = "UPDATE Phrases SET Rate = @mark WHERE IDp = @id";
                command.Parameters.AddWithValue("@mark", Convert.ToSingle(mark));
                command.Parameters.AddWithValue("@id", Convert.ToInt32(id));
                command.ExecuteNonQuery();
            }

            using (SqlCommand command = Connection.CreateCommand())
            {
                command.CommandText = "SELECT Rate FROM Phrases WHERE IDp = @id";
                command.Parameters.AddWithValue("@id", Convert.ToInt32(id));
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    reader.Read();
                    result = Convert.ToSingle(reader.GetDouble(0));
                }
            }
            return result;
        }

        /// <summary>
        /// Функция для добавления новый фразы в базу данных
        /// </summary>
        public void NewPhrase(int id, string text, DateTime today)
        {
            using (SqlCommand command = Connection.CreateCommand())
            {
                command.CommandText = "INSERT Phrases (Content, PDate, Rate, Votes, TypeID) VALUES (@text, @date, 0, 0, @type)";
                command.Parameters.AddWithValue("@text", text);
                command.Parameters.AddWithValue("@type", id);
                command.Parameters.AddWithValue("@date", today);
                command.ExecuteNonQuery();
            }
        }
    }

    // Класс для хранения информации о фразе
    public class Phrase
    {
        public int Type;
        public string TypeName;
        public int Id;
        public string Content;
        public DateTime PubDate;
        public float Rate;
        public int Votes;
    }

    // Класс для хранения информации о разделе с фразами
    public class PType
    {
        public int Id;
        public string Name;
    }
}
