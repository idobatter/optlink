		TITLE	SUBS - Copyright (c) SLR Systems 1994

		INCLUDE MACROS

		PUBLIC	OPTI_MOVE_PRESERVE_SIGNIFICANT,MULT_32,SAY_VERBOSE,FLUSH_OUTBUF,MOVESTG,SIGNON,OUT5,HEXWOUT,SAY_VERBOSE_DEBUG
		PUBLIC	HEXTBL,CBTA16,MOVE_ESI_EDI_STG,FORCE_SIGNON,GET_32,OPTI_MOVE_PRESERVE_IGNORE,UPPER_TABLE,LOWER_TABLE
		PUBLIC	OPTI_MOVE_UPPER_IGNORE,MOVE_STG1,OPTI_MOVE_LOWER_IGNORE,CBTA32,HEXDWOUT


		.DATA

		EXTERNDEF	OUTBUF:BYTE,CRLF:BYTE

		EXTERNDEF	CLASS_HASH_TABLE_PTR:DWORD,SEGMENT_HASH_TABLE_PTR:DWORD,GROUP_HASH_TABLE_PTR:DWORD
		EXTERNDEF	MODULE_HASH_TABLE_PTR:DWORD,LOCAL_HASH_TABLE_PTR:DWORD

		EXTERNDEF	OPTI_HASH:DWORD


		.CODE	ROOT_TEXT

		EXTERNDEF	_err_abort:proc,DO_SIGNON:PROC,LOUTALL_CON:PROC

		EXTERNDEF	MUL32_ERR:ABS


FORCE_SIGNON	LABEL	PROC

		SETT	LOGO_OUTPUT

SIGNON		PROC
		;
		;
		;
		GETT	AL,LOGO_OUTPUT
		GETT	AH,SIGNON_DONE

		TEST	AL,AL
		JZ	L9$

		TEST	AH,AH
		JNZ	L9$

		CALL	DO_SIGNON

L9$:
		RET

SIGNON		ENDP


FLUSH_OUTBUF	PROC
		;
		;EAX IS END OF OUTBUF
		;
		LEA	ECX,[EAX+2]
		MOV	DPTR [EAX],0A0DH

		MOV	EAX,OFF OUTBUF

		SUB	ECX,EAX
		JMP	LOUTALL_CON

FLUSH_OUTBUF	ENDP


MOVESTG 	PROC
		;
		;
		;

MOVE_STG1	LABEL	PROC


		PUSH	ESI
		MOV	ESI,ECX

		XOR	ECX,ECX
		PUSH	EDI

		MOV	EDI,EAX
		MOV	CL,[ESI]

		INC	ESI

		OPTI_MOVSB

		MOV	EAX,EDI
		POP	EDI

		POP	ESI

		RET

MOVESTG 	ENDP


MOVE_ESI_EDI_STG	PROC
		XOR	ECX,ECX

		MOV	CL,[ESI]
		INC	ESI

		OPTI_MOVSB

		RET

MOVE_ESI_EDI_STG	ENDP


GET_32		PROC
		;
		;EAX IS POINTER
		;
		MOV	EDX,4[EAX]
		MOV	EAX,[EAX]

MULT_32		LABEL	PROC
		;
		;MULTIPLY CX:BX  BY  DX:AX, RESULT IN DX:AX
		;
		MUL	EDX
		JC	M32_OVER
		RET

M32_OVER:
		MOV	AL,MUL32_ERR
		push	EAX
		call	_err_abort

GET_32		ENDP


OPTI_MOVE_PRESERVE_SIGNIFICANT	PROC
		;
		;HASH, MOVE, PRESERVING CASE, CASE SIGNIFICANT
		;ESI IS INPUT STRING
		;EDI IS OUTPUT STRING
		;EAX IS BYTE COUNT
		;
		PUSH	ECX
		MOV	ECX,EAX

		PUSH	EBX
		XOR	EDX,EDX

		SHR	ECX,2
		JZ	L2$
L1$:
		MOV	EBX,[ESI]
		ADD	ESI,4

		XOR	EDX,EBX
		MOV	[EDI],EBX

		ROL	EDX,4
		DEC	ECX

		LEA	EDI,4[EDI]
		JNZ	L1$
