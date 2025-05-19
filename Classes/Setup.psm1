class Setup {
    static [string] $ArchiveName = "Transcript_$((Get-Date).ToString("yy-MM-dd"))";
    <# METHODS #>
    # Standalone Method
    static [void] StartArchive() {
        $archive_name = [Setup]::ArchiveName;
        try {
            Start-Transcript -Path ".\var\log\$($archive_name).log" -Append -Force;
            Trace-Info -module "SETUP" -message "Initiated PS Transcript: $($archive_name).log ";
            Start-Sleep -Seconds 1
        }
        catch {
            Write-Host -ForegroundColor Red "[!] Failed to initiate .\var\log\$($archive_name).log: $($Error[0])";
            Read-Host "[!] Press ENTER to continue";
        }
        
    }
    # Standalone Method
    static [void] StopArchive() {
        $archive_name = [Setup]::ArchiveName;
        try {
            Start-Transcript -Path ".\var\log\$($archive_name).log" -Append -Force;
            Write-Host -ForegroundColor Green "[*] Archive Log initiated, find at: .\var\log\$($archive_name).log"
        }
        catch {
            Write-Host -ForegroundColor Red "[!] Failed to initiate archive log: : $($Error[0])"
        }
        
    }
    # Builder Method: Terminal Color
    static [void] TerminalColor() {
        $Scriptblock = {
            try {
                $host.UI.RawUI.ForegroundColor = 'White';
                $host.UI.RawUI.BackgroundColor = 'Black';
                Trace-Info -module "SETUP" -message "Configured: Terminal Color ";
            }
            catch {
                [string]$ErrorMessage = ($Error).ToString();
                $ErrorMessage = $ErrorMessage.Substring(0, 30);
                Trace-Error -module "SETUP" -message "Terminal Color Error:  $($ErrorMessage)";
            } 
        }
        Invoke-Command -ErrorAction Stop -ScriptBlock $Scriptblock;
    }
    # Builder Method: Terminal Size
    static [void] TerminalSize([int]$PreferredWidth = 64,[int]$PreferredHeight = 40,[int]$PreferredBufferHeight = 40) {
        $Scriptblock = {
            Param($PreferredWidth, $PreferredHeight, $PreferredBufferHeight)
            try {
                $rawUI = $Host.UI.RAWUI;
                $bufferSize = New-Object System.Management.Automation.Host.Size;
                $bufferSize.Width = [Math]::Max($PreferredWidth, $rawUI.BufferSize.Width);
                $bufferSize.Height = [Math]::Max($PreferredBufferHeight, $PreferredHeight);
                $rawUI.BufferSize = $bufferSize

                $WindowSize = New-Object System.Management.Automation.Host.Size;
                $WindowSize.Width = $PreferredWidth
                $WindowSize.Height = $PreferredHeight
                $rawUI.WindowSize = $WindowSize
                Trace-Info -module "SETUP" -message "Terminal Resized";
            }
            catch {
                [string]$ErrorMessage = ($Error).ToString();
                $ErrorMessage = $ErrorMessage.Substring(0, 30);
                Trace-Error -module "SETUP" -message "Terminal resize config failed: $($ErrorMessage)";
            }   
        }
        Invoke-Command -ErrorAction Stop -ArgumentList($PreferredWidth, $PreferredHeight, $PreferredBufferHeight) -ScriptBlock $Scriptblock;
    }
    # Main Method: Terminal Setup
    static [void] TerminalSetup() {[Setup]::TerminalColor();}

}