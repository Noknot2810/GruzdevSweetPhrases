using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

//
// Описание класса для добавления новой фразы в БД
//

using GruzdevSweetPhrases.Services;

namespace GruzdevSweetPhrases.Pages
{
    public class AddPhraseModel : PageModel
    {
        public IActionResult OnGet(int id, string text)
        {                        
            var cont = new DataContainer();
            cont.NewPhrase(id, text, DateTime.Now);
            cont.closeConnection();
            return Redirect("Section?id=" + id);
        }
    }
}
