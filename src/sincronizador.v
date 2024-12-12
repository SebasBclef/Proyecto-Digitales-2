`include "CodeGroups.v" //archivo con las tablas de los code-gruops
module sincronizador (/*AUTOARG*/
   // Outputs
   code_sync_status, rx_even, SUDI,
   // Inputs
   clk, signal_detect, mr_main_reset, mr_loopback, PUDI
   );

input
    clk,            //<-- señal de reloj, 
    signal_detect,  //<-- indica si se ha detectado una señal 
    mr_main_reset,  //<-- reset principal
    mr_loopback;    //<-- señal de bucle de retroalimentación 
input [9:0] 
    PUDI;           //<-- rx_code-group<9:0> de la capa PMA

output reg 
  code_sync_status, //<-- Estado de la sincronización
  rx_even;          //<-- Indica si el ciclo actual es par

output reg [9:0]
  SUDI;             //<-- code-group<9:0> hacia el receptor

/*AUTOINPUT*/
/*AUTOOUTPUT*/
/*AUTOREG*/

reg 
    signal_detectCHANGE,    //<-- detección de cambio en la señal
                            // 1 si la señal ha cambiado, 0 si se mantiene
    previous_signal_detect, //<-- memoria de signal_detect en el anterior ciclo
    P_K_COMMA,                //<-- Valor en alto si se detecta una coma;
    P_K,                    //<-- Valor en alto si se detecta un code-group K;
    P_D_IDLE,               //<-- Valor en alto si se detecta un code-group D relacionado a IDLE;
    P_D,                    //<-- Valor en alto si se detecta un code-group D;
    flip_rx;                 //<-- valor para flipear rx_even 

reg [2:0] good_cgs, bad_cgs; /*<-- contadores para contar hasta 4 veces y decidir si reconectar
                                   o desconectar la sincronización*/

reg [2:0] next_good_cgs, next_bad_cgs;

/******************************************************************************
                              PARAMETROS DE ESTADO
 *****************************************************************************/
localparam N = 7;  // PARAMETRO PARA CANTIDAD DE ESTADOS

localparam LOSS_OF_SYNC = {{(N-1){1'b0}} , 1'b1}; // CONCATENANDO N-1 CEROS CON UN 1 
localparam COMMA_DETECT_1 = LOSS_OF_SYNC << 1;
localparam ACQUIRE_SYNC_1 = LOSS_OF_SYNC << 2;
localparam COMMA_DETECT_2 = LOSS_OF_SYNC << 3;
localparam ACQUIRE_SYNC_2 = LOSS_OF_SYNC << 4;
localparam COMMA_DETECT_3 = LOSS_OF_SYNC << 5;
localparam SYNC_ACQUIRE_1 = LOSS_OF_SYNC << 6;

// REGISTROS INTERNO PARA MANEJO DE ESTADOS
reg [N-1:0] state, nextState;

/******************************************************************************
                              COMPORTAMIENTOS
 *****************************************************************************/

// Lógica secuencial para signal_detectCHANGE
always @(posedge clk) begin
  previous_signal_detect <= signal_detect; /*<-- Se guarda el valor anterior de
                                                  signal detect */
end

always @(posedge clk) begin // LÓGICA SECUENCIAL
  if (!mr_main_reset) begin             
                              // reset DE VALORES DE FF
    state <= LOSS_OF_SYNC;
    rx_even <= 0;
    good_cgs <= 0;
    bad_cgs <= 0;
    next_bad_cgs  <= 0;
    next_good_cgs <= 0;
  /*AUTORESET*/
  end else begin              
    state <= nextState;       // TRANSICIÓN DE ESTADOS DE FF
    good_cgs <= next_good_cgs;
    bad_cgs <= next_bad_cgs;
    SUDI <= PUDI;
    
    rx_even <= ~rx_even;  // Flipeando la señal rx_even para poder sincronizar

  end
end

always @(*) begin   // LÓGICA COMBINACIONAL 

                              // SOSTENIENDO VALORES DE FF
nextState = state;
                              // VALORES DE OUTPUTS POR DEFECTO
code_sync_status = 0; /*<-- Valor por defecto del estado de sincronización
                            ya que sync_acquired_1 es el único estado que 
                            modifica este valor, ya para los estados
                            entre este y LOSS_OF_SYNC serán manejados con
                            contadores */

// Lógica combinacional para signal_detectCHANGE inherente a los estados
  if (signal_detect == previous_signal_detect) begin
    signal_detectCHANGE = 0;
  end else begin
    signal_detectCHANGE = 1;
  end

// CASE PUDI PARA DATOS K
case(PUDI)
  `K28_0_10bits: P_K = 1;
  `K28_1_10bits: P_K = 1;
  `K28_2_10bits: P_K = 1;
  `K28_3_10bits: P_K = 1;
  `K28_4_10bits: P_K = 1;
  `K28_5_10bits: P_K = 1;
  ~`K28_5_10bits: P_K = 1;
  `K28_6_10bits: P_K = 1;
  `K28_7_10bits: P_K = 1;
  `K23_7_10bits: P_K = 1;
  `K27_7_10bits: P_K = 1;
  `K29_7_10bits: P_K = 1;
  `K30_7_10bits: P_K = 1;

  default: begin
    P_K = 0;
  end
