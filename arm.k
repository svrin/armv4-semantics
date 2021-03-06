/*!
\title{armv4 language in K}

\author{Severin Orth}
\email{severin.orth@st.ovgu.de}
\lecture{SemProg 2014}

Follows the ARM® and Thumb®-2 Instruction Set / Quick Reference Card

*/

module ARMV4-TOKEN

    /* Condition Field */
    syntax ConditionMnemonic          ::= "eq"  /* Equal: z */
                                        | "ne"  /* Not equal: ¬z */
                                        | "cs"  /* Carry set: c */
                                        | "hs"  /* Unsigned higher or same: c */
                                        | "cc"  /* Carry clear: ¬c */
                                        | "lo"  /* Unsigned lower: ¬c */
                                        | "mi"  /* Negative: n */
                                        | "pl"  /* Positive or zero: ¬n */
                                        | "vs"  /* Overflow: v */
                                        | "vc"  /* No overflow: ¬v */
                                        | "hi"  /* Unsigned higher: c && ¬z */
                                        | "ls"  /* Unsigned lower or same: ¬c || z */
                                        | "ge"  /* Signed greater than or equal: n == v */
                                        | "lt"  /* Signed less than: n != v */
                                        | "gt"  /* Signed greater than: ¬z && n == v */
                                        | "le"  /* Signed less than or equal: z || n != v */
                                        | "al"  /* always: 1 */

    /* {S} */
    syntax UpdateConditionFlag        ::= "s"

    /* Rd, Rm, Rs, Rn */
    /* Note that arm asm alawys to define own named registers, beside the predfined ones */
    syntax Register                   ::= Id

    /* <reglist> */
    syntax RegisterList               ::= List{Register, ","}

    /* <label> */
    syntax Label                      ::= Id

    /* #<imm16> / #<shift> */
    syntax ImmediateValue             ::= "#" Int


    /* <Operand2> */
    syntax FlexibleOperand2           ::= ImmediateValue
                                        | Register
                                        > Register "," ShiftMnemonic ImmediateValue                                                                 [strict(3)]
                                        | Register "," ShiftMnemonic Register                                                                       [strict(3)]
                                        | Register "," RrxMnemonic

    /* Register, optionally shifted by constant */
    syntax FlexibleRegister           ::= Register
                                        > Register "," ShiftMnemonic ImmediateValue                                                                 [strict(3)]
                                        | Register "," RrxMnemonic

    /* <Rs|sh> */
    syntax FlexibleShift              ::= Register
                                        | ImmediateValue

    /* <size> */
    syntax Size                       ::= "b"   /* byte */
                                        | "sb"  /* signed byte */
                                        | "h"   /* half */
                                        | "sh"  /* signed half */

    /* +/- */
    syntax PlusMinus                  ::= "+"
                                        | "-"

    /* {IA|IB|DA|DB} */
    syntax MemoryOperatorSuffix       ::= "ia"  /* increment after */
                                        | "ib"  /* increment before */
                                        | "da"  /* decrement after */
                                        | "db"  /* decrement before */

endmodule


