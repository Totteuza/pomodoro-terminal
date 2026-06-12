# Pomodoro Terminal - PowerShell
# Uso: .\pomodoro.ps1
# Teclas durante o timer: [P] pausar/continuar  [S] pular  [Q] sair

param(
    [int]$FocusMin = 25,
    [int]$ShortMin = 5,
    [int]$LongMin  = 15,
    [int]$Rounds   = 4
)

$logFile = Join-Path $PSScriptRoot "historico.txt"

function Write-Centered {
    param([string]$Text, [ConsoleColor]$Color = 'Cyan')
    $width = $Host.UI.RawUI.WindowSize.Width
    $pad   = [Math]::Max(0, [int](($width - $Text.Length) / 2))
    Write-Host (" " * $pad + $Text) -ForegroundColor $Color
}

function Write-Bar {
    param([int]$Elapsed, [int]$Total, [ConsoleColor]$Color)
    $width  = [Math]::Min(50, $Host.UI.RawUI.WindowSize.Width - 12)
    $filled = [Math]::Round($width * $Elapsed / $Total)
    $empty  = $width - $filled
    $pct    = [Math]::Round(100 * $Elapsed / $Total)
    $bar    = ("=" * $filled) + ("-" * $empty)
    Write-Host ("  [" + $bar + "] " + $pct + "%") -ForegroundColor $Color
}

function Beep-Notify {
    param([bool]$IsFocus)
    if ($IsFocus) {
        [Console]::Beep(880, 300)
        Start-Sleep -Milliseconds 100
        [Console]::Beep(1100, 400)
    } else {
        [Console]::Beep(660, 200)
        Start-Sleep -Milliseconds 80
        [Console]::Beep(660, 200)
    }
}

function Format-Time {
    param([int]$Seconds)
    "{0:D2}:{1:D2}" -f [Math]::Floor($Seconds / 60), ($Seconds % 60)
}

function Log-Session {
    param([string]$Label, [datetime]$Start, [datetime]$End)
    $line = "{0}  |  {1,-20}  |  inicio {2}  |  fim {3}" -f `
        $Start.ToString("yyyy-MM-dd"), $Label, `
        $Start.ToString("HH:mm"), $End.ToString("HH:mm")
    Add-Content -Path $logFile -Value $line
}

function Run-Timer {
    param([string]$Label, [int]$Minutes, [ConsoleColor]$Color)

    $total   = $Minutes * 60
    $elapsed = 0
    $paused  = $false
    $start   = Get-Date
    $skipped = $false

    while ($elapsed -le $total) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true).Key
            if ($key -eq 'Q') {
                return "quit"
            }
            if ($key -eq 'S') {
                $skipped = $true
                break
            }
            if ($key -eq 'P') {
                $paused = -not $paused
            }
        }

        Clear-Host
        Write-Host ""
        Write-Centered "*** POMODORO TIMER ***" Cyan
        Write-Host ""
        Write-Centered $Label $Color
        Write-Host ""
        Write-Centered (Format-Time ($total - $elapsed)) White
        Write-Host ""
        Write-Bar -Elapsed $elapsed -Total $total -Color $Color
        Write-Host ""

        if ($paused) {
            Write-Centered "[ PAUSADO ]  P=continuar  S=pular  Q=sair" Yellow
        } else {
            Write-Centered "P=pausar   S=pular   Q=sair" DarkGray
        }

        if (-not $paused) {
            $elapsed++
        }
        Start-Sleep -Seconds 1
    }

    $end = Get-Date
    if (-not $skipped) {
        Log-Session $Label $start $end
        Beep-Notify -IsFocus ($Label -like "*FOCO*")
    }
    return "done"
}

function Show-History {
    Clear-Host
    Write-Host ""
    Write-Centered "HISTORICO DE SESSOES" Cyan
    Write-Host ""
    if (Test-Path $logFile) {
        $lines = Get-Content $logFile
        $lines | Select-Object -Last 20 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }
        Write-Host ""
        Write-Host ("  Total de sessoes registradas: " + $lines.Count) -ForegroundColor DarkCyan
    } else {
        Write-Host "  Nenhuma sessao registrada ainda." -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  Pressione qualquer tecla para voltar..." -ForegroundColor DarkGray
    [Console]::ReadKey($true) | Out-Null
}

# Loop principal
while ($true) {
    Clear-Host
    Write-Host ""
    Write-Centered "*** POMODORO TIMER ***" Cyan
    Write-Host ""
    Write-Host "  Configuracao atual:" -ForegroundColor DarkGray
    Write-Host ("    Foco:        " + $FocusMin + " min") -ForegroundColor White
    Write-Host ("    Pausa curta: " + $ShortMin + " min") -ForegroundColor White
    Write-Host ("    Pausa longa: " + $LongMin  + " min  (a cada " + $Rounds + " rodadas)") -ForegroundColor White
    Write-Host ""
    Write-Host "  I = Iniciar ciclo" -ForegroundColor Green
    Write-Host "  H = Ver historico" -ForegroundColor Yellow
    Write-Host "  Q = Sair"          -ForegroundColor Red
    Write-Host ""

    $key = [Console]::ReadKey($true).Key

    if ($key -eq 'Q') {
        break
    }

    if ($key -eq 'H') {
        Show-History
        continue
    }

    if ($key -eq 'I') {
        $round = 1
        $quit  = $false

        while (-not $quit) {
            $label  = "FOCO - Rodada " + $round + " de " + $Rounds
            $result = Run-Timer -Label $label -Minutes $FocusMin -Color Green
            if ($result -eq "quit") {
                $quit = $true
                break
            }

            if (($round % $Rounds) -eq 0) {
                $result = Run-Timer -Label "PAUSA LONGA" -Minutes $LongMin -Color Blue
                $round  = 1
            } else {
                $result = Run-Timer -Label "PAUSA CURTA" -Minutes $ShortMin -Color DarkCyan
                $round++
            }

            if ($result -eq "quit") {
                $quit = $true
            }
        }
    }
}

Clear-Host
Write-Host ""
Write-Centered "Ate logo! Sessoes salvas em historico.txt" DarkGray
Write-Host ""
