# Servidor HTTP local para o FinanceiroPro
# Execute com: powershell -ExecutionPolicy Bypass -File servidor.ps1

$port   = 8080
$root   = $PSScriptRoot
$prefix = "http://localhost:$port/"

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'application/javascript; charset=utf-8'
  '.json' = 'application/json'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.gif'  = 'image/gif'
  '.svg'  = 'image/svg+xml'
  '.ico'  = 'image/x-icon'
  '.pdf'  = 'application/pdf'
  '.woff' = 'font/woff'
  '.woff2'= 'font/woff2'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "   FinanceiroPro - Servidor rodando!" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Acesse: http://localhost:$port" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Pressione Ctrl+C para parar o servidor." -ForegroundColor Gray
Write-Host ""

# Abre o navegador automaticamente
Start-Process "http://localhost:$port"

while ($listener.IsListening) {
  try {
    $ctx  = $listener.GetContext()
    $req  = $ctx.Request
    $resp = $ctx.Response

    $path = $req.Url.LocalPath -replace '/', '\'
    $file = Join-Path $root $path

    # Página padrão: index.html
    if ($path -eq '\' -or $path -eq '') {
      $file = Join-Path $root 'index.html'
    }

    # Se for diretório, serve index.html dentro dele
    if (Test-Path $file -PathType Container) {
      $file = Join-Path $file 'index.html'
    }

    if (Test-Path $file -PathType Leaf) {
      $ext  = [System.IO.Path]::GetExtension($file).ToLower()
      $ct   = if ($mime[$ext]) { $mime[$ext] } else { 'application/octet-stream' }
      $bytes = [System.IO.File]::ReadAllBytes($file)

      $resp.StatusCode  = 200
      $resp.ContentType = $ct
      $resp.ContentLength64 = $bytes.Length
      $resp.OutputStream.Write($bytes, 0, $bytes.Length)

      Write-Host "  [200] $($req.Url.LocalPath)" -ForegroundColor Green
    } else {
      $msg   = [System.Text.Encoding]::UTF8.GetBytes("404 - Arquivo nao encontrado: $($req.Url.LocalPath)")
      $resp.StatusCode  = 404
      $resp.ContentType = 'text/plain; charset=utf-8'
      $resp.ContentLength64 = $msg.Length
      $resp.OutputStream.Write($msg, 0, $msg.Length)

      Write-Host "  [404] $($req.Url.LocalPath)" -ForegroundColor Red
    }

    $resp.OutputStream.Close()

  } catch [System.Net.HttpListenerException] {
    break
  } catch {
    Write-Host "  [ERRO] $_" -ForegroundColor Red
    try { $ctx.Response.Abort() } catch {}
  }
}

$listener.Stop()
Write-Host "`n  Servidor encerrado." -ForegroundColor Gray
