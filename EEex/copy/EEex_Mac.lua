--[[

Defines all macros used by EEex. Macros give names to assembly bytes, and are used in place
of raw bytes in order to improve the legibility of on-the-fly functions. Unlike labels,
macros have no significance to cross-platform compatibility. More complex assembly solutions
cannot be solved using static byte configurations, thus, macros also support being resolver functions.

EEex_WriteAssembly support =>
1. !macro = Inserts the bytes resolved by the macro into the assembly definition

--]]

EEex_MacroFlag = {
	["OFFSET_SENSITIVE"] = 0,
	["VARIABLE_LENGTH"] = 1,
}

for _, macroEntry in ipairs({
	{"add_eax_byte", "83 C0"},
	{"add_eax_dword", "05"},
	{"add_eax_edx", "03 C2"},
	{"add_eax_esi", "03 C6"},
	{"add_ebx_esi", "03 DE"},
	{"add_edx_esi", "03 D6"},
	{"add_esp_byte", "83 C4"},
	{"add_esp_dword", "81 C4"},
	{"add_esp_eax", "03 E0"},
	{"and_eax_byte", "83 E0"},
	{"and_eax_dword", "25"},
	{"build_stack_frame", "55 8B EC"},
	{"call", "E8"},
	{"call_eax", "FF D0"},
	{"cmove_eax_ebx", "0F 44 C3"},
	{"cmovne_eax_ebx", "0F 45 C3"},
	{"cmovne_eax_edi", "0F 45 C7"},
	{"cmp_[ebp+byte]_byte", "83 7D"},
	{"cmp_[ebp+byte]_ebx", "39 5D"},
	{"cmp_[ecx+byte]_byte", "83 79"},
	{"cmp_[ecx+byte]_esi", "39 71"},
	{"cmp_eax_byte", "83 F8"},
	{"cmp_eax_dword", "3D"},
	{"cmp_eax_ebx", "3B C3"},
	{"cmp_eax_edx", "3B C2"},
	{"cmp_edx_ebx", "3B D3"},
	{"cmp_esi_ebx", "3B F3"},
	{"cmp_esi_edi", "3B F7"},
	{"cmp_esi_edx", "3B F2"},
	{"fild_[esp+byte]", "DB 44 24"},
	{"fild_[esp+dword]", "DB 84 24"},
	{"fild_[esp]", "DB 04 24"},
	{"fstp_qword:[esp+byte]", "DD 5C 24"},
	{"fstp_qword:[esp+dword]", "DD 9C 24"},
	{"fstp_qword:[esp]", "DD 1C 24"},
	{"imul_edx", "F7 EA"},
	{"inc_[ebp+byte]", "FF 45"},
	{"inc_edi", "47"},
	{"inc_edx", "42"},
	{"inc_esi", "46"},
	{"je_byte", "74"},
	{"je_dword", "0F 84"},
	{"jl_byte", "7C"},
	{"jl_dword", "0F 8C"},
	{"jle_byte", "7E"},
	{"jle_dword", "0F 8E"},
	{"jmp_byte", "EB"},
	{"jmp_dword", "E9"},
	{"jne_byte", "75"},
	{"jne_dword", "0F 85"},
	{"lea_eax_[ebp+byte]", "8D 45"},
	{"lea_eax_[ebp+dword]", "8D 85"},
	{"lea_eax_[ebp]", "8D 45 00"},
	{"lea_ebx_[eax+byte]", "8D 58"},
	{"lea_ebx_[eax+dword]", "8D 98"},
	{"lea_ebx_[eax]", "8D 18"},
	{"lea_ecx_[ebp+byte]", "8D 4D"},
	{"lea_ecx_[ebp+dword]", "8D 8D"},
	{"lea_ecx_[ebp]", "8D 4D 00"},
	{"lea_edi_[eax+byte]", "8D 78"},
	{"lea_edi_[eax+dword]", "8D B8"},
	{"lea_edi_[eax]", "8D 78 00"},
	{"mov_[ebp+byte]_dword", "C7 45"},
	{"mov_[ebp+byte]_eax", "89 45"},
	{"mov_[ebp+byte]_ecx", "89 4D"},
	{"mov_[ebp+byte]_edi", "89 7D"},
	{"mov_[ebp+byte]_esp", "89 65"},
	{"mov_[ebp+dword]_dword", "C7 85"},
	{"mov_[ebp+dword]_edi", "89 BD"},
	{"mov_[ebp+dword]_esp", "89 A5"},
	{"mov_[ebp]_dword", "C7 45 00"},
	{"mov_[ebp]_edi", "89 7D 00"},
	{"mov_[ebp]_esp", "89 65 00"},
	{"mov_[edi+byte]_al", "88 47"},
	{"mov_[edi+byte]_byte", "C6 47"},
	{"mov_[edi+byte]_dword", "C7 47"},
	{"mov_[edi+byte]_eax", "89 47"},
	{"mov_[edi+dword]_al", "88 87"},
	{"mov_[edi+dword]_byte", "C6 87"},
	{"mov_[edi+dword]_dword", "C7 87"},
	{"mov_[edi+dword]_eax", "89 87"},
	{"mov_[edi]_al", "88 07"},
	{"mov_[edi]_byte", "C6 07"},
	{"mov_[edi]_dword", "C7 47 00"},
	{"mov_[edi]_eax", "89 47 00"},
	{"mov_al_[esi+byte]", "8A 46"},
	{"mov_al_[esi+dword]", "8A 86"},
	{"mov_al_[esi]", "8A 46 00"},
	{"mov_eax", "B8"},
	{"mov_eax_[dword]", "A1"},
	{"mov_eax_[eax+dword]", "8B 80"},
	{"mov_eax_[ebp+byte]", "8B 45"},
	{"mov_eax_[ebp+dword]", "8B 85"},
	{"mov_eax_[ebp]", "8B 45 00"},
	{"mov_eax_[edi]", "8B 07"},
	{"mov_eax_[esi+byte]", "8B 46"},
	{"mov_eax_[esi+dword]", "8B 86"},
	{"mov_eax_[esi]", "8B 46 00"},
	{"mov_eax_edx", "8B C2"},
	{"mov_ebx_eax", "8B D8"},
	{"mov_ebx_esp", "8B DC"},
	{"mov_ecx_[ebp+byte]", "8B 4D"},
	{"mov_ecx_[edx+byte]", "8B 4A"},
	{"mov_ecx_[edx+dword]", "8B 8A"},
	{"mov_ecx_[edx]", "8B 4A 00"},
	{"mov_ecx_edi", "8B CF"},
	{"mov_edi_[ebp+byte]", "8B 7D"},
	{"mov_edi_[ebp+dword]", "8B BD"},
	{"mov_edi_[ebp]", "8B 7D 00"},
	{"mov_edi_eax", "8B F8"},
	{"mov_edi_esp", "8B FC"},
	{"mov_edx", "BA"},
	{"mov_edx_[ebx+byte]", "8B 53"},
	{"mov_edx_[ebx+dword]", "8B 93"},
	{"mov_edx_[ebx]", "8B 53 00"},
	{"mov_edx_[edi+byte]", "8B 57"},
	{"mov_edx_[edi+dword]", "8B 97"},
	{"mov_edx_[edi]", "8B 57 00"},
	{"mov_edx_[edx+byte]", "8B 52"},
	{"mov_edx_[edx+dword]", "8B 92"},
	{"mov_edx_[edx]", "8B 52 00"},
	{"mov_edx_eax", "8B D0"},
	{"mov_esi", "BE"},
	{"mov_esi_eax", "8B F0"},
	{"mov_esp_[ebp+byte]", "8B 65"},
	{"mov_esp_[ebp+dword]", "8B A5"},
	{"mov_esp_[ebp]", "8B 65 00"},
	{"movzx_esi_word:[ebp-byte]", "0F B7 75"},
	{"nop", "90"},
	{"pop_eax", "58"},
	{"pop_ecx", "59"},
	{"pop_state", "5F 5E 5A 59 5B 5D"},
	{"push_[dword]", "FF 35"},
	{"push_[ebp+byte]", "FF 75"},
	{"push_[ebp+dword]", "FF B5"},
	{"push_[ebp]", "FF 75 00"},
	{"push_[edi+byte]", "FF 77"},
	{"push_byte", "6A"},
	{"push_dword", "68"},
	{"push_eax", "50"},
	{"push_ecx", "51"},
	{"push_edi", "57"},
	{"push_edx", "52"},
	{"push_esi", "56"},
	{"push_registers", "53 51 52 56 57"},
	{"push_state", "55 8B EC 53 51 52 56 57"},
	{"restore_stack_frame", "5F 5E 5A 59 5B 8B E5 5D"},
	{"ret", "C3"},
	{"ret_word", "C2"},
	{"shl_edx", "C1 E2"},
	{"shr_eax", "C1 E8"},
	{"sub_esp_byte", "83 EC"},
	{"sub_esp_dword", "81 EC"},
	{"sub_esp_eax", "2B E0"},
	{"sub_esp_edx", "2B E2"},
	{"test_[ecx+byte]_byte", "F6 41"},
	{"test_[ecx+dword]_byte", "F6 81"},
	{"test_[ecx]_byte", "F6 41 00"},
	{"test_al_al", "84 C0"},
	{"test_eax_eax", "85 C0"},
	{"test_edi_edi", "85 FF"},
	{"test_edx_edx", "85 D2"},
	{"xor_eax_eax", "33 C0"},
	{"xor_ebx_ebx", "33 DB"},
	--[[
	{"je", {
		["write"] = function(currentWriteAddress, macroArgs, func)
			local targetAddress = macroArgs[1]
			local targetOffset = targetAddress - currentWriteAddress
			-- Using decimal checks, because unlike assembly,
			-- lua's hex values aren't in 2's complement.
			if targetOffset >= -128 and targetOffset <= 127 then
				func(currentWriteAddress, 0x74)
				func(currentWriteAddress + 1, targetOffset + 2)
				return 2
			else
				func(currentWriteAddress, 0x0F)
				func(currentWriteAddress + 1, 0x84)
				for i = 0, 3, 1 do
					local byte = bit32.extract(targetOffset, i * 8, 8)
					func(currentWriteAddress + 2 + i, byte)
				end
				return 6
			end
		end,
		["validate"] = function(currentWriteAddress, macroArgs, func)

		end,
		["flags"] = {
			EEex_MacroFlag.OFFSET_SENSITIVE,
			EEex_MacroFlag.VARIABLE_LENGTH,
		},
	}},-
	-]]
})
do
	local macroName = macroEntry[1]
	local macroValue = macroEntry[2]
	EEex_DefineAssemblyMacro(macroName, macroValue)
end
