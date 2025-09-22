.MODEL SMALL
.STACK 100h

.DATA
    ; Room Structure: [Status][Type][Price_Low][Price_High][Service_Low][Service_High]
    ; Status: 0=Vacant, 1=Occupied, 2=Unavailable
    ; Type: 1=Single, 2=Double, 3=Suite
    
    MAX_ROOMS      EQU 9
    ROOM_SIZE      EQU 6        ; 6 bytes per room structure
    
    ; Room array - each room is 6 bytes
    rooms          DB MAX_ROOMS * ROOM_SIZE DUP(0)
    room_count     DB 5         ; Initially 5 rooms
    
    ; Messages
    welcome_msg    DB 10,13,'=== HOTEL MANAGEMENT SYSTEM ===',10,13,'$'
    menu_msg       DB 10,13,'1. Check-in',10,13
                   DB '2. Check-out',10,13
                   DB '3. Add Room',10,13
                   DB '4. Remove Room',10,13
                   DB '5. View Room Status',10,13
                   DB '6. Book Room',10,13
                   DB '7. View Billing',10,13
                   DB '8. Order Room Service',10,13
                   DB '9. Exit',10,13
                   DB 'Choose option: $'
    
    prompt_room    DB 10,13,'Enter room number (1-9):$'
    prompt_type    DB 10,13,'Enter room type (1=Single, 2=Double, 3=Suite): $'
    ; prompt_price   DB 10,13,'Enter price per night (max 3 digits): $'
    prompt_days    DB 10,13,'Enter number of days: $'
    prompt_service DB 10,13,'Enter service charge: $'
    
    msg_success    DB 10,13,'Operation successful!',10,13,'$'
    msg_error      DB 10,13,'Error: Invalid operation!',10,13,'$'
    msg_occupied   DB 10,13,'Room is occupied!',10,13,'$'
    msg_vacant     DB 10,13,'Room is vacant!',10,13,'$'
    msg_unavail    DB 10,13,'Room is unavailable!',10,13,'$'
    msg_invalid    DB 10,13,'Invalid room number!',10,13,'$'
    msg_max_rooms  DB 10,13,'Cannot add more rooms! Maximum is 9.',10,13,'$'
    msg_invalid_type DB 10,13,'Invalid room type! (1=Single, 2=Double, 3=Suite)',10,13,'$'
    
    room_status_hdr DB 10,13,'Room Status:',10,13
                    DB 'Room  Type      Status     Price   Services',10,13
                    DB '----  ----      ------     -----   --------',10,13,'$'
    room_vac        DB 'Vacant $'
    room_occ        DB 'Occupied $'
    room_unv        DB 'Unavailable $'
    room_unk        DB 'Unknown $'
    room_sin        DB 'Single $'
    room_dou        DB 'Double $'
    room_sui        DB 'Suite  $'
    
    billing_hdr    DB 10,13,'Billing Information:',10,13
                   DB 'Room: $'
    billing_invday DB 'Error: Invalid days $'
    billing_rmcst  DB 'Room cost: $'
    billing_srvc   DB 'Service:   $'
    billing_total  DB 'Total:     $'
    
    
    newline        DB 10,13,'$'
    space          DB ' $'
    
    ; Temporary variables
    temp_room      DB 0
    temp_type      DB 0
    temp_price     DW 0
    temp_days      DB 0
    temp_service   DW 0
    input_buffer   DB 10 DUP(0)

.CODE

; ============= MACROS =============

; Display string macro
DISPLAY_STRING MACRO msg
    LEA DX, msg
    MOV AH, 09h
    INT 21h
ENDM

; Get single character input
GET_CHAR MACRO
    MOV AH, 01h
    INT 21h
ENDM

; Display single character
DISPLAY_CHAR MACRO char
    MOV DL, char
    MOV AH, 02h
    INT 21h
ENDM

; Get number input macro
GET_NUMBER MACRO
    CALL read_number
ENDM

; ============= MAIN PROGRAM =============

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Initialize hotel with default rooms
    CALL init_hotel
    
    ; Display welcome message
    DISPLAY_STRING welcome_msg
    