L2$:
		XOR	EBX,EBX
		AND	EAX,3

		JZ	L9$

		MOV	BH,[ESI]
		INC	ESI

		MOV	[EDI],BH
		INC	EDI

		DEC	EAX
		JZ	L8$

		SHL	EBX,16

		MOV	BL,[ESI]
		INC	ESI

		MOV	[EDI],BL
		INC	EDI

		DEC	EAX
		JZ	L7$

		MOV	BH,[ESI]
		INC	ESI

		MOV	[EDI],BH
		INC	EDI
L7$:
		ROR	EBX,16
L8$:
		XOR	EDX,EBX
L9$:
		POP	EBX
		XOR	EAX,EAX
		POP	ECX
		MOV	[EDI],EAX
		INC	EDI
		RET

OPTI_MOVE_PRESERVE_SIGNIFICANT	ENDP


OPTI_HASH_SIGNIFICANT	PROC
		;
		;HASH, MOVE, PRESERVING CASE, CASE SIGNIFICANT
		;ESI IS INPUT STRING
		;EDI IS OUTPUT STRING
		;EAX IS BYTE COUNT
		;
		PUSH	ECX
		MOV	ECX,EAX

		PUSH	EBX
		XOR	EDX,EDX

		SHR	ECX,2
		JZ	L2$
L1$:
		ROL	EDX,4
		MOV	EBX,[ESI]

		ADD	ESI,4
		XOR	EDX,EBX

		DEC	ECX
		JNZ	L1$

		ROL	EDX,4
L2$:
		XOR	EBX,EBX

		AND	EAX,3
		JZ	L9$

		MOV	BH,[ESI]
		INC	ESI

		DEC	EAX
		JZ	L8$

		SHL	EBX,16
		MOV	BL,[ESI]

		INC	ESI
		DEC	EAX

		JZ	L7$

		MOV	BH,[ESI]
		INC	ESI
L7$:
		ROR	EBX,16
L8$:
		XOR	EDX,EBX
L9$:
		POP	EBX
		POP	ECX
		RET

OPTI_HASH_SIGNIFICANT	ENDP


OPTI_HASH_IGNORE	PROC
		;
		;HASH, MOVE, PRESERVING CASE, CASE SIGNIFICANT
		;ESI IS INPUT STRING
		;EDI IS OUTPUT STRING
		;EAX IS BYTE COUNT
		;
		PUSH	ECX
		MOV	ECX,EAX
		PUSH	EBX
		XOR	EDX,EDX
		SHR	ECX,2
		JZ	L2$
L1$:
		MOV	EBX,[ESI]

		ROL	EDX,4
		AND	EBX,0DFDFDFDFH

		ADD	ESI,4
		XOR	EDX,EBX

		DEC	ECX
		JNZ	L1$

		ROL	EDX,4
L2$:
		XOR	EBX,EBX
		AND	EAX,3
		JZ	L9$
		MOV	BH,[ESI]
		INC	ESI
		DEC	EAX
		JZ	L8$
		SHL	EBX,16
		MOV	BL,[ESI]
		INC	ESI
		DEC	EAX
		JZ	L7$
		MOV	BH,[ESI]
		INC	ESI
L7$:
		ROR	EBX,16
L8$:
		AND	EBX,0DFDFDFDFH
		XOR	EDX,EBX
L9$:
		POP	EBX
		POP	ECX
		RET

OPTI_HASH_IGNORE	ENDP


OPTI_MOVE_PRESERVE_IGNORE	PROC
		;
		;HASH, MOVE, PRESERVING CASE, CASE SIGNIFICANT
		;ESI IS INPUT STRING
		;EDI IS OUTPUT STRING
		;EAX IS BYTE COUNT
		;
		PUSH	ECX
		MOV	ECX,EAX
		PUSH	EBX
		XOR	EDX,EDX
		SHR	ECX,2
		JZ	L2$
L1$:
		MOV	EBX,[ESI]

		ROL	EDX,4
		MOV	[EDI],EBX

		ADD	EDI,4
		AND	EBX,0DFDFDFDFH

		ADD	ESI,4
		XOR	EDX,EBX

		DEC	ECX
		JNZ	L1$

		ROL	EDX,4
L2$:
		XOR	EBX,EBX
		AND	EAX,3
		JZ	L9$
		MOV	BH,[ESI]
		INC	ESI
		MOV	[EDI],BH
		INC	EDI
		DEC	EAX
		JZ	L8$
		SHL	EBX,16
		MOV	BL,[ESI]
		INC	ESI
		MOV	[EDI],BL
		INC	EDI
		DEC	EAX
		JZ	L7$
		MOV	BH,[ESI]
		INC	ESI
		MOV	[EDI],BH
		INC	EDI
		DEC	EAX
