# Stage 1: Build and test the project
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /app

# Copy the solution file and restore dependencies
COPY *.sln .
COPY WebApplication1/*.csproj ./WebApplication1/
COPY WebApplication1Test/*.csproj ./WebApplication1Test/
RUN dotnet restore

# Copy the project files
COPY . .

# Run tests
WORKDIR /app/WebApplication1Test
RUN dotnet test --no-restore --verbosity normal
RUN testExitCode=$?; if [ $testExitCode -ne 0 ]; then exit $testExitCode; fi

# Stage 2: Build the project
FROM build AS publish
WORKDIR /app/WebApplication1
RUN dotnet publish -c Release -o /app/publish

# Stage 3: Create the final image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebApplication1.dll"]
