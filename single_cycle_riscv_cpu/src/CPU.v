// Please include verilog file if you write module in other file
module CPU(
    input             clk,
    input             rst,
    input             [31:0] data_out,//represents the data send from DM .
    input             [31:0] instr_out,//represents the instruction send from IM .
    output reg instr_read,//represents the signal whether the instruction should be read in IM.
    output reg data_read,//represents the signal whether the data should be read in DM.
    output reg [31:0] instr_addr,//represents the instruction address in IM.
    output reg [31:0] data_addr,//represents the data address in DM.
    output reg [3:0]  data_write,//has four signal , and every signal represents the byte of the data whether should be wrote in DM.
                                /*Mem[0] = {Mem[0][31:24],Mem[0][23:16],Mem[0][15:8],Mem[0][7:0]}
                                data_write[3] => control Mem[0][31:24]
                                data_write[2] => control Mem[0][23:16]
                                data_write[1] => control Mem[0][15:8 ]
                                data_write[0] => control Mem[0][7:0 ]*/
    output reg [31:0] data_in//represents the data which will be wrote into DM .
);
/*  R-type 
        funct7 rs2 rs1 funct3 rd opcode
        {funtion7[6:0],rs2[4:0],rs1[4:0],function3[2:0],rd[4:0],opcode[6:0]}
    I-type
        imm[11:0] rs1 funct3 rd opcode
        {imm[11:0],rs1[4:0],function3[2:0],rd[4:0],opcode[6:0]}
    S-type
        imm[11:5] rs2 rs1 funct3 imm[4:0] opcode
        {imm[11:5],rs2[4:0],rs1[4:0],function3[2:0],imm[4:0],opcode[6:0]}
    B-type
        imm[12|10:5] rs2 rs1 funct3 imm[4:1|11] opcode
        {imm[12|10:5],rs2[4:0],rs1[4:0],function3[2:0],imm[4:1|11],opcode[6:0]}
    U-type
        imm[31:12] rd opcode
        {imm[31:12],rd[4:0],opcode[6:0]}
    J-type
        imm[20|10:1|11|19:12] rd opcode
        {imm[20|10:1|11|19:12],rd[4:0],opcode[6:0]}
    */
/* Add your design */

reg [31:0] Register [31:0];
reg [31:0] instr_addr_temp;
reg [31:0] next_instr_addr;
reg [31:0] data_addr_temp;
//reg [4:0] rs1;
//reg [4:0] rs2;
//reg [4:0] rd;
reg [64:0] result;
//reg [31:0] imm;
//reg [4:0]shamt;
reg [2:0]State;


localparam Slow =3'd5 ;
localparam Next_instr = 3'd4;
localparam MotherFucker = 3'd3;
localparam Run = 3'd2;
localparam Decode = 3'd1;
localparam Reset_CPU = 3'd0;

always @(*) begin
    Register[0] <= 0;
end

always @(posedge clk) begin
    case (State)
        Slow :begin
            State = Decode;
        end
        Next_instr:begin
            data_write = 4'b0;
            instr_addr = instr_addr + 4;
            State = Slow;
            data_read=0;
        end
        MotherFucker:begin
            State = Next_instr;
        end
        Run:begin
            State = MotherFucker;
        end
        Decode:begin
            State = Run;
        end
        Reset_CPU:begin
            instr_read = 1;
            State = Decode;
        end
        default:begin
            
        end
    endcase
end