main_loop:
    ; Display menu
    DISPLAY_STRING menu_msg
    
    ; Get user choice
    GET_CHAR
    SUB AL, '0'     ; Convert to number
    
    ; Process menu choice
    CMP AL, 1
    JE do_checkin
    CMP AL, 2
    JE do_checkout
    CMP AL, 3
    JE do_add_room
    CMP AL, 4
    JE do_remove_room
    CMP AL, 5
    JE do_view_status
    CMP AL, 6
    JE do_booking
    CMP AL, 7
    JE do_billing
    CMP AL, 8
    JE do_room_service
    CMP AL, 9
    JE exit_program
    
    ; Invalid choice
    DISPLAY_STRING msg_error
    JMP main_loop

do_checkin:
    CALL checkin_proc
    JMP main_loop

do_checkout:
    CALL checkout_proc
    JMP main_loop

do_add_room:
    CALL add_room_proc
    JMP main_loop

do_remove_room:
    CALL remove_room_proc
    JMP main_loop

do_view_status:
    CALL view_status_proc
    JMP main_loop

do_booking:
    CALL booking_proc
    JMP main_loop

do_billing:
    CALL billing_proc
    JMP main_loop

do_room_service:
    CALL room_service_proc
    JMP main_loop

exit_program:
    MOV AH, 4Ch
    INT 21h

MAIN ENDP

; ============= INITIALIZATION PROCEDURE =============

init_hotel PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    ; Initialize 5 default rooms
    LEA SI, rooms
    
    ; Room 1: Single, $50, Vacant
    MOV BYTE PTR [SI], 0      ; Status: Vacant
    MOV BYTE PTR [SI+1], 1    ; Type: Single
    MOV WORD PTR [SI+2], 50   ; Price: $50
    MOV WORD PTR [SI+4], 0    ; Service charges: $0
    ADD SI, ROOM_SIZE
    
    ; Room 2: Double, $80, Vacant
    MOV BYTE PTR [SI], 0      ; Status: Vacant
    MOV BYTE PTR [SI+1], 2    ; Type: Double
    MOV WORD PTR [SI+2], 80   ; Price: $80
    MOV WORD PTR [SI+4], 0    ; Service charges: $0
    ADD SI, ROOM_SIZE
    
    ; Room 3: Suite, $150, Vacant
    MOV BYTE PTR [SI], 0      ; Status: Vacant
    MOV BYTE PTR [SI+1], 3    ; Type: Suite
    MOV WORD PTR [SI+2], 150  ; Price: $150
    MOV WORD PTR [SI+4], 0    ; Service charges: $0
    ADD SI, ROOM_SIZE
    
    ; Room 4: Single, $50, Vacant
    MOV BYTE PTR [SI], 0      ; Status: Vacant
    MOV BYTE PTR [SI+1], 1    ; Type: Single
    MOV WORD PTR [SI+2], 50   ; Price: $50
    MOV WORD PTR [SI+4], 0    ; Service charges: $0
    ADD SI, ROOM_SIZE
    
    ; Room 5: Double, $80, Vacant
    MOV BYTE PTR [SI], 0      ; Status: Vacant
    MOV BYTE PTR [SI+1], 2    ; Type: Double
    MOV WORD PTR [SI+2], 80   ; Price: $80
    MOV WORD PTR [SI+4], 0    ; Service charges: $0
    
    POP SI
    POP CX
    POP BX
    POP AX
    RET
init_hotel ENDP

; ============= CHECK-IN PROCEDURE =============

checkin_proc PROC
    PUSH AX
    PUSH BX
    PUSH SI
    
    DISPLAY_STRING prompt_room
    GET_NUMBER
    MOV temp_room, AL
    
    ; Use get_room_address for validation
    CALL get_room_address
    CMP SI, 0FFFFh
    JE invalid_room
    
    CMP BYTE PTR [SI], 0      ; Check if vacant
    JNE room_not_vacant
    
    ; Mark room as occupied
    MOV BYTE PTR [SI], 1
    DISPLAY_STRING msg_success
    JMP checkin_end

room_not_vacant:
    DISPLAY_STRING msg_occupied
    JMP checkin_end

invalid_room:
    DISPLAY_STRING msg_invalid

checkin_end:
    POP SI
    POP BX
    POP AX
    RET
checkin_proc ENDP