module ARMV4-SYNTAX
    imports ARMV4-TOKEN

    /* Add, Subtract */
    syntax ArithmeticMnemonic         ::= "add"  /* Add */
                                        | "adc"  /* Add with carry */
                                        | "sub"  /* Subtract */
                                        | "sbc"  /* Subtract with carry */
                                        | "rsb"  /* Reverse subtract */
                                        | "rsc"  /* Reverse subtract with carry */

    syntax ArithmeticOperator         ::= ArithmeticMnemonic
                                        > ArithmeticMnemonic UpdateConditionFlag

    /* OP{S} Rd, Rn, <Operand2> */
    syntax ArithmeticOperation        ::= ArithmeticOperator Register "," Register "," FlexibleOperand2                                             [strict(4)]
                                        | ArithmeticOperator ConditionMnemonic Register "," Register "," FlexibleOperand2                           [strict(2)]

    /* Multiply */
    syntax MultiplyMnemonic           ::= "mul"  /* Multiply */

    syntax MultiplyOperator           ::= MultiplyMnemonic
                                        > MultiplyMnemonic UpdateConditionFlag

    /* OP{S} Rd, Rm, Rs */
    syntax MultiplyOperation          ::= MultiplyOperator Register "," Register "," Register
                                        | MultiplyOperator ConditionMnemonic Register "," Register "," Register                                     [strict(2)]

    /* Move data */
    syntax MoveMnemonic               ::= "mov"  /* Move */
                                        | "mvn"  /* Move NOT */

    syntax MoveOperator               ::= MoveMnemonic
                                        > MoveMnemonic UpdateConditionFlag

    /* OP{S} Rd, <Operand2> */
    syntax MoveOperation              ::= MoveOperator Register "," FlexibleOperand2                                                                [strict(3)]
                                        > MoveOperator ConditionMnemonic Register "," FlexibleOperand2                                              [strict(2)]

    /* Shift */
    syntax ShiftMnemonic              ::= "asr"  /* Arithmetic shift right */
                                        | "lsl"  /* Logical shift left */
                                        | "lsr"  /* Logical shift right */
                                        | "ror"  /* Rotate right */

    /* OP{S} Rd, Rm, <Rs|sh> */
    syntax ShiftOperation             ::= ShiftMnemonic Register "," Register "," FlexibleShift
                                        > ShiftMnemonic UpdateConditionFlag Register "," Register "," FlexibleShift
                                        | ShiftMnemonic UpdateConditionFlag ConditionMnemonic Register "," Register "," FlexibleShift
                                        | ShiftMnemonic ConditionMnemonic Register "," Register "," FlexibleShift

    /* Shift */
    syntax RrxMnemonic                ::= "rrx"  /* Rotate right with extend */

    /* OP{S} Rd, Rm */
    syntax RrxOperation               ::= RrxMnemonic Register "," Register
                                        > RrxMnemonic UpdateConditionFlag Register "," Register
                                        | RrxMnemonic UpdateConditionFlag ConditionMnemonic Register "," Register
                                        | RrxMnemonic ConditionMnemonic Register "," Register

    /* Compare, Logical */
    syntax TestMnemonic               ::= "cmp"  /* Compare */
                                        | "cmn"  /* Compare negative */
                                        | "tst"  /* Test */
                                        | "teq"  /* Test equivalence */

    /* OP Rn, <Operand2> */
    syntax TestOperation              ::= TestMnemonic Register "," FlexibleOperand2
                                        > TestMnemonic ConditionMnemonic Register "," FlexibleOperand2

    /* Logical */
    syntax LogicalMnemonic            ::= "and"  /* AND: Bitweise logical AND operation */
                                        | "eor"  /* EOR: Bitweise exclusive OR operation */
                                        | "orr"  /* ORR: Bitweise logical OR operation */
                                        | "orn"  /* &1 || ¬&2 */
                                        | "bic"  /* &1 && ¬&2 */

    syntax LogicalOperator            ::= LogicalMnemonic
                                        > LogicalMnemonic UpdateConditionFlag

    /* OP{S} Rd, Rn, <Operand2> */
    syntax LogicalOperation           ::= LogicalOperator Register "," Register "," FlexibleOperand2                                                [strict(4)]
                                        | LogicalOperator ConditionMnemonic Register "," Register "," FlexibleOperand2                              [strict(2)]

    /* Branch */
    syntax BranchMnemonic             ::= "b"   /* branch */
                                        | "bl"  /* branch with link */

    /* OP <Label> */
    syntax BranchOperation            ::= BranchMnemonic Label
                                        > BranchMnemonic UpdateConditionFlag Label

    /* Branch and exchange */
    syntax BxMnemonic                 ::= "bx"  /* branch with link and exchange */

    /* OP <Label> */
    syntax BxOperation                ::= BxMnemonic Register
                                        > BxMnemonic UpdateConditionFlag Register

    /* Load or store word, byte or halfword */
    syntax SingleMemoryMnemonic       ::= "ldr"  /* Load */
                                        | "str"  /* Store */

    syntax SingleMemoryOperator       ::= SingleMemoryMnemonic
                                        > SingleMemoryMnemonic Size
                                        | SingleMemoryMnemonic ConditionMnemonic
                                        > SingleMemoryMnemonic Size ConditionMnemonic

    syntax SingleMemoryOperand        ::= "[" Register "]"
                                        | Label
                                        > "[" Register "," ImmediateValue "]"
                                        | "[" Register "]" "," ImmediateValue
                                        > "[" Register "," FlexibleRegister "]"
                                        | "[" Register "," PlusMinus FlexibleRegister "]"
                                        | "[" Register "]" "," FlexibleRegister
                                        | "[" Register "]" "," PlusMinus FlexibleRegister



    /* <op>{size} Rd, [Rn] */
    syntax SingleMemoryOperation      ::= SingleMemoryOperator Register "," SingleMemoryOperand                                                         [strict(3)]

    /* Load or store multiple */
    syntax MultipleMemoryMnemonic     ::= "ldm"  /* Load multiple */
                                        | "stm"  /* Store multiple */

    syntax MultipleMemoryOperator     ::= MultipleMemoryMnemonic
                                        > MultipleMemoryMnemonic MemoryOperatorSuffix
                                        | MultipleMemoryMnemonic ConditionMnemonic
                                        > MultipleMemoryMnemonic MemoryOperatorSuffix ConditionMnemonic

    /* <op>{IA|IB|DA|DB} Rn, <reglist> */
    syntax MultipleMemoryOperation    ::= MultipleMemoryOperator Register "{" RegisterList "}"
                                        > MultipleMemoryOperator Register "!" "{" RegisterList "}"
                                        | MultipleMemoryOperator Register "{" RegisterList "}" "^"
                                        | MultipleMemoryOperator Register "!" "{" RegisterList "}" "^"




