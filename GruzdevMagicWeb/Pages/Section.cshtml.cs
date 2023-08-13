
//
// Описание класса для работы страницы с разделом фраз
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace GruzdevSweetPhrases.Pages
{
    public class SectionModel : MasterModel
    {
        public void OnGet(int id)
        {
        	TID = id;
        }

        public int TID;
    }
}
