library verilog;
use verilog.vl_types.all;
entity ex_mem is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        ex_wreg         : in     vl_logic;
        ex_wd           : in     vl_logic_vector(4 downto 0);
        ex_wdata        : in     vl_logic_vector(31 downto 0);
        mem_wreg        : out    vl_logic;
        mem_wd          : out    vl_logic_vector(4 downto 0);
        mem_wdata       : out    vl_logic_vector(31 downto 0)
    );
end ex_mem;