endmodule


module ARMV4-PROGRAM
    imports ARMV4-SYNTAX

    /* Instruction Set */
    syntax Operation          ::= ArithmeticOperation
                                | MultiplyOperation
                                | MoveOperation
                                | ShiftOperation
                                | RrxOperation
                                | TestOperation
                                | LogicalOperation
                                | BranchOperation
                                | BxOperation
                                | SingleMemoryOperation
                                | MultipleMemoryOperation

    /* Program */
    syntax Operations          ::= List{Operation, ""}
    syntax Procedure           ::= Label ":" Operations
    syntax Program             ::= List{Procedure, " "}

    /* Named Register */
    /* These are the predefined named registers */
    syntax Register            ::= "r0"
                                 | "a1"  /* argument 1 */
                                 | "r1"
                                 | "a2"  /* argument 2 */
                                 | "r2"
                                 | "a3"  /* argument 3 */
                                 | "r3"
                                 | "a4"  /* argument 4 */
                                 | "r4"
                                 | "v1"  /* register variable 1 */
                                 | "r5"
                                 | "v2"  /* register variable 2 */
                                 | "r6"
                                 | "v3"  /* register variable 3 */
                                 | "r7"
                                 | "v4"  /* register variable 4 */
                                 | "r8"
                                 | "v5"  /* register variable 5 */
                                 | "r9"
                                 | "sb"
                                 | "v6"  /* stack base */
                                 | "r10"
                                 | "sl"
                                 | "v7"  /* stack limit */
                                 | "r11"
                                 | "fp"
                                 | "v8"  /* frame pointer */
                                 | "r12"
                                 | "ip"  /* inter link unit call */
                                 | "r13"
                                 | "sp"  /* stack pointer */
                                 | "r14"
                                 | "lr"  /* link register */
                                 | "r15"
                                 | "pc"  /* program counter */

    /* Status Register */
    /* These are currently just for naming convention, internal n,z,c,v is used */
    syntax Register             ::= "cpsr"
                                  | "spsr"

    /* Condition Register */
    /* Used for conditional evaluation */
    syntax Register            ::= "n"
                                 | "z"
                                 | "c"
                                 | "v"
endmodule


/*
    How an arm prorga,m gets executed
*/
module ARMV4-EXECUTION
    imports ARMV4-SYNTAX
    imports ARMV4-PROGRAM

    /* Entry Point Label */
    syntax Label               ::= "main"

    /* Special instruction counter for assigning labels */
    /* These gets incremented internally for assigning memory address for code lines */
    /* basicly the job that the linker normally does */
    syntax Id                  ::= "ic"

    /* Special register value UNKNOWN */
    syntax Int                 ::= "NaN"

    configuration
    <T color="yellow">
        <k color="green"> $PGM:Program </k>
        <register color="red"> .Map </register>  /* Register */
        <store color="magenta"> .Map </store>    /* Label -> Address Store */
        <memory color="blue"> .Map </memory>     /* Memory */

        <ic color="yellow"> 0 </ic>              /* Instruction Counter for Preprocessing */

        <cycles>
            <c> 0 </c>                           /* Coprocessor register transfer cycle */
            <i> 0 </i>                           /* Internal Cycle */
            <n> 0 </n>                           /* Nonsequential cycle */
            <s> 0 </s>                           /* Sequential cycle */
        </cycles>
    </T>

    /* Collect all Labels and store them */
    rule
    <k> I:Label : O1:Operation Os:Operations P:Program => I : Os P ... </k>
    <store> E => E[IC/I] </store>
    <memory> ... .=>(IC|->O1) </memory>
    <ic> IC => IC +Int 4 </ic>
    when notBool(I in keys(E))
    rule
    <k> I:Label : O2:Operation Os:Operations P:Program => I : Os P ... </k>
    <store> E => E </store>
    <memory> ... .=>(IC|->O2) </memory>
    <ic> IC => IC +Int 4 </ic>
    when I in keys(E)

    rule
    <k> I:Label : .Operations P:Program => P ... </k>

    /* Preprocessing done, set pc to main procedure and start execution */
    /* here is default stack pointer set to 8000 */
    rule
    <k> .Program => . </k>
    <store> ... main|->PC ... </store>
    <register> R => R[PC/pc][NaN/lr][8000/sp][NaN/ip][0/fp][4000/sl][8000/sp][NaN/r8][NaN/r7][NaN/r6][NaN/r5][NaN/r4][NaN/r3][NaN/r2][NaN/r1][NaN/r0][NaN/n][NaN/z][NaN/c][NaN/v] </register>

    /* Load Instruction */
    rule
    <k> . => O:Operation </k>
    <memory> ... PC|->O ... </memory>
    <register> ... pc |-> (PC => PC +Int 4) ... </register>     /* increment PC */
    <s> CS => CS +Int 1 </s>                                    /* one sequential cycle on instruction bus */

