function Get-USB-Disks {
    $global:usb_disks = Get-Disk | Where BusType -eq USB | Get-Partition | Get-Volume | Sort-Object -Property DriveLetter
    }

function Get-Source-Path {
    $current_location = $(Get-Location).Path + '\usb_content\'
    $source_path = Read-Host -Prompt "What is the source path [$current_location]"
    if ([string]::IsNullOrWhiteSpace($source_path))
    {

      $source_path = $current_location

    }
    $global:source_path = $source_path
}

function Get-Log-Path {
    $current_location = $(Get-Location).Path
    $log_path = Read-Host -Prompt "What is the log path [$current_location]"
    if ([string]::IsNullOrWhiteSpace($log_path))
    {

      $log_path = $current_location

    }
    $global:log_path = $log_path
}

function Get-Confirmation {
    Write-Host
    Write-Host Please confirm the information below.:
    Write-Host 
    Write-Host Source Directory:
    Write-Host $source_path
    Write-Host 
    Write-Host USB Disk Drive Letters that will be formatted and loaded with Content:
    Write-Host $usb_disks.DriveLetter
    Write-Host
    Write-Host Log Directory:
    Write-Host $log_path
    $confirmation = Read-Host "Are you Sure? [Y/N]"
    Switch ($confirmation) {
    Y { COPY-CMES-USB }
    N { exit }
    }
}

## Not working
# function Format-Disks {
#     foreach ($disk in $usb_disks)
#     {
#         Write-Host Formatting $disk.DriveLetter
#         Format-Volume -DriveLetter $disk.DriveLetter -NewFileSystemLabel "CMES" -FileSystem NTFS -force -full -WhatIf
#     }
# }

function COPY-CMES-USB {
    Write-Host Copying content...
    $usb_disks | ForEach-Object -Parallel {
        $Source = "$using:source_path"
        $Destination = $_."DriveLetter" + ':\'
        $Log_File = $using:log_path + '\' + $_."DriveLetter" + '_copy.log'
        robocopy $Source $Destination /E /COPY:DAT /LOG:$Log_File
    }
}

Get-USB-Disks
Get-Source-Path
Get-Log-Path
Get-Confirmation
#Delete-Logs # Make a function to delete the log files after transfer
## Get Parallel throttle limit from user