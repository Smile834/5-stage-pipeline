module pc_reg(
	//时钟信号，复位信号，指令地址，指令存储器使能信号
	input wire clk,   
	input wire rst,
	output reg[`InstAddrBus] pc,
	output reg ce
);

always @(posedge clk) begin
	if (rst == `RstEnable) begin //复位的时候指令存储器禁用
		// reset
		ce <= `ChipDisable
	end
	else begin
		ce <= `ChipEnable
	end
end

always @(posedge clk) begin
	if (ce == `ChipDisable) begin
		// reset
		pc <= 32'h00000000;
	end
	else begin
		pc <= pc + 4'h4;  //使能的的时候，pc每时钟周期加4
	end
end

endmodule