L7$:
		ROR	EBX,16
L8$:
		AND	EBX,0DFDFDFDFH
		XOR	EDX,EBX
L9$:
		MOV	[EDI],EAX
		INC	EDI
		POP	EBX
		POP	ECX
		RET

OPTI_MOVE_PRESERVE_IGNORE	ENDP


OPTI_MOVE_LOWER_IGNORE	LABEL	PROC
		;
		;
		;
		PUSH	EBX
		MOV	EBX,OFF LOWER_TABLE
		JMP	OPTI_MOVE_CONV

OPTI_MOVE_UPPER_IGNORE	PROC
		;
		;HASH, MOVE, CONVERT TO UPPER OR LOWER, CASE INSIGNIFICANT
		;
		PUSH	EBX
		MOV	EBX,OFF UPPER_TABLE

OPTI_MOVE_CONV	LABEL	PROC

		PUSHM	EDI,EAX

		PUSH	ECX
		XOR	ECX,ECX

		TEST	EAX,EAX
		JZ	L2$
L1$:
		MOV	CL,[ESI]		;01
		INC	EDI

		INC	ESI

		MOV	CL,[ECX+EBX]
		DEC	EAX

		MOV	[EDI-1],CL
		JNZ	L1$
L2$:
		POP	ECX
		MOV	[EDI],EAX

		POPM	EAX,ESI

		POP	EBX

		JMP	OPTI_HASH

OPTI_MOVE_UPPER_IGNORE	ENDP


OUT5		PROC
		;
		;OUTPUT DX:AX IN 5-BYTE FORMAT, TRAILING H & SPACE
		;PRESERVE ALL BUT DI...
		;
		PUSH	EAX
		PUSH	EAX

		SHR	EAX,16

		AND	EAX,0FH
		INC	EDI

		MOV	AL,HEXTBL[EAX]

		MOV	[EDI-1],AL

		POP	EAX
		CALL	HEXWOUT

		POP	EAX
		MOV	DPTR [EDI],' H'
		ADD	EDI,2
		RET

OUT5		ENDP


HEXDWOUT	PROC

		PUSH	EAX

		SHR	EAX,16
		CALL	HEXWOUT

		POP	EAX

HEXDWOUT	ENDP

HEXWOUT		PROC
		;
		;
		;
		PUSH	EBX
		XOR	EBX,EBX

		PUSH	ESI
		MOV	BL,AH

		SHR	BL,4
		MOV	ESI,OFF HEXTBL

		PUSH	EAX
		AND	AH,0FH

		MOV	AL,[EBX+ESI]
		MOV	BL,AH

		MOV	[EDI],AL

		MOV	BL,[EBX+ESI]
		POP	EAX

		MOV	[EDI+1],BL
		MOV	BL,AL

		SHR	AL,4
		AND	BL,0FH

		MOV	AH,[EBX+ESI]
		MOV	BL,AL

		MOV	[EDI+3],AH
		ADD	EDI,4

		MOV	AL,[EBX+ESI]
		POP	ESI

		POP	EBX
		MOV	[EDI-2],AL

		RET

HEXWOUT		ENDP


CBTA32		PROC
		;
		;EAX IS NUMBER TO CONVERT, ECX IS DESTINATION
		;NO LEADING SPACES
		;
		PUSH	EDI
		MOV	EDI,ECX

		PUSH	EBX
		TEST	EAX,0FFFF0000H

		MOV	ECX,10*256	;MAX TEN DIGITS
		JZ	CBTA16A
		;
		;LONG DIVIDE...
		;
		SUB	CH,11
		CALL	ADJUST_PTR

		MOV	EBX,1000000000
		CALL	CBTA32_1

		MOV	EBX,100000000
		CALL	CBTA32_1

		MOV	EBX,10000000
		CALL	CBTA32_1

		MOV	EBX,1000000
		CALL	CBTA32_1

		MOV	EBX,100000
		CALL	CBTA32_1

		JMP	CBTA32_2

CBTA32		ENDP

		public	_cbta16
_cbta16		proc
		mov	EAX,4[ESP]
		mov	ECX,8[ESP]
_cbta16		endp

