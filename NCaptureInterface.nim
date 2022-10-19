{.passL: "-s -static-libgcc".}

import winim

## GetInterface function
type interface_fn* = proc (pName: cstring, pReturnCode: int): pointer {.cdecl.}   # change pointer with func type
proc GetInterface*(dllName: cstring, interfaceName: cstring): auto {.cdecl.} =
  let create_interface = cast[interface_fn](GetProcAddress(GetModuleHandleA(dllName), "CreateInterface"))
  return create_interface(interfaceName, 0)
## --------

proc mainThread(lpParameter: LPVOID) =
  AllocConsole()
  discard stdout.reopen("CONOUT$", fmWrite)

  while GetAsyncKeyState(VK_END) == 0:
    echo GetInterface("client.dll", "VClientEntityList003").repr        # return Interface pointer

  stdout.close()
  FreeConsole()
  FreeLibraryAndExitThread(cast[HINSTANCE](lpParameter), 0)

proc NimMain() {.cdecl, importc.}

proc DllMain(hModule: HINSTANCE, reasonForCall: DWORD, lpReserved: LPVOID): WINBOOL {.exportc, dynlib, stdcall.} =
  NimMain()
  if reasonForCall == DLL_PROCESS_ATTACH:
      DisableThreadLibraryCalls(hModule)
      CloseHandle(CreateThread(cast[LPSECURITY_ATTRIBUTES](nil), 0.SIZE_T, cast[LPTHREAD_START_ROUTINE](mainThread), cast[LPVOID](hModule), 0.DWORD, cast[LPDWORD](nil)))
  return TRUE
