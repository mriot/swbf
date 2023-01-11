export function fnvHash(input) {
  // Battlefront.exe+1F744B - test cx,cx
  if (input.length <= 0) return 0;

  // Battlefront.exe+1F7450 - mov eax,811C9DC5
  let hash = 0x811c9dc5; // base hash

  for (let i = 0; i < input.length; i++) {
    // Battlefront.exe+1F7458 - xor eax,ecx
    hash ^= input[i];

    // Battlefront.exe+1F745D - imul eax,eax,0x1000193
    hash *= 0x1000193;
  }

  console.log(hash);
  return hash;
}