; ============= CHECK-OUT PROCEDURE =============

checkout_proc PROC
    PUSH AX
    PUSH BX
    PUSH SI
    
    DISPLAY_STRING prompt_room
    GET_NUMBER
    MOV temp_room, AL
    
    ; Use get_room_address for validation
    CALL get_room_address
    CMP SI, 0FFFFh
    JE invalid_room_co
    
    CMP BYTE PTR [SI], 1      ; Check if occupied
    JNE room_not_occupied
    
    ; Mark room as vacant and clear services
    MOV BYTE PTR [SI], 0
    MOV WORD PTR [SI+4], 0    ; Clear service charges
    DISPLAY_STRING msg_success
    JMP checkout_end

room_not_occupied:
    DISPLAY_STRING msg_vacant
    JMP checkout_end

invalid_room_co:
    DISPLAY_STRING msg_invalid

checkout_end:
    POP SI
    POP BX
    POP AX
    RET
checkout_proc ENDP

; ============= ADD ROOM PROCEDURE (MODIFIED) =============

add_room_proc PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    ; Check if we can add more rooms
    MOV AL, room_count
    CMP AL, MAX_ROOMS
    JGE max_rooms_reached
    
    DISPLAY_STRING prompt_type
    GET_NUMBER                 ; Still uses single-digit GET_NUMBER for type
    MOV temp_type, AL
    
    ; Validate room type
    CMP AL, 1
    JL invalid_type
    CMP AL, 3
    JG invalid_type
    
    ; --- Assign default price based on room type ---
    MOV AX, 0 ; Clear AX
    CMP temp_type, 1
    JE assign_single_price
    CMP temp_type, 2
    JE assign_double_price
    CMP temp_type, 3
    JE assign_suite_price
    JMP invalid_type ; Should ideally not be reached if validation above is good
    
assign_single_price:
    MOV AX, 50
    JMP price_assigned
    
assign_double_price:
    MOV AX, 80
    JMP price_assigned
    
assign_suite_price:
    MOV AX, 150
    JMP price_assigned

price_assigned:
    ; AX now holds the default price for the chosen room type
    ; temp_price is no longer directly used for price input, but for consistency we'll store it.
    MOV temp_price, AX ; Store in temp_price just in case, though AX goes directly to memory
    
    ; Add new room to the end of the array
    MOV AL, room_count
    MOV AH, 0
    MOV BL, ROOM_SIZE
    MUL BL                    ; AX = offset for new room
    LEA SI, rooms
    ADD SI, AX                ; SI points to the new room's location
    
    ; Set room data
    MOV BYTE PTR [SI], 0          ; Status: Vacant
    MOV AL, temp_type
    MOV BYTE PTR [SI+1], AL       ; Type
    MOV AX, temp_price            ; Reload price from temp_price (which now holds the default)
    MOV WORD PTR [SI+2], AX       ; Price
    MOV WORD PTR [SI+4], 0        ; Service charges
    
    ; Increment room count
    INC room_count
    
    DISPLAY_STRING msg_success
    JMP add_room_end

max_rooms_reached:
    DISPLAY_STRING msg_max_rooms
    JMP add_room_end

invalid_type:
    DISPLAY_STRING msg_invalid_type

add_room_end:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
add_room_proc ENDP

; ============= REMOVE ROOM PROCEDURE =============

