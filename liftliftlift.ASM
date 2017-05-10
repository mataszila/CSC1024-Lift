	JMP Start;
	DB	25	; Hardware Timer Interrupt Vector
	db	00	; Keyboard Interrupt Vector (unused)
	db	26	; Numeric Keypad Interrupt Vector
	DB 	"UP    "; 
	DB 	"DOWN  ";
	DB	"TOP   ";
	DB	"BOTTOM";

; ----- EXAMPLE - CONTROLLING THE LIFT --------------------------
Start:
	CLO
	sti
	out	08
	out	06
	jmp	DownCheck
	
; ============================

; ===== Hardware Timer =======
	org	25
	iret



; ===== Keyboard Handler =====
	org	26
	CLI			; Prevent re-entrant use
	push	al
	pushf
	in	08
	mov	[be],al		;
	mov	cl,[be]		;[be] ir cl idet 0
	popf
	pop	al		;
	STI
	iret


;----------CHECK IF BOTTOM BUTTON IS PRESSED--------------
DownCheck:
	IN	06		; Read lift status
	AND	AL,10		; Isolate DOWN button bit	
	JZ	UpCheck		; Go to UpCheck Loop if DOWN button not pressed
	MOV	BL,0B		; BL = "D"
	CALL	AA		; Call printing procedure, prints out DOWN
	MOV	AL,2		; Once the printing is done, start going down
	OUT	06		; Reset DOWN button and turn on DOWN motor
;-----------WHILE GOING DOWN-----------------------------------------

CheckIfBottom:
	IN	06		; Read lift status
	AND	AL,EF		; Isolate DOWN button
	OUT	06		; Display lift window
	CMP	AL,0A		; Check if bottom is touched
	JZ	Stop		; If yes -> stop the lift
	JMP	CheckIfBottom	; If not -> repeat the CheckIfBottom loop
;----------CHECK IF TOP BUTTON IS PRESSED
UpCheck:
	
	IN	06		; Read lift status
	AND	AL, 20		; Isolate UP button bit
	JZ	DownCheck	; Loop if UP button not pressed
	MOV	BL,05		; BL = "U"
	CALL	AA		; Call printing procedure, prints out UP

	MOV	AL,1		; Once the printing is done, start going up
	OUT	06		; Reset UP button and turn on UP motor
;-----------WHILE GOING UP-------------------------------------------

CheckIfTop:
	
	IN	08		; Read keyboard status
	CMP	CL,0D		; Check if "Enter" is pressed
	JZ	EnterListener	; If Enter is pressed

;------If enter is not pressed, keep checking if top is touched
	IN	06		; Read lift status
	AND	AL,DF		; Isolate UP button
	CMP	AL,5		; Check if top is touched
	JZ	Stop		; If yes -> stop the lift
	JNZ	CheckIfTop	; If not -> repeat the CheckIfTop loop

;------When Enter is pressed----------
EnterListener:

	MOV	AL,0		; Turn off MOt 
	MOV	CL,0		; Reset CL so it can listen to new keyboard values.
	OUT	06		; Display lift with new AL
GoDown:
	MOV	BL,0B		; BL = "D"
	CALL	AA		; Call printing procedure, prints out "DOWN"
	MOV	AL,1A		; Set up lift bits
	OUT	06		; Start going down
	JMP	CheckIfBottom	; Jump to CheckIfBottom loop
;-----------TURNS OFF THE MOTOR-------------------------------------------
Stop:
	PUSH	AL		; Save AL value
	MOV	AL,0		; Turn off the motor
	OUT	06		; Display lift window with a new AL value
	POP	AL		; Restore AL value


	CMP	AL,0A		; If bottom is touched
	JZ	PrintBottom	; Go to PrintBottom loop

	MOV	BL,11		; If not bottom is touched(means top is touched)
	CALL	AA		; Call the printing procedure	
	JMP	DownCheck	; Go to the starting DownCheck loop

;----------PRINTS OUT "BOTTOM"
PrintBottom:
	MOV	BL,17		; BL = "B"
	CALL	AA		; Call printing procedure, prints out "BOTTOM"
	JMP	DownCheck	; Go to the starting DownCheck loop

;----------PRINTING PROCEDURE-------------------------------------
	ORG	AA	        ;  
        MOV	DL,C0           ;

Print:
	MOV	AL,[BL]		; hardcode content of 2 to AL
				; C0 copy to DL. C0 displays the data
               			; Move contents of AL to CL	
	MOV	[DL],AL		; Move CL value to the contents of DL
	INC	DL		; Increase DL (DL increases as well)
	INC	BL		; Increase BL
	CMP	DL,c6		; Compare DL and C6
	JNZ     Print		; If DL is not C6 already, print again.
 
	RET			; Return to the program



; --------------------------------------------------------------

	

END				;