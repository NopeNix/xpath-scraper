FROM mcr.microsoft.com/powershell:latest

RUN apt update
RUN apt upgrade -y
RUN pwsh -c "Install-Module -Name SimplySql -RequiredVersion 1.6.2 -force"
RUN pwsh -c "Install-Module -Name SelectHtml -force"
RUN mkdir /app
COPY scraper.ps1 /app/scraper.ps1

CMD [ "pwsh", "/app/scraper.ps1"]
