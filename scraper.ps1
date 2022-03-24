# Imports
Import-Module SimplySql

# Checking Optional Vars and assign values
if ($null -eq $env:DB_SERVER_TABLENAME_TARGETS -or $env:DB_SERVER_TABLENAME_TARGETS -eq "") {
    $DB_SERVER_TABLENAME_TARGETS = "scraper_targets"
    Write-Host "Using Default value for `$env:DB_SERVER_TABLENAME_TARGETS which is $DB_SERVER_TABLENAME_TARGETS" -ForegroundColor Blue
}
else {
    $DB_SERVER_TABLENAME_TARGETS = $env:DB_SERVER_TABLENAME_TARGETS
    Write-Host "Using Env value for `$env:DB_SERVER_TABLENAME_TARGETS which is $DB_SERVER_TABLENAME_TARGETS" -ForegroundColor Blue
}
if ($null -eq $env:DB_SERVER_TABLENAME_RESULTS -or $env:DB_SERVER_TABLENAME_RESULTS -eq "") { 
    $DB_SERVER_TABLENAME_RESULTS = "scraper_results" 
    Write-Host "Using Default value for `$env:DB_SERVER_TABLENAME_RESULTS which is $DB_SERVER_TABLENAME_RESULTS" -ForegroundColor Blue
}
else {
    $DB_SERVER_TABLENAME_RESULTS = $env:DB_SERVER_TABLENAME_RESULTS
    Write-Host "Using Env value for `$env:DB_SERVER_TABLENAME_RESULTS which is $DB_SERVER_TABLENAME_RESULTS" -ForegroundColor Blue
}

while ($true) {
    # Connect to to DB
    Write-Host ("Connecting to Database " + $env:DB_SERVER_DATABASE + " on Server " + $env:DB_SERVER_HOSTNAME + ":" + $env:DB_SERVER_PORT + " with Username " + $env:DB_SERVER_USERNAME) -ForegroundColor Yellow
    try {
        Open-MySqlConnection -ConnectionName "db" -Server $env:DB_SERVER_HOSTNAME -Port $env:DB_SERVER_PORT -Database $env:DB_SERVER_DATABASE -UserName $env:DB_SERVER_USERNAME -Password $env:DB_SERVER_PASSWORD -WarningAction SilentlyContinue
        Write-Host " -> Connected!" -ForegroundColor Green
    }
    catch {
        Write-Host (" -> Error while connecting to Database: " + $_.Exception.Message) -ForegroundColor Red
        Exit
    }
    
    # Get Targets
    Write-Host ("Getting Targets") -ForegroundColor Yellow
    try {
        $Targets = Invoke-SqlQuery -ConnectionName "db" -Query ('SELECT * FROM `' + $DB_SERVER_TABLENAME_TARGETS + '`')
        Write-Host (" -> Done, received " + $Targets.count + " targets") -ForegroundColor Green
    }
    catch {
        Write-Host (" -> Error while querying for Targets: " + $_.Exception.Message) -ForegroundColor Red
        Exit
    }
    
    # Scrape Targets
    Write-Host ("Scraping " + $Targets.count + " Targets") -ForegroundColor Yellow
    try {
        $Targets | ForEach-Object {
            Write-Host (" - " + $_.name) -ForegroundColor Yellow        
            try {
                # Scraping
                $ScrapedValue = Select-Html -XPath $_.xpath -Uri $_.url
              
                #Region: Replace what defined in $_.replace
                try {
                    if ($null -ne $_.replace -and $_.replace -ne "" -and $_.replace -ne "null") {
                        $json = $_.replace | ConvertFrom-Json
                        $json | Get-Member -MemberType NoteProperty -ErrorAction Stop | ForEach-Object {
                            $what = $_.name 
                            $with = $json.($_.name)
                            $ScrapedValue = $ScrapedValue.replace($what, $with)
                        }
                    }
                }
                catch { }
                #endregion

                #Region:  Check if there is already a table for this data
                try {
                    $Query = Invoke-SqlQuery -ConnectionName "db" -Query ("SELECT * FROM information_schema.tables WHERE table_schema = '" + $env:DB_SERVER_DATABASE + "' AND table_name = 'result-" + ($_.name) + "' LIMIT 1;")
                }
                catch {
                    throw("Could not check if table is present: " + $_.Exception.Message) 
                }       
                #endregion         

                #Region:  Create Table if it did not exist
                try {
                    if ($Query.count -eq "0") {
                        # Table does not exist, adding table
                        Invoke-SqlUpdate -ConnectionName "db" -Query ("CREATE TABLE ``$env:DB_SERVER_DATABASE``.``result-" + ($_.name) + "`` ( ``time`` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP , ``value`` FLOAT NULL ) ENGINE = InnoDB;") -ErrorAction Stop | Out-Null
                    }
                }
                catch {
                    throw("Could not add table for new Scraped Item: " + $_.Exception.Message) 
                } 
                #endregion

                #Region: Adding to Table
                try {
                    $UpdateQuery = Invoke-SqlUpdate  -ConnectionName "db" -Query ("INSERT INTO ``result-" + ($_.name) + "`` (``time``, ``value``) VALUES (current_timestamp(), '" + $ScrapedValue + "');") -ErrorAction Stop
                    if ($UpdateQuery -ne "1") {
                        throw "No Data has been inserted into DB"
                    }

                    Write-Host ("  -> OK: " + $ScrapedValue) -ForegroundColor Green
                }
                catch {
                    Throw ("  -> Could not add the data to its table: " + $_.Exception.Message)
                }
                #endregion
            }
            catch {
                Write-Host (" -> Error while Scraping: " + $_.Exception.Message) -ForegroundColor Red
                Exit
            }
        }
    }
    catch {}

    #Region: Disconnect from DB
    Write-Host ("Disconnecting from Database " + $env:DB_SERVER_DATABASE + " on Server " + $env:DB_SERVER_HOSTNAME + ":" + $env:DB_SERVER_PORT + " with Username " + $env:DB_SERVER_USERNAME) -ForegroundColor Yellow
    try {
        Close-SqlConnection -ConnectionName "db"
        Write-Host " -> Disconnected!" -ForegroundColor Green
    }
    catch {
        Write-Host (" -> Error while disconnecting from Database: " + $_.Exception.Message) -ForegroundColor Red
        Exit
    }
    #endregion

    Write-Host
    Write-Host
    Write-Host "Done! Waiting $env:SCRAPER_CYCLE_PAUSE Minutes to start the next run..." -ForegroundColor Blue
    Write-Host
    Start-Sleep -Seconds (60 * $env:SCRAPER_CYCLE_PAUSE)

}