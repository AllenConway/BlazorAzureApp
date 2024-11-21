// FILE: BlazorAzureWebApp.Tests/Services/WeatherServiceTest.cs
using NUnit.Framework;
using BlazorAzureWebApp.Services;
using System.Threading.Tasks;
using System.Linq;
using System.Net.Http;

namespace BlazorAzureWebApp.Tests.Services
{
    [TestFixture]
    public class WeatherServiceTest
    {
        private WeatherService _weatherService = default!;
        private HttpClient _httpClient = default!;

        [SetUp]
        public void Setup()
        {
            _httpClient = new HttpClient();
            _weatherService = new WeatherService(_httpClient);
        }

        [TearDown]
        public void TearDown()
        {
            _httpClient?.Dispose();
        }

        [Test]
        public async Task GetForecastsAsync_ReturnsFiveForecasts()
        {
            var forecasts = await _weatherService.GetForecastsAsync();
            Assert.That(forecasts.Length, Is.EqualTo(5));
        }

        [Test]
        public async Task GetForecastsAsync_ForecastsHaveValidDates()
        {
            var forecasts = await _weatherService.GetForecastsAsync();
            var startDate = DateOnly.FromDateTime(DateTime.Now).AddDays(1);
            for (int i = 0; i < forecasts.Length; i++)
            {
                Assert.That(forecasts[i].Date, Is.EqualTo(startDate.AddDays(i)));
            }
        }

        [Test]
        public async Task GetForecastsAsync_ForecastsHaveValidTemperature()
        {
            var forecasts = await _weatherService.GetForecastsAsync();
            foreach (var forecast in forecasts)
            {
                Assert.That(forecast.TemperatureC, Is.InRange(-20, 55));
            }
        }

        [Test]
        public async Task GetForecastsAsync_ForecastsHaveValidSummary()
        {
            var forecasts = await _weatherService.GetForecastsAsync();
            var summaries = WeatherSummaries.Summaries;
            foreach (var forecast in forecasts)
            {
                Assert.Contains(forecast.Summary, summaries);
            }
        }
    }
}
