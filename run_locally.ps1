# Script to run Java JSP/Servlet application locally without NetBeans using portable Tomcat 9
$tomcatVersion = "9.0.98"
$tomcatZip = "apache-tomcat-$tomcatVersion-windows-x64.zip"
$tomcatUrl = "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.98/bin/$tomcatZip"
$workspace = $PSScriptRoot
$tomcatDir = "$workspace\tomcat"

Write-Host "=== TASK MANAGER LOCAL RUNNER ===" -ForegroundColor Magenta

# Find Java JDK
$javaHome = ""
if (Test-Path "C:\Program Files\Java") {
    $jdk = Get-ChildItem -Path "C:\Program Files\Java" -Filter "jdk-*" | Sort-Object Name -Descending | Select-Object -First 1
    if ($jdk) {
        $javaHome = $jdk.FullName
    }
}

if (!$javaHome) {
    $javaHome = "C:\Program Files\Java\jdk-23"
}

Write-Host "Using JAVA_HOME: $javaHome" -ForegroundColor Cyan

# 1. Create tomcat directory if not exists
if (!(Test-Path $tomcatDir)) {
    New-Item -ItemType Directory -Path $tomcatDir | Out-Null
}

$zipPath = "$tomcatDir\$tomcatZip"
$extractedPath = "$tomcatDir\apache-tomcat-$tomcatVersion"

# 2. Download Tomcat if zip and extraction don't exist
if (!(Test-Path $zipPath) -and !(Test-Path $extractedPath)) {
    Write-Host "Downloading Apache Tomcat $tomcatVersion..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $tomcatUrl -OutFile $zipPath -UserAgent "Mozilla/5.0"
        Write-Host "Download successful!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download Tomcat. Trying curl..." -ForegroundColor Yellow
        curl.exe -L -o $zipPath $tomcatUrl
    }
}

# 3. Unzip if not unzipped
if (!(Test-Path $extractedPath)) {
    Write-Host "Extracting Apache Tomcat..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $tomcatDir
}

# 4. Deploy webapp
$webappsRoot = "$extractedPath\webapps\ROOT"
if (Test-Path $webappsRoot) {
    Write-Host "Removing default Tomcat ROOT app..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $webappsRoot
}
New-Item -ItemType Directory -Path $webappsRoot | Out-Null

Write-Host "Deploying TaskManager application to Tomcat..." -ForegroundColor Green

# Copy JSP, HTML, CSS files from web/ (contains our latest updates!)
Copy-Item -Recurse -Force "$workspace\web\*" $webappsRoot

# Copy compiled classes from build/web/WEB-INF/classes
$destClasses = "$webappsRoot\WEB-INF\classes"
if (!(Test-Path $destClasses)) {
    New-Item -ItemType Directory -Path $destClasses | Out-Null
}
Copy-Item -Recurse -Force "$workspace\build\web\WEB-INF\classes\*" $destClasses

# Copy libraries from build/web/WEB-INF/lib
$destLib = "$webappsRoot\WEB-INF\lib"
if (!(Test-Path $destLib)) {
    New-Item -ItemType Directory -Path $destLib | Out-Null
}
Copy-Item -Recurse -Force "$workspace\build\web\WEB-INF\lib\*" $destLib

# 5. Configure Tomcat Port to 8082 (avoids conflict with other servers)
$serverXmlPath = "$extractedPath\conf\server.xml"
$serverXml = Get-Content $serverXmlPath
$serverXml = $serverXml -replace 'port="8080"', 'port="8082"'
$serverXml | Set-Content $serverXmlPath

# 6. Start Tomcat in a separate cmd window and KEEP IT OPEN (/k) to see any error logs if they happen!
Write-Host "Starting Apache Tomcat on http://localhost:8082 ..." -ForegroundColor Green
Start-Process -FilePath "cmd.exe" -ArgumentList "/k cd /d ""$extractedPath\bin"" && set ""JAVA_HOME=$javaHome"" && catalina.bat run"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "SUCCESS: Tomcat is starting up!" -ForegroundColor Green
Write-Host "Please open your browser and access:" -ForegroundColor Cyan
Write-Host "👉 http://localhost:8082/" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Magenta
