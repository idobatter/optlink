!INCLUDE ..\COMMON\MAKEMACS


FLAGS = $(MASMFLAGS)
SRC = $(BASE)\DLLSTUFF


ALL : $(LIB)\DLLSTUFF.LIB


$(LIB)\DLLSTUFF.LIB : $(OBJ)\LIBENTRY.OBJ $(OBJ)\DLLENTRY.OBJ
  $(BUILD_LIB)

$(OBJ)\LIBENTRY.OBJ : LIBENTRY.ASM ..\COMMON\MACROS
  ML $(FLAGS) $(SRC)\LIBENTRY.ASM

$(OBJ)\DLLENTRY.OBJ : DLLENTRY.ASM ..\COMMON\MACROS ..\COMMON\SYMCMACS ..\COMMON\RELEASE ..\COMMON\WIN32DEF ..\COMMON\WINMACS ..\COMMON\IO_STRUC
  ML $(FLAGS) $(SRC)\DLLENTRY.ASM