remove_room_proc PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    PUSH SI
    
    DISPLAY_STRING prompt_room
    GET_NUMBER
    MOV temp_room, AL ; temp_room now holds the 1-based room number
    
    ; Use get_room_address to validate room number and get its memory address
    ; get_room_address checks if temp_room is 1-based and <= room_count
    CALL get_room_address    ; SI will point to the room, or 0FFFFh if invalid
    CMP SI, 0FFFFh
    JE invalid_room_rm_ext   ; This branch handles invalid room numbers or rooms beyond current room_count
    
    ; At this point, SI points to the start of the room structure to remove
    ; temp_room holds the 1-based index of the room to remove.

    ; Determine if it's the last room or if shifting is needed
    MOV AL, room_count
    CMP temp_room, AL       ; Is temp_room (1-based) equal to room_count (total 1-based)?
    JE remove_last_room_only ; If yes, it's the last room, no shifting needed

    ; --- If not the last room, perform shifting ---
    ; For overlapping memory regions, we need to move from high to low addresses
    ; to avoid overwriting data we haven't moved yet
    
    ; Calculate number of rooms to move
    MOV AL, room_count      ; AL = total room count
    SUB AL, temp_room       ; AL = number of rooms *after* the one being removed
    CMP AL, 0               ; If no rooms after, skip shifting
    JE remove_last_room_only
    
    MOV AH, 0
    MOV BL, ROOM_SIZE       ; BL = 6
    MUL BL                  ; AX = total bytes to shift
    MOV CX, AX              ; CX = number of bytes to move
    
    ; Set up source and destination for memory move
    ; We move from the room after the deleted one to overwrite the deleted room
    MOV DI, SI              ; DI points to the room to remove (destination)
    ADD SI, ROOM_SIZE       ; SI points to the *next* room (source)
    
    ; For proper overlapping memory handling, use MOVSB with forward direction
    PUSH DS                 ; Save DS register
    POP ES                  ; Set ES = DS for MOVSB
    CLD                     ; Clear direction flag (move forward)
    REP MOVSB               ; Move CX bytes from [DS:SI] to [ES:DI]

    ; Fall through to decrement_room_count

remove_last_room_only:
    ; No data shifting needed if it was the last room, just decrement room_count
decrement_room_count:
    DEC room_count
    DISPLAY_STRING msg_success
    JMP remove_room_end

invalid_room_rm_ext:
    DISPLAY_STRING msg_invalid

remove_room_end:
    POP SI
    POP DI
    POP CX
    POP BX
    POP AX
    RET
remove_room_proc ENDP

; ============= VIEW STATUS PROCEDURE (FIXED) =============

view_status_proc PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    DISPLAY_STRING room_status_hdr
    
    MOV BL, 1               ; BL = Room counter (1-based for display)
    LEA SI, rooms           ; SI points to the beginning of the rooms array
    
status_loop:
    MOV AL, room_count      ; Load current room count
    CMP BL, AL              ; Compare current room number with total rooms
    JG status_loop_end      ; Exit if we've displayed all active rooms

    ; Display room number
    MOV AL, BL
    ADD AL, '0'
    DISPLAY_CHAR AL
    DISPLAY_STRING space
    DISPLAY_STRING space
    DISPLAY_STRING space
    DISPLAY_STRING space
    
    ; Display room type
    MOV AL, [SI+1]
    CMP AL, 1
    JE type_single
    CMP AL, 2
    JE type_double
    CMP AL, 3
    JE type_suite
    JMP display_unknown_type

type_single:
    DISPLAY_STRING room_sin
    JMP display_status_pad

type_double:
    DISPLAY_STRING room_dou
    JMP display_status_pad

type_suite:
    DISPLAY_STRING room_sui
    JMP display_status_pad

display_unknown_type:
    DISPLAY_STRING room_unk

display_status_pad:
    DISPLAY_STRING space
    DISPLAY_STRING space
    DISPLAY_STRING space
    DISPLAY_STRING space
    
    ; Display status
    MOV AL, [SI]
    CMP AL, 0
    JE status_vacant
    CMP AL, 1
    JE status_occupied
    CMP AL, 2
    JE status_unavail
    JMP status_unknown

status_vacant:
    DISPLAY_STRING room_vac
    DISPLAY_STRING space
    DISPLAY_STRING space
    JMP display_price_pad

status_occupied:
    DISPLAY_STRING room_occ
    JMP display_price_pad

status_unavail:
    DISPLAY_STRING room_unv
    JMP display_price_pad

status_unknown:
    DISPLAY_STRING room_unk

display_price_pad:
    DISPLAY_STRING space
    DISPLAY_STRING space
    DISPLAY_STRING space
    DISPLAY_STRING space
    
    ; Display price 
    MOV AX, [SI+2]
    CALL print_number
    
    DISPLAY_STRING space
    DISPLAY_STRING space
    DISPLAY_STRING space
    DISPLAY_STRING space
    
    ; Display service charges
    MOV AX, [SI+4]
    CALL print_number
    
    DISPLAY_STRING newline

    ; Move to next room
    ADD SI, ROOM_SIZE       ; Move to the next room's data
    INC BL                  ; Increment display room number
    JMP status_loop
    
