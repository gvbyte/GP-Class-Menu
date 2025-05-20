class Elements {
    static [int]$MenuWidth = ((Get-Content -Path "$(Get-location)\etc\Config\config.json" -Raw | ConvertFrom-Json).Width);
    static [string]$UserName = ((Get-Content '.\etc\Config\config.json' -Raw | ConvertFrom-Json).Name);
    # Main header for menus
    static [void] Header() {
        Clear-Host;
        Write-Host -ForegroundColor Green (Get-Content './etc/Config/header.txt' -Raw)
    }
    static [void] Spacer(){Write-Host -ForegroundColor Green "`n|____________________________________________________________________________|";}
    static [void] SpacerHeader(){Write-Host -ForegroundColor Green "`n|____________________________________________________________________________|";}
    static [void] WelcomeHeader(){$Day = (Get-Date).Day;[Elements]::OptionCenter("Happy $((Get-Date).DayOfWeek)! $([Elements]::UserName)");[Elements]::Spacer();}
    static [void] OptionFormat([string]$option, [string]$align, [int]$width) {
        $left_pad = 0;
        $right_pad = 0;
        $content_width = $width - 2
        if($option.Length -gt $width){
            throw "Text is too long to fit in the box of width: $($width)"
        }
        switch ($align) {
            "Left"   { $left_pad = 1;$right_pad = $width - $option.Length - $left_pad - 2; }
            "Center" {$left_pad = [math]::Floor(($content_width - $option.Length)/2);$right_pad = $content_width - $left_pad - $option.Length;}
            "Right"  {$right_pad = 1;$left_pad = $width - $option.Length - $right_pad - 2;}
        }
        $left_string = '|' + (' ' * $left_pad)
        $right_string = (' ' * $right_pad) + '|'
        Write-Host -ForegroundColor Green $left_string -NoNewline;
        Write-Host -ForegroundColor White $option -NoNewline;
        Write-Host -ForegroundColor Green $right_string -NoNewline;
    }

    static [void] ChangeColor([string]$Color){
        $Scriptblock = {
            Param($Color)
            try {
                $host.UI.RawUI.ForegroundColor = $Color;
                Write-Host -ForegroundColor Green "[!] Color Changed"
            }
            catch {
                [string]$ErrorMessage = ($Error).ToString();
                $ErrorMessage = $ErrorMessage.Substring(0, 30);
            } 
        }
        Invoke-Command -ErrorAction Stop -ArgumentList $Color -ScriptBlock $Scriptblock;
    }
    static [void] OptionLeft([string]$option)   {[Elements]::OptionFormat($option, 'Left', [Elements]::MenuWidth)}
    static [void] OptionCenter([string]$option) {[Elements]::OptionFormat($option, 'Center', [Elements]::MenuWidth)}
    static [void] OptionRight([string]$option)  {[Elements]::OptionFormat($option, 'Right', [Elements]::MenuWidth)}
    # Passes array to display in options
    static [void] OptionWindow([array]$list){
        $list | ForEach-Object {[Elements]::Spacer();[Elements]::OptionCenter("$($_)");[Elements]::Spacer();}
    }
    # Passes array to display in numbered options
    [void] NumberedWindow([array]$list) {
    Write-Host -ForegroundColor Yellow "`r|            [Select and option and press ENTER]           |
|__________________________________________________________|"
    $option_number = 1;
    $list | ForEach-Object {  $string_complete = "$($option_number): $_"; $string_len = $string_complete.length; $string_space = (" " * (42 - $string_len)); $string_complete = ($string_complete + $string_space);Write-Host -ForegroundColor White "`r|                $($string_complete)|
|__________________________________________________________|"; $option_number++}
    }
    
    static [void] Text($Mode, $Text) {
        switch ($Mode) {
            -1 { Write-Host -ForegroundColor Red "[-] $($Text)";} 
            0  { Write-Host -ForegroundColor White "[*] $($Text)";}
            1  { Write-Host -ForegroundColor Green "[+] $($Text)";}
            2  { Write-Host -ForegroundColor Yellow "[!] $($Text)";}
            3  { Read-Host $Text}
        }
        Start-Sleep -Seconds 1;
    }

    static [string] FormatUserInput() {
        [string] $user_option = Read-Host -Prompt "`rOPTION"
        While (($user_option.Length -eq 0) -or ($user_option -contains " ")) {
            $user_option = (((Read-Host -Prompt "`rOPTION" ).ToLower()).ToCharArray())[0]
        }
        return $user_option
    }

    static [void] Quit(){
        try {
            Stop-Transcript;
            Trace-Info -module "Menu" -message "---> LOG STOPPED <---";
            [Elements]::Text(1, "Logs have been archived, path: .\var\log\");
            Exit;
        }
        catch {
            [Elements]::Text(-1, "Failed to archive log");
            Exit;
        }
    }
}