always @(posedge clk,posedge rst) begin
    if(rst)begin
        Register[0]<=0;
        instr_addr<=0;
        data_addr <= 0;
        data_in <= 0;
        data_write <= 0;
        result <= 0;
        data_read <= 0;
        State <= Reset_CPU;
        //imm <= 0;
        //shamt <= 0;
        //rs1 <= 0;
        //rs2 <= 0;
        //rd <= 0;
    end
    else begin
        case(instr_out[6:0])//opcode
            7'b0110011:begin
                //{funtion7[6:0],rs2[4:0],rs1[4:0],function3[2:0],rd[4:0],opcode[6:0]}
                /*rs1  = instr_out[19:15];
                rs2  = instr_out[24:20];
                rd  = instr_out[11:7];*/
                case(instr_out[31:25])//function7
                    7'b0000000:begin
                        case(instr_out[14:12])//function3
                            3'b000:begin//ADD
                                //rd = rs1 + rs2;
                                if(State ==Run)Register[instr_out[11:7]] <= Register[instr_out[19:15]] + Register[instr_out[24:20]];
                            end
                            3'b001:begin//SLL 
                                //rd = rs1u << rs2[4:0]    
                                if(State ==Run)Register[instr_out[11:7]] <= $unsigned(Register[instr_out[19:15]])<< Register[instr_out[24:20]][4:0];
                            end
                            3'b010:begin//SLT 
                                //rd = rs1s < rs2s ? 1 : 0
                                if(State ==Run)begin
                                    if ( $signed(Register[instr_out[19:15]]) < $signed(Register[instr_out[24:20]]) )begin
                                    Register[instr_out[11:7]] <= 1;
                                    end
                                    else begin
                                        Register[instr_out[11:7]] <= 0;
                                    end
                                end  
                                
                            end
                            3'b011:begin//SLTU 
                                //rd = rs1u < rs2u ? 1 : 0
                                if(State ==Run)begin
                                    if ( $unsigned(Register[instr_out[19:15]]) < $unsigned(Register[instr_out[24:20]]) )begin
                                    Register[instr_out[11:7]] <= 1;
                                    end
                                    else begin
                                        Register[instr_out[11:7]]  <= 0;
                                    end
                                end
                                
                            end
                            3'b100:begin//XOR 
                                //rd = rs1 ^ rs2
                                if(State ==Run)Register[instr_out[11:7]]  <= Register[instr_out[19:15]] ^ Register[instr_out[24:20]];
                            end
                            3'b101:begin//SRL 
                                //rd = rs1u >> rs2[4:0]
                                if(State ==Run)Register[instr_out[11:7]]  <= $unsigned(Register[instr_out[19:15]]) >> Register[instr_out[24:20]][4:0];
                            end
                            3'b110:begin//OR 
                                //rd = rs1 | rs2
                                if(State ==Run)Register[instr_out[11:7]]  <= Register[instr_out[19:15]] | Register[instr_out[24:20]];
                            end
                            3'b111:begin//AND 
                                //rd = rs1 & rs2
                                if(State ==Run)Register[instr_out[11:7]]  <= Register[instr_out[19:15]] & Register[instr_out[24:20]];
                            end
                            default:begin
                                //Error
                            end
                        endcase
                        //State  <=  Next_instr;
                    end
                    7'b0100000:begin
                        case(instr_out[14:12])
                            3'b000:begin//SUB
                                //rd = rs1 - rs2
                                if(State ==Run)Register[instr_out[11:7]] <= Register[instr_out[19:15]] - Register[instr_out[24:20]];
                            end
                            3'b101:begin//SRA
                                //rd = rs1s >> rs2[4:0]
                                if(State ==Run)Register[instr_out[11:7]] <= $signed(Register[instr_out[19:15]]) >> Register[instr_out[24:20]][4:0];
                            end
                            default:begin
                                //Other Instruction
                            end
                        endcase
                        //State <=  Next_instr;
                    end
                    7'b0000001:begin
                        case(instr_out[14:12])
                            3'b000:begin//MUL
                                /*result = rs1s * rs2s
                                rd = result[31:0]*/
                                if(State == Decode)begin
                                    result <= $signed(Register[instr_out[19:15]]) * $signed(Register[instr_out[24:20]]);
                                    //State <=  Run;
                                end
                                else if (State == Run) begin
                                    Register[instr_out[11:7]] <= result[31:0];
                                    //State <= Next_instr;
                                end
                            end
                            3'b001:begin//MULH
                                /*result = rs1s * rs2s
                                rd = result[63:32]*/
                                if(State == Decode)begin
                                    result <= $signed(Register[instr_out[19:15]]) * $signed(Register[instr_out[24:20]]);
                                    //State <=  Run;
                                end
                                else if (State == Run) begin
                                    Register[instr_out[11:7]] <= result[63:32];
                                    //State <= Next_instr;
                                end
                            end
                            3'b011:begin//MULHU
                                /*result = rs1u* rs2u
                                rd = result[63:32]*/
                                if(State == Decode)begin
                                    result <= $unsigned(Register[instr_out[19:15]]) * $unsigned(Register[instr_out[24:20]]);
                                    //State <= Run;
                                end
                                else if (State == Run) begin
                                    Register[instr_out[11:7]] <= result[63:32];
                                    //State <= Next_instr;
                                end
                            end
                            default:begin
                                //State <=  Next_instr;
                            end
                        endcase
                    end
                    default:begin
                        //State <= Next_instr;
                    end
                endcase
            end
            7'b0000011:begin
                /*imm  = {20'b0,instr_out[31:20]};
                rs1  = instr_out[19:15];
                rd  = instr_out[11:7];*/
                case(instr_out[14:12])
                    3'b000:begin//LB
                        //rd =M[rs1+ imm]𝑏𝑠
                        if (State == Decode)begin
                            data_addr <= Register[instr_out[19:15]] + {20'b0,instr_out[31:20]};
                            data_read <= 1;
                            //State <= Run;
                        end
                        else if (State == Run)begin
                            Register[instr_out[11:7]] <= {{24{data_out[7]}},data_out[7:0]};
                            data_read <= 0;
                            //State <= Next_instr;
                        end
                    end
                    3'b001:begin//LH
                        //rd =M[rs1+ imm]ℎ𝑠
                        if (State == Decode)begin
                            data_addr <= Register[instr_out[19:15]] + {20'b0,instr_out[31:20]};
                            data_read <= 1;
                            //State <= Run;
                        end
                        else if (State == Run)begin
                            Register[instr_out[11:7]] <= {{16{data_out[15]}},data_out[15:0]};
                            data_read <= 0;
                            //State <=  Next_instr;
                        end
                    end
                    3'b010:begin//LW
                        //rd =M[rs1 + imm]
                        if (State == Decode)begin
                            data_addr <= Register[instr_out[19:15]] + {{20{instr_out[31]}},instr_out[31:20]};
                            data_read <= 1;
                            //State <= MotherFucker;
                        end
                        else if (State == Run)begin
                            //Register[instr_out[11:7]]<=Register[instr_out[11:7]];
                                data_read <= 1;
                            //State <=  Next_instr;
                        end
                        else if (State == MotherFucker)begin
                            Register[instr_out[11:7]] <= data_out;
                            data_read <= 1;
                            //State <=  Run;
                        end
                    end
                    3'b100:begin//LBU
                        //rd =M[rs1+imm]𝑏𝑢
                        if (State == Decode)begin
                            data_addr <= Register[instr_out[19:15]] + {20'b0,instr_out[31:20]};
                           //State <= MotherFucker;
                        end
                        else if (State == MotherFucker)begin
                            data_read <= 1;
                           //State <=  Run;
                        end
                        else if (State == Run)begin
                            Register[instr_out[11:7]] <= {24'b0,data_out[7:0]};
                            data_read <= 0;
                           //State <=  Next_instr;
                        end
                    end
                    3'b101:begin//LHU
                        //rd =M[rs1+imm]ℎ𝑢
                        if (State == Decode)begin
                            data_addr <= Register[instr_out[19:15]] + {20'b0,instr_out[31:20]};
                           //State <= MotherFucker;
                        end
                        else if (State == MotherFucker)begin
                            data_read <= 1;
                           //State <=  Run;
                        end
                        else if (State == Run)begin
                            Register[instr_out[11:7]] <= {16'b0,data_out[15:0]};
                            data_read <= 0;
                           //State <= Next_instr;
                        end
                    end
                    default:begin
                       //State <= Next_instr;
                    end
                endcase
            end
            7'b0010011:begin
                /*imm  = {{20{instr_out[31]}},instr_out[31:20]};
                rs1  = instr_out[19:15];
                rd  = instr_out[11:7];
                shamt  = instr_out[24:20];*/
                case (instr_out[14:12])
                    3'b000:begin//ADDI
                        //rd = rs1 + imm
                        if(State==Run)Register[instr_out[11:7]] <= Register[instr_out[19:15]] + $signed ({{20{instr_out[31]}},instr_out[31:20]});
                    end
                    3'b001:begin//SLLI
                        if(instr_out[31:25]==7'b0000000)begin//SLLI
                            //rd = rs1u << shamt
                            if(State ==Run)Register[instr_out[11:7]] <= $unsigned(Register[instr_out[19:15]]) << instr_out[24:20]; 
                        end
                        else begin
                            //Error
                        end
                    end
                    3'b010:begin//SLTI
                        //rd = rs1s < imms? 1:0
                        if($signed(Register[instr_out[19:15]]) < $signed({{20{instr_out[31]}},instr_out[31:20]}))begin
                            if(State ==Run)Register[instr_out[11:7]] <= 1;
                        end
                        else begin
                            if(State ==Run)Register[instr_out[11:7]] <= 0;
                        end
                    end
                    3'b011:begin//SLTIU
                        //rd  = rs1u < immu? 1:0
                        if(State ==Run)begin
                            if($unsigned(Register[instr_out[19:15]]) < $signed({{20{instr_out[31]}},instr_out[31:20]}))begin
                            Register[instr_out[11:7]] <= 1;
                            end
                            else begin
                                Register[instr_out[11:7]] <= 0;
                            end
                        end
                    end
                    3'b100:begin//XORI
                        //rd = rs1 ^ imm
                        if(State ==Run)Register[instr_out[11:7]]  = Register[instr_out[19:15]] ^ {{20{instr_out[31]}},instr_out[31:20]};
                    end
                    3'b101:begin
                        case(instr_out[31:25])
                            7'b0000000:begin//SRLI
                                //rd = rs1u >> shamt
                                if(State ==Run)begin
                                    if(instr_out[31:25]==7'b0000000)begin
                                    Register[instr_out[11:7]] <= $unsigned(Register[instr_out[19:15]]) >> instr_out[24:20]; 
                                    end
                                    else begin
                                        //Error
                                    end
                                end
                                
                            end
                            7'b0100000:begin//SRAI
                                //rd = rs1s >> shamt
                                if(State ==Run)begin
                                    if(instr_out[31:25]==7'b0100000)begin
                                    Register[instr_out[11:7]] <= $signed(Register[instr_out[19:15]]) >> instr_out[24:20]; 
                                    end
                                    else begin
                                        //Error
                                    end
                                end
                                
                            end
                            default:begin
                                //ERROR
                            end
                        endcase
                    end
                    3'b110:begin//ORI
                        //rd = rs1 | imm
                        if(State ==Run)Register[instr_out[11:7]] <= Register[instr_out[19:15]] | {{20{instr_out[31]}},instr_out[31:20]};
                    end
                    3'b111:begin//ANDI
                        //rd = rs1 & imm
                        if(State ==Run)Register[instr_out[11:7]] <=  Register[instr_out[19:15]] & {{20{instr_out[31]}},instr_out[31:20]};
                    end
                    default:begin
                        //Error
                    end
                endcase
               //State <= Next_instr;
            end
            7'b1100111:begin
                /*imm  = {{20{instr_out[31]}},instr_out[31:20]};
                rs1  = instr_out[19:15];
                rd  = instr_out[11:7];*/
                if(instr_out[14:12]==3'b000)begin//JALR
                    /*rd = PC + 4
                    PC = imm + rs1
                    (Set LSB of PC to 0)*/
                    if(State == Decode)begin
                        Register[instr_out[11:7]] = instr_addr + 4;
                        instr_addr_temp = {{20{instr_out[31]}},instr_out[31:20]} + Register[instr_out[19:15]];
                       //State = Run;
                    end
                    else if(State == Run)begin
                        instr_addr <= instr_addr_temp-4;
                       //State <= Next_instr;                 
                    end
                end
                else begin
                    
                end
            end
            7'b1100011:begin
                /*imm  = {{17{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:6],1'b0};
                rs2  = instr_out[24:20];
                rs1  = instr_out[19:15];*/
                case(instr_out[14:12])
                3'b000:begin//BEQ
                    /*PC = (rs1 == rs2) ?
                    PC + imm : PC + 4*/
                    if(State ==Run)begin
                        if(Register[instr_out[19:15]] == Register[instr_out[24:20]])begin
                        instr_addr <= instr_addr +{{17{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:8],1'b0}-4;
                        end
                        else begin
                        end
                    end
                    
                end
                3'b001:begin//BNE
                    /*PC = (rs1 != rs2) ?
                    PC + imm : PC + 4*/
                    if(State ==Run)begin
                        if(Register[instr_out[19:15]] != Register[instr_out[24:20]])begin
                        instr_addr <= instr_addr +{{17{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:8],1'b0}-4;
                        end
                        else begin
                        end
                    end
                    
                end
                3'b100:begin//BLT
                    /*PC = (rs1s < rs2 s) ?
                    PC + imm : PC + 4*/
                    if(State ==Run)begin
                        if($signed(Register[instr_out[19:15]]) < $signed(Register[instr_out[24:20]]))begin
                        instr_addr <= instr_addr +{{17{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:8],1'b0}-4;
                        end
                        else begin
                        end
                    end
                    
                end
                3'b101:begin//BGE
                    /*PC = (rs1s ≧ rs2 s)?
                    PC + imm : PC + 4*/
                    if(State ==Run)begin
                       if($signed(Register[instr_out[19:15]]) > $signed(Register[instr_out[24:20]]) || $signed(Register[instr_out[19:15]]) == $signed(Register[instr_out[24:20]]))begin
                        instr_addr <= instr_addr +{{17{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:8],1'b0}-4;
                        end
                        else begin
                        end 
                    end
                    
                end
                3'b110:begin//BLTU
                    /*PC = (rs1u < rs2 u) ?
                    PC + imm : PC + 4*/
                    if(State ==Run)begin
                        if($unsigned(Register[instr_out[19:15]]) < $unsigned(Register[instr_out[24:20]]))begin
                        instr_addr <= instr_addr +{{17{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:8],1'b0}-4;
                        end
                        else begin
                        end
                    end
                    
                end
                3'b111:begin//BGEU
                    /*PC = (rs1u ≧ rs2 u) ?
                    PC + imm : PC + 4*/
                    if(State ==Run)begin
                       if($unsigned(Register[instr_out[19:15]]) > $unsigned(Register[instr_out[24:20]]) || $unsigned(Register[instr_out[19:15]]) == $unsigned(Register[instr_out[24:20]]))begin
                        instr_addr <= instr_addr +{{17{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:8],1'b0}-4;
                        end
                        else begin
                        end 
                    end
                    
                end
                endcase
               //State <= Next_instr;
            end
            7'b0100011:begin
                /*rs1 = instr_out[19:15];
                rs2 = instr_out[24:20]
                imm  = {{20{instr_out[31]}},instr_out[31:25],instr_out[11:7]};*/
                case(instr_out[14:12])
                    3'b000:begin//SB
                        //M[rs1+imm]𝑏= 𝑟𝑠2𝑏
                        if(State == Decode)begin
                            data_addr <= Register[instr_out[19:15]] + {{20{instr_out[31]}},instr_out[31:25],instr_out[11:7]};
                            data_read <= 1;
                            data_write <= 4'b1111;
                           //State <= Run;
                        end
                        else if(State == Run)begin
                            data_in <= {data_out[31:8],Register[instr_out[24:20]][7:0]}; 
                            data_write <= 4'b0000;
                            data_read<=0;
                           //State <= Next_instr;
                        end
                    end
                    3'b001:begin//SH
                        //M[rs1+imm]ℎ= 𝑟𝑠2ℎ
                        if(State == Decode)begin
                            data_addr <= Register[instr_out[19:15]] + {{20{instr_out[31]}},instr_out[31:25],instr_out[11:7]};
                            data_read <= 1;
                            data_write <= 4'b1111;
                           //State <= Run;
                        end
                        else if(State == Run)begin
                            data_in <= {data_out[31:16],Register[instr_out[24:20]][15:0]}; 
                            data_write <= 4'b0000;
                            data_read<=0;
                           //State <= Next_instr;
                        end
                    end
                    3'b010:begin//SW
                        //M[rs1 + imm]<=rs2
                        if(State == Decode)begin
                            data_addr <= Register[instr_out[19:15]] + {{20{instr_out[31]}},instr_out[31:25],instr_out[11:7]};
                            data_write <= 4'b1111;
                           //State <= MotherFucker;
                        end
                        else if(State ==MotherFucker)begin
                            data_write <= 4'b1111;
                           //State <= Run;
                        end
                        else if(State == Run)begin
                            data_in <= Register[instr_out[24:20]];
                            data_write <= 4'b1111;
                           //State <= Next_instr;
                        end
                        else begin
                            //
                        end
                    end
                    default:begin
                       //State <= Next_instr;
                    end
                endcase
            end
            7'b0010111:begin//AUIPC
                /*imm = {instr_out[31:12],12'b0};
                rd = instr_out[11:7];*/
                if(State ==Run)Register[instr_out[11:7]] <= instr_addr + {instr_out[31:12],12'b0};
               //State <= Next_instr;
            end
            7'b1101111:begin//JAL
                /*rd = PC + 4
                PC = PC + imm*/
                /*imm = {{11{instr_out[31]}},instr_out[31],instr_out[19:12],instr_out[20],instr_out[30:21],1'b0};
                rd = instr_out[11:7]*/
                if(State ==Run)begin
                    Register[instr_out[11:7]] <= instr_addr + 4;
                    instr_addr <= instr_addr + {{11{instr_out[31]}},instr_out[31],instr_out[19:12],instr_out[20],instr_out[30:21],1'b0}-4;
               //State <= Next_instr;
                end
                else if (State == MotherFucker)begin
                    instr_addr <= instr_addr + {{11{instr_out[31]}},instr_out[31],instr_out[19:12],instr_out[20],instr_out[30:21],1'b0}-4;
                end
            end
            7'b0110111:begin//LUI
                //rd = imm
                /*imm = {instr_out[31:12],12'b0};
                rd = instr_out[11:7]*/
                if(State ==Run)Register[instr_out[11:7]] <= {instr_out[31:12],12'b0};
               //State <= Next_instr;
            end
            default:begin
                //NoInstruction found
            end
        endcase 
    end
end


endmodule
