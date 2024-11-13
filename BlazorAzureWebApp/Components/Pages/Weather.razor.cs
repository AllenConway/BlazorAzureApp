using BlazorAzureWebApp.Services;
using Microsoft.AspNetCore.Components;

namespace BlazorAzureWebApp.Components.Pages
{
    public partial class Weather
    {
        public WeatherForecast[]? forecasts;

        [Inject]
        protected WeatherService WeatherService { get; set; } = default!;

        protected override async Task OnInitializedAsync()
        {
            forecasts = await WeatherService.GetForecastsAsync();
        }
    }
}