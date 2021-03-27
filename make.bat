@echo off
vasmarm_std_win32.exe -L compile.txt -linedebug -m250 -Fbin -opt-adr -o build\test.bin test.asm
rem vasmarm_std_win32.exe -L compileelf.txt -m250 -Felf -opt-adr -o build\test.elf test.asm
if %ERRORLEVEL%==0 copy build\test.bin "C:\Archi\Arculator_V2.0_Windows\hostfs\test,ff8"