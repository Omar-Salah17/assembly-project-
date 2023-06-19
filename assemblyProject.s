.intel_syntax noprefix  # use the intel syntax, not AT&T syntax. do not prefix registers with %



.section .data                        # this section is for memory variables
input: .asciz "%d"                    # string terminated by 0 that will be used for scanf parameter
output: .asciz "The sum of 1+(1/r*r) algoritm is : %f\n"     # string terminated by 0 that will be used for printf parameter

n: .int 0                             # the variable n which we will get from user using scanf
s: .double 0.0                        # the variable s=1/1+1/2+1/3+...+1/n that will be calculated by the program and will be printed by printf, s is initialized to 0
one: .double 1.0
r: .double 1.0   
multr: .double 1.0

.section .text                       # instructions
.globl _main                         # make _main accessible from external

_main:                #  the start of the program
   push OFFSET n      # push to stack the second parameter to scanf (the address of the integer variable n)
   push OFFSET input  # push to stack the first parameter to scanf
   call _scanf        # call scanf, it will use the two parameters on the top of the stack in the reverse order
   add esp, 8         # pop the above two parameters from the stack (the esp register keeps track of the stack top, 8=2*4 bytes popped as param was 4 bytes)
   
   mov ecx, n         # ecx <- n (the number of iterations)
loop1:
   # the following instructions increase s by (r+1/r*r)

   # 1+(1/r) 
   fld qword ptr r                  # push r to the floating point stack
   fadd qword ptr s                 # pop the following 
   fstp qword ptr s                 # pop the following 
   # ( 1+(1/r*r) )
   fld qword ptr r                 # push r to the floating point stack
   fmul qword ptr r                # fmul is a function to multiply r 
   fstp qword ptr multr            # pop the following 

   fld qword ptr one                # push 1 to the floating point stack
   fdiv qword ptr multr             # pop the floating point stack top (1), divide it over multr and push the result ( 1+(1/r*r) )

   fadd qword ptr s             # pop the floating point stack top (1/r), add it to s, and push the result s + ( 1+(1/r*r) )
   fstp qword ptr s             # pop the floating point stack top (s+(1/r)) into the memory variable s

   # the following 3 instructions increase r by 1   
   fld qword ptr r              # push 1 to the floating point stack
   fadd qword ptr one           # pop the floating point stack top (1), add it to r and push the result (r+1)
   fstp qword ptr r             # pop the floating point stack top (r+1) into the memory variable r

   loop loop1         # ecx -=1 , then goto loop1 only if ecx is not zero
   
   push [s+4]         # push to stack the high 32-bits of the second parameter to printf (the double at label s)
   push s             # push to stack the low 32-bits of the second parameter to printf (the double at label s)
   push OFFSET output # push to stack the first parameter to printf
   call _printf       # call printf
   add esp, 12        # pop the two parameters

   ret                # end the main function
