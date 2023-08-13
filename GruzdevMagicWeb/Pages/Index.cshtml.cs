
//
// Описание класса для работы главной страницы
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using GruzdevSweetPhrases.Services;
using Microsoft.AspNetCore.Mvc;


using Microsoft.AspNetCore.Mvc.RazorPages;

namespace GruzdevSweetPhrases.Pages
{
    public class IndexModel : MasterModel
    {
        public void OnGet()
        {
        	LeftPhrases = new List<Phrase>();
        	RightPhrases = new List<Phrase>();
            bool fl = true;
        	for (int i = 0; i < Phrases.Count && i < 20; i++, fl = !fl)
            {
                if (fl)
                    LeftPhrases.Add(Phrases[i]);
                else
                    RightPhrases.Add(Phrases[i]);
            }
        }

        public List<Phrase> LeftPhrases;
        public List<Phrase> RightPhrases;
    }
}
