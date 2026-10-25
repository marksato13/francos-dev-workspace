<#
    Chequeo de integracion: que pasa si se fusionan a develop TODOS los PR abiertos.

    No usa IA ni toca tu checkout: trabaja con refs remotas y en un worktree
    temporal que se borra al terminar. Nunca hace push, merge real ni stash.

    Que revisa:
      1. Cada PR abierto contra origin/develop: conflictos y commits de atraso.
      2. Cada par de PR entre si: conflictos que apareceran al fusionar el segundo.
      3. Migraciones de Prisma: timestamps repetidos o anteriores a la ultima de develop.
      4. develop + todos los PR que fusionan limpio, juntos: install, prisma
         validate/generate, build, lint:check y test. Con -E2E tambien e2e.

    El -E2E aplica las migraciones de todos los PR en la base que le pases.
    Usa SIEMPRE una base desechable, nunca la de desarrollo:
      -DatabaseUrl "postgresql://usuario:clave@localhost:5432/francos_merge_check"

    USO:
      pwsh -File "C:\Users\markp\Desktop\PY-MEGATRON\PY - PERFIL DE EGRESO -DEV\francos-dev-workspace\herramientas\merge-check.ps1"
      pwsh -File "...\merge-check.ps1" -SoloConflictos     # rapido, sin compilar
      pwsh -File "...\merge-check.ps1" -E2E -DatabaseUrl "postgresql://.../francos_merge_check"

    Sale con codigo 0 si todo esta limpio y en verde, 1 si hay algo que mirar.
    El informe queda en reportes\merge-check\ dentro del workspace.
#>

param(
    [switch]$SoloConflictos,
    [switch]$E2E,
    [string]$DatabaseUrl
)

$ErrorActionPreference = "Continue"
$BACKEND   = "C:\Users\markp\Desktop\PY-MEGATRON\PY - PERFIL DE EGRESO -DEV\backend-monolito-francos"
$WORKSPACE = "C:\Users\markp\Desktop\PY-MEGATRON\PY - PERFIL DE EGRESO -DEV\francos-dev-workspace"
$YO        = "marksato13"
$STAMP     = Get-Date -Format "yyyyMMdd-HHmmss"
$REPORTE   = Join-Path $WORKSPACE "reportes\merge-check\merge-check-$STAMP.md"
$WT        = Join-Path $env:TEMP "francos-merge-check-$STAMP"

# Variables falsas que usa el CI (.github/workflows/ci.yml). Nunca se lee el .env.
$ENV_CI = @{
    FRONTEND_STORE_URL  = "http://localhost:4200"
    FRONTEND_PORTAL_URL = "http://localhost:4201"
    SMTP_HOST = "localhost"; SMTP_PORT = "1025"; SMTP_USER = "ci"; SMTP_PASS = "ci"
    SMTP_FROM = "ci@francos.test"
    S3_BUCKET_DOCS = "francos-docs-ci"; S3_BUCKET_MEDIA = "francos-media-ci"
    JWT_SECRET = "ci-only-not-a-real-secret"
}

$informe = New-Object System.Collections.Generic.List[string]
$problemas = 0

function Titulo($t) {
    Write-Host ""
    Write-Host ("  " + $t) -ForegroundColor Cyan
    Write-Host ("  " + ("-" * $t.Length)) -ForegroundColor DarkGray
    $informe.Add(""); $informe.Add("## $t"); $informe.Add("")
}

function Linea($texto, $color = "Gray") {
    Write-Host ("    " + $texto) -ForegroundColor $color
    $informe.Add("- " + $texto)
}

function GitB { & git -C $BACKEND @args 2>&1 }

# git merge-tree --write-tree --name-only: exit 0 = limpio, 1 = conflictos.
# La salida es el tree, luego los archivos en conflicto y una linea en blanco.
function Conflictos($a, $b) {
    $salida = & git -C $BACKEND merge-tree --write-tree --name-only $a $b 2>&1
    if ($LASTEXITCODE -eq 0) { return @() }
    $archivos = @()
    foreach ($l in ($salida | Select-Object -Skip 1)) {
        if ([string]::IsNullOrWhiteSpace($l)) { break }
        $archivos += "$l"
    }
    if ($archivos.Count -eq 0) { $archivos = @("(sin lista: $($salida | Select-Object -Last 1))") }
    return $archivos
}

