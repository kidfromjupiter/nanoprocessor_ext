# Microcode UOp Diagrams

These diagrams describe the generic ALU/register-bank microcode used by `MUL` and `DIV`.
Both instructions use `R3`-`R7` as visible scratch registers.

## Multiplication

Scratch convention:

- `R3`: constant `1`
- `R4`: multiplicand copy from original `Rd`
- `R5`: decrementing multiplier copy from `Rs`
- `R6`: running product
- `R7`: compare result

```mermaid
flowchart TD
    M20["20 UOP_LOAD_A_RD<br/>A = Rd"]
    M21["21 UOP_LOAD_B_MICRO_SRC R0<br/>B = 0"]
    M22["22 UOP_WRITE_ALU_MICRO_DST R4 ADD<br/>R4 = Rd + 0"]
    M23["23 UOP_LOAD_A_MICRO_SRC R0<br/>A = 0"]
    M24["24 UOP_LOAD_B_RS<br/>B = Rs"]
    M25["25 UOP_WRITE_ALU_MICRO_DST R5 ADD<br/>R5 = 0 + Rs"]
    M26["26 UOP_WRITE_IMM_MICRO_DST R6<br/>R6 = 0"]
    M27["27 UOP_WRITE_IMM_MICRO_DST R3<br/>R3 = 1"]

    M28["28 UOP_LOAD_A_MICRO_SRC R5<br/>A = multiplier"]
    M29["29 UOP_LOAD_B_MICRO_SRC R0<br/>B = 0"]
    M30{"30 R7 = (R5 == 0)<br/>NEXT_IF_NONZERO 37"}
    M31["31 UOP_LOAD_A_MICRO_SRC R6<br/>A = product"]
    M32["32 UOP_LOAD_B_MICRO_SRC R4<br/>B = multiplicand"]
    M33["33 UOP_WRITE_ALU_MICRO_DST R6 ADD<br/>R6 = R6 + R4"]
    M34["34 UOP_LOAD_A_MICRO_SRC R5<br/>A = multiplier"]
    M35["35 UOP_LOAD_B_MICRO_SRC R3<br/>B = 1"]
    M36["36 UOP_WRITE_ALU_MICRO_DST R5 SUB<br/>R5 = R5 - 1<br/>NEXT_ABS 28"]

    M37["37 UOP_LOAD_A_MICRO_SRC R6<br/>A = product"]
    M38["38 UOP_LOAD_B_MICRO_SRC R0<br/>B = 0"]
    M39["39 UOP_WRITE_ALU_RD ADD<br/>Rd = R6 + 0<br/>PC++"]

    M20 --> M21 --> M22 --> M23 --> M24 --> M25 --> M26 --> M27
    M27 --> M28 --> M29 --> M30
    M30 -- "R7 != 0" --> M37 --> M38 --> M39
    M30 -- "R7 == 0" --> M31 --> M32 --> M33 --> M34 --> M35 --> M36
    M36 --> M28
```

## Division

Scratch convention:

- `R3`: constant `1`
- `R4`: running remainder
- `R5`: divisor copy from `Rs`
- `R6`: running quotient
- `R7`: compare result

```mermaid
flowchart TD
    D40["40 UOP_CLEAR_DIV_ZERO<br/>Div_Zero = 0"]
    D41["41 UOP_LOAD_A_RD<br/>A = dividend"]
    D42["42 UOP_LOAD_B_MICRO_SRC R0<br/>B = 0"]
    D43["43 UOP_WRITE_ALU_MICRO_DST R4 ADD<br/>R4 = Rd + 0"]
    D44["44 UOP_LOAD_A_MICRO_SRC R0<br/>A = 0"]
    D45["45 UOP_LOAD_B_RS<br/>B = divisor"]
    D46["46 UOP_WRITE_ALU_MICRO_DST R5 ADD<br/>R5 = 0 + Rs"]
    D47["47 UOP_WRITE_IMM_MICRO_DST R6<br/>R6 = 0"]
    D48["48 UOP_WRITE_IMM_MICRO_DST R3<br/>R3 = 1"]
    D49["49 UOP_LOAD_A_MICRO_SRC R5<br/>A = divisor"]
    D50["50 UOP_LOAD_B_MICRO_SRC R0<br/>B = 0"]
    D51{"51 R7 = (R5 == 0)<br/>NEXT_IF_NONZERO 64"}

    D52["52 UOP_LOAD_A_MICRO_SRC R4<br/>A = remainder"]
    D53["53 UOP_LOAD_B_MICRO_SRC R5<br/>B = divisor"]
    D54{"54 R7 = (R4 < R5)<br/>NEXT_IF_NONZERO 61"}
    D55["55 UOP_LOAD_A_MICRO_SRC R4<br/>A = remainder"]
    D56["56 UOP_LOAD_B_MICRO_SRC R5<br/>B = divisor"]
    D57["57 UOP_WRITE_ALU_MICRO_DST R4 SUB<br/>R4 = R4 - R5"]
    D58["58 UOP_LOAD_A_MICRO_SRC R6<br/>A = quotient"]
    D59["59 UOP_LOAD_B_MICRO_SRC R3<br/>B = 1"]
    D60["60 UOP_WRITE_ALU_MICRO_DST R6 ADD<br/>R6 = R6 + 1<br/>NEXT_ABS 52"]

    D61["61 UOP_LOAD_A_MICRO_SRC R6<br/>A = quotient"]
    D62["62 UOP_LOAD_B_MICRO_SRC R0<br/>B = 0"]
    D63["63 UOP_WRITE_ALU_RD ADD<br/>Rd = R6 + 0<br/>PC++"]

    D64["64 UOP_SET_DIV_ZERO<br/>Div_Zero = 1"]
    D65["65 UOP_LOAD_A_MICRO_SRC R0<br/>A = 0"]
    D66["66 UOP_LOAD_B_MICRO_SRC R0<br/>B = 0"]
    D67["67 UOP_WRITE_ALU_RD ADD<br/>Rd = 0<br/>PC++"]

    D40 --> D41 --> D42 --> D43 --> D44 --> D45 --> D46 --> D47 --> D48
    D48 --> D49 --> D50 --> D51
    D51 -- "R7 != 0" --> D64 --> D65 --> D66 --> D67
    D51 -- "R7 == 0" --> D52 --> D53 --> D54
    D54 -- "R7 != 0" --> D61 --> D62 --> D63
    D54 -- "R7 == 0" --> D55 --> D56 --> D57 --> D58 --> D59 --> D60
    D60 --> D52
```
