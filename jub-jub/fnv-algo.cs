using System;

namespace BattlefrontNameHash {
    class Program {
        static void Main(string[] args) {
            start();
        }

        static void start() {
            Console.Write("Enter a name to generate the hash for: ");
            string input = Console.ReadLine();

            Console.WriteLine("=> Hash for {0} is {1}\n", input, generateHash(input).ToString("X"));
            start();
        }

        static uint generateHash(string input) {
            // Battlefront.exe+1F744B - test cx,cx
            if (input.Length <= 0) return 0;

            // Battlefront.exe+1F7450 - mov eax,811C9DC5
            uint hash = 0x811C9DC5; // base hash

            for (int i = 0; i < input.Length; i++) {
                // Battlefront.exe+1F7458 - xor eax,ecx
                hash ^= input[i];

                /*
                 * Here the third operand (source2) of imul got misinterpreted by the disassembler
                 * it is actually a prime number and not a memory address.
                 * If you add the base address (0x00400000) and 0xC00193, the result is 0x1000193
                 */
                // Battlefront.exe+1F745D - imul eax,eax,Battlefront.exe+C00193
                hash *= 0x1000193;
            }

            return hash;
        }
    }
}
