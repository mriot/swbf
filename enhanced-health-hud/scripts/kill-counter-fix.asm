; 2022-01-02
; make negative kills flash in red

[ENABLE]
alloc(newmem,2048)
label(returnhere)
label(exit)

newmem:
mov ecx,FFDF2020 ; red

exit:
jmp returnhere

"Battlefront.exe"+1A405A:
jmp newmem
nop
returnhere:


[DISABLE]
dealloc(newmem)
"Battlefront.exe"+1A405A:
mov ecx,[Battlefront.exe+3279EC]
;Alt: db 8B 0D EC 79 72 00
