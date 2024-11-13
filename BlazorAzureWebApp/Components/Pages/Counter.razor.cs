namespace BlazorAzureWebApp.Components.Pages
{
    public partial class Counter
    {
        private List<CounterValue> counterValues = new List<CounterValue>();
        private int currentPage = 1;
        private int pageSize = 10;

        private IEnumerable<CounterValue> PagedCounterValues => counterValues
            .Skip((currentPage - 1) * pageSize)
            .Take(pageSize);

        private bool CanGoToPreviousPage => currentPage > 1;
        private bool CanGoToNextPage => currentPage * pageSize < counterValues.Count;

        public int currentCount = 0;

        public void IncrementCount()
        {
            Random random = new Random();
            currentCount = random.Next(1, 101); // Generates a random number between 1 and 100
            counterValues.Add(new CounterValue { Index = counterValues.Count + 1, Value = currentCount });
        }

        public void PreviousPage()
        {
            if (CanGoToPreviousPage)
            {
                currentPage--;
            }
        }

        public void NextPage()
        {
            if (CanGoToNextPage)
            {
                currentPage++;
            }
        }

        private class CounterValue
        {
            public int Index { get; set; }
            public int Value { get; set; }
        }
    }
}