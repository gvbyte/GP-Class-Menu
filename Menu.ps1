using module '.\Classes\MenuItem.psm1'
using module '.\Classes\MenuPage.psm1'
using module '.\Classes\Elements.psm1'
using module '.\Classes\Setup.psm1'

class Menu {
    static [string]$Name = ((Get-Content '.\etc\Config\config.json' -Raw | ConvertFrom-Json).Menu);
    # Initializes Menu
    static [void] Init(){
        [Setup]::StartArchive();
        [Setup]::TerminalSetup();
        [MenuInit]::new().OSType("menu-main", "Menus");
    }
    # Option -Help ==> Displays the help menu 
    static [void] Help() {
        [Elements]::Header();
        [Elements]::OptionWindow(@(
                ".\$([Menu]::Name) -menu | open main menu",
                ".\$([Menu]::Name) -help | get help"
        ));
    }
    # Log -Log     ==> Displays the logs
    static [void] Log() {
        try {
            [Elements]::Header();
            $Dirs = (Get-ChildItem -Path '.\var\log\Log*.log')[-1];
            Write-Host $(Get-Content -Raw -Path ".\var\log\$($Dirs.Name)");
            Write-Host -ForegroundColor Green $(Read-Host "[!] Press ENTER to continue");
            Trace-Info -module "Function" -message "Show-Log";
        }
        catch {
            Trace-Error -module "Function" -message "Show-Log | Error: $(($Error)[0])";
        }

       
    }
    # Clear -Clear ===> 
    static [void] Clear([string]$export){
        try{
            $total_logs =  Get-ChildItem -Path "./var/$($export)/*" -Filter "*.$($export)" -Recurse | Where-Object{$_.Name -ne "README.md"}; 
            $total_logs_count = $total_logs.Count; 
            $total_logs | Remove-Item -Force; [Elements]::OptionLeft("[!] Successfully cleared $($total_logs_count) $($export)");
            Read-Host;
        }
        catch{
            [Elements]::OptionLeft("[!] Failed to clear /var/log");Read-Host;
        }
    }
    # Clear -Clear ===> 
    static [void] ClearAll() {
        [Menu]::Clear('csv');
        [Menu]::Clear('html');
        [Menu]::Clear('log');
        [Menu]::Clear('xlsx');

    }
}
class MenuInit {
    [string] GetOSName() {
        $osVersion = [System.Environment]::OSVersion
        return $(switch ($true) {
                ($osVersion.Platform -eq "Unix") { return "Unix - PowerShell Core" }
                ($osVersion.Version.Major -eq 10 -and $osVersion.Version.Minor -eq 0) { return "Windows 10 / Server 2016+" }
                ($osVersion.Version.Major -eq 6 -and $osVersion.Version.Minor -eq 3) { return "Windows 8.1 / Server 2012 R2" }
                ($osVersion.Version.Major -eq 6 -and $osVersion.Version.Minor -eq 2) { return "Windows 8 / Server 2012" }
                ($osVersion.Version.Major -eq 6 -and $osVersion.Version.Minor -eq 1) { return "Windows 7 / Server 2008 R2" }
                ($osVersion.Version.Major -eq 6 -and $osVersion.Version.Minor -eq 0) { return "Windows Vista / Server 2008" }
                ($osVersion.Version.Major -lt 6) { return "Legacy OS (XP or older)" }
                default { return "Unknown OS" }
            } )
    }

    [void] OSType([string]$menu, [string]$folder) {
        $osName = $this.GetOSName();
        Trace-Info -module "SETUP" -message "[!] Detected OS: $osName";
        Start-Sleep -Seconds 2;
        switch ($osName) {
            "Windows 10 / Server 2016+" {
                $manager = [MenuManager]::new("menu-main.json", "Menus")
                $manager.ShowMenu()
            }
            "Windows8.1" {
                Write-Host "Running script for Windows 8.1..."
            }
            "Windows8" {
                Write-Host "Running script for Windows 8..."
            }
            "Windows7" {
                Write-Host "Running script for Windows 7..."
            }
            "Vista" {
                Write-Host "Running Vista fallback..."
            }
            "Legacy" {
                Write-Host "Unsupported legacy OS."
            }
            "Unix - PowerShell Core" {
                $manager = [MenuManager]::new("menu-main.json", "Menus")
                $manager.ShowMenu()
            }
            default {
                Write-Warning "No known script for detected OS: $osName"
            }
        }
    }
}
class MenuManager {
    [hashtable]$Pages
    [System.Collections.Stack]$History
    [MenuPage]$CurrentPage
    [string]$MenuFolder

