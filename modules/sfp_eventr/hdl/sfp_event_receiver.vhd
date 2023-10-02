library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.picxo_pkg.all;
use work.support.all;

library unisim;
use unisim.vcomponents.all;

entity sfp_event_receiver is
    port (GTREFCLK          : in  std_logic;
          sysclk_i          : in  std_logic;
          event_reset_i     : in  std_logic;
          rxp_i             : in  std_logic;
          rxn_i             : in  std_logic;
          txp_o             : out std_logic;
          txn_o             : out std_logic;
          rxbyteisaligned_o : out std_logic;
          rxbyterealign_o   : out std_logic;
          rxcommadet_o      : out std_logic;
          rxdata_o          : out std_logic_vector(15 downto 0);
          rxoutclk_o        : out std_logic;
          rxcharisk_o       : out std_logic_vector(1 downto 0);
          rxdisperr_o       : out std_logic_vector(1 downto 0);
          mgt_ready_o       : out std_logic;
          rxnotintable_o    : out std_logic_vector(1 downto 0);
          txdata_i          : in  std_logic_vector(15 downto 0);
          txoutclk_o        : out std_logic;
          txcharisk_i       : in  std_logic_vector(1 downto 0);
          cpll_lock_o       : out std_logic
          );

end sfp_event_receiver;

architecture rtl of sfp_event_receiver is

component event_receiver_mgt
    port
    (
    SYSCLK_IN                               : in   std_logic;
    SOFT_RESET_TX_IN                        : in   std_logic;
    SOFT_RESET_RX_IN                        : in   std_logic;
    DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
    GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_DATA_VALID_IN                       : in   std_logic;

    --_________________________________________________________________________
    --GT0  (X0Y1)
    --____________________________CHANNEL PORTS________________________________
    --------------------------------- CPLL Ports -------------------------------
    gt0_cpllfbclklost_out                   : out  std_logic;
    gt0_cplllock_out                        : out  std_logic;
    gt0_cplllockdetclk_in                   : in   std_logic;
    gt0_cpllreset_in                        : in   std_logic;
    -------------------------- Channel - Clocking Ports ------------------------
    gt0_gtrefclk0_in                        : in   std_logic;
    gt0_gtrefclk1_in                        : in   std_logic;
    ---------------------------- Channel - DRP Ports  --------------------------
    gt0_drpaddr_in                          : in   std_logic_vector(8 downto 0);
    gt0_drpclk_in                           : in   std_logic;
    gt0_drpdi_in                            : in   std_logic_vector(15 downto 0);
    gt0_drpdo_out                           : out  std_logic_vector(15 downto 0);
    gt0_drpen_in                            : in   std_logic;
    gt0_drprdy_out                          : out  std_logic;
    gt0_drpwe_in                            : in   std_logic;
    --------------------------- Digital Monitor Ports --------------------------
    gt0_dmonitorout_out                     : out  std_logic_vector(7 downto 0);
    --------------------- RX Initialization and Reset Ports --------------------
    gt0_eyescanreset_in                     : in   std_logic;
    gt0_rxuserrdy_in                        : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out                : out  std_logic;
    gt0_eyescantrigger_in                   : in   std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    gt0_rxusrclk_in                         : in   std_logic;
    gt0_rxusrclk2_in                        : in   std_logic;
    ------------------ Receive Ports - FPGA RX interface Ports -----------------
    gt0_rxdata_out                          : out  std_logic_vector(15 downto 0);
    ------------------ Receive Ports - RX 8B/10B Decoder Ports
    gt0_rxdisperr_out                       : out  std_logic_vector(1 downto 0);
    gt0_rxnotintable_out                    : out  std_logic_vector(1 downto 0);
    --------------------------- Receive Ports - RX AFE -------------------------
    gt0_gtxrxp_in                           : in   std_logic;
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gt0_gtxrxn_in                           : in   std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    gt0_rxbyteisaligned_out                 : out std_logic;
    gt0_rxbyterealign_out                   : out std_logic;
    gt0_rxcommadet_out                      : out std_logic;
    gt0_rxmcommaalignen_in                  : in  std_logic;
    gt0_rxpcommaalignen_in                  : in  std_logic;
    --------------------- Receive Ports - RX Equalizer Ports -------------------
    gt0_rxdfelpmreset_in                    : in   std_logic;
    gt0_rxmonitorout_out                    : out  std_logic_vector(6 downto 0);
    gt0_rxmonitorsel_in                     : in   std_logic_vector(1 downto 0);
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    gt0_rxoutclk_out                        : out  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in                        : in   std_logic;
    gt0_rxpmareset_in                       : in   std_logic;
    ---------------------- Receive Ports - RX gearbox ports --------------------
--    gt0_rxslide_in                          : in   std_logic;
    ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
    gt0_rxcharisk_out                       : out  std_logic_vector(1 downto 0);
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    gt0_rxresetdone_out                     : out  std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in                        : in   std_logic;
    gt0_txuserrdy_in                        : in   std_logic;
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    gt0_txusrclk_in                         : in   std_logic;
    gt0_txusrclk2_in                        : in   std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    gt0_txdata_in                           : in   std_logic_vector(15 downto 0);
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    gt0_gtxtxn_out                          : out  std_logic;
    gt0_gtxtxp_out                          : out  std_logic;
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt0_txoutclk_out                        : out  std_logic;
    gt0_txoutclkfabric_out                  : out  std_logic;
    gt0_txoutclkpcs_out                     : out  std_logic;
    -------------------- Transmit Ports - TX Gearbox Ports ---------------------
    gt0_txcharisk_in                        : in   std_logic_vector(1 downto 0);
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt0_txresetdone_out                     : out  std_logic;
    --____________________________COMMON PORTS________________________________
     GT0_QPLLOUTCLK_IN  : in std_logic;
     GT0_QPLLOUTREFCLK_IN : in std_logic
    );

