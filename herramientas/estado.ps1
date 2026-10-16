<#
    Estado unificado: Orca + Git + GitHub en una sola vista.

    No usa IA ni consume tokens: son llamadas a orca, git y gh.
    Jira no entra aqui porque su MCP usa OAuth y no hay token local;
    para Jira usa el comando /estado dentro de Claude Code.

    Funciona con Claude y con Codex indistintamente: el agente de cada terminal
    se lee del campo agentIdentity, que Orca rellena con "claude", "codex" o el
    id del agente que este corriendo.

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

function Hace($ms) {
    if (-not $ms) { return "-" }
    $min = [int]((Get-Date) - [DateTimeOffset]::FromUnixTimeMilliseconds($ms).LocalDateTime).TotalMinutes
    if ($min -lt 60)   { return "hace ${min}m" }
    if ($min -lt 2880) { return "hace " + [int]($min/60) + "h" }
    return "hace " + [int]($min/1440) + "d"
}

Write-Host ""
Write-Host "  ESTADO  ·  $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor White

#--------------------------------------------------------------------
# 1. Presupuesto de cada IA
#--------------------------------------------------------------------
Titulo "PRESUPUESTO DE MIS IAs"

$acc = OrcaJson @("account","list","--json")
if (-not $acc) {
    Write-Host "    Orca no responde" -ForegroundColor Yellow
} else {
    foreach ($prov in @("claude","codex")) {
        $r = $acc.result.rateLimits.$prov
        if (-not $r -or $r.status -ne "ok") {
            $motivo = if ($r.error) { $r.error } else { "sin datos" }
            Write-Host ("    {0,-8} no disponible: {1}" -f $prov, $motivo) -ForegroundColor DarkGray
            continue
        }
        $ses = if ($r.session) { "sesion {0,3}%" -f $r.session.usedPercent } else { "sesion   -" }
        $sem = if ($r.weekly)  { "semanal {0,3}%" -f $r.weekly.usedPercent }  else { "semanal   -" }
        $pico = if ($r.weekly) { $r.weekly.usedPercent } else { 0 }
        $c = if ($pico -ge 80) { "Red" } elseif ($pico -ge 50) { "Yellow" } else { "Green" }
        $reset = if ($r.weekly) { "reinicia " + $r.weekly.resetDescription } else { "" }
        Write-Host ("    {0,-8} {1}   {2}   {3}" -f $prov, $ses, $sem, $reset) -ForegroundColor $c
    }
    $otros = @()
    foreach ($p in $acc.result.rateLimits.PSObject.Properties.Name) {
        if ($p -in @("claude","codex")) { continue }
        $v = $acc.result.rateLimits.$p
        if ($v -and $v.status -eq "ok") { $otros += $p }
    }
    if ($otros.Count -gt 0) { Write-Host ("    tambien activos: " + ($otros -join ", ")) -ForegroundColor DarkGray }
}

#--------------------------------------------------------------------
# 2. Orca: quien esta trabajando
#--------------------------------------------------------------------
Titulo "AGENTES Y ESPACIOS (Orca)"

$ps = OrcaJson @("worktree","ps","--json")
if (-not $ps) {
    Write-Host "    Orca no responde. Arrancalo con: orca open" -ForegroundColor Yellow
} else {
    foreach ($w in $ps.result.worktrees) {
        $activo = if ($w.status -eq "active") { "ACTIVO  " } else { "inactivo" }
        $color  = if ($w.status -eq "active") { "Green" } else { "DarkGray" }

        # El agente vive en agentIdentity de cada terminal, no en worktree.agents
        $agentes = "-"
        if ($w.liveTerminalCount -gt 0) {
            $tl = OrcaJson @("terminal","list","--worktree","id:$($w.worktreeId)","--json")
            if ($tl -and $tl.result.terminals) {
                $ids = @($tl.result.terminals | ForEach-Object {
                    if ($_.agentIdentity) { $_.agentIdentity } else { "shell" }
                } | Select-Object -Unique)
                if ($ids.Count -gt 0) { $agentes = $ids -join ", " }
            }
        }

        Write-Host ("    {0}  {1,-26} {2,-32}" -f $activo, $w.repo, $w.displayName) -ForegroundColor $color
        Write-Host ("              agente: {0,-14} terminales: {1}  estado: {2}  visto: {3}" -f $agentes, $w.liveTerminalCount, $w.workspaceStatus, (Hace $w.lastActivityAt)) -ForegroundColor DarkGray
        if ($w.comment)   { Write-Host ("              nota: " + $w.comment) -ForegroundColor DarkCyan }
        if ($w.linkedPR)  { Write-Host ("              PR:   #" + $w.linkedPR) -ForegroundColor DarkCyan }
    }
}

