$ErrorActionPreference = 'Stop'

# OpenCode puede heredar un entorno anterior al cambio de variables de usuario.
# Leer la clave al iniciar este MCP; no guardarla en la configuración ni imprimirla.
$apiKey = [Environment]::GetEnvironmentVariable('TESTSPRITE_API_KEY', 'User')
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    [Console]::Error.WriteLine('TestSprite: falta TESTSPRITE_API_KEY en las variables de usuario.')
    exit 1
}

$env:API_KEY = $apiKey
$apiKey = $null
& npx.cmd -y '@testsprite/testsprite-mcp@latest'
exit $LASTEXITCODE
