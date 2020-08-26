module mem_addr_gen(
   input clk,
   input rst,
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output [16:0] pixel_addr,
   input [3:0]direction,
   output [9:0]h_pac,
   output [9:0]v_pac,
   input [7:0]eaten,
   output [9:0]h_gho,
   output [9:0]v_gho,
   output [9:0]h_gho2,
   output [9:0]v_gho2,
   input space,
   output [1:0]life
   );
   reg [16:0] pixel_tmp; 
   reg [7:0] position;
   reg [4:0]print_h,next_h=0,print_v,next_v=0;
   reg [9:0] hcnt_pic,vcnt_pic;
   reg [10:0]counter,next_counter=0;
   reg [9:0]h_pac,v_pac,h_gho,h_gho2,v_gho,v_gho2;
   reg [3:0] dir,dir2;
   reg [1:0]life;
   reg bang;
assign pixel_addr=pixel_tmp;
 
always @(h_cnt or v_cnt)begin
    if(!space)begin
        if((h_cnt)<((220)+200) && (h_cnt)>(220) && (v_cnt)>(290) && (v_cnt)<((290)+100))begin
            pixel_tmp =((h_cnt)-(220)+200*((v_cnt)-(290)))%20000;
        end
    end
    else begin
        if(life!=0)begin
            if(eaten!=8'b11111111)begin
            
                if((h_cnt)<((h_pac)+20) && (h_cnt)>(h_pac) && (v_cnt)>(v_pac) && (v_cnt)<((v_pac)+20))begin
                    pixel_tmp =((h_cnt)-(h_pac)+20*((v_cnt)-(v_pac)))%400;
                end
                else if((h_cnt)<((147)+15) && (h_cnt)>(147) && (v_cnt)>(50) && (v_cnt)<((50)+15) && eaten[0]==0)begin
                    pixel_tmp =((h_cnt)-(147)+15*((v_cnt)-(50)))%225;
                end
                else if((h_cnt)<((147)+15) && (h_cnt)>(147) && (v_cnt)>(141) && (v_cnt)<((141)+15) && eaten[1]==0)begin
                    pixel_tmp =((h_cnt)-(147)+15*((v_cnt)-(141)))%225;
                end
                else if((h_cnt)<((147)+15) && (h_cnt)>(147) && (v_cnt)>(304) && (v_cnt)<((304)+15) && eaten[2]==0)begin
                    pixel_tmp =((h_cnt)-(147)+15*((v_cnt)-(304)))%225;
                end
                else if((h_cnt)<((147)+15) && (h_cnt)>(147) && (v_cnt)>(395) && (v_cnt)<((395)+15) && eaten[3]==0)begin
                    pixel_tmp =((h_cnt)-(147)+15*((v_cnt)-(395)))%225;
                end
                else if((h_cnt)<((478)+15) && (h_cnt)>(478) && (v_cnt)>(50) && (v_cnt)<((50)+15) && eaten[4]==0)begin
                    pixel_tmp =((h_cnt)-(478)+15*((v_cnt)-(50)))%225;
                end
                else if((h_cnt)<((478)+15) && (h_cnt)>(478) && (v_cnt)>(141) && (v_cnt)<((141)+15) && eaten[5]==0)begin
                    pixel_tmp =((h_cnt)-(478)+15*((v_cnt)-(141)))%225;
                end        
                else if((h_cnt)<((478)+15) && (h_cnt)>(478) && (v_cnt)>(304) && (v_cnt)<((304)+15) && eaten[6]==0)begin
                    pixel_tmp =((h_cnt)-(478)+15*((v_cnt)-(304)))%225;
                end
                else if((h_cnt)<((478)+15) && (h_cnt)>(478) && (v_cnt)>(395) && (v_cnt)<((395)+15) && eaten[7]==0)begin
                    pixel_tmp =((h_cnt)-(478)+15*((v_cnt)-(395)))%225;
                end      
                else if((h_cnt)<((h_gho)+20) && (h_cnt)>(h_gho) && (v_cnt)>(v_gho) && (v_cnt)<((v_gho)+20))begin
                    pixel_tmp =((h_cnt)-(h_gho)+20*((v_cnt)-(v_gho)))%400;
                end 
                else if((h_cnt)<((h_gho2)+20) && (h_cnt)>(h_gho2) && (v_cnt)>(v_gho2) && (v_cnt)<((v_gho2)+20))begin
                    pixel_tmp =((h_cnt)-(h_gho2)+20*((v_cnt)-(v_gho2)))%400;
                end                                        
                else begin
                    pixel_tmp = ((h_cnt>>1)+320*(v_cnt>>1) )% 76800;  //640*480 --> 320*240 
                end
            end
            else begin
                if((h_cnt)<((220)+150) && (h_cnt)>(220) && (v_cnt)>(290) && (v_cnt)<((290)+100))begin
                    pixel_tmp =((h_cnt)-(220)+150*((v_cnt)-(290)))%15000;
                end
            end
        end
        else begin
            if((h_cnt)<((220)+150) && (h_cnt)>(220) && (v_cnt)>(290) && (v_cnt)<((290)+100))begin
                    pixel_tmp =((h_cnt)-(220)+150*((v_cnt)-(290)))%15000;
            end
        end
    end
 end  
 
 
 always@(posedge clk or posedge rst)begin
    if(rst)begin
        life<=2'b11;
        bang<=0;
    end
    else begin
        if((h_pac<=(h_gho+17)&&v_pac<=(v_gho+17)&&h_pac>=h_gho&&v_pac>=v_gho)||(h_gho<=(h_pac+17)&&v_gho<=(v_pac+17)&&h_gho>=h_pac&&v_gho>=v_pac)||(h_pac<=(h_gho2+17)&&v_pac<=(v_gho2+17)&&h_pac>=h_gho2&&v_pac>=v_gho2)||(h_gho2<=(h_pac+17)&&v_gho2<=(v_pac+17)&&h_gho2>=h_pac&&v_gho2>=v_pac))begin
            bang<=1;
            if(bang==0 && life>=1)
                life<=life-1;
            else begin
                life<=life;
            end
        end
        else begin
            bang<=0;
            life<=life;
        end
    end
 end
 
 
 ////////////////////////////////////////////////////////
always @ (posedge clk or posedge rst) begin
        if(rst)begin
            dir<=4'b0100; //down
        end
        else if(((h_gho-h_pac<2)||(h_gho-h_pac>-2))&&((v_gho-v_pac<21)||(v_gho-v_pac>-21)))begin
            dir<=(v_gho>v_pac)?4'b0001:4'b0100;
        end
        else begin
            //up-down
            if((((h_gho>=208)&&(h_gho<=211))||((h_gho>=413)&&(h_gho<=416))||(h_gho>=475&&h_gho<=478&&(v_gho>299||v_gho<=146))||(h_gho>=142&&h_gho<=144&&(v_gho>299||v_gho<=146)))&&(v_gho>v_pac+19))// up
                dir <= 4'b0001; 
            else if((((h_gho>=208)&&(h_gho<=211))||((h_gho>=413)&&(h_gho<=416))||(h_gho>=475&&h_gho<=478&&(v_gho>=299||v_gho<146))||(h_gho>=142&&h_gho<=144&&(v_gho>=299||v_gho<146)))&&(v_gho<v_pac-19))
                dir <= 4'b0100;
            //left-right
             else if((v_gho>=44&&v_gho<=47)||(v_gho>=144&&v_gho<=146)||(v_gho>=299&&v_gho<=301)||(v_gho>=398&&v_gho<=400))begin
                if(h_gho>h_pac+5) dir <= 4'b0010; //left
                else if(h_gho<h_pac-5) dir <= 4'b1000; //right
                else  dir<=dir;
             end
             
              else  dir<=dir;
        end
  end
 //////////////////////////////////////////////
   //ghost 1 cordinate
   always @ (posedge clk or posedge rst) begin
      if(rst || bang)begin
          h_gho<=413;
          v_gho<=45;          
      end
      else begin
            if(life==0 || eaten==8'b11111111)begin
                   h_gho<=413;
                   v_gho<=146;
              end else begin
           if(dir==4'b0001 && space)begin //up
                h_gho<=h_gho;
                if(v_gho<=45) v_gho<=45;
                else v_gho<=v_gho-1;
           end

     
           else if(dir==4'b0100 && space)begin //down
                h_gho<=h_gho;
                if(v_gho>=400) v_gho<=400;
                else v_gho<=v_gho+1;
           end

             
           else if(dir==4'b0010 && space)begin //left
                v_gho<=v_gho;
                if(h_gho<=142) h_gho<=142;
                else h_gho<=h_gho-1;
           end

       
           else if(dir==4'b1000  && space)begin //right
                v_gho<=v_gho;
                if(h_gho>=478) h_gho<=478;
                else h_gho<=h_gho+1;
          end 
       
           else begin
           h_gho<=h_gho;
           v_gho<=v_gho;
           end     
        end
        end
   end

 ////////////////////////////////////////////////////////
always @ (posedge clk or posedge rst) begin
         if(rst)begin
             dir2<=4'b0100; //down
         end
         else if(((h_gho2-h_pac<2)||(h_gho2-h_pac>-2))&&((v_gho2-v_pac<21)||(v_gho2-v_pac>-21)))begin
             dir2<=(v_gho2>v_pac)?4'b0001:4'b0100;
         end
         else begin
             //up-down
             if((((h_gho2>=208)&&(h_gho2<=211))||((h_gho2>=413)&&(h_gho2<=416))||(h_gho2>=475&&h_gho2<=478&&(v_gho2>299||v_gho2<=146))||(h_gho2>=142&&h_gho2<=144&&(v_gho2>299||v_gho2<=146)))&&(v_gho2>v_pac+19))// up
                 dir2 <= 4'b0001; 
             else if((((h_gho2>=208)&&(h_gho2<=211))||((h_gho2>=413)&&(h_gho2<=416))||(h_gho2>=475&&h_gho2<=478&&(v_gho2>=299||v_gho2<146))||(h_gho2>=142&&h_gho2<=144&&(v_gho2>=299||v_gho2<146)))&&(v_gho2<v_pac-19))
                 dir2 <= 4'b0100;
             //left-right
              else if((v_gho2>=44&&v_gho2<=47)||(v_gho2>=144&&v_gho2<=146)||(v_gho2>=299&&v_gho2<=301)||(v_gho2>=398&&v_gho2<=400))begin
                 if(h_gho2>h_pac+5) dir2 <= 4'b0010; //left
                 else if(h_gho2<h_pac-5) dir2 <= 4'b1000; //right
                 else  dir2<=dir2;
              end
              
               else  dir2<=dir2;
         end
   end
  //////////////////////////////////////////////
    //ghost 2 cordinate
    always @ (posedge clk or posedge rst) begin
       if(rst || bang)begin
           h_gho2<=208;
           v_gho2<=146;         
       end
       else if (((h_gho2-h_gho<22)||(h_gho2-h_gho>-22))&&((v_gho2-v_gho<22)||(v_gho2-v_gho>-22))) begin 
                       h_gho2<=h_gho2;
                       v_gho2<=v_gho2;
       end
       else begin
             if(life==0 || eaten==8'b11111111)begin
                    h_gho2<=208;
                    v_gho2<=146;
               end else begin
            if(dir2==4'b0001 && space)begin //up
                 h_gho2<=h_gho2;
                 if(v_gho2<=45) v_gho2<=45;
                 else v_gho2<=v_gho2-1;
            end
 
      
            else if(dir2==4'b0100 && space)begin //down
                 h_gho2<=h_gho2;
                 if(v_gho2>=400) v_gho2<=400;
                 else v_gho2<=v_gho2+1;
            end
 
              
            else if(dir2==4'b0010 && space)begin //left
                 v_gho2<=v_gho2;
                 if(h_gho2<=142) h_gho2<=142;
                 else h_gho2<=h_gho2-1;
            end
 
        
            else if(dir2==4'b1000 && space)begin //right
                 v_gho2<=v_gho2;
                 if(h_gho2>=478) h_gho2<=478;
                 else h_gho2<=h_gho2+1;
           end 
        
            else begin
            h_gho2<=h_gho2;
            v_gho2<=v_gho2;
            end     
         end
         end
    end


//-------------------------------------------------------------------------------------
//pecman  cordinate 
   always @ (posedge clk or posedge rst) begin
      if(rst || bang)begin
          h_pac<=476;
          v_pac<=364;
      end
      else begin
          if( (life==0)|| eaten==8'b11111111)begin
            h_pac<=476;
            v_pac<=364;
          end
          else begin
                if(direction==4'b0001)begin
                h_pac<=h_pac;
                if(((h_pac>=208)&&(h_pac<=211))||((h_pac>=413)&&(h_pac<=416))||(h_pac>=475&&h_pac<=478&&(v_pac>299||v_pac<=146))||(h_pac>=142&&h_pac<=144&&(v_pac>299||v_pac<=146)))begin
                    if(v_pac<=45)begin
                        v_pac<=45;
                    end
                    else begin
                        v_pac<=v_pac-1;
                    end
                end
                else begin
                    v_pac<=v_pac;
                end
            end    
      else if(direction==4'b0100)begin
           h_pac<=h_pac;
           if(((h_pac>=208)&&(h_pac<=211))||((h_pac>=413)&&(h_pac<=416))||(h_pac>=475&&h_pac<=478&&(v_pac>=299||v_pac<146))||(h_pac>=142&&h_pac<=144&&(v_pac>=299||v_pac<146)))begin
                if(v_pac>=400)begin
                    v_pac<=400;
                end
                else begin
                    v_pac<=v_pac+1;
                end
           end
           else begin
                v_pac<=v_pac;
           end
      end    
      else if(direction==4'b0010)begin
           v_pac<=v_pac;
           if((v_pac>=44&&v_pac<=47)||(v_pac>=144&&v_pac<=146)||(v_pac>=299&&v_pac<=301)||(v_pac>=398&&v_pac<=400))begin
                if(h_pac<=142)begin
                    h_pac<=142;
                end
                else begin
                    h_pac<=h_pac-1;
                end
           end
           else begin
                h_pac<=h_pac;
           end
      end          
      else if(direction==4'b1000)begin
           v_pac<=v_pac;
           if((v_pac>=44&&v_pac<=47)||(v_pac>=144&&v_pac<=146)||(v_pac>=299&&v_pac<=301)||(v_pac>=398&&v_pac<=400))begin
                if(h_pac>=478)begin
                    h_pac<=478;
                end
                else begin
                    h_pac<=h_pac+1;
                end
          end
          else begin
                h_pac<=h_pac;
          end      
      end          
      else begin
           h_pac<=h_pac;
           v_pac<=v_pac;
      end     
   end
   end
end    
endmodule
