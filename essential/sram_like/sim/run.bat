@echo off

echo choose one to simulation
echo 1. spi
echo 2. fsmc
echo.
set /p num=

if "%num%"=="1" (
    cd ./modelsim_prj
    vsim -do ./run_spi.do
    pause
)

if "%num%"=="2" (
    cd ./modelsim_prj
    vsim -do ./run_fsmc.do
    pause
)
