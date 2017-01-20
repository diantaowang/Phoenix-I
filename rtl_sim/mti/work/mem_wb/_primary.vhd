library verilog;
use verilog.vl_types.all;
entity mem_wb is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        mem_wreg        : in     vl_logic;
        mem_wd          : in     vl_logic_vector(4 downto 0);
        mem_wdata       : in     vl_logic_vector(31 downto 0);
        wb_wreg         : out    vl_logic;
        wb_wd           : out    vl_logic_vector(4 downto 0);
        wb_wdata        : out    vl_logic_vector(31 downto 0)
    );
end mem_wb;
