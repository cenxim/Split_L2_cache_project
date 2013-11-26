/*

function of MESI protocol

*/
`include "conf.v"
module mesi_function();
function[3:0] mesi;
input [1:0]presentState;
input [3:0]command;
input [1:0]snoopResult;
begin
  case(presentState)
    `Modified: begin
        if(command == `SnoopReadRequest)
          mesi = {`Shared, `memoryWrite};
      else if(command == `SnoopRFO)
          mesi = {`Invalid,`memoryWrite};
        else 
          mesi = {`Modified,`nothing};
        end
    `Exclusive: begin
        if(command == `SnoopReadRequest)
          mesi = {`Shared,`nothing};
      else if(command == `SnoopRFO)
          mesi = {`Invalid,`nothing};
      else if(command == `L1_DataCacheWrite)
        mesi = {`Modified,`nothing};
      else 
          mesi = {`Exclusive,`nothing};
      
    end
    `Shared: begin
        if(command == `SnoopReadRequest)
          mesi = {`Shared,`nothing};
      else if(command == `SnoopInvalidateRequest || command == `SnoopRFO)
          mesi = {`Invalid,`nothing};
      else if(command == `L1_DataCacheWrite)
        mesi = {`Modified,`RFO};
        else
          mesi = {`Shared,`nothing};
    end
    `Invalid: begin
      if((command == `L1_DataCacheRead || command == `L1_InstructionCacheRead) && snoopResult == `HIT)
        mesi = {`Shared,`memoryRead};
      else if((command == `L1_DataCacheRead || command == `L1_InstructionCacheRead) && snoopResult == `NoHIT)
        mesi = {`Exclusive,`memoryRead};
      else if(command == `L1_DataCacheWrite)
        mesi = {`Modified,`RFO};
      else
       mesi = {`Invalid,`nothing};
    end
    default:begin
      mesi = {`Exclusive,`memoryRead};
    end
      endcase
end
endfunction
endmodule




