FROM mcr.microsoft.com/powershell:alpine-3.14

RUN apk update
RUN apk upgrade
RUN pwsh -c "Install-Module -Name SimplySql -RequiredVersion 1.6.2 -force"
RUN pwsh -c "Install-Module -Name SelectHtml -force"
RUN mkdir /app
COPY scraper.ps1 /app/scraper.ps1

CMD [ "pwsh", "/app/scraper.ps1"]
