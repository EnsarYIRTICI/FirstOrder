# Functions\Windows\OpenSSH.ps1
function Enable-OpenSSHServer {
    try {
        # Özelliği etkinleştir
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop | Out-Null

        # Servisi başlat ve otomatik başlatma moduna ayarla
        Start-Service sshd
        Set-Service -Name sshd -StartupType 'Automatic'

        Write-Host "OpenSSH Server başarıyla etkinleştirildi ve başlatıldı." -ForegroundColor Green
    } catch {
        Write-Host "OpenSSH Server etkinleştirilirken bir hata oluştu: $_" -ForegroundColor Red
    }
}
