// ECE 585 Fall 2013 
//Configuration File. Contains parameter defination of essential variables 

//Cache Parameters
`define add_size 32
`define associativity 8            //Associtivity (lines/set)
`define line_size 64               //Line Size (in Bytes)
`define set_count 16384           //Number of sets in cache

//Calculation of Tag Overhead 
`define offset_size $ln(`line_size)/$ln(2)
`define index_size $ln(`set_count)/$ln(2)
`define tag_size `add_size-`offset_size-`index_size
`define counter_size $ln(`associativity)/$ln(2)
`define mesi_bits 2

//constants
`define M 2'b00
`define E 2'b01
`define S 2'b10
`define I 2'b11

`define NoHIT 2'b00
`define HIT   2'b01
`define HITM  2'b10

//Debug Options 
`define fileop 0
`define debug 1

//Operation Trace File 
`define L1_DataCacheRead 0
`define L1_DataCacheWrite 1
`define L1_InstructionCacheRead 2
`define SnoopInvalidateRequest 3
`define SnoopReadRequest 4
`define SnoopWriteRequest 5
`define SnoopRFO 6
`define ClearCache 8
`define PrintCache 9


// Include facility of code sanity- check lenghts of address and index bits are okay 