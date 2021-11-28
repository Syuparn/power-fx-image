FROM mcr.microsoft.com/dotnet/sdk:6.0 as build

WORKDIR /source
RUN git clone https://github.com/microsoft/power-fx-host-samples.git

WORKDIR /source/power-fx-host-samples/Samples/ConsoleREPL

# HACK: patch default locale, otherwise built-in function initialization fails
RUN sed -i -e 's/ResetEngine();/CultureInfo.DefaultThreadCurrentCulture = CultureInfo.CreateSpecificCulture("en-US");ResetEngine();/g' ./ConsoleREPL.cs
RUN sed -i -e 's/using System;/using System;\nusing System.Globalization;/g' ./ConsoleREPL.cs

RUN dotnet restore
RUN dotnet publish --configuration Debug -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:3.1
WORKDIR /app
COPY --from=build /app ./
RUN chmod +x ./ConsoleREPL
ENV PATH $PATH:/app
