![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/NopeNix/xpath-scraper/Build%20and%20Push%20to%20Docker%20Hub.yml?label=Build%20and%20Push%20to%20Docker%20Hub)
![GitHub issues](https://img.shields.io/github/issues-raw/NopeNix/xpath-scraper)
![Docker Stars](https://img.shields.io/docker/stars/nopenix/xpath-scraper)
![GitHub Repo stars](https://img.shields.io/github/stars/NopeNix/xpath-scraper?label=GitHub%20Stars)
![GitHub top language](https://img.shields.io/github/languages/top/NopeNix/xpath-scraper)

# xpath-scraper
## Information about the Container
### Purpose
This container should read a list of targets which consist of URL's and xpath informations from a MariaDB/MySQL Server -> Scrape the Information and write it to a MariaDB/MySQL Database
### Container Name
nopenix/xpath-scraper
### Based on
[mcr.microsoft.com/powershell:lts-alpine-3.17](https://hub.docker.com/_/microsoft-powershell)

### docker-compose.yml
```yml
version: "3"

services:
  scraper:
    image: nopenix/xpath-scraper
    restart: unless-stopped
    volumes: 
      - .\scraper.ps1:/app/scraper.ps1 # This is for Developing purpose! please comment this out in productive envoronments
    environment:
      SCRAPER_CYCLE_PAUSE: 1
      DB_SERVER_HOSTNAME: db
      DB_SERVER_PORT: 3306
      DB_SERVER_USERNAME: root
      DB_SERVER_PASSWORD: changemeplz
      DB_SERVER_DATABASE: scraper
      #DB_SERVER_TABLENAME_TARGETS: 
      #DB_SERVER_TABLENAME_RESULTS:  

  db:
    image: mariadb:10.3
    command: mysqld --character-set-server=utf8 --collation-server=utf8_unicode_ci
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: changemeplz
      TZ: Europe/Berlin
    volumes:
      - mariadb:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin
    restart: always
    ports:
      - 80:80
    environment:
      PMA_ARBITRARY: 0
      PMA_HOST: db
      PMA_PORT: 3306

volumes:
  mariadb:
```
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
### Updates
The Container gets automatically updated, build and pushed every Sunday.
