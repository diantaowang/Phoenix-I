library verilog;
use verilog.vl_types.all;
entity mem is
    port(
        rst             : in     vl_logic;
        wreg_i          : in     vl_logic;
        wd_i            : in     vl_logic_vector(4 downto 0);
        wdata_i         : in     vl_logic_vector(31 downto 0);
        wreg_o          : out    vl_logic;
        wd_o            : out    vl_logic_vector(4 downto 0);
        wdata_o         : out    vl_logic_vector(31 downto 0)
    );
end mem;
