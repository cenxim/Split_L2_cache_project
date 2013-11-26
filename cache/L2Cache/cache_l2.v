//Cache Testbench 



`include "conf.v"

module cache_l2();
  
//Instantiation of Cache Memory. Further referenced as m.cache[set][column]
check_cache c();
mesi_function m();

//File Handlers 
integer data_file    ; // file handler
integer scan_file,eof    ; // file handler

reg [3:0] command;
reg [31:0]address;
//cache specific variables
reg [`index_size-1:0]index;
reg [`tag_size-1:0]tag;
reg [`offset_size-1:0]offset;

//Global variables for maintaining count
integer hitCount,readOp,writeOp;

reg[3:0]response,a;
reg [3:0]result,way, mesiState;
reg dummy;
initial
begin
  
  data_file = $fopen("cc1.din", "r");
  eof = $feof(data_file);
   hitCount = 0;
   readOp = 0;
   writeOp = 0;
  while(!eof)
    begin
      scan_file = $fscanf(data_file, "%d %h\n", command,address); 
      eof = $feof(data_file);
      
      offset=address[`offset_size-1:0];
      index=address[`index_size+`offset_size-1:`offset_size];
      tag=address[(`add_size-1):(`index_size+`offset_size)];
      
      if(`debug)
        begin
          
    $display("Address is=%b",address);
    $display("Offset=%h Index=%h Tag=%h",offset,index,tag);
   // response=c.check_cache(index,tag);
   // $display("Response Is=%b",response);
   // a=c.LRU(index,response[`counter_size:1]);
   // $display("evicted  way : %b", c.evict_this_way(index));
    
   //$display("reading from address : %b :: valid bits : %b",address,c.check_cache(index,tag));
        end
    
      case(command)
        `L1_DataCacheRead: begin
              readOp = readOp + 1;
              //Call Check Cache Function
              result = c.check_cache(index,tag);
              //If hit increment hit count
              //else do bus operation
              if(!result[0])
                begin
                //$display("Cache is read from memory");
                way = c.empty_way(index);
                if(way === 3'bxxx)
                begin
                    way = c.find_evict_way(index);
                    dummy = c.evict_way(index,way);
                  end
                
                dummy = c.cache_write(index,tag,way);
                
                if(c.set_mesi(index,tag,way,command,c.GetSnoopResult(address,`R)))
                  dummy = c.LRU(index,way);
                else
                  $display("Error in mesi function");
              end
              else
                begin
                  hitCount = hitCount + 1;
                //$display("cache HIT");
                dummy = c.LRU(index,result[3:1]);
              end
              //Call Cache Write
               end
         
        `L1_DataCacheWrite: begin
              writeOp = writeOp + 1;
              //Call Check Cache Function
              result = c.check_cache(index,tag);
              if(!result[0])
                begin
               //$display("Cache is written from memory");
                way = c.empty_way(index);
                if(way === 3'bxxx)// all ways are filled
                begin
                    way = c.find_evict_way(index);
                    dummy = c.evict_way(index,way);
                  end
                dummy = c.cache_write(index,tag,way);
                if(c.set_mesi(index,tag,way,command,c.GetSnoopResult(address,`W)))
                dummy = c.LRU(index,way);
              //Else Call Bus Operation function
              //Call Cache Write
              
            end
            //If Hit Call Cache Write Function
          else
            begin
              //$display("Cache is write HIT");
            dummy = c.cache_write(index,result[3:1]);
            if(c.set_mesi(index,tag,way,command,c.GetSnoopResult(address,`W)))
            dummy = c.LRU(index,result[3:1]);
          end 
               end
               
        `L1_InstructionCacheRead: begin
                  readOp = readOp + 1;
              //Call Check Cache Function
              result = c.check_cache(index,tag);
              //If hit increment hit count
              //else do bus operation
              if(!result[0])
                begin
                //$display("Cache is read from memory");
                way = c.empty_way(index);
                if(way === 3'bxxx)
                way = c.find_evict_way(index);
                
                dummy = c.cache_write(index,tag,way);
                
                if(c.set_mesi(index,tag,way,command,c.GetSnoopResult(address,`R)))
                  dummy = c.LRU(index,way);
                else
                  $display("Error in mesi function");
              end
              else
                begin
                  hitCount = hitCount + 1;
                //$display("cache HIT");
                dummy = c.LRU(index,result[3:1]);
              end
              //Call Cache Write
               end
        `SnoopInvalidateRequest: begin
              //Call Check Cache 
              //Call Put Snoop Function 
              //Call MESI
                end
        
        `SnoopReadRequest: begin
                //Call Check Cache
                //Call Put Snoop Function
                //Call MESI
                end
                
        `SnoopWriteRequest: begin
                //Call Check Cache
                //Call Put Snoop
                //Call MESI
                end
                
        `SnoopRFO: begin 
               //Call Check Cache 
               //Call Put Snoop
               //Call MESI 
               end
               
        `ClearCache: begin
               //Clear all lines 
               end
               
        `PrintCache: begin
              //Call print function
              dummy = c.print(0);
                end 
                
        default:begin
                $display("\n This Command is not supported by current version. Please contact Sameer,Sanket and Rob");
                end
      endcase
  end
  $display("hit = %d, read = %d, write = %d",hitCount,readOp,writeOp);
end
  
endmodule 