// 2023-01-02
// enable health view for all soldiers and destructible objects

[ENABLE]
alloc(newmem,2048)
label(returnhere)
label(originalcode)
label(exit)
registersymbol(target)
alloc(target, 4)

newmem:
// store target in custom symbol (we need it for the color manager script)
push ebx
mov ebx, [eax+30]
mov [target], ebx
pop ebx


originalcode:
// neutral = 0, teammate = 1, enemy = -1
// the game is using "jnl" so by using 2 we should see health hud for all
cmp [eax+30],2
jnl Battlefront.exe+1980E0


exit:
jmp returnhere


"Battlefront.exe"+1980C3:
jmp newmem
returnhere:


[DISABLE]
dealloc(newmem)
dealloc(target)
unregistersymbol(target)

"Battlefront.exe"+1980C3:
cmp [eax+30],ebx
jnl Battlefront.exe+1980E0
//Alt: db 39 58 30 7D 18
