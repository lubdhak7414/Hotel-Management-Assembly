# Hotel Management System

A comprehensive hotel management system implemented in Intel 8086 Assembly Language for EMU8086.

## Features

### Core Operations
- **Check-in/Check-out** - Assign guests to rooms and process departures
- **Room Management** - Add/remove rooms dynamically (max 9 rooms)
- **Room Status** - View all rooms with type, availability, and pricing
- **Booking System** - Reserve rooms for guests
- **Billing Calculator** - Calculate total charges including room rates and services
- **Room Service** - Add service charges to guest bills

### Room Types & Pricing
- **Single Room**: $50/night
- **Double Room**: $80/night  
- **Suite**: $150/night

## Technical Specifications

- **Architecture**: Intel 8086
- **Assembler**: EMU8086
- **Memory Model**: Small
- **Room Capacity**: 9 rooms maximum
- **Room Structure**: 6 bytes per room (status, type, price, services)

## Installation & Usage

### Prerequisites
- EMU8086 assembler/emulator
- DOS environment (simulated)

### Running the Program
1. Open EMU8086
2. Load the source code file
3. Compile using **F9** or Build menu
4. Execute the program
5. Follow the menu prompts

### Menu Options
```
1. Check-in       - Assign guest to available room
2. Check-out      - Process guest departure  
3. Add Room       - Add new room to inventory
4. Remove Room    - Remove room from service
5. View Status    - Display all room information
6. Book Room      - Reserve room for guest
7. View Billing   - Calculate and show total charges
8. Room Service   - Add service charges to bill
9. Exit           - Close application
```

## System Architecture

### Memory Management
- **Array-based storage** for room data
- **6-byte room structure**: [Status][Type][Price_Low][Price_High][Service_Low][Service_High]
- **Dynamic room counting** with bounds checking

### Data Structure
```
Room Status: 0=Vacant, 1=Occupied, 2=Unavailable
Room Types:  1=Single, 2=Double, 3=Suite
Pricing:     16-bit word values for room rates and services
```

### Key Procedures
- `init_hotel` - Initialize default rooms
- `checkin_proc` - Handle guest check-ins
- `checkout_proc` - Process guest departures
- `billing_proc` - Calculate total charges
- `room_service_proc` - Add service charges
- `view_status_proc` - Display room information

### Utility Functions
- `get_room_address` - Validate and locate room data
- `read_number` - Single-digit input handler
- `read_multi_digit_number` - Multi-digit input (up to 3 digits)
- `print_number` - Number output formatting

## Sample Usage

### Basic Workflow
1. **Start** → View welcome message
2. **Option 5** → Check initial room status (5 default rooms)
3. **Option 1** → Check-in guest to room 1
4. **Option 8** → Add $25 room service charge
5. **Option 7** → View billing (3 days × $50 + $25 = $175)
6. **Option 2** → Check-out guest

### Default Room Configuration
```
Room 1: Single  - $50/night  - Vacant
Room 2: Double  - $80/night  - Vacant  
Room 3: Suite   - $150/night - Vacant
Room 4: Single  - $50/night  - Vacant
Room 5: Double  - $80/night  - Vacant
```

## Error Handling

- **Input Validation** - Checks for valid room numbers and types
- **Room Status Verification** - Prevents invalid operations (e.g., checking into occupied rooms)
- **Bounds Checking** - Ensures room numbers stay within valid range
- **Graceful Degradation** - Handles invalid inputs without crashing

## Technical Implementation

### Macros Used
- `DISPLAY_STRING` - Consistent message output
- `GET_CHAR` - Single character input
- `DISPLAY_CHAR` - Single character output  
- `GET_NUMBER` - Numeric input handling

### Memory Layout
- **Stack**: 256 bytes (100h)
- **Data Segment**: Room array + messages + variables
- **Code Segment**: Main program + procedures

### I/O Operations
- **DOS Interrupts**: INT 21h for all input/output
- **Keyboard Input**: Character and numeric input handling
- **Screen Output**: Formatted text display with proper alignment

## Limitations

- Maximum 9 rooms supported
- Single-digit input for most operations (except service charges)
- Prices limited to reasonable ranges (up to 999)
- No persistent storage (data lost on program exit)
- Basic error messages (no detailed diagnostics)

## Educational Value

This project demonstrates:
- **Assembly Language Programming** - Low-level system programming
- **Memory Management** - Array manipulation and pointer arithmetic
- **Procedure Design** - Modular programming with subroutines
- **Macro Usage** - Code reusability and maintenance
- **DOS Programming** - System calls and interrupt handling
- **Data Structures** - Efficient room data organization