end component;

constant DELAY_3ms : natural := 375_000; -- 3 ms at 125 MHz

signal gt0_rxoutclk                 : std_logic;
signal gt0_txoutclk                 : std_logic;
signal rxoutclk                     : std_logic;
signal txoutclk                     : std_logic;
signal GT0_TX_FSM_RESET_DONE        : std_logic;
signal GT0_RX_FSM_RESET_DONE        : std_logic;
signal data_valid                   : std_logic;

signal gt0_cplllock                 : std_logic;
signal gt0_drpdo                    : std_logic_vector(15 downto 0);
signal gt0_drprdy                   : std_logic;
signal gt0_drpen                    : std_logic;
signal gt0_drpwe                    : std_logic;
signal gt0_drpdi                    : std_logic_vector(15 downto 0);
signal gt0_drpaddr                  : std_logic_vector(8 downto 0);

signal gt0_rxresetdone              : std_logic;
signal gt0_txresetdone              : std_logic;
signal gt0_qplloutclk_in            : std_logic;
signal gt0_qplloutrefclk_in         : std_logic;

signal GT0_TX_FSM_RESET_DONE_sync   : std_logic;
signal GT0_RX_FSM_RESET_DONE_sync   : std_logic;
signal gt0_txresetdone_sync         : std_logic;
signal gt0_rxresetdone_sync         : std_logic;
signal init_rst                     : std_logic;
signal mgt_rst                      : std_logic;

-- PICXO control parameters (currently default to constant init values in pkg)
signal  G1                              : STD_LOGIC_VECTOR (4 downto 0)     := c_G1;
signal  G2                              : STD_LOGIC_VECTOR (4 downto 0)     := c_G2;
signal  R                               : STD_LOGIC_VECTOR (15 downto 0)    := c_R;
signal  V                               : STD_LOGIC_VECTOR (15 downto 0)    := c_V;
signal  ce_dsp_rate                     : std_logic_vector (23 downto 0)    := c_ce_dsp_rate;
signal  C                               : STD_LOGIC_VECTOR (6 downto 0)     := c_C;
signal  P                               : STD_LOGIC_VECTOR (9 downto 0)     := c_P;
signal  N                               : STD_LOGIC_VECTOR (9 downto 0)     := c_N;
signal  don                             : STD_LOGIC_VECTOR (0 downto 0)     := c_don;

signal  Offset_ppm                      : std_logic_vector (21 downto 0)    := c_Offset_ppm;
signal  Offset_en                       : std_logic                         := c_Offset_en;
signal  hold                            : std_logic                         := c_hold;
signal  acc_step                        : STD_LOGIC_VECTOR (3 downto 0)     := c_acc_step;

-- PICXO Monitoring signals (currently dangling, but can be connected to ILA)
signal error_o                          : STD_LOGIC_VECTOR (20 downto 0) ;
signal volt_o                           : STD_LOGIC_VECTOR (21 downto 0) ;
signal drpdata_short_o                  : STD_LOGIC_VECTOR (7  downto 0) ;
signal ce_pi_o                          : STD_LOGIC ;
signal ce_pi2_o                         : STD_LOGIC ;
signal ce_dsp_o                         : STD_LOGIC ;
signal ovf_pd                           : STD_LOGIC ;
signal ovf_ab                           : STD_LOGIC ;
signal ovf_volt                         : STD_LOGIC ;
signal ovf_int                          : STD_LOGIC ;

signal    picxo_rst                     : std_logic_vector(7 downto 0) := (others =>'0');
attribute shreg_extract                 : string;
attribute equivalent_register_removal   : string;
attribute shreg_extract of picxo_rst                  : signal is "no";
attribute equivalent_register_removal of picxo_rst    : signal is "no"; 

