@echo off
set VbScript=U:\deal68\Util\SendEmail.vbs
Set VbApp=%SystemRoot%\System32\CScript.exe

call %VbApp% %VbScript% %1 %2 %3 %4