module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
);

wire [3:0] cpu_byteen;
wire cpu_we;
wire [31:0] cpu_wdata;
wire [31:0] cpu_addr;
wire [31:0] cpu_rdata;
wire [31:0] cpu_pc;


wire [3:0] DM_byteen;
wire [31:0] DM_addr;

wire TC0_we;
wire [31:0] TC0_rdata;
wire TC0_irq;

wire TC1_we;
wire [31:0] TC1_rdata;
wire TC1_irq;

assign m_data_addr =  cpu_addr;
assign m_data_byteen =  DM_byteen ;
assign m_data_wdata  = cpu_wdata;

assign m_int_addr = cpu_addr ;
assign m_int_byteen = cpu_byteen;

assign m_inst_addr = cpu_pc;
assign macroscopic_pc = cpu_pc;
// cpu instance
cpu u_cpu (
    .clk(clk),              // 输入: 时钟信号
    .reset(reset),            // 输入: 复位信号
    .HWInt({3'b000, interrupt,TC1_irq,TC0_irq}),            // 输入: 硬件中断信号 (6位)
    .i_inst_rdata(i_inst_rdata),     // 输入: 取指指令数据 (32位)
    .m_data_rdata(cpu_rdata),     // 输入: 内存读数据 (32位)

    .i_inst_addr(i_inst_addr),      // 输出: 指令地址 (32位)
    .m_data_addr(cpu_addr),      // 输出: 内存地址 (32位)
    .m_data_wdata(cpu_wdata),     // 输出: 内存写数据 (32位)
    .m_data_byteen(cpu_byteen),    // 输出: 内存字节使能信号 (4位)
    .m_inst_addr(cpu_pc),      // 输出: 内存指令地址 (32位)
    .w_grf_we(w_grf_we),         // 输出: GRF 写使能信号
    .w_grf_addr(w_grf_addr),       // 输出: GRF 写地址 (5位)
    .w_grf_wdata(w_grf_wdata),      // 输出: GRF 写数据 (32位)
    .w_inst_addr(w_inst_addr)       // 输出: 写回指令地址 (32位)
);


// Bridge instance
Bridge u_Bridge (
    .byteen(cpu_byteen),
    .addr(cpu_addr),           // 输入: 字节使能信号 (4位)
    .data_out(cpu_rdata),         // 输出: 数据输出 (32位)

    // DM (数据存储器接口)
    .DM_data(m_data_rdata),          // 输入: 数据存储器的数据 (32位)
    .DM_byteen(DM_byteen),        // 输出: 数据存储器的字节使能信号 (4位)

    // Timer0 (定时器 0 接口)
    .TC0_data(TC0_rdata),         // 输入: 定时器 0 的数据 (32位)
    .TC0_we(TC0_we),           // 输出: 定时器 0 的写使能信号

    // Timer1 (定时器 1 接口)
    .TC1_data(TC1_rdata),         // 输入: 定时器 1 的数据 (32位)
    .TC1_we(TC1_we)            // 输出: 定时器 1 的写使能信号
);

// TC instance
TC TC0 (
    .clk(clk),         // 输入: 时钟信号
    .reset(reset),       // 输入: 复位信号
    .Addr(cpu_addr[31:2]),        // 输入: 地址 (高 30 位，忽略低 2 位)
    .WE(TC0_we),          // 输入: 写使能信号
    .Din(cpu_wdata),         // 输入: 写入数据 (32位)
    .Dout(TC0_rdata),        // 输出: 读取数据 (32位)
    .IRQ(TC0_irq)          // 输出: 中断请求信号
);
// TC instance
TC TC1 (
    .clk(clk),         // 输入: 时钟信号
    .reset(reset),       // 输入: 复位信号
    .Addr(cpu_addr[31:2]),        // 输入: 地址 (高 30 位，忽略低 2 位)
    .WE(TC1_we),          // 输入: 写使能信号
    .Din(cpu_wdata),         // 输入: 写入数据 (32位)
    .Dout(TC1_rdata),        // 输出: 读取数据 (32位)
    .IRQ(TC1_irq)          // 输出: 中断请求信号
);



endmodule