status_loop_end:
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
view_status_proc ENDP

; ============= BOOKING PROCEDURE =============

booking_proc PROC
    PUSH AX
    PUSH SI
    
    DISPLAY_STRING prompt_room
    GET_NUMBER
    MOV temp_room, AL
    
    CALL get_room_address
    CMP SI, 0FFFFh
    JE invalid_room_book
    
    CMP BYTE PTR [SI], 0      ; Check if vacant
    JNE room_not_available
    
    ; Mark room as booked (occupied for simplicity)
    MOV BYTE PTR [SI], 1
    DISPLAY_STRING msg_success
    JMP booking_end

room_not_available:
    DISPLAY_STRING msg_occupied
    JMP booking_end

invalid_room_book:
    DISPLAY_STRING msg_invalid

booking_end:
    POP SI
    POP AX
    RET
booking_proc ENDP

; ============= BILLING PROCEDURE (FIXED) =============

billing_proc PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    DISPLAY_STRING prompt_room
    GET_NUMBER
    MOV temp_room, AL
    
    CALL get_room_address
    CMP SI, 0FFFFh
    JE invalid_room_bill
    
    CMP BYTE PTR [SI], 1      ; Check if occupied
    JNE room_not_occupied_bill
    
    ; Display billing header
    DISPLAY_STRING billing_hdr
    MOV AL, temp_room
    ADD AL, '0'
    DISPLAY_CHAR AL
    
    
    ; Get number of days
    DISPLAY_STRING prompt_days
    GET_NUMBER
    MOV temp_days, AL
    
    ; Validate days input (1-9 for single digit)
    CMP AL, 0
    JLE invalid_days_bill
    CMP AL, 9
    JG invalid_days_bill
    
    ; Calculate room cost: days * room_price
    MOV AL, temp_days         ; AL = number of days
    MOV AH, 0                 ; Clear AH for 16-bit math
    MOV BX, [SI+2]            ; BX = room price per night
    MUL BX                    ; AX = days * price_per_night
    MOV CX, AX                ; Save room cost in CX
    
    ; Add service charges
    MOV AX, [SI+4]            ; AX = service charges
    ADD AX, CX                ; AX = room_cost + service_charges
    
    ; Display itemized bill
    DISPLAY_STRING newline
    DISPLAY_STRING newline
    DISPLAY_STRING billing_rmcst
    DISPLAY_CHAR '$'
    MOV AX, CX                ; Display room cost
    CALL print_number
    DISPLAY_STRING newline
    
    DISPLAY_STRING billing_srvc
    DISPLAY_CHAR '$'
    MOV AX, [SI+4]            ; Display service charges
    CALL print_number
    
    ; Display total
    DISPLAY_STRING newline
    DISPLAY_STRING billing_total
    DISPLAY_CHAR '$'
    MOV AX, CX                ; Total = room_cost + service_charges
    ADD AX, [SI+4]
    CALL print_number
    DISPLAY_STRING newline
    JMP billing_end

invalid_days_bill:
    DISPLAY_STRING newline
    DISPLAY_STRING billing_invday
    DISPLAY_STRING newline
    JMP billing_end

room_not_occupied_bill:
    DISPLAY_STRING msg_vacant
    JMP billing_end

invalid_room_bill:
    DISPLAY_STRING msg_invalid

billing_end:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
billing_proc ENDP

; ============= ROOM SERVICE PROCEDURE =============

room_service_proc PROC
    PUSH AX
    PUSH BX
    PUSH SI
    
    DISPLAY_STRING prompt_room
    GET_NUMBER
    MOV temp_room, AL
    
    CALL get_room_address
    CMP SI, 0FFFFh
    JE invalid_room_service
    
    CMP BYTE PTR [SI], 1      ; Check if occupied
    JNE room_not_occupied_service
    
    ; Get service charge
    DISPLAY_STRING prompt_service
    CALL read_multi_digit_number ; Use multi-digit reader for service charge
    
    ; Add to existing service charges
    ADD [SI+4], AX
    
    DISPLAY_STRING msg_success
    JMP service_end

room_not_occupied_service:
    DISPLAY_STRING msg_vacant
    JMP service_end