begin

-- Assign outputs

rxoutclk_o <= rxoutclk;
txoutclk_o <= txoutclk;
cpll_lock_o <= gt0_cplllock;

-- Clock buffers for RX recovered clock and TX clock

rxoutclk_bufg : BUFG
port map(
    O => rxoutclk,
    I => gt0_rxoutclk
);

txoutclk_bufg : BUFG
port map(
    O => txoutclk,
    I => gt0_txoutclk
);

--synchronise signals from MGT clock domains
TX_FSM_RST_sync : entity work.sync_bit
    port map(
     clk_i => sysclk_i,
     bit_i => GT0_TX_FSM_RESET_DONE,
     bit_o => GT0_TX_FSM_RESET_DONE_sync
);

RX_FSM_RST_sync : entity work.sync_bit
    port map(
     clk_i => sysclk_i,
     bit_i => GT0_RX_FSM_RESET_DONE,
     bit_o => GT0_RX_FSM_RESET_DONE_sync
);

txreset_sync : entity work.sync_bit
    port map(
     clk_i => sysclk_i,
     bit_i => gt0_txresetdone,
     bit_o => gt0_txresetdone_sync
);

rxreset_sync : entity work.sync_bit
    port map(
     clk_i => sysclk_i,
     bit_i => gt0_rxresetdone,
     bit_o => gt0_rxresetdone_sync
);

-- Indicates when the link is up when the rx and tx reset have finished
ps_linkup: process(sysclk_i)
begin
    if rising_edge(sysclk_i) then
        if ( GT0_TX_FSM_RESET_DONE_sync and GT0_RX_FSM_RESET_DONE_sync and
             gt0_rxresetdone_sync and gt0_txresetdone_sync) = '1' then
            mgt_ready_o <= '1';
        else
            mgt_ready_o <= '0';
        end if;
     end if;
 end process ps_linkup;

-- Must be set high
data_valid <= '1';

-- If connected causes build to fail
gt0_qplloutclk_in <= '0';
gt0_qplloutrefclk_in <= '0';

-- Hold MGT in reset for 3 ms after startup
-- See Xilinx AR#65199
startup_rst: process(sysclk_i)
  variable startup_ctr : unsigned(LOG2(DELAY_3ms) downto 0) := (others => '0');
begin
    if rising_edge(sysclk_i) then
        if startup_ctr = DELAY_3ms then
            init_rst <= '0';
        else
            init_rst <= '1';
            startup_ctr := startup_ctr + 1;
        end if;
    end if;
end process;

mgt_rst <= event_reset_i or init_rst;

