# xpath-scraper
## Information about the Container
### Purpose
This container should read a list of targets which consist of URL's and xpath informations from a MariaDB/MySQL Server -> Scrape the Information and write it to a MariaDB/MySQL Database
### Container Name
nopenix/xpath-scraper
### Based on
[mcr.microsoft.com/powershell:alpine-3.14](https://hub.docker.com/_/microsoft-powershell)
### Environment Variables
| Variable | Purpose |
| -------- | ------- |
| SCRAPER_CYCLE_PAUSE | Pause in Minutes between Scraping runs |
| DB_SERVER_HOSTNAME | |
| DB_SERVER_PORT | |
| DB_SERVER_USERNAME | |
| DB_SERVER_PASSWORD | |
| DB_SERVER_DATABASE | |
| DB_SERVER_TABLENAME_TARGETS | Optional. The Default Tablename for the Targetlist is scraper_targets |
| DB_SERVER_TABLENAME_RESULTS | Optional. The Default Tablename for the scraped results is scraper_results |
### Requirements
* MySQL/MariaDB Server
* Connection to the targets which you want to scrape
### Tags
No Tags, only `:latest`
