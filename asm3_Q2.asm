TITLE  asm3_Q2.asm
; Chen Gohari 313614414

INCLUDE  Irvine32.inc
INCLUDE asm3_Q2_data.inc

.data
	myName BYTE 'Chen Gohari 313614414', 10, 13, 0
	pathlenMSG BYTE 'The path length is:', 0
	continueMSG BYTE 'Calling check path, returns: ', 0
	pathMSG BYTE 'The path from S to E is: ', 0
	output BYTE 4 dup(?)
	validityStatus SBYTE 0
	res DWORD ?
	recRes DWORD 0 
	BoardT BYTE lengthof Board DUP (?)
	offsetNum DWORD 0
	pathLen DWORD 0
	path BYTE 50 DUP(?)
	x_cord DWORD 0
	y_cord DWORD 0
	pathError SDWORD -1



.code
my_main PROC
	mov edx, OFFSET myName
	call writestring
	
	push OFFSET Board
	push OFFSET BoardT
	mov eax, lengthof Board
	push eax
	call copyBoard
	
	mov  esi, OFFSET BoardT
    mov  ecx, LENGTHOF BoardT
    mov  ebx, TYPE BoardT
    call DumpMem

	mov eax, offset Board
	mov ebx, offset path
	
	push eax
	push ebx
	call findPath
	
	call crlf
	call crlf

	mov edx, OFFSET pathMSG
	call writestring
	mov edx, OFFSET path
	call writestring
	call crlf
	call crlf

	mov edx, OFFSET pathlenMSG
	call writestring
	mov eax, OFFSET pathLen
	mov eax, [eax]
	call writeInt
	call crlf
	call crlf

	
	mov edx, OFFSET continueMSG
	call writestring
	call crlf
	
	push offset BoardT
	push offset path
	call check_path
	mov edx, OFFSET output
	call writestring
	exit
	
my_main ENDP


; fuction for copyBoard
; 	eax = given board
; 	ebx = Destination board
;	ecx = Board length
;	edx = Temp register

copyBoard PROC
	
	push ebp
	mov ebp, esp
	
	push eax
	push ebx
	push ecx
	push edx 
	
	mov eax, [ebp+16] ; board
	mov ebx, [ebp+12] ; boardT
	mov ecx, [ebp+8] ; loop counter
	mov edx, 0

	
	copyLoop:
		mov dl, [eax]
		mov [ebx], dl
		inc eax
		inc ebx
		loop copyLoop
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	
	ret 12
	copyBoard ENDP

; function for findPath from S to E is exists
;	ecx = OFFSET board
;	edx = OFFSET path

findPath PROC
	push ebp
	mov ebp, esp
	
	push ecx
	push edx
	
	mov ecx, [ebp+12]
	mov edx, [ebp+8]
	
	; get start point
	push offset x_cord
	push offset y_cord
	push ecx
	call start_point_search
	
	push ecx
	push x_cord
	push y_cord
	push OFFSET pathLen
	push edx
	call findPath_r
	
	pop edx
	pop ecx
	mov esp, ebp
	pop ebp
	
	ret 8
	findPath ENDP
	
; function for find a path recursivly in the board from S to E is exists
;	eax = x_cord
;	ebx = y_cord
;	ecx = OFFSET pathLen
;	edi = OFFSET Board
;	esi = OFFSET Path
;	edx = Flattened index and a temp register
	
