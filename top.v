// DO NOT CHANGE THE NAME OR THE SIGNALS OF THIS MODULE

module top (
  input        clk    ,
  input  [3:0] sw     ,
  input  [3:0] btn    ,
  output [7:0] led    ,
  output [7:0] seven  ,
  output [3:0] segment
);

/* Your module instantiations go to here. */

wire clk_div;      
wire myBtn2, myBtn0, myBtn1, myBtn3;    
wire [7:0] seven0;
wire [7:0] seven1;
wire [7:0] seven2;
wire [7:0] seven3;

clk_divider clk_div_inst (
  .clk_in(clk), 
  .divided_clk(clk_div)
);


debouncer forBtn2 (
  .clk(clk_div),  
  .rst(1'b0),      
  .noisy_in(~btn[2]), 
  .clean_out(myBtn2) 
);

debouncer forBtn0 (
  .clk(clk_div), 
  .rst(1'b0),  
  .noisy_in(~btn[0]),  
  .clean_out(myBtn0) 
);

debouncer forBtn1 (
  .clk(clk_div), 
  .rst(1'b0),  
  .noisy_in(~btn[1]),  
  .clean_out(myBtn1) 
);

debouncer forBtn3 (
  .clk(clk_div), 
  .rst(1'b0),  
  .noisy_in(~btn[3]),  
  .clean_out(myBtn3) 
);


battleship myBattle (
  .clk(clk_div), 
  .rst(myBtn2), 
  .start(myBtn1), 
  .X(sw[3:2]), 
  .Y(sw[1:0]), 
  .pAb(myBtn3), 
  .pBb(myBtn0), 
  .disp0(seven0), 
  .disp1(seven1), 
  .disp2(seven2), 
  .disp3(seven3), 
  .led(led)
);

ssd mySSD (
  .clk(clk),
  .disp0(seven0),
  .disp1(seven1), 
  .disp2(seven2), 
  .disp3(seven3),
  .seven(seven),
  .segment(segment)
);

endmodule

module battleship (
  input            clk  ,
  input            rst  ,
  input            start,
  input      [1:0] X    ,
  input      [1:0] Y    ,
  input            pAb  ,
  input            pBb  ,
  output reg [7:0] disp0,
  output reg [7:0] disp1,
  output reg [7:0] disp2,
  output reg [7:0] disp3,
  output reg [7:0] led
);

/* Your design goes here. */

parameter [3:0] IDLE = 4'b0000, SHOW_A = 4'b0001, A_IN = 4'b0010, ERROR_A = 4'b0011, SHOW_B = 4'b0100, B_IN = 4'b0101, ERROR_B = 4'b0110, SHOW_SCORE = 4'b0111, A_SHOOT = 4'b1000, A_SINK = 4'b1001, A_WIN = 4'b1010, B_SHOOT = 4'b1011, B_SINK = 4'b1100, B_WIN = 4'b1101, yalandan_1 = 4'b1110, yalandan_2 = 4'b1111;

reg [3:0] state, next_state;
reg [5:0] timer; // 1 sec 50 clock  (50hz)
reg [15:0] mapA;
reg [15:0] mapB;
reg [2:0] inputCount;
reg Z;
reg [2:0] scoreA, scoreB;
reg ledDance;

always @(posedge clk or posedge rst) begin
  if(rst) begin
    state <= IDLE;
    mapA <= 16'b0;
    mapB <= 16'b0;
    inputCount <= 0;
    Z <= 0;
    ledDance <= 0;
    scoreA <= 0;
    scoreB <= 0;
    timer <= 0;
  end else begin
    case (state)

    IDLE:
    begin
      if(start)       state <= SHOW_A;
      else            state <= IDLE;
    end

    SHOW_A:
    begin
      timer <= timer + 1'b1;
      if(timer < 50)      state <= SHOW_A;
      else                state <= A_IN;
    end

    A_IN:
    begin
      timer <= 0;
      if (pAb) begin
        if (mapA[X + 4*Y])      state <= ERROR_A;
        else begin
          if (inputCount > 2)begin
            inputCount <= 0;
            mapA[X + 4*Y] <= 1'b1;
            state <= SHOW_B;
          end
          else begin
            mapA[X + 4*Y] <= 1'b1;
            inputCount <= inputCount + 1;
            state <= A_IN;
          end
        end
      end  
      else                      state <= A_IN;
    end

    ERROR_A:
    begin
      timer <= timer + 1'b1;
      if(timer < 50)    state <= ERROR_A;
      else              state <= A_IN;
    end

    SHOW_B:
    begin
      timer <= timer + 1'b1;
      if(timer < 50)      state <= SHOW_B;
      else                state <= B_IN;
    end

    B_IN:
    begin
      timer <= 0;
      if (pBb) begin
        if (mapB[X + 4*Y])      state <= ERROR_B;
        else begin
          if (inputCount > 2)begin
            mapB[X + 4*Y] <= 1'b1;
            state <= SHOW_SCORE;
          end
          else begin
            inputCount <= inputCount + 1;
            mapB[X + 4*Y] <= 1'b1;
            state <= B_IN;
          end
        end
      end 
      else                      state <= B_IN;
    end

    ERROR_B:
    begin
      timer <= timer + 1'b1;
      if (timer < 50)   state <= ERROR_B;
      else              state <= B_IN;
    end
    
    SHOW_SCORE:
    begin
      timer <= timer + 1'b1;
      if (timer < 50) state <= SHOW_SCORE;
      else            state <= A_SHOOT;
    end

    A_SHOOT:
    begin
      timer <= 0;
      if (pAb) begin
        if (mapB[X + 4*Y] == 1'b1) begin
          scoreA <= scoreA + 1;
          Z <= 1;
          mapB[X + 4*Y] <= 1'b0;
          state <= A_SINK;
        end else begin
          scoreA <= scoreA;
          Z <= 0;
          state <= A_SINK;
        end
      end
      else      state <= A_SHOOT;
    end

    A_SINK:
    begin
      timer <= timer + 1'b1;
      if (timer < 50) begin 
          state <= A_SINK;
      end
      else begin
        if (scoreA > 3) state <= A_WIN;
        else            state <= B_SHOOT;
      end
    end

    A_WIN:
    begin
      timer <= timer + 1'b1;
      if (timer < 150) begin
        state <= A_WIN;
      end
      else     state <= A_WIN;
    end

    B_SHOOT:
    begin
      timer <= 0;
      if (pBb) begin 
        if (mapA[X + 4*Y] == 1'b1) begin
          scoreB <= scoreB + 1;
          Z <= 1;
          mapA[X + 4*Y] <= 1'b0;
          state <= B_SINK;
      end else begin   
        scoreB <= scoreB;
        Z <= 0;
        state <= B_SINK;
        end
      end 
      else state <= B_SHOOT;
    end


    B_SINK:
    begin
      timer <= timer + 1'b1;
      if (timer < 50) begin 
          state <= B_SINK;
      end
      else begin
        if (scoreB > 3) state <= B_WIN;
        else            state <= A_SHOOT;
      end
    end

    B_WIN:
    begin
      timer <= timer + 1'b1;
      if (timer < 150) begin
        state <= B_WIN;
      end
      else state <= B_WIN;
    end

    yalandan_1:
    begin
      state <= yalandan_2;
    end

    yalandan_2:
    begin
      state <= yalandan_1;
    end

    default: state <= IDLE;
    endcase
    end
end


always @(*)begin

  
  case (state)

    IDLE:
    begin
      disp3 = 8'b00000110; // "I"
      disp2 = 8'b01011110; // "d" 
      disp1 = 8'b00111000; // "L"
      disp0 = 8'b01111001; // "E"

      led = 8'b10011001;
    end 

    SHOW_A:
    begin
      disp3 = 8'b01110111; // "A"
      disp2 = 8'b00000000; 
      disp1 = 8'b00000000; 
      disp0 = 8'b00000000; 

      led = 8'b10011001;
    end

    A_IN: 
    begin

      if (X == 0)         disp1 = 8'b00111111; // 0
      else if (X == 1)    disp1 = 8'b00000110; // 1
      else if (X == 2)    disp1 = 8'b01011011; // 2
      else if (X == 3)    disp1 = 8'b01001111; // 3
      else                disp1 = 8'b01100110; // 4

      if (Y == 0)         disp0 = 8'b00111111; // 0
      else if (Y == 1)    disp0 = 8'b00000110; // 1
      else if (Y == 2)    disp0 = 8'b01011011; // 2
      else if (Y == 3)    disp0 = 8'b01001111; // 3
      else                disp0 = 8'b01100110; // 4
      
      disp3 = 8'b00000000;
      disp2 = 8'b00000000; 

      if (inputCount == 0)         led = 8'b10000000;
      else if (inputCount == 1)    led = 8'b10010000;
      else if (inputCount == 2)    led = 8'b10100000;
      else if (inputCount == 3)    led = 8'b10110000;
      else led = 8'b10100000; 
    end  

    ERROR_A:
    begin
      disp3 = 8'b01111001;  // E
      disp2 = 8'b01010000;  // r
      disp1 = 8'b01010000;  // r
      disp0 = 8'b01011100;  // o
      led = 8'b10011001;    // 7 4 3 0
    end

    SHOW_B:
    begin
      disp3 = 8'b01111100;  // b
      disp2 = 8'b00000000; 
      disp1 = 8'b00000000; 
      disp0 = 8'b00000000; 
      led = 8'b10011001;    // 7 4 3 0
    end

    B_IN:
    begin

      if (X == 0)         disp1 = 8'b00111111; // 0
      else if (X == 1)    disp1 = 8'b00000110; // 1
      else if (X == 2)    disp1 = 8'b01011011; // 2
      else if (X == 3)    disp1 = 8'b01001111; // 3
      else                disp1 = 8'b01100110; // 4

      if (Y == 0)         disp0 = 8'b00111111; // 0
      else if (Y == 1)    disp0 = 8'b00000110; // 1
      else if (Y == 2)    disp0 = 8'b01011011; // 2
      else if (Y == 3)    disp0 = 8'b01001111; // 3
      else                disp0 = 8'b01100110; // 4
      disp3 = 8'b00000000;
      disp2 = 8'b00000000; 

      if (inputCount == 0)         led = 8'b00000001;
      else if (inputCount == 1)    led = 8'b00000101;
      else if (inputCount == 2)    led = 8'b00001001;
      else if (inputCount == 3)    led = 8'b00001101;
      else led = 8'b00001001;
    end

    ERROR_B:
    begin
      disp3 = 8'b01111001;  // E
      disp2 = 8'b01010000;  // r
      disp1 = 8'b01010000;  // r
      disp0 = 8'b01011100;  // o
      led = 8'b10011001;    // 7 4 3 0
    end

    SHOW_SCORE:
    begin
      disp3 = 8'b00000000; 
      disp2 = 8'b00111111;  // 0
      disp1 = 8'b01000000;  // -
      disp0 = 8'b00111111;  // 0 
      led = 8'b10011001;
    end

    A_SHOOT:  
    begin

      if (X == 0)         disp1 = 8'b00111111; // 0
      else if (X == 1)    disp1 = 8'b00000110; // 1
      else if (X == 2)    disp1 = 8'b01011011; // 2
      else if (X == 3)    disp1 = 8'b01001111; // 3
      else                disp1 = 8'b01100110; // 4

      if (Y == 0)         disp0 = 8'b00111111; // 0
      else if (Y == 1)    disp0 = 8'b00000110; // 1
      else if (Y == 2)    disp0 = 8'b01011011; // 2
      else if (Y == 3)    disp0 = 8'b01001111; // 3
      else                disp0 = 8'b01100110; // 4
      disp3 = 8'b00000000; 
      disp2 = 8'b00000000; 

      led = 8'b10000000;
      // A part:
      if (scoreA == 0)         led = led | 8'b00000000;
      else if (scoreA == 1)    led = led | 8'b00010000;
      else if (scoreA == 2)    led = led | 8'b00100000;
      else                     led = led | 8'b00110000;
      // B part:
      if (scoreB == 0)         led = led | 8'b00000000;
      else if (scoreB == 1)    led = led | 8'b00000100;
      else if (scoreB == 2)    led = led | 8'b00001000;
      else                     led = led | 8'b00001100; 
    
    end

    A_SINK:
    begin
      disp3 = 8'b00000000;
      disp1 = 8'b01000000;  // -

      if(scoreA == 0)         disp2 = 8'b00111111;
      else if (scoreA == 1)   disp2 = 8'b00000110;
      else if (scoreA == 2)   disp2 = 8'b01011011;
      else if (scoreA == 3)   disp2 = 8'b01001111;
      else                    disp2 = 8'b01100110;
    
      if(scoreB == 0)         disp0 = 8'b00111111;
      else if (scoreB == 1)   disp0 = 8'b00000110;
      else if (scoreB == 2)   disp0 = 8'b01011011;
      else if (scoreB == 3)   disp0 = 8'b01001111;
      else                    disp0 = 8'b01100110;

      if (Z)    led = 8'b11111111;
      else      led = 8'b00000000;
      disp1 = 8'b01000000;  // -
    end

    A_WIN:
    begin
      disp3 = 8'b01110111; // "A"
      disp1 = 8'b01000000;  // -

      if(scoreA == 0)         disp2 = 8'b00111111;
      else if (scoreA == 1)   disp2 = 8'b00000110;
      else if (scoreA == 2)   disp2 = 8'b01011011;
      else if (scoreA == 3)   disp2 = 8'b01001111;
      else                    disp2 = 8'b01100110;
    
      if(scoreB == 0)         disp0 = 8'b00111111;
      else if (scoreB == 1)   disp0 = 8'b00000110;
      else if (scoreB == 2)   disp0 = 8'b01011011;
      else if (scoreB == 3)   disp0 = 8'b01001111;
      else                    disp0 = 8'b01100110;

    led = 8'b10101010;
    end

    B_SHOOT:  
    begin

      if (X == 0)         disp1 = 8'b00111111; // 0
      else if (X == 1)    disp1 = 8'b00000110; // 1
      else if (X == 2)    disp1 = 8'b01011011; // 2
      else if (X == 3)    disp1 = 8'b01001111; // 3
      else                disp1 = 8'b01100110; // 4

      if (Y == 0)         disp0 = 8'b00111111; // 0
      else if (Y == 1)    disp0 = 8'b00000110; // 1
      else if (Y == 2)    disp0 = 8'b01011011; // 2
      else if (Y == 3)    disp0 = 8'b01001111; // 3
      else                disp0 = 8'b01100110; // 4
      disp3 = 8'b00000000; 
      disp2 = 8'b00000000; 

      led = 8'b00000001;
      // A part:
      if (scoreA == 0)         led = led | 8'b00000000;
      else if (scoreA == 1)    led = led | 8'b00010000;
      else if (scoreA == 2)    led = led | 8'b00100000;
      else                     led = led | 8'b00110000;
      // B part:
      if (scoreB == 0)         led = led | 8'b00000000;
      else if (scoreB == 1)    led = led | 8'b00000100;
      else if (scoreB == 2)    led = led | 8'b00001000;
      else                     led = led | 8'b00001100; 
    end

    B_SINK:
    begin
      disp3 = 8'b00000000;
      disp1 = 8'b01000000;  // -

      if(scoreA == 0)         disp2 = 8'b00111111;
      else if (scoreA == 1)   disp2 = 8'b00000110;
      else if (scoreA == 2)   disp2 = 8'b01011011;
      else if (scoreA == 3)   disp2 = 8'b01001111;
      else                    disp2 = 8'b01100110;
    
      if(scoreB == 0)         disp0 = 8'b00111111;
      else if (scoreB == 1)   disp0 = 8'b00000110;
      else if (scoreB == 2)   disp0 = 8'b01011011;
      else if (scoreB == 3)   disp0 = 8'b01001111;
      else                    disp0 = 8'b01100110;

      if (Z)    led = 8'b11111111;
      else      led = 8'b00000000;

    end

    B_WIN:
    begin
      disp3 = 8'b01111100;  // b
      disp1 = 8'b01000000;  // -

      if(scoreA == 0)         disp2 = 8'b00111111;
      else if (scoreA == 1)   disp2 = 8'b00000110;
      else if (scoreA == 2)   disp2 = 8'b01011011;
      else if (scoreA == 3)   disp2 = 8'b01001111;
      else                    disp2 = 8'b01100110;
    
      if(scoreB == 0)         disp0 = 8'b00111111;
      else if (scoreB == 1)   disp0 = 8'b00000110;
      else if (scoreB == 2)   disp0 = 8'b01011011;
      else if (scoreB == 3)   disp0 = 8'b01001111;
      else                    disp0 = 8'b01100110;

      led = 8'b10101010;
    
    end
   
    default:
    begin
      disp0 = 8'b00000000;
      disp1 = 8'b00000000;
      disp2 = 8'b00000000;
      disp3 = 8'b00000000;
      led   = 8'b00000000;
    end
  endcase

end
endmodule



// DO NOT CHANGE THIS MODULE

/*
It is possible to change the frequency of the output clock
by changing the toggle_value
27 MHz to 50 Hz
*/

module clk_divider (
  input      clk_in     ,
  output reg divided_clk
);

  parameter  toggle_value = 270000;
  reg [24:0] cnt                 ;

  initial begin
    cnt = 0;
    divided_clk = 0;
  end

  always@(posedge clk_in)
    begin
      if (cnt==toggle_value) begin
        cnt         <= 0;
        divided_clk <= ~divided_clk;
      end
      else begin
        cnt         <= cnt +1;
        divided_clk <= divided_clk;
      end
    end

endmodule



// DO NOT CHANGE THIS MODULE

module debouncer(
	input 		clk,
	input 		rst,
	input 		noisy_in, // port from the push button
	output reg 	clean_out // port into the circuit
    );

reg noisy_in_reg;

reg clean_out_tmp1; // will be used to detect rising edge
reg clean_out_tmp2; // will be used to detect rising edge
reg clean_out_tmp3; // will be used to detect rising edge
reg clean_out_tmp4; // will be used to detect rising edge

always@(posedge clk or posedge rst)
begin
	if (rst==1'b1) begin
		noisy_in_reg <= 0;
		clean_out_tmp1 <= 0;
		clean_out_tmp2 <= 0;
		
		clean_out <= 0;
	end
	else begin
		// store the input
		noisy_in_reg <= noisy_in; 
		clean_out_tmp1 <= noisy_in_reg;
				
		// rising edge detect
		clean_out_tmp2 <= clean_out_tmp1;
        clean_out_tmp3 <= clean_out_tmp2;
        clean_out_tmp4 <= clean_out_tmp3;
		clean_out <= ~clean_out_tmp4 & clean_out_tmp3; // it produce a single pulse during a risingedge	
	end
end

endmodule


// DO NOT CHANGE THIS MODULE

module ssd (
    input clk,
    input [7:0] disp0,
    input [7:0] disp1,
    input [7:0] disp2,
    input [7:0] disp3,
    output reg [7:0] seven,
    output reg [3:0] segment
);
    reg [15:0] dispCounter = 0; // Display timeout counter
    reg [1:0] index;
    
    always @(posedge clk) begin
        dispCounter <= dispCounter + 1;
        if (dispCounter == 0) begin
            case (index)
                0: begin
                    seven <= disp0;
                end 
                1: begin
                    seven <= disp1;
                end 
                2: begin
                    seven <= disp2;
                end 
                3: begin
                    seven <= disp3;
                end 
                default: begin
                    seven <= 0;
                end
            endcase
            segment <= 1 << index;
            index <= index + 1;
        end
    end
endmodule
// DO NOT CHANGE THE NAME OR THE SIGNALS OF THIS MODULE
