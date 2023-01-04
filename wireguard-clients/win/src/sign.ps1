param (
    [string]$dir
    )


$filePathArr = Get-ChildItem -Path $dir -Recurse -include *.dll,*.exe,*.msi


foreach ($filePath in $filePathArr)
{
    echo "filePath is: $filePath"
    #echo "pathToBuildTools is: $pathToBuildTools"
    Invoke-Expression -Command .\signcode.ps1'  -useSavedCredentials   "$filePath"'
}