findPath_r PROC
	push ebp
	mov ebp, esp
	
	push eax 
	push ebx 
	push ecx 
	push edx
	push edi
	push esi
	
	mov edx, 0
	mov eax, [ebp + 20]
	mov ebx, [ebp + 16]
	mov ecx, [ebp + 12]
	mov edi, [ebp + 24]
	mov esi, [ebp + 8]
	
	push eax
	push ebx
	push OFFSET validityStatus
	call checkBoundries
	
	mov dl, validityStatus
	push ecx
	mov ecx, 0
	dec ecx
	cmp dl, cl
	pop ecx
	JE blockedCell
	
	push eax
	push ebx
	push OFFSET res
	call cordToNum
	mov edx, res
	
	push eax
	mov eax, 0
	mov al, [edi + edx]
	cmp eax, 'E'
	pop eax
	JE pathFound
	
	push eax
	mov eax, 0
	mov al, [edi + edx]
	cmp eax, 1
	pop eax
	JE blockedCell
	
	
	mov BYTE ptr [edi + edx], 1 ; mark cell as black 
	
	
	; R
	push eax
	push ebx
	mov eax, 0
	mov ebx, 0
	mov eax, 'R'
	mov ebx, [ecx]
	mov [esi + ebx], al

	
	inc ebx
	mov [ecx], ebx
	pop ebx
	pop eax
	
	push offset Board
	inc eax
	push eax
	push ebx
	push ecx
	push offset path	
	call findPath_r
	
	mov edi, OFFSET recRes
	mov edi, [edi]
	cmp edi, pathError
	JNE finishPath
	
	push ebx 
	mov ebx, [ecx]
	dec ebx
	mov [ecx], ebx
	pop ebx
	
	dec eax


	; L
	push eax
	push ebx
	mov eax, 0
	mov eax, 'L'
	mov ebx, [ecx]
	mov [esi + ebx], al
	
	inc ebx
	mov [ecx], ebx
	pop ebx
	pop eax
	
	push offset Board
	dec eax
	push eax
	push ebx
	push ecx
	push offset path
	call findPath_r
	
	mov edi, OFFSET recRes
	mov edi, [edi]
	cmp edi, pathError
	JNE finishPath
	
	push ebx ;
	mov ebx, [ecx]
	dec ebx
	mov [ecx], ebx
	pop ebx
	
	inc eax
	
	; U
	push eax
	push ebx
	mov eax, 0
	mov eax, 'U'
	mov ebx, [ecx]
	mov [esi + ebx], al
	
	inc ebx
	mov [ecx], ebx
	pop ebx
	pop eax
	
	push offset Board
	dec ebx
	push eax
	push ebx
	push ecx
	push offset path
	call findPath_r
	
	mov edi, OFFSET recRes
	mov edi, [edi]
	cmp edi, pathError
	JNE finishPath
	
	push ebx 
	mov ebx, [ecx]
	dec ebx
	mov [ecx], ebx
	pop ebx
	
	inc ebx
	
	; D
	push eax
	push ebx
	mov eax, 0
	mov eax, 'D'
	mov ebx, [ecx]
	mov [esi + ebx], al
	
	inc ebx
	mov [ecx], ebx
	pop ebx
	pop eax
	
	push offset Board
	inc ebx
	push eax
	push ebx
	push ecx
	push offset path
	call findPath_r
	
	mov edi, OFFSET recRes
	mov edi, [edi]
	cmp edi, pathError
	JNE finishPath
	
	push ebx
	mov ebx, [ecx]
	dec ebx
	mov [ecx], ebx
	pop ebx
	
	dec ebx
	
	cmp eax, x_cord
	JE checkY
	JNE dontCheckY
	checkY:
	cmp ebx, y_cord
	JE noPathFound
	dontCheckY:
	JNE finishPath
	
	noPathFound:
	push eax
	push ebx
	mov eax, OFFSET pathLen
	mov ebx, 0
	dec ebx
	mov [eax], ebx
	mov ebx, 0
	mov ebx, OFFSET path
	mov [ebx], byte ptr 0
	pop ebx
	pop eax
	
	blockedCell:
	push ecx
	push edx
	
	mov ecx, OFFSET recRes
	xor edx, edx
	dec edx
	mov [ecx], edx
	
	pop edx
	pop ecx
	JMP finishPath
	
	pathFound:
	push edx
	push ebx
	mov ebx, [ecx]
	mov edx, OFFSET recRes
	mov [edx], ebx
	pop ebx
	pop edx
	JMP finishPath

	
	finishPath:
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	
	ret 20
	
	findPath_r ENDP



; function for checking if a cell is in the boards boundries
;	eax = x_cord
;	ebx = y_cord
;	ecx = Temp register
;	edx = Holds the validityStatus
checkBoundries PROC
	
	push ebp
	mov ebp, esp
	
	push eax 
	push ebx 
	push edx 
	push ecx
	
	mov eax, [ebp + 16]
	mov ebx, [ebp + 12]
	mov edx, [ebp + 8]
	xor ecx, ecx
	mov [edx], ecx
	
	cmp bx, n_rows
	JAE notLegal
	cmp ebx, 0
	JB notLegal
	cmp ax, n_cols
	JAE notLegal
	cmp eax, 0
	JB notLegal
	
	JMP legal
	
	notLegal:
		dec ecx
		mov [edx], ecx
		
	legal:
		pop ecx
		pop edx
		pop ebx 
		pop eax
		mov esp, ebp
		pop ebp
	
	ret 12
	checkBoundries ENDP
	
; Function for returning the correct place in the board
;	eax = x_cord
;	ebx = y_cord
;	ecx = Temp register
;	edx = OFFSET res
cordToNum PROC

	push ebp
	mov ebp, esp
	
	push eax
	push ebx
	push edx
	push ecx
	
	mov eax, [ebp+16] ; x
	mov ebx, [ebp+12] ; y
	mov edx, [ebp+8] ; offset res
	mov ecx, 0
	mov cx, n_cols
	dec ecx
	
	multLoop:
		add ebx, [ebp+12]
		loop multLoop
	
	add ebx, eax
	mov [edx], ebx
	
	pop ecx
	pop edx
	pop ebx ; y
	pop eax ; x
	mov esp, ebp
	pop ebp
	ret 12
	cordToNum ENDP
	
