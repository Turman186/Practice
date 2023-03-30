using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace LightWeight.Controllers
{
    [ApiController]
    public class AccountsController : ControllerBase
    {
        [Route("sign-out")]
        [HttpGet]
        public async Task<ActionResult> SignOutGoogle()
        {
            await HttpContext.SignOutAsync();
            return Ok();
        }

    }
}