#--------------------------------------------------------------------
# 3. Automatizaciones
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
        Write-Host ("    [{0}] {1,-24} via {2,-7} {3,-34} proxima: {4}" -f $estado, $a.name, $a.agentId, $a.rrule, $prox) -ForegroundColor $color
    }
    if ($au.result.automations | Where-Object { -not $_.enabled }) {
        Write-Host "    Hay automatizaciones apagadas. Pruebalas con: orca automations run <id> --json" -ForegroundColor DarkYellow
    }
}

#--------------------------------------------------------------------
# 4. Backend
#--------------------------------------------------------------------
Titulo "BACKEND"

if (-not (Test-Path $BACKEND)) {
    Write-Host "    No encuentro el repo en $BACKEND" -ForegroundColor Red
} else {
    Push-Location $BACKEND
    git fetch --prune origin 2>$null | Out-Null

    Write-Host ("    rama actual: {0}" -f (git branch --show-current 2>$null))

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
        Write-Host ("    worktree con {0} archivo(s) sin confirmar" -f ($sucio | Measure-Object -Line).Lines) -ForegroundColor Yellow
    } else {
        Write-Host "    worktree limpio" -ForegroundColor Green
    }
    Pop-Location
}

#--------------------------------------------------------------------
# 5. Mis PRs
#--------------------------------------------------------------------
Titulo "MIS PULL REQUESTS"

if (Test-Path $BACKEND) {
    Push-Location $BACKEND
    $yo = (gh api user --jq ".login" 2>$null)
    if (-not $yo) {
        Write-Host "    gh no autenticado. Corre: gh auth login" -ForegroundColor Yellow
    } else {
        $prs = gh pr list --author $yo --state open --json number,title,headRefName,statusCheckRollup 2>$null | ConvertFrom-Json
        if (-not $prs -or $prs.Count -eq 0) {
            Write-Host ("    no tienes PRs abiertos (autor: {0})" -f $yo) -ForegroundColor DarkGray
        } else {
            foreach ($pr in $prs) {
                $fallos = @($pr.statusCheckRollup | Where-Object { $_.conclusion -eq "FAILURE" })
                $curso  = @($pr.statusCheckRollup | Where-Object { $_.status -eq "IN_PROGRESS" })
                if ($fallos.Count -gt 0)     { $ci = "CI EN ROJO ($($fallos.Count))"; $c = "Red" }
                elseif ($curso.Count -gt 0)  { $ci = "CI corriendo";                  $c = "Yellow" }
                else                         { $ci = "CI en verde";                   $c = "Green" }
                Write-Host ("    #{0,-4} {1,-48} {2}" -f $pr.number, $pr.title, $ci) -ForegroundColor $c
                Write-Host ("          {0}" -f $pr.headRefName) -ForegroundColor DarkGray
            }
        }
    }
    Pop-Location
}

#--------------------------------------------------------------------
# 6. Jira
#--------------------------------------------------------------------
Titulo "JIRA"
Write-Host "    Este script no consulta Jira: su MCP usa OAuth y no hay token local." -ForegroundColor DarkGray
Write-Host "    Dentro de Claude Code:" -ForegroundColor DarkGray
Write-Host "      /estado    esta vista mas tus subtareas de Jira" -ForegroundColor White
Write-Host "      /sync      reconcilia Jira, GitHub y las fichas" -ForegroundColor White
Write-Host ""
