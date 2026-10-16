<#
    Estado unificado: Orca + Git + GitHub en una sola vista.

    No usa IA ni consume tokens: son llamadas a orca, git y gh.
    Jira no entra aqui porque su MCP usa OAuth y no hay token local;
    para Jira usa el comando /estado dentro de Claude Code.

    USO:
      pwsh -File "C:\Users\markp\Desktop\PY-MEGATRON\PY - PERFIL DE EGRESO -DEV\francos-dev-workspace\herramientas\estado.ps1"
#>

$ErrorActionPreference = "Continue"
$BACKEND = "C:\Users\markp\Desktop\PY-MEGATRON\PY - PERFIL DE EGRESO -DEV\backend-monolito-francos"

function Titulo($t) {
    Write-Host ""
    Write-Host ("  " + $t) -ForegroundColor Cyan
    Write-Host ("  " + ("-" * $t.Length)) -ForegroundColor DarkGray
}

function OrcaJson($argumentos) {
    try {
        $salida = & orca @argumentos 2>$null | Out-String
        if ([string]::IsNullOrWhiteSpace($salida)) { return $null }
        return $salida | ConvertFrom-Json
    } catch { return $null }
}

Write-Host ""
Write-Host "  ESTADO  ·  $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor White

#--------------------------------------------------------------------
# 1. Orca: quien esta trabajando
#--------------------------------------------------------------------
Titulo "AGENTES Y ESPACIOS (Orca)"

$ps = OrcaJson @("worktree","ps","--json")
if (-not $ps) {
    Write-Host "    Orca no responde. Arrancalo con: orca open" -ForegroundColor Yellow
} else {
    foreach ($w in $ps.result.worktrees) {
        $activo = if ($w.status -eq "active") { "ACTIVO  " } else { "inactivo" }
        $color  = if ($w.status -eq "active") { "Green" } else { "DarkGray" }

        $agentes = if ($w.agents -and $w.agents.Count -gt 0) {
            ($w.agents | ForEach-Object { $_.agentId }) -join ", "
        } elseif ($w.liveTerminalCount -gt 0) {
            "shell"
        } else { "-" }

        $visto = if ($w.lastActivityAt) {
            $min = [int]((Get-Date) - [DateTimeOffset]::FromUnixTimeMilliseconds($w.lastActivityAt).LocalDateTime).TotalMinutes
            if ($min -lt 60) { "hace ${min}m" } else { "hace " + [int]($min/60) + "h" }
        } else { "-" }

        Write-Host ("    {0}  {1,-26} {2,-32}" -f $activo, $w.repo, $w.displayName) -ForegroundColor $color
        Write-Host ("              agente: {0,-12} terminales: {1}  estado: {2}  visto: {3}" -f $agentes, $w.liveTerminalCount, $w.workspaceStatus, $visto) -ForegroundColor DarkGray
        if ($w.comment) { Write-Host ("              nota: " + $w.comment) -ForegroundColor DarkCyan }
    }
}

#--------------------------------------------------------------------
# 2. Automatizaciones
#--------------------------------------------------------------------
Titulo "AUTOMATIZACIONES"

$au = OrcaJson @("automations","list","--json")
if (-not $au -or -not $au.result.automations -or $au.result.automations.Count -eq 0) {
    Write-Host "    ninguna configurada" -ForegroundColor DarkGray
} else {
    foreach ($a in $au.result.automations) {
        $estado = if ($a.enabled) { "ON " } else { "OFF" }
        $color  = if ($a.enabled) { "Green" } else { "Yellow" }
        $prox = if ($a.enabled -and $a.nextRunAt) {
            [DateTimeOffset]::FromUnixTimeMilliseconds($a.nextRunAt).LocalDateTime.ToString("dd/MM HH:mm")
        } else { "-" }
        Write-Host ("    [{0}] {1,-26} {2,-34} proxima: {3}" -f $estado, $a.name, $a.rrule, $prox) -ForegroundColor $color
    }
    if ($au.result.automations | Where-Object { -not $_.enabled }) {
        Write-Host "    Hay automatizaciones apagadas. Pruebalas con: orca automations run <id> --json" -ForegroundColor DarkYellow
    }
}