; Function for finding the start point
;	eax = x_cord
;	ebx = y_cord
;	ecx = Temp register
;	edx = Flattened coardinate in the board
; 	esi = Board
start_point_search PROC 

	push ebp
	mov ebp, esp
	
	push eax
	push ebx
	push ecx
	push edx
	push esi
	
	mov esi, [ebp + 8]
	mov eax, 0 ; x
	mov ecx, 0 
	mov ebx, 0 ; y
	mov edx, 0
	findS:
		push eax
		push ebx
		push OFFSET res
		call cordToNum
		mov edx, res
		mov ecx, 0
		mov cl, [esi + edx]
		cmp ecx, 'S'
		JE found
		cmp ax, n_cols
		JAE resetCol
		inc eax
	loop findS
		
	resetCol:
		mov eax, 0
		inc ebx
		JMP findS
		
	found:
		mov edx, 0
		mov edx, [ebp+12]
		mov [edx], ebx
		mov edx, [ebp+16]
		mov [edx], eax
			
		pop esi	
		pop edx
		pop ecx
		pop ebx
		pop eax ; x
		mov esp, ebp
		pop ebp
		
		ret 12
		
		start_point_search ENDP
		
; Function for checking if a given path is correct
;	eax = Path
;	ebx = Path index
;	ecx = Temp register
;	edx = y_cord
;	edi = x_cord
; 	esi = Board
check_path PROC

	push ebp
	mov ebp, esp
	
	push eax 
	push ebx 
	push ecx
	push edx
	push edi
	push esi

	mov eax, [ebp + 8] 
	mov ebx, 0
	mov esi, [ebp + 12]
	
	cmp [eax], byte ptr 0
	JE gotStuck
	
	mov edi, x_cord
	mov edx, y_cord
	push edi 
	push edx
	push OFFSET res
	call cordToNum
	
	check_current_place_in_path:
		mov ecx, 0
		mov cl, [eax + ebx]
		cmp ecx, 0
		JE finished_path
		cmp cl, 'U'
		JE move_up
		cmp cl, 'D'
		JE move_down
		cmp cl, 'L'
		JE move_left
		cmp cl, 'R'
		JE move_right
		loop check_current_place_in_path

	move_up:
		dec edx
		push edi
		push edx
		push offset BoardT
		call pathMoveValidCheck
		mov cl, validityStatus
		push eax
		mov eax, 0
		dec eax
		cmp ecx, eax
		pop eax
		JE gotStuck
		JNE BackToLoop

		
	move_down:
		inc edx
		push edi
		push edx
		push offset BoardT
		call pathMoveValidCheck
		mov cl, validityStatus
		push eax
		mov eax, 0
		dec eax
		cmp ecx, eax
		pop eax
		JE gotStuck
		JNE BackToLoop

	move_right:
		inc edi
		push edi
		push edx
		push offset BoardT
		call pathMoveValidCheck
		mov cl, validityStatus
		push eax
		mov eax, 0
		dec eax
		cmp ecx, eax
		pop eax
		JE gotStuck
		JNE BackToLoop
		
	move_left:
		dec edi
		push edi
		push edx
		push offset BoardT
		call pathMoveValidCheck
		mov cl, validityStatus
		push eax
		mov eax, 0
		dec eax
		cmp ecx, eax
		pop eax
		JE gotStuck
		JNE BackToLoop

	BackToLoop: 
		inc ebx
		JMP check_current_place_in_path
		
	finished_path:
		push edi
		push edx
		push OFFSET res
		call cordToNum
		mov eax, 0
		mov ecx, res
		mov al, [esi + ecx] ; board[res]
		cmp eax, 'E'
		JNE fail
		JE succ

	gotStuck:
		mov output, 'I'
		JMP done

	fail:
		mov output, 'F'
		JMP done
		
	succ:
		mov output, 'S'
		JMP done
		
	done:
		pop esi
		pop edi
		pop edx
		pop ecx
		pop ebx
		pop eax
		mov esp, ebp
		pop ebp

		ret 8

check_path ENDP

; Function for checking if a given path move is correct
;	eax = x_cord
;	ebx = y_cord
;	ecx = Temp register
;	edx = Board
; 	esi = Flattened index
pathMoveValidCheck PROC
		
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi

	mov eax, [ebp + 16]
	mov ebx, [ebp + 12]
	mov edx, [ebp + 8]
	mov esi, 0 

	; check boundries
	cmp bx, n_rows
	JAE illegal_path
	cmp ebx, 0
	JB illegal_path
		
	cmp ax, n_cols
	JAE illegal_path
	cmp eax, 0
	JB illegal_path
	
	; check validity of cell
	mov ecx, 0

	push eax
	push ebx
	push OFFSET res
	call cordToNum
	mov esi, res
	mov cl, [edx + esi]
	cmp ecx, 1
	mov esi, OFFSET validityStatus

	JE illegal_path
	mov byte ptr [esi], 0
	JMP done
	
	illegal_path:
	push ecx
	mov ecx, 0
	dec ecx
	mov [esi], cl
	pop ecx

	done:
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret 12
pathMoveValidCheck ENDP
	
end my_main