endmodule


/*
    These defines the alias names for named register

    Here in the semantics we only use the names r0-r9 and sb,sl,ip,sp,lr,pc
*/
module ARMV4-SEMANTICS-NAMED-REGISTER
    imports ARMV4-PROGRAM

    rule a1:Register => r0    [anywhere]
    rule a2:Register => r1    [anywhere]
    rule a3:Register => r2    [anywhere]
    rule a4:Register => r3    [anywhere]

    rule v1:Register => r4    [anywhere]
    rule v2:Register => r5    [anywhere]
    rule v3:Register => r6    [anywhere]
    rule v4:Register => r7    [anywhere]
    rule v5:Register => r8    [anywhere]
    rule v6:Register => r9    [anywhere]

    rule r10:Register => sb:Register   [anywhere]
    rule v7:Register  => sb:Register   [anywhere]

    rule r11:Register => sl:Register   [anywhere]
    rule v8:Register  => sl:Register   [anywhere]

    rule r12:Register  => ip  [anywhere]
    rule r13:Register  => sp  [anywhere]
    rule r14:Register  => lr  [anywhere]
    rule r15:Register  => pc  [anywhere]

endmodule


/*
    Provides the semantic for the FlexibleOperand2
*/
module ARMV4-SEMANTICS-FLEXIBLE
    imports ARMV4-PROGRAM

    /* On Semantic Level FlexibleOperant2 becomes evaluated to an int */
    syntax FlexibleOperand2 ::= Int

    /* Evaluate ImmediateValue */
    rule
    <k> # I:Int => I ... </k>

    /* Evaluate Register */
    rule
    <k> Rm:Register => I:Int ... </k>
    <register> ... Rm |-> I ... </register>


endmodule

/*
    Provides the semantic for the MemoryOperand: RegisterList
*/
module ARMV4-SEMANTICS-MEMORY-OPERAND
    imports ARMV4-PROGRAM

    /* On Semantic Level MemoryOperand becomes evaluated to an int */
    syntax SingleMemoryOperand ::= Int

    /* Evaluate Label */
    rule
    <k> L:Label => A:Int ... </k>
    <store> ... L|->A ... </store>

    /* Evaluate Register */
    rule
    <k> [ Rn:Register ] => A:Int ... </k>
    <register> ... Rn |-> A ... </register>

    /* Evaluate Register with Immediate offset */
    rule
    <k> [ Rn:Register ], # I:Int => A:Int +Int I ... </k>
    <register> ... Rn |-> A ... </register>

    /* Evaluate Register with Register offset */
    rule [ Rn:Register , Rm:Register ] => [ Rn:Register , + Rm:Register ]               [structural]
    rule
    <k> [ Rn:Register , + Rm:Register ] => A:Int +Int I ... </k>
    <register> ... Rn |-> A
                   Rm |-> I ... </register>
    rule
    <k> [ Rn:Register , - Rm:Register ] => A:Int -Int I ... </k>
    <register> ... Rn |-> A
                   Rm |-> I ... </register>




endmodule