event_receiver_mgt_inst : event_receiver_mgt
    port map
        (
        SYSCLK_IN                   => GTREFCLK,
        SOFT_RESET_TX_IN            => mgt_rst,
        SOFT_RESET_RX_IN            => mgt_rst,
        DONT_RESET_ON_DATA_ERROR_IN => '0',
        GT0_TX_FSM_RESET_DONE_OUT   => GT0_TX_FSM_RESET_DONE,
        GT0_RX_FSM_RESET_DONE_OUT   => GT0_RX_FSM_RESET_DONE,
        GT0_DATA_VALID_IN           => data_valid,
        --_________________________________________________________________________
        --GT0  (X0Y1)
        --____________________________CHANNEL PORTS________________________________
        --------------------------------- CPLL Ports -------------------------------
        gt0_cpllfbclklost_out       => open,
        gt0_cplllock_out            => gt0_cplllock,
        gt0_cplllockdetclk_in       => sysclk_i,
        gt0_cpllreset_in            => '0',
        -------------------------- Channel - Clocking Ports ------------------------
        gt0_gtrefclk0_in            => '0',
        gt0_gtrefclk1_in            => GTREFCLK,
        ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in              => gt0_drpaddr,
        gt0_drpclk_in               => txoutclk,
        gt0_drpdi_in                => gt0_drpdi,
        gt0_drpdo_out               => gt0_drpdo,
        gt0_drpen_in                => gt0_drpen,
        gt0_drprdy_out              => gt0_drprdy,
        gt0_drpwe_in                => gt0_drpwe,
        --------------------------- Digital Monitor Ports --------------------------
        gt0_dmonitorout_out         => open,
        --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in         => '0',
        gt0_rxuserrdy_in            => '0',
        -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescandataerror_out    => open,
        gt0_eyescantrigger_in       => '0',
        ------------------ Receive Ports - FPGA RX Interface Ports -----------------
        gt0_rxusrclk_in             => rxoutclk,
        gt0_rxusrclk2_in            => rxoutclk,
        ------------------ Receive Ports - FPGA RX interface Ports -----------------
        gt0_rxdata_out              => rxdata_o,
        ----------------- Receiver Ports - RX 8B/10B Decoder Ports -----------------
        gt0_rxdisperr_out           => rxdisperr_o,
        gt0_rxnotintable_out        => rxnotintable_o,
        --------------------------- Receive Ports - RX AFE -------------------------
        gt0_gtxrxp_in               => rxp_i,
        ------------------------ Receive Ports - RX AFE Ports ----------------------
        gt0_gtxrxn_in               => rxn_i,
        -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
        gt0_rxbyteisaligned_out     => rxbyteisaligned_o,
        gt0_rxbyterealign_out       => rxbyterealign_o,
        gt0_rxcommadet_out          => rxcommadet_o,
        gt0_rxmcommaalignen_in      => '1',
        gt0_rxpcommaalignen_in      => '1',
        --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt0_rxdfelpmreset_in        => '0',
        gt0_rxmonitorout_out        => open,
        gt0_rxmonitorsel_in         => (others => '0'),
        --------------- Receive Ports - RX Fabric Output Control Ports -------------
        gt0_rxoutclk_out            => gt0_rxoutclk,
        ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in            => '0',
        gt0_rxpmareset_in           => '0',
        ---------------------- Receive Ports - RX gearbox ports --------------------
--        gt0_rxslide_in              => '0',
        ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
        gt0_rxcharisk_out           => rxcharisk_o,
        -------------- Receive Ports -RX Initialization and Reset Ports ------------
        gt0_rxresetdone_out         => gt0_rxresetdone,
        --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in            => '0',
        gt0_txuserrdy_in            => '0',
        ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
        gt0_txusrclk_in             => txoutclk,
        gt0_txusrclk2_in            => txoutclk,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        gt0_txdata_in               => txdata_i,
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        gt0_gtxtxn_out              => txn_o,
        gt0_gtxtxp_out              => txp_o,
        ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        gt0_txoutclk_out            => gt0_txoutclk,
        gt0_txoutclkfabric_out      => open,
        gt0_txoutclkpcs_out         => open,
        ----------------- Transmit Port - TX Gearbox Port
        gt0_txcharisk_in            => txcharisk_i,
        ------------- Transmit Ports - TX Initialization and Reset Ports -----------
        gt0_txresetdone_out         => gt0_txresetdone,
        --____________________________COMMON PORTS________________________________
        GT0_QPLLOUTCLK_IN           => gt0_qplloutclk_in,
        GT0_QPLLOUTREFCLK_IN        => gt0_qplloutrefclk_in
        );

process (txoutclk, picxo_rst, gt0_cplllock)
begin
   if(picxo_rst(0) = '1' or not gt0_cplllock ='1') then
        picxo_rst (7 downto 1)     <= (others=>'1');
   elsif rising_edge (txoutclk) then
        picxo_rst (7 downto 1)     <=  picxo_rst(6 downto 0);
end if;
end process;  

sfp_eventr_PICXO : PICXO_FRACXO
    PORT MAP (
        RESET_I => picxo_rst(7),
        REF_CLK_I => sysclk_i,
        TXOUTCLK_I => txoutclk,
        DRPEN_O => gt0_drpen,
        DRPWEN_O => gt0_drpwe,
        DRPDO_I => gt0_drpdo,
        DRPDATA_O => gt0_drpdi,
        DRPADDR_O => gt0_drpaddr,
        DRPRDY_I => gt0_drprdy,
        RSIGCE_I => '1',
        VSIGCE_I => '1',
        VSIGCE_O => open,
        ACC_STEP => acc_step,
        G1 => G1,
        G2 => G2,
        R => R,
        V => V,
        CE_DSP_RATE => ce_dsp_rate,
        C_I => C,
        P_I => P,
        N_I => N,
        OFFSET_PPM => Offset_ppm,
        OFFSET_EN => Offset_en,
        HOLD => hold,
        DON_I => don,

        DRP_USER_REQ_I => '0',
        DRP_USER_DONE_I => picxo_rst(7),
        DRPEN_USER_I => '0',
        DRPWEN_USER_I => '0',
        DRPADDR_USER_I => (others => '1'),
        DRPDATA_USER_I => (others => '1'),
        DRPDATA_USER_O => open,
        DRPRDY_USER_O => open,
        DRPBUSY_O => open,

        ACC_DATA => open,
        ERROR_O => error_o,
        VOLT_O => volt_o,
        DRPDATA_SHORT_O => drpdata_short_o,
        CE_PI_O => ce_pi_o,
        CE_PI2_O => ce_pi2_o,
        CE_DSP_O => ce_dsp_o,
        OVF_PD => ovf_pd,
        OVF_AB => ovf_ab,
        OVF_VOLT => ovf_volt,
        OVF_INT => ovf_int
    );

end rtl;
