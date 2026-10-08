FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /source
COPY Directory.Build.props global.json NuGet.Config ./
COPY src/Mismade.Domain/Mismade.Domain.csproj src/Mismade.Domain/
COPY src/Mismade.Application/Mismade.Application.csproj src/Mismade.Application/
COPY src/Mismade.Infrastructure/Mismade.Infrastructure.csproj src/Mismade.Infrastructure/
COPY src/Mismade.Web/Mismade.Web.csproj src/Mismade.Web/
RUN dotnet restore src/Mismade.Web/Mismade.Web.csproj --configfile NuGet.Config
COPY src/ src/
# sin --no-restore: los assets del framework de Blazor (_framework/blazor.web.js) se resuelven en el restore del publish
RUN dotnet publish src/Mismade.Web/Mismade.Web.csproj -c Release -o /app/publish --configfile NuGet.Config \
    && test -f /app/publish/wwwroot/_framework/blazor.web.js

# imagen oficial (Ubuntu 24.04); ya incluye tzdata para America/Argentina/Buenos_Aires
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
# Npgsql intenta cargar Kerberos al conectar; sin esta librería loguea un error inofensivo
RUN apt-get update && apt-get install -y --no-install-recommends libgssapi-krb5-2 \
    && rm -rf /var/lib/apt/lists/*
ENV ASPNETCORE_ENVIRONMENT=Production
# Render/Railway terminan HTTPS en un proxy: respetar X-Forwarded-Proto/For
ENV ASPNETCORE_FORWARDEDHEADERS_ENABLED=true
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "Mismade.Web.dll"]
