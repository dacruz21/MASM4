set projectName=MASM4
del *.obj *exe *lst *pdb *ilk
\masm32\bin\ml /c /coff String1.asm
\masm32\bin\ml /c /coff String2.asm
\masm32\bin\ml /c /coff %projectName%.asm
\masm32\bin\Link /SUBSYSTEM:CONSOLE /out:%projectName%.exe String1.obj String2.obj %projectName%.obj \masm32\lib\kernel32.lib ..\..\macros\convutil201604.obj ..\..\macros\io.obj ..\..\macros\utility201609.obj
%projectName%
pause