/*
    Provides the semantic for the Conditionals
*/
module ARMV4-SEMANTICS-CONDITIONAL
    imports ARMV4-PROGRAM

    /* Equal: z */
    rule
    <k> eq => . ... </k>
    <register> ... z |-> true ... </register>
    rule
    <k> eq ~> _ => . </k>
    <register> ... z |-> false ... </register>

    /* Not Equal: ¬z */
    rule
    <k> ne => . ... </k>
    <register> ... z |-> false ... </register>
    rule
    <k> ne ~> _ => . </k>
    <register> ... z |-> true ... </register>

    /* Carry Set / Unsigned higher or same: c */
    rule cs => hs
    rule
    <k> cs => . ... </k>
    <register> ... c |-> true ... </register>
    rule
    <k> cs ~> _ => . </k>
    <register> ... c |-> false ... </register>

    /* Cary Clear / Unsigned lower: ¬c */
    rule lo => cc [structural]
    rule
    <k> cc => . ... </k>
    <register> ... c |-> false ... </register>
    rule
    <k> cc ~> _ => . </k>
    <register> ... c |-> true ... </register>

    /* Negative: n */
    rule
    <k> mi => . ... </k>
    <register> ... n |-> true ... </register>
    rule
    <k> mi ~> _ => . </k>
    <register> ... n |-> false ... </register>

    /* Positive or zero: ¬n */
    rule
    <k> pl => . ... </k>
    <register> ... n |-> false ... </register>
    rule
    <k> pl ~> _ => . </k>
    <register> ... n |-> true ... </register>

    /* Overflow: v */
    rule
    <k> vs => . ... </k>
    <register> ... v |-> true ... </register>
    rule
    <k> vs ~> _ => . </k>
    <register> ... v |-> false ... </register>

    /* No overflow: ¬v */
    rule
    <k> vc => . ... </k>
    <register> ... v |-> false ... </register>
    rule
    <k> vc ~> _ => . </k>
    <register> ... v |-> true ... </register>

    /* Unsigned higher: c && ¬z */
    rule
    <k> hi => . ... </k>
    <register> ... c |-> true z |-> false ... </register>
    rule
    <k> hi ~> _ => . </k>
    <register> ... c |-> false ... </register>
    rule
    <k> hi ~> _ => . </k>
    <register> ... z |-> true ... </register>

    /* Unsigned lower or same: ¬c || z */
    rule
    <k> ls => . ... </k>
    <register> ... c |-> false ... </register>
    rule
    <k> ls => . ... </k>
    <register> ... z |-> true ... </register>
    rule
    <k> ls ~> _ => . </k>
    <register> ... c |-> true z |-> false ... </register>

    /* Signed greater than or equal: n == v */
    rule
    <k> ge => . ... </k>
    <register> ... n |-> false v |-> false ... </register>
    rule
    <k> ge => . ... </k>
    <register> ... n |-> true v |-> true ... </register>
    rule
    <k> ge ~> _ => . </k>
    <register> ... n |-> false v |-> true ... </register>
    rule
    <k> ge ~> _ => . </k>
    <register> ... n |-> true v |-> false ... </register>

    /* Signed less than: n != v */
    rule
    <k> lt => . ... </k>
    <register> ... n |-> false v |-> true ... </register>
    rule
    <k> lt => . ... </k>
    <register> ... n |-> true v |-> false ... </register>
    rule
    <k> lt ~> _ => . </k>
    <register> ... n |-> false v |-> false ... </register>
    rule
    <k> lt ~> _ => . </k>
    <register> ... n |-> true v |-> true ... </register>

    /* Signed greater than: ¬z && n == v */
    rule
    <k> gt => . ... </k>
    <register> ... z |-> false n |-> false v |-> false ... </register>
    rule
    <k> gt => . ... </k>
    <register> ... z |-> false n |-> true v |-> true ... </register>
    rule
    <k> gt ~> _ => . </k>
    <register> ... z |-> true ... </register>
    rule
    <k> gt ~> _ => . </k>
    <register> ... n |-> true v |-> false ... </register>
    rule
    <k> gt ~> _ => . </k>
    <register> ... n |-> false v |-> true ... </register>

    /* Signed less than or equal: z || n != v */
    rule
    <k> le => . ... </k>
    <register> ... z |-> true ... </register>
    rule
    <k> le => . ... </k>
    <register> ... n |-> true v |-> false ... </register>
    rule
    <k> le => . ... </k>
    <register> ... n |-> false v |-> true ... </register>
    rule
    <k> le ~> _ => . </k>
    <register> ... z |-> false n |-> false v |-> false ... </register>
    rule
    <k> le ~> _ => . </k>
    <register> ... z |-> false n |-> true v |-> true ... </register>

    /* Always executed: 1 */
    rule al => . [structural]

endmodule