function Paso($nombre, [scriptblock]$accion) {
    $log = Join-Path $env:TEMP "merge-check-$STAMP-$($nombre -replace '[^a-z0-9]','-').log"
    $inicio = Get-Date
    & $accion *> $log
    $ok = ($LASTEXITCODE -eq 0)
    $seg = [int]((Get-Date) - $inicio).TotalSeconds
    if ($ok) {
        Linea ("{0,-16} paso ({1}s)" -f $nombre, $seg) "Green"
    } else {
        $script:problemas++
        Linea ("{0,-16} FALLO ({1}s)  log: {2}" -f $nombre, $seg, $log) "Red"
        Get-Content $log -Tail 15 | ForEach-Object { $informe.Add("    $_") }
    }
    return $ok
}

Write-Host ""
Write-Host "  MERGE CHECK  ·  $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor White
$informe.Add("# Merge check · $(Get-Date -Format 'yyyy-MM-dd HH:mm')")

#--------------------------------------------------------------------
# 0. Refs al dia y PR abiertos
#--------------------------------------------------------------------
GitB fetch --prune origin | Out-Null
$develop = (GitB rev-parse --short origin/develop) | Select-Object -First 1

Push-Location $BACKEND
$prs = gh pr list --base develop --state open --limit 50 --json number,title,headRefName,author,isDraft | ConvertFrom-Json
Pop-Location
$prs = @($prs | Where-Object { -not $_.isDraft } | Sort-Object number)

Titulo "PR ABIERTOS HACIA DEVELOP ($develop)"
if ($prs.Count -eq 0) { Linea "No hay PR abiertos. Nada que revisar." "Green"; exit 0 }

#--------------------------------------------------------------------
# 1. Cada PR contra develop
#--------------------------------------------------------------------
$limpios = @()
foreach ($pr in $prs) {
    $ref = "origin/$($pr.headRefName)"
    $marca = if ($pr.author.login -eq $YO) { "[mio]" } else { "[$($pr.author.login)]" }
    $cuenta = (GitB rev-list --left-right --count "origin/develop...$ref") -split "\s+"
    $c = Conflictos "origin/develop" $ref
    if ($c.Count -eq 0) {
        $limpios += $pr
        Linea ("#{0} {1} {2}  limpio, {3} atras / {4} adelante" -f $pr.number, $marca, $pr.headRefName, $cuenta[0], $cuenta[1]) "Green"
    } else {
        $problemas++
        Linea ("#{0} {1} {2}  CONFLICTO con develop: {3}" -f $pr.number, $marca, $pr.headRefName, ($c -join ", ")) "Red"
    }
}

#--------------------------------------------------------------------
# 2. Cada par de PR entre si
#--------------------------------------------------------------------
Titulo "CONFLICTOS ENTRE PR (al fusionar uno despues del otro)"
$pares = 0
for ($i = 0; $i -lt $prs.Count; $i++) {
    for ($j = $i + 1; $j -lt $prs.Count; $j++) {
        $a = $prs[$i]; $b = $prs[$j]
        $c = Conflictos "origin/$($a.headRefName)" "origin/$($b.headRefName)"
        if ($c.Count -gt 0) {
            $pares++; $problemas++
            Linea ("#{0} x #{1}: {2}" -f $a.number, $b.number, ($c -join ", ")) "Yellow"
        }
    }
}
if ($pares -eq 0) { Linea "Ningun par de PR choca entre si." "Green" }

#--------------------------------------------------------------------
# 3. Migraciones de Prisma
#--------------------------------------------------------------------
Titulo "MIGRACIONES"
$ultimaDevelop = (GitB ls-tree --name-only origin/develop prisma/migrations/) |
    ForEach-Object { Split-Path $_ -Leaf } | Where-Object { $_ -match '^\d{14}_' } | Sort-Object | Select-Object -Last 1
