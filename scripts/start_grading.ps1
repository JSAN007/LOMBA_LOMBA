param([string]$Model = 'gpt-4.1-mini', [int]$Port = 8787, [ValidateSet('local-nlp', 'openai')][string]$Engine = 'local-nlp')
$ErrorActionPreference = 'Stop'
$nodeCommand = Get-Command node -ErrorAction SilentlyContinue
$nodeExecutable = if ($nodeCommand) { $nodeCommand.Source } else {
  Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
}
if (-not (Test-Path -LiteralPath $nodeExecutable)) { throw 'Install Node.js 22 or newer first.' }
$backendFile = Join-Path $PSScriptRoot '..\backend\grader.mjs'
$savedKey = $env:OPENAI_API_KEY
try {
  if ($Engine -eq 'openai' -and -not $env:OPENAI_API_KEY) {
    $secret = Read-Host 'Masukkan API key OpenAI BARU (input disembunyikan)' -AsSecureString
    $env:OPENAI_API_KEY = [System.Net.NetworkCredential]::new('', $secret).Password
  }
  if ($Engine -eq 'openai' -and -not $env:OPENAI_API_KEY) { throw 'API key belum diisi.' }
  $env:GRADING_ENGINE = $Engine
  $env:OPENAI_MODEL = $Model
  $env:PORT = $Port
  & $nodeExecutable $backendFile
} finally { $env:OPENAI_API_KEY = $savedKey }
