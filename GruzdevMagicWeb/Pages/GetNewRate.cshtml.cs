
//
// Описание класса для обновления рейтинга фразы и её получения из БД
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using GruzdevSweetPhrases.Services;

namespace GruzdevSweetPhrases.Pages
{
    public class GetNewRateModel : PageModel
    {
        public IActionResult OnGet(string mark, string id)
        {            
            var cont = new DataContainer();
            float content = cont.RefreshRate(mark, id);
            cont.closeConnection();

            return new JsonResult(content);
        }
    }
}
