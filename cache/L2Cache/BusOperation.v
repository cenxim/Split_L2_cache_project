/*
Bus operation function
*/
`include "conf.v"
module BusOperation();
  
  function busRead;
    input [31:0]address;
    if(`busOperation)
    $display("R %h",address);
  endfunction
 
  function busWrite;
    input [31:0]address;
    if(`busOperation)
    $display("W %h",address);
  endfunction
  
 function busModify;
   input [31:0]address;
   if(`busOperation)
   $display("M %h",address);
 endfunction
 
 function busInvalidate;
   input [31:0]address;
   if(`busOperation)
   $display("I %h",address);
 endfunction
  
endmodule