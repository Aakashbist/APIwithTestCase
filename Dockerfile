# docker build --build-arg Nuget_CustomFeedPassword=<PAT> --force-rm -t timeseriesservice:v1 .
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

ARG Nuget_CustomFeedPassword

WORKDIR /app

COPY NuGet.config .

COPY WebApplication1/WebApplication1.csproj WebApplication1/
RUN dotnet restore WebApplication1/WebApplication1.csproj

COPY . .

WORKDIR /app/WebApplication1

# Run tests
RUN dotnet test --no-restore --verbosity normal WebApplication1Test/WebApplication1Test.csproj
RUN if [ $? -ne 0 ]; then exit 1; fi

# Build the project
RUN dotnet build WebApplication1.csproj -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app
COPY --from=build /app/build .


ENTRYPOINT ["dotnet", "WebApplication1.dll"]

