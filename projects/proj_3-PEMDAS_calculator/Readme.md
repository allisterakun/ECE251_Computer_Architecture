# PEMDAS Calculator:
Write a basic calculator that takes into account the standard "PEMDAS" rule. Your calculator will be invoked by the following:

    $> ./calc <operation>

where operation is defined as:

operation = <operand> <arithmetic operation> <operand> , ... 

up to 4 times. So for example, your program will have to support the following invocation:

    $> ./calc 3+4*2-3 
    $> 8

There can be fewer than 4 operations, which your program will need to support:

    $> ./calc 3+4 
    $> 7

The parentheses portion of PEMDAS will also need to be supported:

    $> ./calc (3+4)*2-3
    $> 11
    
YOUR PROGRAM MUST SUPPORT FLOATING POINT NUMBERS.

Don't worry about exponents. 