Linea "Ultima en develop: $ultimaDevelop"
$vistas = @{}
foreach ($pr in $prs) {
    $nuevas = (GitB diff --name-only --diff-filter=A "origin/develop...origin/$($pr.headRefName)" -- prisma/migrations) |
        Where-Object { $_ -match 'migration\.sql$' } | ForEach-Object { Split-Path (Split-Path $_ -Parent) -Leaf }
    foreach ($m in $nuevas) {
        $ts = $m.Substring(0, 14)
        $color = "Gray"; $nota = ""
        if ($ultimaDevelop -and $m -lt $ultimaDevelop) { $color = "Red"; $nota = "  ANTERIOR a la ultima de develop"; $problemas++ }
        if ($vistas.ContainsKey($ts)) { $color = "Red"; $nota += "  MISMO timestamp que #$($vistas[$ts])"; $problemas++ }
        $vistas[$ts] = $pr.number
        Linea ("#{0}: {1}{2}" -f $pr.number, $m, $nota) $color
    }
}
if ($vistas.Count -eq 0) { Linea "Ningun PR trae migraciones." }

#--------------------------------------------------------------------
# 4. Todo junto: develop + PR que fusionan limpio
#--------------------------------------------------------------------
if (-not $SoloConflictos) {
    Titulo "DEVELOP + TODOS LOS PR JUNTOS"
    GitB worktree add --detach $WT origin/develop | Out-Null
    $incluidos = @()
    foreach ($pr in $limpios) {
        & git -C $WT -c user.name=merge-check -c user.email=merge-check@local merge --no-edit --no-ff -q "origin/$($pr.headRefName)" *> $null
        if ($LASTEXITCODE -eq 0) {
            $incluidos += "#$($pr.number)"
        } else {
            & git -C $WT merge --abort *> $null
            $problemas++
            Linea "#$($pr.number) choca con los PR anteriores en el merge acumulado; queda fuera" "Yellow"
        }
    }
    Linea "Fusionados en el worktree temporal: $($incluidos -join ', ')"

    foreach ($k in $ENV_CI.Keys) { Set-Item "env:$k" $ENV_CI[$k] }
    Push-Location $WT
    $ok = Paso "install" { pnpm install --frozen-lockfile }
    if ($ok) {
        Paso "prisma validate" { pnpm exec prisma validate } | Out-Null
        Paso "prisma generate" { pnpm exec prisma generate } | Out-Null
        Paso "build"           { pnpm build } | Out-Null
        Paso "lint:check"      { pnpm lint:check } | Out-Null
        Paso "test"            { pnpm test --ci } | Out-Null
        if ($E2E) {
            if (-not $DatabaseUrl) {
                Linea "e2e omitido: falta -DatabaseUrl con una base desechable" "Yellow"
            } else {
                $env:DATABASE_URL = $DatabaseUrl
                Paso "migrate deploy" { pnpm exec prisma migrate deploy } | Out-Null
                Paso "test:e2e"       { pnpm test:e2e --ci --runInBand } | Out-Null
            }
        } else {
            Linea "e2e no ejecutado (usa -E2E -DatabaseUrl ... para incluirlo)" "DarkGray"
        }
    }
    Pop-Location
    GitB worktree remove --force $WT | Out-Null
    # En Windows git no siempre puede borrar node_modules; la carpeta es temporal y nuestra.
    if (Test-Path $WT) { Remove-Item -Recurse -Force $WT -ErrorAction SilentlyContinue }
    GitB worktree prune | Out-Null
}

#--------------------------------------------------------------------
# Veredicto
#--------------------------------------------------------------------
Titulo "VEREDICTO"
if ($problemas -eq 0) {
    Linea "Todo limpio: los PR abiertos se pueden fusionar en cualquier orden." "Green"
} else {
    Linea "$problemas punto(s) a revisar antes de fusionar." "Red"
}

New-Item -ItemType Directory -Force (Split-Path $REPORTE -Parent) | Out-Null
$informe | Set-Content -Encoding UTF8 $REPORTE
Write-Host ""
Write-Host "  Informe: $REPORTE" -ForegroundColor DarkGray
exit ([int]($problemas -gt 0))
