		TITLE	COMPRELE - Copyright (c) SLR Systems 1994

		INCLUDE MACROS

if	fg_slrpack

if	fgh_win32
		INCLUDE	WIN32DEF
endif

		PUBLIC	RELEASE_LARGE_SEGMENT


		.DATA

		EXTERNDEF	SEG_RELEASED_128K:DWORD,SEG_RELEASED_256K:DWORD


		.CODE	ROOT_TEXT

		EXTERNDEF	RELEASE_SEGMENT:PROC,_seg_released:proc,FORCE_RELEASE_SEGMENT:PROC,OOM_ERROR:PROC
		externdef	_release_large_segment:proc


if	fgh_dosx

RELEASE_LARGE_SEGMENT	PROC
		;
		;
		;
		CMP	ECX,256K
		JZ	RELEASE_256K_SEGMENT

		CMP	ECX,128K
		JNZ	OOM_ERROR

		MOV	SEG_RELEASED_128K,EAX

		RET

RELEASE_256K_SEGMENT:
		;
		;
		;
		MOV	SEG_RELEASED_256K,EAX

		RET

RELEASE_LARGE_SEGMENT	ENDP

endif

if	fgh_win32

RELEASE_LARGE_SEGMENT	PROC
		;
		;
		;
		PUSHM	EDX,ECX

		push	EAX
		call	_release_large_segment
		add	ESP,4

;		PUSH	MEM_RELEASE
;		PUSH	0		;RELEASE ALL

;		PUSH	EAX
;		CALL	VirtualFree

;		TEST	EAX,EAX
;		JZ	_seg_released

		POPM	ECX,EDX

		RET

RELEASE_LARGE_SEGMENT	ENDP

endif

endif

		END

