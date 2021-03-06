		TITLE LNAMES - Copyright (c) 1994 by SLR Systems

		INCLUDE	MACROS

		PUBLIC	LNAMES,LLNAMES


		.DATA

		EXTERNDEF	END_OF_RECORD:DWORD,BUFFER_OFFSET:DWORD,CURNMOD_GINDEX:DWORD,SYM_HASH_MOD:DWORD

		EXTERNDEF	LNAME_LARRAY:LARRAY_STRUCT

		EXTERNDEF	OPTI_MOVE:DWORD


		.CODE	PASS1_TEXT

		EXTERNDEF	OBJ_PHASE:PROC,DO_DEFINE_MODULE:PROC,LNAME_INSTALL:PROC


LNAMES_VARS	STRUC

SYM_HASHMOD_BP	DD	?
SYMBOL_TP_BP	TPTR_STRUCT<>
		DB	SYMBOL_TEXT_SIZE DUP(?)

LNAMES_VARS	ENDS


FIX	MACRO	X

X	EQU	[EBP].LNAMES_VARS.(X&_BP)

	ENDM

FIX	SYMBOL_TP
FIX	SYM_HASHMOD


LNAMES		PROC		;USES
		;
		;THIS IS RECORD CONTAINING NAME(S) USED BY SEGMENT AND GROUP
		;RECORDS AS NAMES OF SEGMENTS, GROUPS AND/OR CLASSES.
		;
		;INSERT SYMBOL IN NAME TABLE.
		;INSERT POINTER IN LNAME TABLE.
		;REPEAT WHILE MORE NAMES
		;
		;DS:SI IS RECORD POINTER
		;
		;DON'T FORGET TO UPPER CASE IT IF NOT RETAINING SIGNIFICANCE.
		;
		;BY NOW WE KNOW THE MODULE NAME, SEE IF WE NEED TO SCAN
		;DEBUG LIST
		;
		XOR	ECX,ECX
LNAMES_0::
		MOV	EAX,END_OF_RECORD
		MOV	DL,-1

		CMP	EAX,ESI
		JBE	L9$

		PUSH	EBP
                MOV	EAX,SYMBOL_TEXT_SIZE/2 - 4

		LEA	EBP,[ESP - SIZEOF LNAMES_VARS]

                SUB	ESP, (SIZEOF LNAMES_VARS) - SYMBOL_TEXT_SIZE

                SUB	ESP,EAX

                PUSH	EBP

                SUB	ESP,EAX

                PUSH	EBP
		MOV	EAX,CURNMOD_GINDEX

		SETT	ANY_LNAMES,DL
		MOV	SYM_HASHMOD,ECX

		TEST	EAX,EAX
		JNZ	LNAMES_TEST
		;
		;WE NOW KNOW MODULE NAME, CHECK SOME THINGS
		;
		CALL	DO_DEFINE_MODULE
		JMP	LNAMES_TEST

LNAMES_1:
		LEA	EDI,SYMBOL_TP
		ASSUME	EDI:PTR TPTR_STRUCT

		GET_NAME_HASH				;PUT IN SYMBOL_TEXT

		MOV	BUFFER_OFFSET,ESI
		LEA	EAX,SYMBOL_TP

		MOV	ECX,SYM_HASHMOD
		CALL	LNAME_INSTALL			;INSTALL IN NAME TABLE
		;
		;EAX IS INDEX, ECX IS POINTER
		;
		INSTALL_POINTER_LINDEX	LNAME_LARRAY

LNAMES_TEST:
		CMP	END_OF_RECORD,ESI
		JA	LNAMES_1		;IF MORE, LOOP

		MOV	EAX,[EBP + SIZEOF LNAMES_VARS]
		LEA	ESP,[EBP + SIZEOF LNAMES_VARS + 4]

		MOV	EBP,EAX
L9$:
		JNZ	LNAMES_ERROR		;ELSE SHOULD BE EXACT...
		RET

LNAMES_ERROR:
		CALL	OBJ_PHASE
		RET

LNAMES		ENDP


LLNAMES		PROC
		;
		;
		;
		MOV	ECX,CURNMOD_GINDEX

		TEST	ECX,ECX
		JNZ	LNAMES_0
L5$:
		;
		;WE NOW KNOW MODULE NAME, CHECK SOME THINGS
		;
		CALL	DO_DEFINE_MODULE
		JMP	LLNAMES

LLNAMES		ENDP


		END

