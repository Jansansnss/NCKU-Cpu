module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output R,
    output G,
    output Y
);

//write your code here
//states NO--> 3'd7
localparam Green_0 =3'd0;
localparam None_0 =3'd1;
localparam Green_1 =3'd2;
localparam None_1 =3'd3;
localparam Green_2 =3'd4;
localparam Yellow_0 =3'd5;
localparam Red_0 =3'd6;

reg [2:0]cur_state;
reg [10:0]clk_cycles;
reg tempG;
reg tempY;
reg tempR;

assign G=tempG;
assign Y=tempY;
assign R=tempR;

always @ ( * )begin //output control
    case (cur_state)
        Green_0 :begin
            tempG=1'b1; tempY=1'b0; tempR=1'b0;      
        end
        None_0 :begin
            tempG=1'b0; tempY=1'b0; tempR=1'b0;
        end
        Green_1 :begin
            tempG=1'b1; tempY=1'b0; tempR=1'b0;
        end
        None_1 :begin
            tempG=1'b0; tempY=1'b0; tempR=1'b0; 
        end
        Green_2 :begin
            tempG=1'b1; tempY=1'b0; tempR=1'b0;
        end
        Yellow_0:begin
            tempG=1'b0; tempY=1'b1; tempR=1'b0;
        end
        Red_0:begin
            tempG=1'b0; tempY=1'b0; tempR=1'b1; 
        end
        default: begin
            tempG=1'b1; tempY=1'b1; tempR=1'b1;
        end
    endcase
end
always @ ( posedge clk, posedge rst)begin
    if(rst)begin
        cur_state<=Green_0;
        clk_cycles<=0;
    end
    else begin
        if(pass==1 && cur_state!=Green_0)begin
        cur_state<=Green_0;
        clk_cycles<=0;
        end
        else begin
            case(cur_state)
            Green_0:begin
                if(clk_cycles==11'd1023)begin
                    clk_cycles<=0;
                    cur_state<=None_0;
                end
                else begin
                    clk_cycles<=clk_cycles+11'b1;
                end
            end
            None_0:begin
                if(clk_cycles==11'd127)begin
                    clk_cycles<=0;
                    cur_state<=Green_1;
                end
                else begin
                    clk_cycles<=clk_cycles+11'b1;
                end
            end
            Green_1:begin
                if(clk_cycles==11'd127)begin
                    clk_cycles<=0;
                    cur_state<=None_1;
                end
                else begin
                    clk_cycles<=clk_cycles+11'b1;
                end 
            end
            None_1:begin
                if(clk_cycles==11'd127)begin
                    clk_cycles<=0;
                    cur_state<=Green_2;
                end
                else begin
                    clk_cycles<=clk_cycles+11'b1;
                end
            end
            Green_2:begin
                if(clk_cycles==11'd127)begin
                    clk_cycles<=0;
                    cur_state<=Yellow_0;
                end
                else begin
                    clk_cycles<=clk_cycles+11'b1;
                end 
            end
            Yellow_0:begin
                if(clk_cycles==11'd511)begin
                    clk_cycles<=0;
                    cur_state<=Red_0;
                end
                else begin
                    clk_cycles<=clk_cycles+11'b1;
                end 
            end
            Red_0:begin
                if(clk_cycles==11'd1023)begin
                    clk_cycles<=0;
                    cur_state<=Green_0;
                end
                else begin
                    clk_cycles<=clk_cycles+11'b1;
                end
            end
            default:begin
                cur_state<=cur_state;
                clk_cycles<=clk_cycles;
            end
        endcase
        end
    end
   
end

endmodule
