FROM mcr.microsoft.com/powershell
WORKDIR /app
COPY . /app
COPY ./app/app.properties /var/config/dtest/app.properties
EXPOSE 8080
CMD [ "pwsh", "/app/app/server.ps1"]
