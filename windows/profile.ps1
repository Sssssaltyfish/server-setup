using namespace System.Management.Automation
using namespace System.Management.Automation.Language

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
(& "E:\Whatever\Miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression
#endregion

function Invoke-Starship-TransientFunction {
    &starship module character
}
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt
$ENV:STARSHIP_CACHE = "$HOME\AppData\Local\Temp"

Import-Module posh-git

. "$PSScriptRoot\completions.ps1"

Set-Alias -Name which -Value where.exe

function Restart-Process {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Name,

        [bool]
        $Yes = $false
    )

    $ErrorActionPreference = "Stop"

    Get-Process $name | ForEach-Object {
        $proc_id = $_.Id
        $title = $_.MainWindowTitle
        $cmdline = (Get-WmiObject Win32_Process -Filter "Handle=$proc_id").CommandLine

        if (-not $Yes) {
            while ((Read-Host "killing $title, press Enter to proceed") -ne "`n") {}
        }

        $_.Kill()
        $_.WaitForExit()

        Write-Host "$title killed, restarting"
        Start-Process -FilePath $cmdline.Split(' ')[0] -ArgumentList $cmdline.Split(' ')[1]
        Write-Host "successfully restarted $title"
    }
}

function update-net-escape {
    $sid = (reg query 'HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Mappings' /s /d /f *Unigram*).split("`n")[1].split("\")[-1].trim()
    Write-Output $sid
    CheckNetIsolation.exe LoopbackExempt -a "-p=$sid"
}

function mount-f {
    # Run as admin
    Set-ItemProperty -Path "HKLM:\\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices\" -Name "F:" -Value "\??\E:\Whatever" -ErrorAction SilentlyContinue
}

function update-env {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User") 
}

Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -CompletionQueryItems 100
Set-PSReadLineOption -PredictionViewStyle InlineView

Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$false

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward


Set-PSReadLineKeyHandler -Key F1 `
    -BriefDescription CommandHelp `
    -LongDescription "Open the help window for the current command" `
    -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $commandAst = $ast.FindAll( {
            $node = $args[0]
            $node -is [CommandAst] -and
            $node.Extent.StartOffset -le $cursor -and
            $node.Extent.EndOffset -ge $cursor
        }, $true) | Select-Object -Last 1

    if ($commandAst -ne $null) {
        $commandName = $commandAst.GetCommandName()
        if ($commandName -ne $null) {
            $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
            if ($command -is [AliasInfo]) {
                $commandName = $command.ResolvedCommandName
            }

            if ($commandName -ne $null) {
                Get-Help $commandName -ShowWindow
            }
        }
    }
}

Set-PSReadLineKeyHandler -Key RightArrow `
    -BriefDescription ForwardCharAndAcceptNextSuggestionWord `
    -LongDescription "Move cursor one character to the right in the current editing line and accept the next word in suggestion when it's at the end of current editing line" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -lt $line.Length) {
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)
    }
}
