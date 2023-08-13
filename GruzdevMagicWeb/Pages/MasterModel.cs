
//
// Описание родительского класса для работы веб-страниц
//

using GruzdevSweetPhrases.Services;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GruzdevSweetPhrases.Pages
{
    public class MasterModel : PageModel
    {
    	public MasterModel()
        {
            data = new DataContainer();
            Phrases = data.GetPhrases();
            PTypes = data.GetTypes();
            data.closeConnection();
        }  
                
        public DataContainer data;
        public List<Phrase> Phrases;
        public List<PType> PTypes;
    }
}
