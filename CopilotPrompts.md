## GitHub Copilot | New Blazor App
    - Please tell me the steps to create a new Blazor app in Visual Studio Code using project templates and any extensions that need installing
    - Update the above and tell me how to use the command palate and not the dotnet CLI
    - [Press F5 to debug, select web, when blank page comes up pick Blazor correct config, restart]

## GitHub Copilot | Inline & Chat
    - //updateforecast method with WeatherForecast input parameter that makes a call to /api/updateweather via PostAsync
    - // handle error for null forecast
    - // humidity as a percentage
    - // wind speed in mph

    - create a delete method for a forecast on a provided date
    - is this code performant and secure?
    - how do generics work in C# and show me an example with the an `Orders` class

## GitHub Copilot | Agents & Slash Commands
 - @workspace suggest improvements for the error handling page implementation
 - @workspace what security measures are implemented in the application?
 - @workspace what test coverage do we currently have in the WeatherService tests?
 - @workspace is there a good vscode extension that shows a report within the IDE of the test results as opposed to just running from the command line and works with nunit


## GitHub Copilot | Code Context
 - @workspace How does Blazor load the app using #file:App.razor when 1st accessing the application?
 - @workspace Where does the blazor.web.js come into bootstrapping the app?

## Prompt Engineering
 - create a deep copy method in JavaScript
 - does the method above handle copying over methods?
 - create a deep copy method in JavaScript and leverage any open source libraries for use
 - create a deep copy method in JavaScript and ensure it does not use lodash or any open source libraries. Ensure it copies over both properties and methods of the object being copied
 - create a weather location service that handles the current location, zip code, and coordinates. Ensure to model this after #file:WeatherService.cs

## Add Funtionality
- Why is this code broke yet I have a partial class defied #file:Counter.razor.cs with the code for these properties? I do not want a `@code` block here but rather use the code behind
- @workspace what should the namespace be for this project and please offer update
- How can I update this line to use a random value and not add to the previous value
- Add a grid that stores the results of the counter value and displays them below the current view in a CSS table. Make sure the table is pageable
- Update the grid to be more dynamic and use Bootstrap, retaining paging functionality. Update any code needed

## GitHub Copilot | Code Refactoring
- @workspace namespace wrap in the correct namespace
- @workspace how can I refactor some of this logic into a separate service that's injected? I only want the logic that's reusable to decide the weather and really shouldn't be in a component. Also the `summaries` should go into their own static file. Make sure to include `using` statements for any newly created filles so there are not missing references.

## Unit Testing
- @workspace /tests using nunit and ensure the tests are added under a new directory that matches this current file but place it in the .Tests project

## Infrastructure as Code
- @workspace create the Terraform files to setup Azure infrastructure and a build pipeline for this app to get it deployed to Azure. I will need to use GitHub Actions. I also need it to work with a Service Principal that's been setup and associated with an app registration in Azure. The values for login from the deployment scripts will be in GitHub secrets. Make sure to use .NET version 9, and do not use any legacy or outdated syntax.