endcase

// CASE PUDI PARA COMMA
case(PUDI)
  `K28_5_10bits:  P_K_COMMA = 1;
  ~`K28_5_10bits: P_K_COMMA = 1;
  default: begin
    P_K_COMMA = 0;
  end
endcase

// CASE PUDI PARA DATOS
case(PUDI)
  `D16_2_10bits:    P_D = 1;
  `D16_2_m_10bits:  P_D = 1;
  `D05_6_10bits:    P_D = 1;

  `D00_0_10bits:    P_D = 1;
  `D01_0_10bits:    P_D = 1;
  `D02_0_10bits:    P_D = 1;
  `D05_0_10bits:    P_D = 1;
  `D10_0_10bits:    P_D = 1;
  `D21_0_10bits:    P_D = 1;
  `D11_1_10bits:    P_D = 1;
  `D20_2_10bits:    P_D = 1;
  `D21_4_10bits:    P_D = 1;
  `D10_5_10bits:    P_D = 1;
  
  default: begin
    P_D = 0;
  end
endcase

// CASE PUDI PARA DATOS DE IDLE
case(PUDI)
  `D16_2_10bits:  P_D_IDLE = 1;
  `D16_2_m_10bits:  P_D_IDLE = 1;
  `D05_6_10bits:  P_D_IDLE = 1;

  default: begin
    P_D_IDLE = 0;
  end
endcase

/*CASOS PARA CADA ESTADO*/
case(state)
//  
  LOSS_OF_SYNC: begin
// Si el dato entrante es una coma, se transiciona al estado de coma detectada
    if (P_K_COMMA) begin
      nextState = COMMA_DETECT_1;
    end
  end
//
  COMMA_DETECT_1: begin
    rx_even = 1;        // Se está en una coma, por lo que rx_even es VERDADERO
// Se transiciona a ACQUIRE_SYNC_1 si el dato es la pareja del set de IDLE
    if (P_D_IDLE) begin
      nextState = ACQUIRE_SYNC_1;
// Caso contrario, se pierde la sincronización
    end else begin
      nextState = LOSS_OF_SYNC;
    end
  end
// 
  ACQUIRE_SYNC_1: begin
  /* Si el dato encontrado es una comma, y rx_even es FALSO, entonces
     se pasa a coma detectada, ya que coma será rx_even VERDADERO 
     en caso contrario, se pierde la sincronización*/
    if (P_K_COMMA && ~rx_even) begin
      nextState = COMMA_DETECT_2;
    end else if (~P_D && ~P_K) begin //cgbad
      nextState = LOSS_OF_SYNC;
    end
  end
// 
  COMMA_DETECT_2: begin
// Mismo comportamiento que coma detectada 1
    rx_even = 1;
    if (P_D_IDLE) begin
      nextState = ACQUIRE_SYNC_2;
    end else begin
      nextState = LOSS_OF_SYNC;
    end
  end
// 
  ACQUIRE_SYNC_2: begin
// Mismo comportamiento que ACQUIRE_SYNC_1
    if (P_K_COMMA && ~rx_even) begin
      nextState = COMMA_DETECT_3;
    end else if (~P_D && ~P_K) begin // cgbad
      nextState = LOSS_OF_SYNC;      
    end
  end
//
  COMMA_DETECT_3: begin
// Mismo comportamiento que coma detectada 1, pero acá se pasa a SYNC_ACQUIRE_1
    rx_even = 1;
    if (P_D_IDLE) begin
      nextState = SYNC_ACQUIRE_1;
    end else begin
      nextState = LOSS_OF_SYNC;
    end
  end
//
  SYNC_ACQUIRE_1: begin
    
    code_sync_status = 1; // Solo en este estado code_sync_status es VERDADERO

    if (good_cgs == 3'b100) begin // Si el contador de good_cgs llega a 4
      next_bad_cgs = 0;           // el contador de bad_cgs se restablece
    end else if (bad_cgs== 3'b100)// pero el el contador bad_cgs llega a 4
     begin 
      nextState = LOSS_OF_SYNC;   // se pierde la sincronia
      next_bad_cgs = 0;           // y se restablecen los contadores
      next_good_cgs = 0;
    end
// Lógica para incrementar contadores
    if (~P_D && ~P_K ) begin     // Si el dato no pertenece a la lista valida
      next_bad_cgs = bad_cgs+1;  // El contador de bad_cgs aumenta a 1
    end else begin               // pero si el dato es correcto
      if (bad_cgs>0)             // y el contador de bad_cgs ya empezó 
      next_good_cgs = good_cgs+1; // se inicia el contador de good_cgs
    end                           // y entre los dos contadores el que llegue
                                  // primero a 4, decide que pasa con la sincro
                                  // nia.

  end
//
  default:  begin
    nextState = LOSS_OF_SYNC;
  end          
endcase
end

endmodule