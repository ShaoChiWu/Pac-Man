module top(
   input clk,
   input rst,
   inout wire PS2_DATA,
   inout wire PS2_CLK,
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync,
   output [1:0] life
    );

    wire [11:0] data,data2;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel,pixel_pic,pixel_pic2,pixel_pic3,pixel_pic4,pixel_fruit,pixel_ghost,pixel_ghost2,pixel_start,pixel_win,pixel_over;
    wire valid;
    //reg check=0;
    //wire [7:0] eaten;
    wire [1:0] life;
    reg [3:0] direction;
    wire [9:0] h_pac,v_pac,h_gho,v_gho,h_gho2,v_gho2;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    reg [7:0] eaten=8'b00000000;
    reg [3:0] vgaRed,vgaGreen,vgaBlue;
    reg [1:0]state,next_state;
    parameter START=2'b00;
    parameter GAME=2'b01;
    parameter END=2'b10;
    parameter [8:0] RIGHT_SHIFT_CODES = 9'b0_0101_1001;
    parameter [8:0] KEY_CODES [0:4] = {
        9'b0_0001_1101,    // W=> 1D 
        9'b0_0001_1100,    // A=> 1C
        9'b0_0001_1011,    // S => 1B
        9'b0_0010_0011,    // D => 23
        9'b0_0010_1001    // 4 => 29
    };
    
    //reg [15:0] nums;
    reg [3:0] key_num;
    reg [9:0] last_key;
    reg space_pressed=0;
    wire [511:0] key_down;
    wire [8:0] last_change;
    wire been_ready;
   

    KeyboardDecoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );

    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            direction<=0;
            space_pressed<=0;
        end else begin
            
            if (been_ready && key_down[last_change] == 1'b1) begin
                if (key_num != 4'b1111)begin
                    if(key_num==4'b0000)begin
                        direction<=4'b0001;
                        space_pressed<=space_pressed;
                    end
                    else if(key_num==4'b0001) begin
                        direction<=4'b0010;
                        space_pressed<=space_pressed;
                    end
                    else if(key_num==4'b0010) begin
                        direction<=4'b0100;
                        space_pressed<=space_pressed;
                    end
                    else if(key_num==4'b0011)begin
                        direction<=4'b1000;                        
                        space_pressed<=space_pressed;
                    end
                    else if(key_num==4'b0100) begin
                        space_pressed<=1;
                        direction<=direction;
                    end
                    else begin
                        direction<=direction;
                        space_pressed<=space_pressed;
                    end
                end
                else begin
                    direction<=direction;
                    space_pressed<=space_pressed;
                end
            end
        end
    end
    
    always @ (*) begin
        case (last_change)
            KEY_CODES[00] : key_num = 4'b0000;
            KEY_CODES[01] : key_num = 4'b0001;
            KEY_CODES[02] : key_num = 4'b0010;
            KEY_CODES[03] : key_num = 4'b0011;
            KEY_CODES[04] : key_num = 4'b0100;
            KEY_CODES[05] : key_num = 4'b0101;

            default : key_num = 4'b1111;
        endcase
    end
    always @(posedge clk) begin
         if(rst)begin
            eaten<=8'b00000000;
         end
         else begin 
            if((h_pac+20)>=((147)+15) && (h_pac)<=(147) && (v_pac)<=(50) && (v_pac+20)>=((50)+15))begin
                eaten[0]<=1;
            end
            else if((h_pac+20)>=((147)+15) && (h_pac)<=(147) && (v_pac)<=(141) && (v_pac+20)>=((141)+15))begin
                eaten[1]<=1;
            end 
            else if((h_pac+20)>=((147)+15) && (h_pac)<=(147) && (v_pac)<=(304) && (v_pac+20)>=((304)+15))begin
                eaten[2]<=1;
            end 
            else if((h_pac+20)>=((147)+15) && (h_pac)<=(147) && (v_pac)<=(395) && (v_pac+20)>=((395)+15))begin
                eaten[3]<=1;
            end 
            else if((h_pac+20)>=((478)+15) && (h_pac)<=(478) && (v_pac)<=(50) && (v_pac+20)>=((50)+15))begin
                eaten[4]<=1;
            end 
            else if((h_pac+20)>=((478)+15) && (h_pac)<=(478) && (v_pac)<=(141) && (v_pac+20)>=((141)+15))begin
                eaten[5]<=1;
            end 
            else if((h_pac+20)>=((478)+15) && (h_pac)<=(478) && (v_pac)<=(304) && (v_pac+20)>=((304)+15))begin
                eaten[6]<=1;
            end 
            else if((h_pac+20)>=((478)+15) && (h_pac)<=(478) && (v_pac)<=(395) && (v_pac+20)>=((395)+15))begin
                eaten[7]<=1;
            end                                                                         
            else begin
                eaten[0]<=eaten[0];
                eaten[1]<=eaten[1];
                eaten[2]<=eaten[2];
                eaten[3]<=eaten[3];
                eaten[4]<=eaten[4];
                eaten[5]<=eaten[5];
                eaten[6]<=eaten[6];
                eaten[7]<=eaten[7];
            end
         end
    end
    
//-------------------------------------------------

always @(posedge clk_25MHz)begin
    if(!space_pressed)begin
           if((h_cnt)<((220)+200) && (h_cnt)>(220+2) && (v_cnt)>(290) && (v_cnt)<((290)+100))begin
                {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_start:12'h0;
           end
           else begin
                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
           end
    end        
    else begin
        if(life!=0)begin
            if(eaten!=8'b11111111)begin
                if((h_cnt)<((h_pac)+20) && (h_cnt)>(h_pac+2) && (v_cnt)>(v_pac) && (v_cnt)<((v_pac)+20))begin
                    case(direction)
                        4'b0001:{vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? ((pixel_pic==12'h0)?pixel:pixel_pic):pixel;
                        4'b0010:{vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? ((pixel_pic3==12'h0)?pixel:pixel_pic3):pixel;
                        4'b0100:{vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? ((pixel_pic2==12'h0)?pixel:pixel_pic2):pixel;
                        4'b1000:{vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? ((pixel_pic4==12'h0)?pixel:pixel_pic4):pixel;
                        4'b0000:{vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? ((pixel_pic==12'h0)?pixel:pixel_pic):pixel;
                    endcase
                end
                else if((h_cnt)<((147)+15) && (h_cnt)>(149) && (v_cnt)>(50) && (v_cnt)<((50)+15)&&eaten[0]==0&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_fruit:12'h0;
                end  
                else if((h_cnt)<((147)+15) && (h_cnt)>(149) && (v_cnt)>(141) && (v_cnt)<((141)+15) && eaten[1]==0&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_fruit:12'h0;
                end
                else if((h_cnt)<((147)+15) && (h_cnt)>(149) && (v_cnt)>(304) && (v_cnt)<((304)+15) && eaten[2]==0&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_fruit:12'h0;
                end
                else if((h_cnt)<((147)+15) && (h_cnt)>(149) && (v_cnt)>(395) && (v_cnt)<((395)+15) && eaten[3]==0&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_fruit:12'h0;
                end
                else if((h_cnt)<((478)+15) && (h_cnt)>(480) && (v_cnt)>(50) && (v_cnt)<((50)+15) && eaten[4]==0&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_fruit:12'h0;
                end
                else if((h_cnt)<((478)+15) && (h_cnt)>(480) && (v_cnt)>(141) && (v_cnt)<((141)+15) && eaten[5]==0&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_fruit:12'h0;
                end
                else if((h_cnt)<((478)+15) && (h_cnt)>(480) && (v_cnt)>(304) && (v_cnt)<((304)+15) && eaten[6]==0&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_fruit:12'h0;
                end
                else if((h_cnt)<((478)+15) && (h_cnt)>(480) && (v_cnt)>(395) && (v_cnt)<((395)+15) && eaten[7]==0&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_fruit:12'h0;
                end     
                else if((h_cnt)<((h_gho)+20) && (h_cnt)>(h_gho+2) && (v_cnt)>(v_gho) && (v_cnt)<((v_gho)+20)&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_ghost:12'h0;
                end
                else if((h_cnt)<((h_gho2)+20) && (h_cnt)>(h_gho2+2) && (v_cnt)>(v_gho2) && (v_cnt)<((v_gho2)+20)&&space_pressed==1)begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_ghost2:12'h0;
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1&&space_pressed==1) ? pixel:12'h0;
                end
            end
            else begin
                if((h_cnt)<((220)+150) && (h_cnt)>(220+2) && (v_cnt)>(290) && (v_cnt)<((290)+100))begin
                    {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_win:12'h0;
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                end
            end
        end
        else begin
            if((h_cnt)<((220)+150) && (h_cnt)>(220+2) && (v_cnt)>(290) && (v_cnt)<((290)+100))begin
                {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_over:12'h0;
            end
            else begin
                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
            end
        end
    end         
end
     clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22)
    );

    mem_addr_gen mem_addr_gen_inst(
    .clk(clk_22),
    .rst(rst),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt),
    .pixel_addr(pixel_addr),
    .direction(direction),
    .h_pac(h_pac),
    .v_pac(v_pac),
    .eaten(eaten),
    .h_gho(h_gho),
    .v_gho(v_gho),
    .h_gho2(h_gho2),
    .v_gho2(v_gho2),
    .space(space_pressed),
    .life(life)
    );
     
 
    blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel)
    ); 
    blk_mem_gen_1 blk_mem_gen_1_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_pic)
    ); 
    blk_mem_gen_2 blk_mem_gen_2_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_fruit)
    ); 
    blk_mem_gen_3 blk_mem_gen_3_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_pic2)
    ); 
    blk_mem_gen_4 blk_mem_gen_4_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_pic3)
    ); 
    blk_mem_gen_5 blk_mem_gen_5_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_pic4)
    );       
    //to be called
    blk_mem_gen_6 blk_mem_gen_6_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_ghost)
    );       
    blk_mem_gen_7 blk_mem_gen_7_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_ghost2)
    );       
     blk_mem_gen_8 blk_mem_gen_8_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_start)
       );
      blk_mem_gen_9 blk_mem_gen_9_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_win)
      );   
      blk_mem_gen_10 blk_mem_gen_10_inst(
          .clka(clk_25MHz),
          .wea(0),
          .addra(pixel_addr),
          .dina(data[11:0]),
          .douta(pixel_over)
      );                
    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
      
endmodule

//decoder
module KeyboardDecoder(
	output reg [511:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [511:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	OnePulse op (
		.signal_single_pulse(pulse_been_ready),
		.signal(been_ready),
		.clock(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 511'b0;
    	end else if (key_decode[last_change] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end
endmodule
//onepulse
module OnePulse (
	output reg signal_single_pulse,
	input wire signal,
	input wire clock
	);
	
	reg signal_delay;

	always @(posedge clock) begin
		if (signal == 1'b1 & signal_delay == 1'b0)
		  signal_single_pulse <= 1'b1;
		else
		  signal_single_pulse <= 1'b0;

		signal_delay <= signal;
	end
endmodule

