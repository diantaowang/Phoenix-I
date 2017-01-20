library verilog;
use verilog.vl_types.all;
entity ex is
    port(
        rst             : in     vl_logic;
        aluop_i         : in     vl_logic_vector(7 downto 0);
        alusel_i        : in     vl_logic_vector(2 downto 0);
        reg1_i          : in     vl_logic_vector(31 downto 0);
        reg2_i          : in     vl_logic_vector(31 downto 0);
        wreg_i          : in     vl_logic;
        wd_i            : in     vl_logic_vector(4 downto 0);
        wdata_o         : out    vl_logic_vector(31 downto 0);
        wreg_o          : out    vl_logic;
        wd_o            : out    vl_logic_vector(4 downto 0)
    );
end ex;