    MenuManager([string]$startJson, [string]$menuFolder) {
        $this.Pages = @{}
        $this.History = [System.Collections.Stack]::new()
        $this.MenuFolder = $menuFolder
        $this.MenuFolder = "$(Get-Location)\etc\Config\$($this.MenuFolder)"

        # Auto-discover all menus
        $AllMenus = Get-ChildItem -Path $this.MenuFolder -Filter *.json
        foreach ($file in $AllMenus) {
            $null = $this.LoadMenu($file.Name)
        }

        $this.CurrentPage = $this.LoadMenu($startJson)
    }

    [MenuPage]LoadMenu([string]$jsonFile) {
        if ($this.Pages.ContainsKey($jsonFile)) {
            return $this.Pages[$jsonFile]
        }

        $path = Join-Path $this.MenuFolder $jsonFile;
        $json = Get-Content $path -Raw | ConvertFrom-Json;
        $jsonTitle = "======> $($json.Title) <======";
        $page = [MenuPage]::new($jsonTitle);

        foreach ($item in $json.Items) {
            $menuItem = [MenuItem]::new(
                $item.Label,
                $item.Action,
                $item.SubMenu,
                $item.HotKey
            )
            $page.AddItem($menuItem)
        }

        $this.Pages[$jsonFile] = $page
        return $page
    }

    [void]ShowMenu() {
        while ($true) {
            Clear-Host
            [Elements]::Header();
            [Elements]::WelcomeHeader();
            [Elements]::OptionCenter($this.CurrentPage.Title);
            [Elements]::SpacerHeader();
            $filter = Read-Host "[!] Filter keyword (Press ENTER to skip)"
            [Elements]::Spacer();
            $filteredItems = if ($filter) {
                [Elements]::Header();
                [Elements]::OptionCenter($this.CurrentPage.Title);
                [Elements]::SpacerHeader();
                $this.CurrentPage.Items | Where-Object { $_.Label -like "*$filter*" }
            }
            else {
                [Elements]::Header();
                [Elements]::OptionCenter($this.CurrentPage.Title);
                [Elements]::SpacerHeader();
                $this.CurrentPage.Items
            }

            for ($i = 0; $i -lt $filteredItems.Count; $i++) {
                $line = "[$(($i + 1))] $($filteredItems[$i].Label)"
                if ($filteredItems[$i].HotKey) {
                    $line += " | [HotKey: $($filteredItems[$i].HotKey)]"
                }
                $line = [Elements]::OptionLeft($line);
                [Elements]::Spacer();
                Write-Host -NoNewline $line
            }

            $choice = Read-Host "`n[!] Choose number, hotkey, or 'q' to quit"
            if ($choice -eq 'q') { [Elements]::Quit();break; }

            $selected = $null

            # Hotkey check
            $hotkeyMatch = $filteredItems | Where-Object { $_.HotKey -and $_.HotKey.ToUpper() -eq $choice.ToUpper() }
            if ($hotkeyMatch) {
                $selected = $hotkeyMatch
            }
            elseif ($choice -as [int] -and $choice -le $filteredItems.Count) {
                $selected = $filteredItems[$choice - 1]
            }

            if ($null -ne $selected) {
                if ($selected.SubMenu) {
                    $this.History.Push($this.CurrentPage)
                    $this.CurrentPage = $this.LoadMenu($selected.SubMenu)
                }
                elseif ($selected.Action -eq 'Back') {
                    if ($this.History.Count -gt 0) {
                        $this.CurrentPage = $this.History.Pop()
                    }
                }
                elseif ($selected.Action -eq 'Quit') {
                    [Elements]::Quit();
                    break
                }elseif ($selected.Action -eq 'Clear') {
                    [Menu]::ClearAll();
                }
                elseif ($selected.Action) {
                    try {
                        Write-Host "`n[!] Executing: $($selected.Action)" -ForegroundColor Yellow
                        Invoke-Expression $selected.Action
                        Pause
                    }
                    catch {
                        Write-Error "Failed to run command: $_"
                    }
                }
            }
            else {
                Write-Host "Invalid selection." -ForegroundColor Red
            }
        }
    }
}