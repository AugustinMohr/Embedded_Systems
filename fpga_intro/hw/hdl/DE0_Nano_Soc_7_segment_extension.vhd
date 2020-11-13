-- #############################################################################
-- DE0_Nano_Soc_7_segment_extension_board.vhd
--
-- BOARD         : DE0-Nano-SoC from Terasic
-- Author        : Florian Depraz
--               : Sahand Kashani-Akhavan from Terasic documentation
-- Revision      : 1.0
-- Creation date : 27/10/2016
--
-- Syntax Rule : GROUP_NAME_N[bit]
--
-- GROUP : specify a particular interface (ex: SDR_)
-- NAME  : signal name (ex: CONFIG, D, ...)
-- bit   : signal index
-- _N    : to specify an active-low signal
-- #############################################################################

library ieee;
use ieee.std_logic_1164.all;

entity DE0_Nano_Soc_7_segment_extension is
    port(
        -- ADC
--        ADC_CONVST       : out   std_logic;
--        ADC_SCK          : out   std_logic;
--        ADC_SDI          : out   std_logic;
--        ADC_SDO          : in    std_logic;

        -- ARDUINO
--        ARDUINO_IO       : inout std_logic_vector(15 downto 0);
--        ARDUINO_RESET_N  : inout std_logic;

        -- CLOCK
			FPGA_CLK1_50     : in    std_logic;
--        FPGA_CLK2_50     : in    std_logic;
--        FPGA_CLK3_50     : in    std_logic;

        -- KEY
--        KEY_N            : in    std_logic_vector(1 downto 0);

        -- LED
--        LED              : out   std_logic_vector(7 downto 0);

        -- SW
--        SW               : in    std_logic_vector(3 downto 0);

        -- GPIO_0
--        GPIO_0           : inout std_logic_vector(35 downto 0);

        -- Extension board 7 segments
        SelSeg           : out   std_logic_vector(7 downto 0);
        Reset_Led        : out   std_logic;
        nSelDig          : out   std_logic_vector(5 downto 0);
--      SwLed            : in    std_logic_vector(7 downto 0);
        nButton          : in    std_logic_vector(3 downto 0);
        LedButton        : out   std_logic_vector(3 downto 0)

        -- HPS
--        HPS_CONV_USB_N   : inout std_logic;
--        HPS_DDR3_ADDR    : out   std_logic_vector(14 downto 0);
--        HPS_DDR3_BA      : out   std_logic_vector(2 downto 0);
--        HPS_DDR3_CAS_N   : out   std_logic;
--        HPS_DDR3_CK_N    : out   std_logic;
--        HPS_DDR3_CK_P    : out   std_logic;
--        HPS_DDR3_CKE     : out   std_logic;
--        HPS_DDR3_CS_N    : out   std_logic;
--        HPS_DDR3_DM      : out   std_logic_vector(3 downto 0);
--        HPS_DDR3_DQ      : inout std_logic_vector(31 downto 0);
--        HPS_DDR3_DQS_N   : inout std_logic_vector(3 downto 0);
--        HPS_DDR3_DQS_P   : inout std_logic_vector(3 downto 0);
--        HPS_DDR3_ODT     : out   std_logic;
--        HPS_DDR3_RAS_N   : out   std_logic;
--        HPS_DDR3_RESET_N : out   std_logic;
--        HPS_DDR3_RZQ     : in    std_logic;
--        HPS_DDR3_WE_N    : out   std_logic;
--        HPS_ENET_GTX_CLK : out   std_logic;
--        HPS_ENET_INT_N   : inout std_logic;
--        HPS_ENET_MDC     : out   std_logic;
--        HPS_ENET_MDIO    : inout std_logic;
--        HPS_ENET_RX_CLK  : in    std_logic;
--        HPS_ENET_RX_DATA : in    std_logic_vector(3 downto 0);
--        HPS_ENET_RX_DV   : in    std_logic;
--        HPS_ENET_TX_DATA : out   std_logic_vector(3 downto 0);
--        HPS_ENET_TX_EN   : out   std_logic;
--        HPS_GSENSOR_INT  : inout std_logic;
--        HPS_I2C0_SCLK    : inout std_logic;
--        HPS_I2C0_SDAT    : inout std_logic;
--        HPS_I2C1_SCLK    : inout std_logic;
--        HPS_I2C1_SDAT    : inout std_logic;
--        HPS_KEY_N        : inout std_logic;
--        HPS_LED          : inout std_logic;
--        HPS_LTC_GPIO     : inout std_logic;
--        HPS_SD_CLK       : out   std_logic;
--        HPS_SD_CMD       : inout std_logic;
--        HPS_SD_DATA      : inout std_logic_vector(3 downto 0);
--        HPS_SPIM_CLK     : out   std_logic;
--        HPS_SPIM_MISO    : in    std_logic;
--        HPS_SPIM_MOSI    : out   std_logic;
--        HPS_SPIM_SS      : inout std_logic;
--        HPS_UART_RX      : in    std_logic;
--        HPS_UART_TX      : out   std_logic;
--        HPS_USB_CLKOUT   : in    std_logic;
--        HPS_USB_DATA     : inout std_logic_vector(7 downto 0);
--        HPS_USB_DIR      : in    std_logic;
--        HPS_USB_NXT      : in    std_logic;
--        HPS_USB_STP      : out   std_logic
    );
end entity DE0_Nano_Soc_7_segment_extension;

architecture rtl of DE0_Nano_Soc_7_segment_extension is

	component system2_2 is
		port(
			clk_clk                                : in  std_logic                    := 'X';             -- clk
			reset_reset_n                          : in  std_logic                    := 'X';             -- reset_n
			a_7_segment_0_conduit_selseg_export    : out std_logic_vector(7 downto 0);                    -- export
			a_7_segment_0_conduit_ledbutton_export : out std_logic_vector(3 downto 0);                    -- export
			a_7_segment_0_conduit_nseldig_export   : out std_logic_vector(5 downto 0);                    -- export
			a_7_segment_0_conduit_nbutton_export   : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
			a_7_segment_0_conduit_reset_led_export : out std_logic                                        -- export
		);

end component system2_2;

begin

u0 : component system2_2
		port map(
			clk_clk                        				=> FPGA_CLK1_50,       			  -- clk.clk
			reset_reset_n                   				=> nButton(0),                  -- reset.reset_n
			a_7_segment_0_conduit_selseg_export			=> SelSeg,
			a_7_segment_0_conduit_ledbutton_export 	=> LedButton,
			a_7_segment_0_conduit_nseldig_export		=> nSelDig,
			a_7_segment_0_conduit_nbutton_export 		=> nButton,
			a_7_segment_0_conduit_reset_led_export		=> Reset_Led
		);




end;
