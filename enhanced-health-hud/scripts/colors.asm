// 2023-01-05
// This script only changes the health-color when we're actually aiming at something.
// This prevents immediate switching to another color when the crosshair is not aiming at something.
// The injection point we're using should have us covered as it only executes
// when there are information such as target health available to display.

// NOTE: symbol "target" is defined in the "enable" script

[ENABLE]
alloc(newmem,2048)
label(returnhere)
label(originalcode)
label(exit)
label(target_is_mate)
label(target_is_neutral)
label(target_is_enemy)
label(update_hud_color)
registersymbol(current_icon_color)
registersymbol(current_icon_color_addr)
registersymbol(current_background_color_addr)
alloc(current_icon_color, 4)
alloc(current_icon_color_addr, 4)
alloc(current_background_color_addr, 4)

// neutral = 0, teammate = 1, enemy = -1
// default red = 20 20 DF FF (BGRA) -> FFDF2020 (ARGB)

newmem:
cmp [target],01
je target_is_mate
cmp [target],-1
je target_is_enemy
jmp target_is_neutral


target_is_mate:
// adjust "red" color to green (ARGB)
mov [007279EC], FF20DF20
//push FF20DF20 // green
push FFEEEEEE // blue-ish background just looks better imo
jmp update_hud_color


target_is_neutral:
// adjust "red" color to blue-ish (ARGB)
mov [007279EC], FF43A7F2
push FF43A7F2
jmp update_hud_color


target_is_enemy:
// restore "red" color (ARGB)
mov [007279EC], FFDF2020
push FFDF2020
jmp update_hud_color


// this changes the health-icon color to match the targets color theme
update_hud_color:
push eax
push ecx
xor eax,eax
xor ecx,ecx

// pointer to icon color
mov eax,["Battlefront.exe"+0035D3E0]
mov eax,[eax+C]
mov eax,[eax+4C]
mov eax,[eax+C]
add eax,107C
// since we want to USE the ADDRESS and *NOT* the VALUE stored at this address,
// we have to use 'add' instead of 'mov'.
// final pointer (eax) + final offset (107C) = address we wanna use

mov ecx,[esp+8] // get color value from stack
mov [eax],ecx // put color value into icon color addr

mov [current_icon_color],ecx      // debug
mov [current_icon_color_addr],eax // debug

// pointer to background color
mov eax,["Battlefront.exe"+0035D3E0]
mov eax,[eax+8]
mov eax,[eax+8]
mov eax,[eax+144]
add eax,125C

mov [eax],ecx // put color value into background color addr

mov [current_background_color_addr],eax // debug

// cleanup
pop ecx
pop eax
add esp,4 // remove our arg (color) from the stack
jmp originalcode


originalcode:
mov ecx,[ecx+000000B8]


exit:
jmp returnhere


"Battlefront.exe"+1980CF:
jmp newmem
nop
returnhere:


[DISABLE]
dealloc(newmem)
dealloc(current_icon_color)
dealloc(current_icon_color_addr)
unregistersymbol(current_icon_color)
unregistersymbol(current_icon_color_addr)
unregistersymbol(current_background_color_addr)

"Battlefront.exe"+1980CF:
mov ecx,[ecx+000000B8]
//Alt: db 8B 89 B8 00 00 00