/*
    Semantics of the operations
*/
module ARMV4-SEMANTICS
    imports ARMV4-PROGRAM
    imports ARMV4-EXECUTION

    imports ARMV4-SEMANTICS-NAMED-REGISTER
    imports ARMV4-SEMANTICS-CONDITIONAL
    imports ARMV4-SEMANTICS-FLEXIBLE
    imports ARMV4-SEMANTICS-MEMORY-OPERAND

    /* Add */
    rule
    <k> add Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J +Int I) ... </register>
    rule
    <k> adds Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J +Int I)
                   n |-> (_ => J +Int I <Int 0)
                   z |-> (_ => J +Int I =Int 0) ... </register>
    rule
    <k> add Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J +Int I) ... </register>
    rule
    <k> adds Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J +Int I)
                   n |-> (_ => J +Int I <Int 0)
                   z |-> (_ => J +Int I =Int 0) ... </register>

    /* Add with carry */
    rule
    <k> adc Rd, Rn, I => . </k>
    <register> ... c |-> C
                   Rn |-> J
                   Rd |-> (_ => J +Int I +Int C) ... </register>
    rule
    <k> adcs Rd, Rn, I => . </k>
    <register> ... c |-> C
                   Rn |-> J
                   Rd |-> (_ => J +Int I +Int C)
                   n |-> (_ => J +Int I +Int C <Int 0)
                   z |-> (_ => J +Int I +Int C =Int 0) ... </register>
    rule
    <k> adc Rd, Rd, I => . </k>
    <register> ... c |-> C
                   Rd |-> (J => J +Int I +Int C) ... </register>
    rule
    <k> adcs Rd, Rd, I => . </k>
    <register> ... c |-> C
                   Rd |-> (J => J +Int I +Int C)
                   n |-> (_ => J +Int I +Int C <Int 0)
                   z |-> (_ => J +Int I +Int C =Int 0) ... </register>

    /* Subtract */
    rule
    <k> sub Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J -Int I) ... </register>
    rule
    <k> subs Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J -Int I)
                   n |-> (_ => J -Int I <Int 0)
                   z |-> (_ => J -Int I =Int 0) ... </register>
    rule
    <k> sub Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J -Int I) ... </register>
    rule
    <k> subs Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J -Int I)
                   n |-> (_ => J -Int I <Int 0)
                   z |-> (_ => J -Int I =Int 0) ... </register>

    /* Subtract with carry */
    rule
    <k> sbc Rd, Rn, I => . </k>
    <register> ... c |-> C
                   Rn |-> J
                   Rd |-> (_ => J -Int I -Int ~Int C) ... </register>
    rule
    <k> sbcs Rd, Rn, I => . </k>
    <register> ... c |-> C
                   Rn |-> J
                   Rd |-> (_ => J -Int I -Int ~Int C)
                   n |-> (_ => J -Int I -Int ~Int C <Int 0)
                   z |-> (_ => J -Int I -Int ~Int C =Int 0) ... </register>
    rule
    <k> sbc Rd, Rd, I => . </k>
    <register> ... c |-> C
                   Rd |-> (J => J -Int I -Int ~Int C) ... </register>
    rule
    <k> sbcs Rd, Rd, I => . </k>
    <register> ... c |-> C
                   Rd |-> (J => J -Int I -Int ~Int C)
                   n |-> (J => J -Int I -Int ~Int C <Int 0)
                   z |-> (J => J -Int I -Int ~Int C =Int 0) ... </register>

    /* reverse subtract */
    rule
    <k> rsb Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => I -Int J) ... </register>
    rule
    <k> rsbs Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => I -Int J)
                   n |-> (_ => I -Int J <Int 0)
                   z |-> (_ => I -Int J =Int 0) ... </register>
    rule
    <k> rsb Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => I -Int J) ... </register>
    rule
    <k> rsbs Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => I -Int J)
                   n |-> (_ => I -Int J <Int 0)
                   z |-> (_ => I -Int J =Int 0) ... </register>

    /* reverse subtract with carry */
    rule
    <k> rsc Rd, Rn, I => . </k>
    <register> ... c |-> C
                   Rn |-> J
                   Rd |-> (_ => I -Int J -Int ~Int C) ... </register>
    rule
    <k> rscs Rd, Rn, I => . </k>
    <register> ... c |-> C
                   Rn |-> J
                   Rd |-> (_ => I -Int J -Int ~Int C)
                   n |-> (_ => I -Int J -Int ~Int C <Int 0)
                   z |-> (_ => I -Int J -Int ~Int C =Int 0) ... </register>
    rule
    <k> rsc Rd, Rd, I => . </k>
    <register> ... c |-> C
                   Rd |-> (J => I -Int J -Int ~Int C) ... </register>
    rule
    <k> rscs Rd, Rd, I => . </k>
    <register> ... c |-> C
                   Rd |-> (J => I -Int J -Int ~Int C)
                   n |-> (_ => I -Int J -Int ~Int C <Int 0)
                   z |-> (_ => I -Int J -Int ~Int C =Int 0) ... </register>

    /* Multiply */
    rule
    <k> mul Rd, Rm, Rs => . </k>
    <register> ... Rm |-> J:Int
                   Rs |-> I:Int
                   Rd |-> (_ => I *Int J) ... </register>
    rule
    <k> muls Rd, Rm, Rs => . </k>
    <register> ... Rm |-> J:Int
                   Rs |-> I:Int
                   Rd |-> (_ => I *Int J)
                   n |-> (_ => I *Int J <Int 0)
                   z |-> (_ => I *Int J =Int 0)  ... </register>

    /* Branch */
    rule
    <k> b L => . </k>
    <store> ... L|->PC ... </store>
    <register> ... pc |-> (_ => PC) ... </register>

    /* Branch and Link */
    rule
    <k> bl L => . </k>
    <store> ... L|->PC ... </store>
    <register> ... pc |-> (LR:Int => PC)
                   lr |-> (_ => LR) ... </register>

    /* Branch and Link */
    rule
    <k> bx Rm => . </k>
    <register> ... Rm |-> J:Int
                   pc |-> (_ => J) ... </register>

    /* Move */
    rule
    <k> mov Rd, I => . </k>
    <register> ... Rd |-> (_ => I:Int) ... </register>
    rule
    <k> movs Rd, I => . </k>
    <register> ... Rd |-> (_ => I:Int)
                   n |-> (_ => I <Int 0)
                   z |-> (_ => I =Int 0) ... </register>

    /* Move NOT */
    rule
    <k> mvn Rd, I => . </k>
    <register> ... Rd |-> (_ => ~Int I:Int) ... </register>
    rule
    <k> mvns Rd, I => . </k>
    <register> ... Rd |-> (_ => ~Int I:Int)
                   n |-> (_ => ~Int I <Int 0)
                   z |-> (_ => ~Int I =Int 0) ... </register>

    /* Shift */
    /* The shift operations are semanticly equivalent to a mov operation as denoted in the arm doc */
    rule asr Rd, Rm, (Rs:Register) => mov Rd, Rm, asr Rs            [structural]
    rule asrs Rd, Rm, (Rs:Register) => movs Rd, Rm, asr Rs          [structural]
    rule lsl Rd, Rm, (Rs:Register) => mov Rd, Rm, lsl Rs            [structural]
    rule lsls Rd, Rm, (Rs:Register) => movs Rd, Rm, lsl Rs          [structural]
    rule lsr Rd, Rm, (Rs:Register) => mov Rd, Rm, lsr Rs            [structural]
    rule lsrs Rd, Rm, (Rs:Register) => movs Rd, Rm, lsr Rs          [structural]
    rule ror Rd, Rm, (Rs:Register) => mov Rd, Rm, ror Rs            [structural]
    rule rors Rd, Rm, (Rs:Register) => movs Rd, Rm, ror Rs          [structural]
    rule asr Rd, Rm, (Iv:ImmediateValue) => mov Rd, Rm, asr Iv      [structural]
    rule asrs Rd, Rm, (Iv:ImmediateValue) => movs Rd, Rm, asr Iv    [structural]
    rule lsl Rd, Rm, (Iv:ImmediateValue) => mov Rd, Rm, lsl Iv      [structural]
    rule lsls Rd, Rm, (Iv:ImmediateValue) => movs Rd, Rm, lsl Iv    [structural]
    rule lsr Rd, Rm, (Iv:ImmediateValue) => mov Rd, Rm, lsr Iv      [structural]
    rule lsrs Rd, Rm, (Iv:ImmediateValue) => movs Rd, Rm, lsr Iv    [structural]
    rule ror Rd, Rm, (Iv:ImmediateValue) => mov Rd, Rm, ror Iv      [structural]
    rule rors Rd, Rm, (Iv:ImmediateValue) => movs Rd, Rm, ror Iv    [structural]
    rule rrx Rd, Rm     => mov Rd, Rm, rrx                          [structural]
    rule rrxs Rd, Rm     => movs Rd, Rm, rrx                        [structural]

    /* AND */
    rule
    <k> and Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J &Int I) ... </register>
    rule
    <k> ands Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J &Int I)
                   n |-> (_ => J &Int I <Int 0)
                   z |-> (_ => J &Int I =Int 0) ... </register>
    rule
    <k> and Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J &Int I) ... </register>
    rule
    <k> ands Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J &Int I)
                   n |-> (_ => J &Int I <Int 0)
                   z |-> (_ => J &Int I =Int 0) ... </register>

    /* EOR */
    rule
    <k> eor Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J xorInt I) ... </register>
    rule
    <k> eors Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J xorInt I)
                   n |-> (_ => J xorInt I <Int 0)
                   z |-> (_ => J xorInt I =Int 0) ... </register>
    rule
    <k> eor Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J xorInt I) ... </register>
    rule
    <k> eors Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J xorInt I)
                   n |-> (_ => J xorInt I <Int 0)
                   z |-> (_ => J xorInt I =Int 0) ... </register>

    /* ORR */
    rule
    <k> orr Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J |Int I) ... </register>
    rule
    <k> orrs Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J |Int I)
                   n |-> (_ => J |Int I <Int 0)
                   z |-> (_ => J |Int I =Int 0) ... </register>
    rule
    <k> orr Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J |Int I) ... </register>
    rule
    <k> orrs Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J |Int I)
                   n |-> (_ => J |Int I <Int 0)
                   z |-> (_ => J |Int I =Int 0) ... </register>

    /* ORN */
    rule
    <k> orn Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J |Int ~Int I) ... </register>
    rule
    <k> orns Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J |Int ~Int I)
                   n |-> (_ => J |Int ~Int I <Int 0)
                   z |-> (_ => J |Int ~Int I =Int 0) ... </register>
    rule
    <k> orn Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J |Int ~Int I) ... </register>
    rule
    <k> orns Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J |Int ~Int I)
                   n |-> (_ => J |Int ~Int I <Int 0)
                   z |-> (_ => J |Int ~Int I =Int 0) ... </register>

    /* Bit Clear */
    rule
    <k> bic Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J &Int ~Int I) ... </register>
    rule
    <k> bics Rd, Rn, I => . </k>
    <register> ... Rn |-> J
                   Rd |-> (_ => J &Int ~Int I)
                   n |-> (_ => J &Int ~Int I <Int 0)
                   z |-> (_ => J &Int ~Int I =Int 0) ... </register>
    rule
    <k> bic Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J &Int ~Int I) ... </register>
    rule
    <k> bics Rd, Rd, I => . </k>
    <register> ... Rd |-> (J => J &Int ~Int I)
                   n |-> (_ => J &Int ~Int I <Int 0)
                   z |-> (_ => J &Int ~Int I =Int 0) ... </register>

    /* Load Single */
    rule
    <k> ldr Rd, (A:Int) => . </k>
    <register> ... Rd |-> (_ => I) ... </register>
    <memory> ... A |-> I ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */

    /* Store Single */
    rule
    <k> str Rd, (A:Int) => . </k>
    <register> ... Rd |-> I ... </register>
    <memory> ... A |-> (_ => I) ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */

    /* Load Multiple */
    rule ldm _:MemoryOperatorSuffix Rn { . } => .           [structural]  /* empty list gets discarded */
    rule ldm Rn { Rs:RegisterList } => ldmia Rn { Rs }      [structural]  /* defaults to ia */
    rule
    <k> ldmia Rn { R:Register , Rs:RegisterList } => ldmia Rn { Rs } </k>
    <register> ... Rn |-> (A => A +Int 4)
                   R |-> (_ => I) ... </register>
    <memory> ... A |-> I ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */
    rule
    <k> ldmib Rn { R:Register , Rs:RegisterList } => ldmib Rn { Rs } </k>
    <register> ... Rn |-> (A => A +Int 4)
                   R |-> (_ => I) ... </register>
    <memory> ... A +Int 4 |-> I ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */
    rule
    <k> ldmda Rn { R:Register , Rs:RegisterList } => ldmda Rn { Rs } </k>
    <register> ... Rn |-> (A => A -Int 4)
                   R |-> (_ => I) ... </register>
    <memory> ... A |-> I ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */
    rule
    <k> ldmdb Rn { R:Register , Rs:RegisterList } => ldmdb Rn { Rs } </k>
    <register> ... Rn |-> (A => A -Int 4)
                   R |-> (_ => I) ... </register>
    <memory> ... A-Int 4 |-> I ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */

    /* Store Multiple */
    rule stm _:MemoryOperatorSuffix Rn { . } => .           [structural]  /* empty list gets discarded */
    rule stm Rn { Rs:RegisterList } => stmia Rn { Rs }      [structural]  /* defaults to ia */
    rule
    <k> stmia Rn { R:Register , Rs:RegisterList } => stmia Rn { Rs } </k>
    <register> ... Rn |-> (A => A +Int 4)
                   R |-> I ... </register>
    <memory> ... A |-> (_ => I) ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */
    rule
    <k> stmib Rn { R:Register , Rs:RegisterList } => stmib Rn { Rs } </k>
    <register> ... Rn |-> (A => A +Int 4)
                   R |-> I ... </register>
    <memory> ... A +Int 4 |-> (_ => I) ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */
    rule
    <k> stmda Rn { R:Register , Rs:RegisterList } => stmda Rn { Rs } </k>
    <register> ... Rn |-> (A => A -Int 4)
                   R |-> I ... </register>
    <memory> ... A |-> (_ => I) ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */
    rule
    <k> stmdb Rn { R:Register , Rs:RegisterList } => stmdb Rn { Rs } </k>
    <register> ... Rn |-> (A => A -Int 4)
                   R |-> I ... </register>
    <memory> ... A-Int 4 |-> (_ => I) ... </memory>
    <i> CI => CI +Int 1 </i>                                    /* one internal cycle on instruction bus */







endmodule


module ARM
    imports ARMV4-PROGRAM
    imports ARMV4-SEMANTICS

    syntax KResult ::= Int
endmodule