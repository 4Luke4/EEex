
EEex_DisableCodeProtection()

if EEex_Profiler_ForceTracePatches then
	print("Installing profiler patches, please wait...")
	EEex.WriteProfilerHooks()
end

EEex_EnableCodeProtection()
