
;4. Data Monitoring and Control Using Port-Based Simulation (4 Marks) 
;    a. Simulate a control program that: 
;        i. Reads a “sensor value” from a specified memory location or input 
;            port (e.g., simulating a water level sensor). 
;        ii. Based on the input, performs actions such as: 
;            1. Turning on a “motor” (by setting a bit in a specific memory location). 
;            2. Triggering an “alarm” if the water level is too high. 
;            3. Stopping the motor if the water level is moderate. 
;    b. Documentation Requirement: Explain how the program determines which 
;    action to take based on the “sensor” input and how memory locations or ports are manipulated to reflect the motor or alarm status.

; Define memory locations/ports
SENSOR    EQU 0x1000    ; Memory location for sensor input
MOTOR     EQU 0x2000    ; Memory location for motor control
ALARM     EQU 0x2001    ; Memory location for alarm control

; Threshold values
LOW_LEVEL    EQU 30     ; Low water level threshold
HIGH_LEVEL   EQU 70     ; High water level threshold

START:    
    ; Read the sensor value
    LOAD SENSOR          ; Load sensor value into the accumulator (ACC)

    ; Check for high water level
    CMP ACC, HIGH_LEVEL  ; Compare sensor value with high level threshold
    JGE HIGH_ALARM       ; Jump to HIGH_ALARM if ACC >= HIGH_LEVEL

    ; Check for low water level
    CMP ACC, LOW_LEVEL   ; Compare sensor value with low level threshold
    JL LOW_MOTOR_ON      ; Jump to LOW_MOTOR_ON if ACC < LOW_LEVEL

MODERATE:    
    ; Moderate water level: Stop motor and clear alarm
    CLR MOTOR            ; Set motor status to OFF
    CLR ALARM            ; Set alarm status to OFF
    JMP START            ; Repeat the process

LOW_MOTOR_ON:
    ; Low water level: Turn on the motor and clear alarm
    SET MOTOR            ; Set motor status to ON
    CLR ALARM            ; Set alarm status to OFF
    JMP START            ; Repeat the process

HIGH_ALARM:
    ; High water level: Trigger alarm and stop motor
    SET ALARM            ; Set alarm status to ON
    CLR MOTOR            ; Set motor status to OFF
    JMP START            ; Repeat the process