#--------------------------------------------------------------------
# 3. Backend
#--------------------------------------------------------------------
Titulo "BACKEND"

if (-not (Test-Path $BACKEND)) {
    Write-Host "    No encuentro el repo en $BACKEND" -ForegroundColor Red
} else {
    Push-Location $BACKEND
    git fetch --prune origin 2>$null | Out-Null

    $rama = (git branch --show-current 2>$null)
    Write-Host ("    rama actual: {0}" -f $rama)

    $cuenta = (git rev-list --left-right --count "HEAD...origin/develop" 2>$null)
    if ($cuenta) {
        $p = $cuenta -split "\s+"
        $delante = [int]$p[0]; $detras = [int]$p[1]
        $c = if ($detras -gt 20) { "Red" } elseif ($detras -gt 0) { "Yellow" } else { "Green" }
        Write-Host ("    vs origin/develop: {0} commits mios sin subir, {1} commits de atraso" -f $delante, $detras) -ForegroundColor $c
        if ($detras -gt 0) { Write-Host "    actualiza con: git switch develop; git pull --ff-only origin develop" -ForegroundColor DarkYellow }
    }

    $sucio = (git status --porcelain 2>$null)
    if ($sucio) {
        $n = ($sucio | Measure-Object -Line).Lines
        Write-Host ("    worktree con {0} archivo(s) sin confirmar" -f $n) -ForegroundColor Yellow
    } else {
        Write-Host "    worktree limpio" -ForegroundColor Green
    }
    Pop-Location
}

#--------------------------------------------------------------------
# 4. Mis PRs
#--------------------------------------------------------------------
Titulo "MIS PULL REQUESTS"

if (Test-Path $BACKEND) {
    Push-Location $BACKEND
    $yo = (gh api user --jq ".login" 2>$null)
    if (-not $yo) {
        Write-Host "    gh no autenticado. Corre: gh auth login" -ForegroundColor Yellow
    } else {
        $prs = gh pr list --author $yo --state open --json number,title,headRefName,statusCheckRollup,createdAt 2>$null | ConvertFrom-Json
        if (-not $prs -or $prs.Count -eq 0) {
            Write-Host ("    no tienes PRs abiertos (autor: {0})" -f $yo) -ForegroundColor DarkGray
        } else {
            foreach ($pr in $prs) {
                $fallos = @($pr.statusCheckRollup | Where-Object { $_.conclusion -eq "FAILURE" })
                $curso  = @($pr.statusCheckRollup | Where-Object { $_.status -eq "IN_PROGRESS" })
                if ($fallos.Count -gt 0) { $ci = "CI EN ROJO ($($fallos.Count))"; $c = "Red" }
                elseif ($curso.Count -gt 0) { $ci = "CI corriendo"; $c = "Yellow" }
                else { $ci = "CI en verde"; $c = "Green" }
                Write-Host ("    #{0,-4} {1,-50} {2}" -f $pr.number, $pr.title, $ci) -ForegroundColor $c
                Write-Host ("          {0}" -f $pr.headRefName) -ForegroundColor DarkGray
            }
        }
    }
    Pop-Location
}

#--------------------------------------------------------------------
# 5. Jira: recordatorio
#--------------------------------------------------------------------
Titulo "JIRA"
Write-Host "    Este script no consulta Jira: su MCP usa OAuth y no hay token local." -ForegroundColor DarkGray
Write-Host "    Para el estado de tus subtareas, dentro de Claude Code ejecuta:" -ForegroundColor DarkGray
Write-Host "      /sync      reconcilia Jira, GitHub y las fichas" -ForegroundColor White
Write-Host "      /estado    esta misma vista mas tus subtareas de Jira" -ForegroundColor White
Write-Host ""