invalid_room_service:
    DISPLAY_STRING msg_invalid

service_end:
    POP SI
    POP BX
    POP AX
    RET
room_service_proc ENDP

; ============= UTILITY PROCEDURES =============

; Get room address in SI based on temp_room
; Returns SI pointing to the room data, or 0FFFFh if not found/invalid
; Validates room number is between 1 and current room_count
get_room_address PROC
    PUSH AX
    PUSH BX
    
    MOV AL, temp_room
    CMP AL, 1
    JL room_not_found_addr   ; Room number less than 1
    CMP AL, MAX_ROOMS
    JG room_not_found_addr   ; Room number greater than MAX_ROOMS (9)
    MOV BL, room_count       ; Compare with current active room count
    CMP AL, BL
    JG room_not_found_addr   ; Room number greater than current room_count
    
    ; Calculate address
    DEC AL                    ; Convert to 0-based index
    MOV AH, 0
    MOV BL, ROOM_SIZE
    MUL BL                    ; AX = offset from 'rooms' array start
    LEA SI, rooms             ; SI points to start of 'rooms'
    ADD SI, AX                ; SI now points to the room's data
    JMP get_addr_end

room_not_found_addr:
    MOV SI, 0FFFFh           ; Error indicator

get_addr_end:
    POP BX
    POP AX
    RET
get_room_address ENDP

; Read number from keyboard (single digit 1-9 for room numbers, 0-9 for other inputs)
; Used for inputs like room type or room number
read_number PROC
    PUSH BX
    
read_char_again:
    MOV AH, 01h
    INT 21h
    
    ; Check for valid digit
    CMP AL, '0'
    JL read_char_again     ; If less than '0', read again
    CMP AL, '9'
    JG read_char_again     ; If greater than '9', read again
    
    SUB AL, '0'            ; Convert ASCII to number
    
    POP BX
    RET
read_number ENDP

read_multi_digit_number PROC
    PUSH SI
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX           ; Initialize result to 0
    MOV CX, 0            ; Digit counter

read_digit_loop:
    CMP CX, 3            ; Maximum 3 digits
    JGE end_read_number

    MOV AH, 01h          ; Read character
    INT 21h

    CMP AL, 0DH          ; Check for Enter key
    JE end_read_number

    ; Validate digit
    CMP AL, '0'
    JL read_digit_loop   ; Not a digit, ignore
    CMP AL, '9'
    JG read_digit_loop   ; Not a digit, ignore

    ; Process valid digit
    SUB AL, '0'          ; Convert ASCII to numeric (0-9)
    MOV AH, 0            ; Clear AH for 16-bit register
    
    ; Multiply current result by 10
    PUSH AX              ; Save the new digit
    MOV AX, BX           ; Load current result
    MOV DX, 10
    MUL DX               ; AX = result * 10
    MOV BX, AX           ; Store back in BX
    
    ; Add new digit
    POP AX               ; Get the digit back
    ADD BX, AX           ; BX = (BX * 10) + new_digit

    INC CX               ; Increment digit counter
    JMP read_digit_loop

end_read_number:
    MOV AX, BX           ; Move result to AX for return
    POP DX
    POP CX
    POP BX
    POP SI
    RET
read_multi_digit_number ENDP

; Print number in AX (simplified version, handles up to 3 digits for prices/services)
print_number PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, 10              ; Divisor
    MOV CX, 0               ; Counter for digits
    
    CMP AX, 0               ; Handle case of AX=0
    JNE divide_loop_start
    PUSH AX                 ; Push 0
    INC CX
    JMP print_loop_start

divide_loop_start:
    MOV DX, 0               ; Clear DX for DIV instruction
    DIV BX                  ; AX = AX / 10, DX = AX % 10
    PUSH DX                 ; Push remainder (digit) onto stack
    INC CX                  ; Increment digit count
    CMP AX, 0               ; Continue if quotient is not zero
    JNE divide_loop_start
    
print_loop_start:
    POP DX                  ; Pop digit
    ADD DL, '0'             ; Convert to ASCII
    MOV AH, 02h             ; Display character function
    INT 21h                 ; Call DOS interrupt
    LOOP print_loop_start   ; Loop CX times
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_number ENDP

END MAIN