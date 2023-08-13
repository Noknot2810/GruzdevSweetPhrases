using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

//
// Описание класса для получения фразы дня из БД
//

using GruzdevSweetPhrases.Services;

namespace GruzdevSweetPhrases.Pages
{
    public class GetDayWishModel : PageModel
    {
        public IActionResult OnGet(string user)
        {            
            var cont = new DataContainer();
            string content = cont.NewWish(user, DateTime.Now);
            cont.closeConnection();

            return new JsonResult(content);
        }
    }
}
