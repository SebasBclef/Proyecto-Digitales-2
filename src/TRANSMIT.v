`include "Transmisor_OS.v"
`include "Transmisor_CB.v"

//Aca, se conectan las dos maquinas de estado para transmit en solo una
module TRANSMIT (
    input mr_main_reset,
    input GTX_CLK,
    input [7:0] TXD,
    input TX_EN,
    input receiving,
    input [2:0] xmit,
    output transmitting,
    output [9:0] PUDR);


    // variables internas de TX
    wire TX_OSET_indicate;
    wire [6:0] TX_O_SET;
    wire TX_EVEN;

    TRANSMIT_OS ordered_set (
        // entradas de TX ordered set
        .mr_main_reset(mr_main_reset),
        .GTX_CLK(GTX_CLK),
        .TXD(TXD[7:0]),
        .TX_EN(TX_EN),
        .tx_even(tx_even),
        .receiving(receiving),
        .TX_OSET_indicate(TX_OSET_indicate),
        .xmit(xmit[2:0]),
        // salidas de TX ordered set
        .TX_O_SET(TX_O_SET),
        .transmitting(transmitting)
    );

    TRANSMIT_CG code_group (
        // entradas de TX code group
        .mr_main_reset(mr_main_reset),
        .GTX_CLK(GTX_CLK),
        .TX_O_SET(TX_O_SET),
        .TXD(TXD[7:0]),

        // salidas de TX code group
        .tx_even(tx_even),
        .TX_OSET_indicate(TX_OSET_indicate),
        .PUDR(PUDR[9:0])
    );
    endmodule