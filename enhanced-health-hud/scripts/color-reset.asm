; 2023-01-02
; this script resets the "red" color on map load before it gets accessed to prevent
; weird things like wrong colors for command posts etc.

[ENABLE]
alloc(newmem,2048)
label(returnhere)
label(originalcode)
label(exit)

newmem:
; restore "red" color
mov [007279EC], FFDF2020 ; ARGB


originalcode:
mov eax,[Battlefront.exe+3279EC]


exit:
jmp returnhere


"Battlefront.exe"+197B85:
jmp newmem
returnhere:

 
[DISABLE]
dealloc(newmem)
"Battlefront.exe"+197B85:
mov eax,[Battlefront.exe+3279EC]
;Alt: db A1 EC 79 72 00
