@echo off
del build\test.bin
copy vectorball2.asm C:\Users\Eric\projects\ARM3D\ARM3D /Y
copy rmrebuild.asm C:\Users\Eric\projects\ARM3D\ARM3D /Y
copy fiqRM.asm C:\Users\Eric\projects\ARM3D\ARM3D /Y

rem vasmarm_std_win32.exe -L compile.txt -linedebug -m250 -Fbin -opt-adr -o build\test.bin vectorball1.asm
vasmarm_std_win32.exe -L compiletest.txt -linedebug -m250 -Fbin -o build\test.bin vectorball2.asm
rem vasmarm_std_win32.exe -L compile.txt -linedebug -m250 -Fbin -o build\320x200.bin 320x200.asm

vasmarm_std_win32.exe -L compileFIQ.txt -linedebug -m250 -Fbin -o build\fiqrmi.bin fiqRM.asm
vasmarm_std_win32.exe -L compileRMI.txt -linedebug -m250 -Fbin -o build\rmi.bin rmrebuild.asm

rem vasmarm_std_win32.exe -L compileelf.txt -m250 -Felf -opt-adr -o build\test.elf test.asm
copy build\test.bin "C:\Archi\Arculator_V2.0_Windows\hostfs\test,ff8"
rem copy build\test.bin "C:\Archi\Arculator_V2.0_Windows\hostfs\test"
copy build\rmi.bin "C:\Archi\Arculator_V2.0_Windows\hostfs\rmi,ff8"
rem copy build\rmi.bin "C:\Archi\Arculator_V2.0_Windows\hostfs\rmi"