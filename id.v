module id(
	//输入的指令地址与指令
	input wire rst,
	input wire[`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,

	//读取的Regfile的值
	input wire[`RegBus] reg1_data_i,
	input wire[`RegBus] reg2_data_i,

	//输出到Regfile的信息
	output reg reg1_read_o,
	output reg[`RegAddrBus] reg1_addr_o,

	output reg reg2_read_o,
	output reg[`RegAddrBus] reg2_addr_o

	//送到执行阶段的信息
	output reg[`AluOpBus] aluop_o,
	output reg[`AluSelBus] alusel_o,
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	//目的寄存器的地址 和 使能信号
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o
);

//指令码
wire[5:0] op = inst_i[31:26];
//指令需要的立即数
reg[`RegBus] imm;

//指示指令 是否有效
reg instvalid;

//第一段 对指令进行译码
always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		aluop = `EXE_NOP_OP;
		alusel_0 = `EXE_RES_NOP;
		wd_o = `NOPRegAddr;
		wreg_o = `WriteDisable;
		instvalid = `InstValid;
		reg1_read_o = 1'b0;
		reg1_addr_o = `NOPRegAddr;
		reg2_read_o = 1'b0;
		reg2_addr_o = `NOPRegAddr;
		imm = 32'h0;
	end
	else begin
		aluop = `EXE_NOP_OP;
		alusel_0 = `EXE_RES_NOP;
		wd_o = `inst_i[15:11];
		wreg_o = `WriteDisable;
		instvalid = `InstValid;
		reg1_read_o = 1'b0;
		reg1_addr_o = `inst_i[25:21];
		reg2_read_o = 1'b0;
		reg2_addr_o = `inst_i[20:16];
		imm = `ZeroWord;

		case(op)
			`EXE_ORI: begin
				alusel_o = `EXE_RES_LOGIC;
				aluop_o = `EXE_OR_OP;
				
				reg1_read_o = 1'b1;
				reg2_read_o = 1'b0;
				imm = {16'h0,inst_i[15:0]};

				wreg_o = `WriteEnable;
				wd_o = `inst_i[20:16];

				instvalid = `InstValid;
			end
			default:begin
				
			end
		endcase
	end
end

//第二段 确定进行运算的源操作数1
always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		reg1_o = `ZeroWord;
	end
	else if (reg1_read_o == 1'b1) begin
		reg1_o = reg1_data_i;
	end
	else if (reg1_read_o == 1'b0) begin
		reg1_o = imm;
	end
	else begin
		reg1_o = `ZeroWord;
	end
end

//第三段 确定进行运算的源操作数1
always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		reg2_o = `ZeroWord;
	end
	else if (reg2_read_o == 1'b1) begin
		reg2_o = reg2_data_i;
	end
	else if (reg2_read_o == 1'b0) begin
		reg2_o = imm;
	end
	else begin
		reg2_o = `ZeroWord;
	end
end
endmodule