CBTA16		PROC
		;
		;
		;
		PUSH	EDI
		MOV	EDI,ECX
		PUSH	EBX
CBTA16A::
		AND	EAX,0FFFFH
		MOV	ECX,500H
		;
		;AX IS NUMBER TO CONVERT, DI IS DESTINATION, CH IS COUNT
		;
		;IF AH IS ZERO, JUST DO 8-BIT MATH
		;
		OR	AH,AH
		JZ	CBTA168

		SUB	CH,6
		CALL	ADJUST_PTR		;DO EXTRA LEADING JUNK
CBTA32_2::
		MOV	EBX,10000
		CALL	CBTA32_1
		MOV	EBX,1000
		CALL	CBTA32_1
		JMP	CBTA164

CBTA168:
		;
		;JUST 8-BIT MATH, FIX POINTER AGAIN
		;
		SUB	CH,4
		CALL	ADJUST_PTR
CBTA164:
		MOV	EBX,100
		CALL	CBTA32_1
		XOR	AH,AH
		MOV	BL,10
		CALL	CBTA32_1
		ADD	AL,30H
		POP	EBX
		MOV	[EDI],AL
		LEA	EAX,[EDI+1]
		POP	EDI
		RET

CBTA16		ENDP


CBTA32_1	PROC	NEAR
		;
		;DIVIDE EAX BY EBX
		;
		XOR	EDX,EDX
		CMP	EAX,EBX
		JB	L7$
L1$:
		SUB	EAX,EBX
		INC	EDX
		JNC	L1$
		ADD	EAX,EBX
		DEC	EDX
		MOV	CL,30H
L7$:
		INC	CH
		OR	DL,CL
		JZ	L8$
		OR	CH,CH
		JS	L8$
		MOV	[EDI],DL
		INC	EDI
L8$:
		RET

CBTA32_1	ENDP


ADJUST_PTR	PROC	NEAR
		;
		;
		;
		JS	ADJUST_RET
		OR	CL,CL
		JZ	ADJUST_RET
AP_1:
		MOV	[EDI],CL
		INC	EDI
		DEC	CH
		JNS	AP_1
ADJUST_RET:
		RET

ADJUST_PTR	ENDP


if	fg_cv

		PUBLIC	SAY_CVPACK

SAY_CVPACK	PROC
		;
		;
		;
		MOV	EAX,OFF CVPACKING_MSG
		JMP	SAY_VERBOSE_DEBUG1

SAY_CVPACK	ENDP


endif


SAY_VERBOSE	PROC
		;
		;
		;
		PUSH	ECX
		GETT	CL,INFORMATION_FLAG

		TEST	CL,CL
		JZ	L9$

		POP	ECX

SAY_VERBOSE_DEBUG1	LABEL	PROC

		PUSHM	ECX,EDX

		MOV	CL,[EAX]
		INC	EAX

		AND	ECX,0FFH
		CALL	LOUTALL_CON

		POP	EDX
L9$:
		POP	ECX

		RET

SAY_VERBOSE	ENDP


if	debug
SAY_VERBOSE_DEBUG	EQU	(SAY_VERBOSE_DEBUG1)
else
SAY_VERBOSE_DEBUG	EQU	(SAY_VERBOSE)
endif



;BEGDATA		SEGMENT	PARA PUBLIC	'BEGDATA'

		.DATA

		ALIGN	4

UPPER_TABLE	LABEL	BYTE
		DB	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
		DB	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
		DB	32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
		DB	48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
		DB	64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
		DB	80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95
		DB	96,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
		DB	80,81,82,83,84,85,86,87,88,89,90,123,124,125,126,127
ZZZ	=	128

		REPT	128
		DB	ZZZ
ZZZ = ZZZ+1
		ENDM

LOWER_TABLE	LABEL	BYTE
		DB	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
		DB	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
		DB	32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
		DB	48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
		DB	64,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111
		DB	112,113,114,115,116,117,118,119,120,121,122,91,92,93,94,95
		DB	96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111
		DB	112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
ZZZ	=	128

		REPT	128
		DB	ZZZ
ZZZ = ZZZ+1
		ENDM

HEXTBL		DB	'0123456789ABCDEF'

;BEGDATA		ENDS

;DGROUP		GROUP	BEGDATA

if	fg_cv

CVPACKING_MSG	DB	LENGTH CVPACKING_MSG-1,0dh,0ah,'Running CVPACK...',0DH,0AH

endif

		END

