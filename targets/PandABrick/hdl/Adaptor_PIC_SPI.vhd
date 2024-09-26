-- =======  Transfer data to/from Adaptor-Board PIC Micro  =======
--
--	 Transfers 18-bit data word to (and from) the PIC periodically (every 2.5mS), no error checking.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity Adaptor_PIC_SPI is
    port (
        i_clk       : in  std_logic;    -- 125MHz System (AXI) clock.
	    o_PIC_SC    : out std_logic;    -- SPI Serial Clock (to PIC)
	    o_PIC_CS    : out std_logic;    -- SPI Chip Select (to PIC, low during transfer)
	    o_PIC_DI    : out std_logic;    -- SPI PIC Data In (to PIC)
	    i_PIC_DO    : in  std_logic;    -- SPI PIC Data Out (from PIC)
	    o_done      : out std_logic;    -- Transfer has finished on rising edge of this output.

	    i_data      : in std_logic_vector(15 downto 0);  -- Data to send to the PIC
                                                         --   UVWT read mode   - Axis 8-1 on i_data[15:8]  - '1' sets uvwt mode
                                                         --   Serial Pass mode - Axis 8-1 on i_data[7:0]   - '1' sets pass-through mode

        o_data      : out std_logic_vector(17 downto 0)  -- Data received from the PIC
                                                         --   LoS         - Axis 8-1 on o_data(15 downto 8)
                                                         --   LD Jumpers  - Axis 8-1 on o_data(7 downto 0)  - '0' if jumper fitted

                                                         --   SFP Tx_Fault Flag:  o_data(17)   - '1' for Tx Fault
                                                         --   SFP_Rx_LoS Flag:    o_data(16)   - '1' for Rx LoS
    );
end Adaptor_PIC_SPI;


architecture rtl of Adaptor_PIC_SPI is

------------------------------------------------------------
-- signal declarations
------------------------------------------------------------

    signal CLK_OUT          : std_logic;
    signal CS_OUT           : std_logic;
    signal SDO_OUT          : std_logic;
    signal running          : std_logic;
    signal tx_shift_reg     : std_logic_vector ( 17 downto 0 );
    signal rx_shift_reg     : std_logic_vector ( 17 downto 0 );
    signal latched_o_data   : std_logic_vector ( 17 downto 0 );
    signal slow_clk         : std_logic;
    signal clk_plse         : std_logic;
    signal pic_frm          : std_logic;

    signal pic_clk_counter  : std_logic_vector ( 10 downto 0 ) := (others => '0');
    signal pic_frm_counter  : std_logic_vector (  7 downto 0 ) := (others => '0');
    signal state            : std_logic_vector (  3 downto 0 ) := (others => '0');
    signal data_count       : std_logic_vector (  4 downto 0 ) := (others => '0');

begin
------------------------------------------------------------
-- SPI Clocking
------------------------------------------------------------

-- SPI Clock Generator...

process(i_clk)
begin
    if rising_edge(i_clk) then
        if (unsigned(pic_clk_counter) >= 1250) then -- = 100kHz, giving 50kHz SPI clock rate.
           clk_plse <= '1';
           pic_clk_counter <= (others => '0');
        else
           clk_plse <= '0';
           pic_clk_counter <= std_logic_vector(unsigned(pic_clk_counter)+1);
        end if;
    end if;
end process;


-- Clock Buffer...

BUFGCE_inst : BUFGCE  
generic map (
    CE_TYPE => "SYNC",              -- ASYNC, HARDSYNC, SYNC
    IS_CE_INVERTED => '0',          -- Programmable inversion on CE
    IS_I_INVERTED => '0',            -- Programmable inversion on I
    SIM_DEVICE => "ULTRASCALE_PLUS" -- ULTRASCALE, ULTRASCALE_PLUS
)
port map (
    O =>  slow_clk, 
    CE => clk_plse, 
    I =>  i_clk 
);


-- SPI Frame rate Generator

process(slow_clk)
begin
    if rising_edge(slow_clk) then
        if (unsigned(pic_frm_counter)>=250) then  -- Update every 2.5mS
            pic_frm <= '1';
            pic_frm_counter <= (others => '0');
        else
            pic_frm <= '0';
            pic_frm_counter <= std_logic_vector(unsigned(pic_frm_counter)+1);
        end if;
    end if;
end process;

------------------------------------------------------------



------------------------------------------------------------
--
-- Sequence:
--              idle... CS and SC both high.
--
--              (set i_start high to initiate transfer).
--                  CS Low and set data bit
--                  SC Low
--                  SC High and set next data bit
--                    ...repeat last two lines for all 16 bits
--                  CS High and flag done.
--
------------------------------------------------------------

process(slow_clk)
begin
    if rising_edge(slow_clk) then
        if (pic_frm='1' and running='0') then  -- Detected Start input flag while not running

            state        <= (others => '0');        -- reset counters and start running
            data_count   <= (others => '0');
            running      <= '1';
            tx_shift_reg <= "00" & i_data(15 downto 0);
            rx_shift_reg <= (others => '0');
        end if;

        if (running = '1') then                      -- DATA TRANSFER...
	
            case state is
            when x"0" =>
                CLK_OUT <= '1';                     -- ensure clock high
                state   <= x"1";   
        
            when x"1" =>
                CS_OUT  <= '0';                     -- CS low,
                SDO_OUT <= tx_shift_reg(17);        -- and set first bit
                state   <= x"2";         
                
            when x"2" =>
                CLK_OUT    <= '0';                                  -- clock low,
                rx_shift_reg(0) <= i_PIC_DO;                        -- read in data bit,
                tx_shift_reg <= tx_shift_reg(16 downto 0) & '0';    -- and shift TX ready for next bit
                data_count <= std_logic_vector(unsigned(data_count)+1);
                state      <= x"3";
        
            when x"3" =>
                CLK_OUT <= '1';                                     -- clock high,
                SDO_OUT <= tx_shift_reg(17);                        -- and set next bit.
                
                if (unsigned(data_count)=18) then                     -- check for end of word,
                    latched_o_data <= rx_shift_reg;
                    state <= x"4";
                else
                    rx_shift_reg <= rx_shift_reg(16 downto 0) & '0';  -- else shift RX ready for next bit
                    state <= x"2";
                end if;
            
            when x"4" =>
                CS_OUT  <= '1';                     -- end of word, so CS high
                CLK_OUT <= '1';
                SDO_OUT <= '0';				
                running <= '0';                     -- and stop.

            when others =>
                running <= '0';
            end case;

        end if;

    end if;
end process;

------------------------------------------------------------
-- Output Assignments
------------------------------------------------------------

o_PIC_SC <= CLK_OUT;
o_PIC_CS <= CS_OUT;
o_PIC_DI <= SDO_OUT;
o_done   <= not running;
o_data   <= latched_o_data;


end rtl;
