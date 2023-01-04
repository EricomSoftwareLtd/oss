echo "building EXEs"
call build.bat
echo "signing EXEs"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './sign.ps1' 'arm64'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './sign.ps1' 'amd64'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './sign.ps1' 'arm'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './sign.ps1' 'x86'"
echo "building MSIs"
call "installer\build.bat"
echo "signing MSIs"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './sign.ps1' 'installer/dist'"
echo "All well that ends well"

