using System;
using System.Linq;
using System.Threading.Tasks;
using static System.Net.WebRequestMethods;

namespace BlazorAzureWebApp.Services
{
    public class WeatherService
    {

        private readonly HttpClient http;
        public WeatherService(HttpClient http)
        {
            this.http = http;
        }

        public async Task<WeatherForecast[]> GetForecastsAsync()
        {
            await Task.Delay(500); // Simulate asynchronous loading

            var startDate = DateOnly.FromDateTime(DateTime.Now);
            var summaries = WeatherSummaries.Summaries;
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = startDate.AddDays(index),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = summaries[Random.Shared.Next(summaries.Length)]
            }).ToArray();
        }
    }

    public class WeatherForecast
    {
        public DateOnly Date { get; set; }
        public int TemperatureC { get; set; }
        public string? Summary { get; set; }
        public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
    }
}
