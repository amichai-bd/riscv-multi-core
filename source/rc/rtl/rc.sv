//-----------------------------------------------------------------------------
// Title            : RC - Ring Controller 
// Project          : LOTR: Lord-Of-The-Ring
//-----------------------------------------------------------------------------
// File             : rc.sv 
// Original Author  : Tzahi Peretz, Shimi Haleluya 
// Created          : 5/2021
//-----------------------------------------------------------------------------
// Description :
// 
//
// 
//------------------------------------------------------------------------------
// Modification history :
//
//
//------------------------------------------------------------------------------
//`timescale 1ns/1ps  
`include "lotr_defines.sv"

module rc
    import rc_pkg::*;  
    (
    //General Interface
    input   logic         QClk                   ,
    input   logic         RstQnnnH               ,
    input   logic  [7:0]  CoreID                 ,

    
    //Ring ---> RC
    input   logic         RingInputValidQ500H    ,
    input   t_opcode      RingInputOpcodeQ500H   ,
    input   logic  [31:0] RingInputAddressQ500H  ,
    input   logic  [31:0] RingInputDataQ500H     ,
    //RC   ---> Ring
    output  logic         RingOutputValidQ502H   ,
    output  t_opcode      RingOutputOpcodeQ502H  ,
    output  logic  [31:0] RingOutputAddressQ502H ,
    output  logic  [31:0] RingOutputDataQ502H    ,
    
    //Core Req/Rsp <---> RC
    input   logic         C2F_ReqValidQ500H      ,
    input   t_opcode      C2F_ReqOpcodeQ500H     ,
    input   logic  [1:0]  C2F_ReqThreadIDQ500H   ,
    input   logic  [31:0] C2F_ReqAddressQ500H    ,
    input   logic  [31:0] C2F_ReqDataQ500H       ,

    output   logic        C2F_RspValidQ502H      ,
    output   logic [1:0]  C2F_RspThreadIDQ502H   ,
    output   logic [31:0] C2F_RspDataQ502H       ,
    output   logic        C2F_RspStall           ,
    
    //RC   Req/Rsp <---> Core
    input   logic         F2C_RspValidQ500H      ,
    input   t_opcode      F2C_RspOpcodeQ500H     , // Fixme -  not sure neccesery - the core recieve on;y read responses
    input   logic  [31:0] F2C_RspAddressQ500H    ,
    input   logic  [31:0] F2C_RspDataQ500H       ,
    
    output  logic         F2C_ReqValidQ502H      ,
    output  t_opcode      F2C_ReqOpcodeQ502H     ,
    output  logic  [31:0] F2C_ReqAddressQ502H    ,
    output  logic  [31:0] F2C_ReqDataQ502H 
);

//=========================================
//=====    Data Path Signals    ===========
//=========================================
// Ring Interface
logic                   RingInputValidQ501H     ;
logic                   PreRingInputValidQ501H  ;
t_opcode                RingInputOpcodeQ501H    ; 
logic   [31:0]          RingInputAddressQ501H   ;
logic   [31:0]          RingInputDataQ501H      ;

logic                   RingOutputValidQ501H    ;
t_opcode                RingOutputOpcodeQ501H   ;
logic   [31:0]          RingOutputAddressQ501H  ;
logic   [31:0]          RingOutputDataQ501H     ;


logic   [C2F_MSB:0]       C2F_BufferValidQnnnH    ;
t_opcode[C2F_MSB:0]       C2F_BufferOpcodeQnnnH   ;
logic   [C2F_MSB:0][1:0]  C2F_BufferThreadIDQnnnH ;
logic   [C2F_MSB:0][31:0] C2F_BufferAddressQnnnH  ;
logic   [C2F_MSB:0][31:0] C2F_BufferDataQnnnH     ;
t_state [C2F_MSB:0]       C2F_BufferStateQnnnH    ;

logic   [C2F_MSB:0]       C2F_NextBufferValidQnnnH     ;
t_opcode[1:0]             C2F_NextBufferOpcodeQnnnH    ;
logic   [C2F_MSB:0][1:0]  C2F_NextBufferThreadIDQnnnH  ;
logic   [C2F_MSB:0][31:0] C2F_NextBufferAddressQnnnH   ;
logic   [C2F_MSB:0][31:0] C2F_NextBufferDataQnnnH      ;
t_state [C2F_MSB:0]       C2F_NextBufferStateQnnnH     ;


logic                     C2F_ReqValidQ501H       ;
t_opcode                  C2F_ReqOpcodeQ501H      ;
logic [31:0]              C2F_ReqAddressQ501H     ;
logic [31:0]              C2F_ReqDataQ501H        ;


// F2C BUFFER
logic   [F2C_MSB:0]       F2C_BufferValidQnnnH    ;
t_opcode[F2C_MSB:0]       F2C_BufferOpcodeQnnnH   ;
logic   [F2C_MSB:0][31:0] F2C_BufferAddressQnnnH  ;
logic   [F2C_MSB:0][31:0] F2C_BufferDataQnnnH     ;
logic   [F2C_MSB:0][2:0]  F2C_BufferStateQnnnH    ;

logic   [F2C_MSB:0]       F2C_NextBufferValidQnnnH    ;
t_opcode[F2C_MSB:0]       F2C_NextBufferOpcodeQnnnH   ;
logic   [F2C_MSB:0][31:0] F2C_NextBufferAddressQnnnH  ;
logic   [F2C_MSB:0][31:0] F2C_NextBufferDataQnnnH     ;
logic   [F2C_MSB:0][2:0]  F2C_NextBufferStateQnnnH    ;

logic                     F2C_RspValidQ501H     ;
t_opcode                  F2C_RspOpcodeQ501H    ;
logic   [31:0]            F2C_RspAddressQ501H   ;
logic   [31:0]            F2C_RspDataQ501H      ;


//=========================================
//=====    Control Bits Signals   =========
//=========================================
// === General ===
t_winner              SelRingOutQ501H       ;
logic                 F2C_AddressMatchQ500H ; 
t_state               state ; 

// === C2F ===
logic [C2F_ENC_MSB:0] C2F_SelRdRingQ501H    ;
logic [C2F_ENC_MSB:0] C2F_SelRdCoreQ502H    ;
logic [C2F_MSB:0]     C2F_EnRingWrQ501H     ;
logic [C2F_MSB:0]     C2F_EnCoreWrQ500H     ; 
logic [C2F_MSB:0]     C2F_EnWrQnnnH         ;
logic [C2F_MSB:0]     C2F_SelWrQnnnH        ;

// === F2C ===
logic [F2C_ENC_MSB:0] F2C_SelRdRingQ501H    ;
logic [F2C_ENC_MSB:0] F2C_SelRdCoreQ502H    ;
logic [F2C_MSB:0]     F2C_EnRingWrQ501H     ;
logic [F2C_MSB:0]     F2C_EnCoreWrQ500H     ;
logic [F2C_MSB:0]     F2C_EnWrQnnnH         ;
logic [F2C_MSB:0]     F2C_SelWrQnnnH        ;

// ==== init C2F MRO ==========
logic [C2F_MSB:0] C2F_DeallocMroQnnnH ;
logic [C2F_MSB:0] C2F_Mask0MroQnnnH   ;
logic [C2F_MSB:0] C2F_Mask1MroQnnnH   ;
logic [C2F_MSB:0] C2F_DecodedSelRdCoreQ502H;
logic [C2F_MSB:0] C2F_DecodedSelRdRingQ501H;
// === FIXME description
logic [F2C_MSB:0] F2C_FirstFreeEntryQ500H          ; 
logic [F2C_MSB:0] F2C_FreeEntriesQ500H             ; 
logic [F2C_MSB:0] F2C_IsValidReqQ500H              ; 
logic [F2C_MSB:0] F2C_ReadResponseMatchesQ500H     ; 
logic [F2C_MSB:0] F2C_FirstReadResponseMatcesQ500H ; 
// ==== init F2C MRO ==========
logic [F2C_MSB:0] F2C_DeallocMroQnnnH ;
logic [F2C_MSB:0] F2C_Mask0MroQnnnH   ;
logic [F2C_MSB:0] F2C_Mask1MroQnnnH   ;
logic [F2C_MSB:0] F2C_DecodedSelRdRingQ501H;
logic [F2C_MSB:0] F2C_DecodedSelRdCoreQ502H;
// === FIXME description
logic[1:0]        VentilationCounterQnnnH    ;
logic[1:0]        NextVentilationCounterQnnnH;
logic             EnVentilationQnnnH         ;
logic             RstVentilationQnnnH        ;
// === FIXME description
logic [C2F_MSB:0] C2F_FirstFreeEntryQ500H                     ; 
logic [C2F_MSB:0] C2F_FreeEntriesQ500H                        ; 
logic [C2F_MSB:0] C2F_ReadResponseMatchesQ501H                ; 
logic [C2F_MSB:0] C2F_FirstReadResponseMatchesQ501H           ; 
logic [C2F_MSB:0] C2F_IsValidReqQ500H                         ;
//======================================================================================
//=========================     Module Content      ====================================
//======================================================================================
//  TODO - add discription of this module structure and blockes
//
//======================================================================================

//=========================================
// Ring input Interface
//=========================================

`LOTR_MSFF( PreRingInputValidQ501H ,  RingInputValidQ500H  , QClk )
`LOTR_MSFF( RingInputOpcodeQ501H   ,  RingInputOpcodeQ500H , QClk )
`LOTR_MSFF( RingInputAddressQ501H  ,  RingInputAddressQ500H, QClk )
`LOTR_MSFF( RingInputDataQ501H     ,  RingInputDataQ500H   , QClk )

//==================================================================================
//              The C2F Buffer - Core 2 Fabric
//==================================================================================
//  TODO - add description of this block
//  only read responses aredont coming from the ring input, therefore if read response arrives from the
//   rinrg ,we  need to update the next buffer data only .
// but if command (read/write) comes from the core , we need to update all
// the next buffers(data,adress, thredid ...)
//==================================================================================


always_comb begin : find_free_candidate
    for (int i=0 ; i< C2F_ENTRIESNUM ; i++) begin 
            C2F_FreeEntriesQ500H[i] = C2F_BufferStateQnnnH[i] == FREE ;  
    end // for
end // always_comb find_free_candidate

`FIND_FIRST(C2F_FirstFreeEntryQ500H ,C2F_FreeEntriesQ500H)

always_comb begin : check_isValidReq_from_core_to_C2F
    if (C2F_ReqValidQ500H && (C2F_ReqOpcodeQ500H != RD_RSP ) && (C2F_ReqAddressQ500H[31:24] != CoreID  ))
        C2F_IsValidReqQ500H = '1 ; 
    else 
        C2F_IsValidReqQ500H = '0 ; 
end // always_comb

always_comb begin : find_read_response_match    
    for (int i=0 ; i < C2F_ENTRIESNUM ; i++ ) begin

        if ((RingInputAddressQ501H == C2F_BufferAddressQnnnH[i]) && (C2F_BufferStateQnnnH[i] == READ_PRGRS))
            C2F_ReadResponseMatchesQ501H[i] = 1'b1 ;  
        else
            C2F_ReadResponseMatchesQ501H[i] = 1'b0 ;  
    end
end
// in case read response matches to entry, we want one entry to alloc
`FIND_FIRST(C2F_FirstReadResponseMatchesQ501H ,C2F_ReadResponseMatchesQ501H)

// ===== C2F Buffer Input =========
assign C2F_EnCoreWrQ500H = C2F_FirstFreeEntryQ500H & C2F_IsValidReqQ500H ;
assign C2F_EnRingWrQ501H = C2F_FirstReadResponseMatchesQ501H  ; 

always_comb begin : next_c2f_buffer_per_buffer_entry
    C2F_EnWrQnnnH           = C2F_EnCoreWrQ500H | C2F_EnRingWrQ501H;
    C2F_SelWrQnnnH          = C2F_EnCoreWrQ500H;
    C2F_NextBufferStateQnnnH= C2F_BufferStateQnnnH ; // default value for state machine 
    RingInputValidQ501H     = PreRingInputValidQ501H;
    for(int i =0; i < C2F_ENTRIESNUM; i++) begin

        C2F_NextBufferOpcodeQnnnH[i]   = C2F_SelWrQnnnH[i] ? C2F_ReqOpcodeQ500H   : RingInputOpcodeQ501H ;
        C2F_NextBufferThreadIDQnnnH[i] = C2F_SelWrQnnnH[i] ? C2F_ReqThreadIDQ500H : C2F_BufferThreadIDQnnnH[i] ;
        C2F_NextBufferAddressQnnnH[i]  = C2F_SelWrQnnnH[i] ? C2F_ReqAddressQ500H  : RingInputAddressQ501H ;
        C2F_NextBufferDataQnnnH[i]     = C2F_SelWrQnnnH[i] ? C2F_ReqDataQ500H     : RingInputDataQ501H   ;
        state = C2F_BufferStateQnnnH[i]; 
        case(state)
            //Slot is FREE
            FREE : 
                    C2F_NextBufferStateQnnnH[i] =  (C2F_NextBufferOpcodeQnnnH[i] == RD)       ? READ        :
                                                   (C2F_NextBufferOpcodeQnnnH[i] == WR)       ? WRITE       :
                                                   (C2F_NextBufferOpcodeQnnnH[i] == WR_BCAST) ? WRITE_BCAST :
                                                                                                FREE        ; 
            //Slot is WRITE
            WRITE : // FIXME  if there is enable for the mux buffer exit .add it to the if .
                    // if the C2F out mux choose this entry , and out mux passing C2F_req
                    if (C2F_SelRdRingQ501H == i && (SelRingOutQ501H == C2FRequest ))
                        C2F_NextBufferStateQnnnH[i] =  FREE ;

            //Slot is READ
            READ :// FIXME  if there is enable for the mux buffer exit .add it to the if .
                    // if the C2F out mux choose this entry , and out mux passing C2F_req
                    if (C2F_SelRdRingQ501H == i && (SelRingOutQ501H == C2FRequest ))
                        C2F_NextBufferStateQnnnH[i] =  READ_PRGRS ;

            //Slot is READ PRGRS
            READ_PRGRS :// FIXME  if there is enable from the core , indicates for new command from it.
                    if (( C2F_NextBufferOpcodeQnnnH[i] == RD_RSP) && (C2F_NextBufferAddressQnnnH[i] == C2F_BufferAddressQnnnH[i] ))
                        C2F_NextBufferStateQnnnH[i] =  READ_RDY ;
                    else
                        C2F_NextBufferStateQnnnH[i] = READ_PRGRS ;
            //Slot is READ_RDY
            READ_RDY :// FIXME  if there is enable for the mux buffer exit towared the core
                    if ( C2F_SelRdCoreQ502H == i )
                        C2F_NextBufferStateQnnnH[i] =  FREE ;

            //Slot is WRITE BCAST
            WRITE_BCAST :// FIXME  if there is enable for the mux buffer exit
                    if (C2F_SelRdRingQ501H == i && (SelRingOutQ501H == C2FRequest ))
                        C2F_NextBufferStateQnnnH[i] =  WRITE_BCAST_PRGRS ;

            //Slot is WRITE BCAST PRGRS
            WRITE_BCAST_PRGRS :// FIXME  if there is enable for the mux buffer exit
                    if (( RingInputOpcodeQ501H == WR_BCAST ) &&  ( C2F_BufferAddressQnnnH[i] == RingInputAddressQ501H ))begin
                        C2F_NextBufferStateQnnnH[i] =  FREE ;
                        RingInputValidQ501H = 1'b0;
                    end //if
        endcase
        C2F_NextBufferValidQnnnH[i]    = C2F_SelWrQnnnH[i] ? C2F_ReqValidQ500H    : RingInputValidQ501H ;
    end //for C2F_BUFFER_SIZE
end //always_comb

// ==== C2F Buffer =================
genvar C2F_ENTRY;
generate for ( C2F_ENTRY =0 ; C2F_ENTRY < C2F_ENTRIESNUM ; C2F_ENTRY++) begin : the_c2f_buffer_array
    `LOTR_EN_RST_MSFF( C2F_BufferValidQnnnH   [C2F_ENTRY], C2F_NextBufferValidQnnnH   [C2F_ENTRY], QClk, C2F_EnWrQnnnH[C2F_ENTRY], RstQnnnH)
    `LOTR_EN_MSFF    ( C2F_BufferOpcodeQnnnH  [C2F_ENTRY], C2F_NextBufferOpcodeQnnnH  [C2F_ENTRY], QClk, C2F_EnWrQnnnH[C2F_ENTRY])
    `LOTR_EN_MSFF    ( C2F_BufferThreadIDQnnnH[C2F_ENTRY], C2F_NextBufferThreadIDQnnnH[C2F_ENTRY], QClk, C2F_EnWrQnnnH[C2F_ENTRY])
    `LOTR_EN_MSFF    ( C2F_BufferAddressQnnnH [C2F_ENTRY], C2F_NextBufferAddressQnnnH [C2F_ENTRY], QClk, C2F_EnWrQnnnH[C2F_ENTRY])
    `LOTR_EN_MSFF    ( C2F_BufferDataQnnnH    [C2F_ENTRY], C2F_NextBufferDataQnnnH    [C2F_ENTRY], QClk, C2F_EnWrQnnnH[C2F_ENTRY])
    `LOTR_EN_MSFF    ( C2F_BufferStateQnnnH   [C2F_ENTRY], C2F_NextBufferStateQnnnH   [C2F_ENTRY], QClk, C2F_EnWrQnnnH[C2F_ENTRY])
end endgenerate // for , generate


// ==== init C2F MRO ==========
always_comb begin : create_mro_input
    for (int i =0 ; i <C2F_ENTRIESNUM ; i++ ) begin
        C2F_DeallocMroQnnnH[i] = (C2F_NextBufferStateQnnnH[i] == FREE);
        C2F_Mask0MroQnnnH[i]   = (C2F_BufferStateQnnnH[i]     == READ_RDY); 
        C2F_Mask1MroQnnnH[i]   = (C2F_BufferStateQnnnH[i]     == READ )      ||
                                 (C2F_BufferStateQnnnH[i]     == WRITE)      ||
                                 (C2F_BufferStateQnnnH[i]     == WRITE_BCAST );
    end //for 
end //always_comb create_mro_input

mro #(.MRO_MSB(C2F_MSB) )
mro_C2F (
     .Clk(QClk),
     .Rst(RstQnnnH),
     .EnAlloc(|(C2F_EnCoreWrQ500H)),
     .NextAlloc(C2F_EnCoreWrQ500H),
     .Dealloc(C2F_DeallocMroQnnnH),
     .Mask0(C2F_Mask0MroQnnnH), // mask 0 for read response
     .Mask1(C2F_Mask1MroQnnnH), // mask 1 for all other commands  
     .Oldest0(C2F_DecodedSelRdCoreQ502H),
     .Oldest1(C2F_DecodedSelRdRingQ501H)
      ) ; 
`ONE_HOT_TO_ENC(C2F_SelRdCoreQ502H , C2F_DecodedSelRdCoreQ502H)
`ONE_HOT_TO_ENC(C2F_SelRdRingQ501H , C2F_DecodedSelRdRingQ501H)

always_comb begin : select_C2F_from_buffer
    // C2F_buferr -> Ring (Requist)
    C2F_ReqValidQ501H   = C2F_BufferValidQnnnH  [C2F_SelRdRingQ501H];
    C2F_ReqOpcodeQ501H  = C2F_BufferOpcodeQnnnH [C2F_SelRdRingQ501H];
    C2F_ReqAddressQ501H = C2F_BufferAddressQnnnH[C2F_SelRdRingQ501H]; // NOTE: The 501 Cycle is due to the origin of the Request (CoreReqQ500H)
    C2F_ReqDataQ501H    = C2F_BufferDataQnnnH   [C2F_SelRdRingQ501H];
    // C2F_buffer -> Core (Response)
    // C2F_RspAddressQ502H = C2F_BufferAddressQnnnH[C2F_SelRdCoreQ502H]; // Note: The 502 Cycle is due to the origin of the Response (RingInputQ500H->RingInputQ501H)
    C2F_RspDataQ502H    = C2F_BufferDataQnnnH    [C2F_SelRdCoreQ502H]      ;
    C2F_RspThreadIDQ502H= C2F_BufferThreadIDQnnnH[C2F_SelRdCoreQ502H];
end //always_comb
    // C2F_buferr -> Ring (Requist)
    
// ==== stall signal logic ==========
always_comb begin : raise_stall_signal
    C2F_RspStall = !(|( C2F_BufferStateQnnnH[C2F_MSB:0] == FREE ));
end //always_comb


//==================================================================================
//              The F2C Buffer - Fabric 2 Core
//==================================================================================
//  TODO - add discription of this block
//
//==================================================================================
always_comb begin : find_free_candidate_F2C
    for (int i=0 ; i< F2C_ENTRIESNUM ; i++) begin 
            F2C_FreeEntriesQ500H[i] = F2C_BufferStateQnnnH[i] == FREE ;  
    end // for
end // always_comb

`FIND_FIRST(F2C_FirstFreeEntryQ500H ,F2C_FreeEntriesQ500H)

always_comb begin : find_read_response_match_F2C
    for (int i=0 ; i < F2C_ENTRIESNUM ; i++ ) begin
            F2C_ReadResponseMatchesQ500H[i] = ((F2C_RspAddressQ500H == F2C_BufferAddressQnnnH[i]) && (F2C_BufferStateQnnnH[i] == READ_PRGRS)) ;  
    end
end
// in case read respones matches to entrey, we want one enntry to alloc
`FIND_FIRST(F2C_FirstReadResponseMatcesQ500H ,F2C_ReadResponseMatchesQ500H)

always_comb begin : check_if_request_from_the_ring_to_the_RC
    F2C_IsValidReqQ500H =((RingInputValidQ501H)                  && 
                          (RingInputOpcodeQ501H != RD_RSP)       &&
                          (RingInputAddressQ501H[31:24] == CoreID || RingInputOpcodeQ501H == WR_BCAST)) ;     
end

assign F2C_EnCoreWrQ500H = F2C_FirstReadResponseMatcesQ500H    ;
assign F2C_EnRingWrQ501H = F2C_FirstFreeEntryQ500H & F2C_IsValidReqQ500H  ; 


// ===== F2C Buffer Input =========
always_comb begin : next_f2c_buffer_per_buffer_entry
    F2C_EnWrQnnnH   = F2C_EnCoreWrQ500H | F2C_EnRingWrQ501H;
    F2C_SelWrQnnnH  = F2C_EnCoreWrQ500H;
    F2C_NextBufferStateQnnnH = F2C_BufferStateQnnnH ; // default value for state machine .
    for(int i =0; i < F2C_ENTRIESNUM; i++) begin
        F2C_NextBufferValidQnnnH[i]   = F2C_SelWrQnnnH[i] ? F2C_RspValidQ500H   : RingInputValidQ501H   ;
        F2C_NextBufferOpcodeQnnnH[i]  = F2C_SelWrQnnnH[i] ? F2C_RspOpcodeQ500H  : RingInputOpcodeQ501H  ;
        F2C_NextBufferAddressQnnnH[i] = F2C_SelWrQnnnH[i] ? F2C_RspAddressQ500H : RingInputAddressQ501H ;
        F2C_NextBufferDataQnnnH[i]    = F2C_SelWrQnnnH[i] ? F2C_RspDataQ500H    : RingInputDataQ501H    ;
        F2C_AddressMatchQ500H         = (F2C_NextBufferAddressQnnnH[i] == F2C_BufferAddressQnnnH[i])    ; 
        case(F2C_BufferStateQnnnH[i])
        //Slot is FREE
            FREE :// given Opcode is Read
                    
                F2C_NextBufferStateQnnnH[i] = (F2C_NextBufferOpcodeQnnnH[i] == RD)       ? READ  : 
                                              (F2C_NextBufferOpcodeQnnnH[i] == WR )      ? WRITE :
                                              (F2C_NextBufferOpcodeQnnnH[i] == WR_BCAST) ? WRITE :
                                                                                           FREE  ;
            
        //Slot is WRITE
            WRITE : // FIXME  if there is enable for the mux buffer exit .add it to the if .
                if (F2C_SelRdCoreQ502H == i  )
                    F2C_NextBufferStateQnnnH[i] =  FREE ;
        //Slot is READ
            READ :// FIXME  if there is enable for the mux buffer exit .add it to the if .
                // if the C2F out mux choose this entry , and out mux passing C2F_req
                if (F2C_SelRdCoreQ502H == i )
                    F2C_NextBufferStateQnnnH[i] =  READ_PRGRS ;

        //Slot is READ PRGRS
            READ_PRGRS :// FIXME  if there is enable from the core , indicates for new command from it.            
                if ( F2C_NextBufferOpcodeQnnnH[i] == RD_RSP && F2C_AddressMatchQ500H )
                    F2C_NextBufferStateQnnnH[i] =  READ_RDY ;

        //Slot is READ_RDY
            READ_RDY :// FIXME  if there is enable for the mux buffer exit towared the core
                if ( F2C_SelRdRingQ501H == i && SelRingOutQ501H == F2CResponse )
                    F2C_NextBufferStateQnnnH[i] =  FREE ;
        endcase
    end //for F2C_BUFFER_SIZE
end //always_comb

// ==== F2C Buffer =================
genvar F2C_ENTRY;
generate for ( F2C_ENTRY =0 ; F2C_ENTRY < F2C_ENTRIESNUM ; F2C_ENTRY++) begin : the_f2c_buffer_array
    `LOTR_EN_RST_MSFF( F2C_BufferValidQnnnH  [F2C_ENTRY], F2C_NextBufferValidQnnnH  [F2C_ENTRY], QClk, F2C_EnWrQnnnH[F2C_ENTRY], RstQnnnH)
    `LOTR_EN_MSFF    ( F2C_BufferOpcodeQnnnH [F2C_ENTRY], F2C_NextBufferOpcodeQnnnH [F2C_ENTRY], QClk, F2C_EnWrQnnnH[F2C_ENTRY])
    `LOTR_EN_MSFF    ( F2C_BufferStateQnnnH  [F2C_ENTRY], F2C_NextBufferStateQnnnH  [F2C_ENTRY], QClk, F2C_EnWrQnnnH[F2C_ENTRY])
    `LOTR_EN_MSFF    ( F2C_BufferAddressQnnnH[F2C_ENTRY], F2C_NextBufferAddressQnnnH[F2C_ENTRY], QClk, F2C_EnWrQnnnH[F2C_ENTRY])
    `LOTR_EN_MSFF    ( F2C_BufferDataQnnnH   [F2C_ENTRY], F2C_NextBufferDataQnnnH   [F2C_ENTRY], QClk, F2C_EnWrQnnnH[F2C_ENTRY])
end endgenerate // for , generate



// ==== init F2C MRO ==========

always_comb begin : create_mro_input_f2c
    for (int i =0 ; i <F2C_ENTRIESNUM ; i++ ) begin
        F2C_DeallocMroQnnnH[i] = (F2C_NextBufferStateQnnnH[i] == FREE);
        F2C_Mask0MroQnnnH[i]   = (F2C_BufferStateQnnnH[i]     == READ_RDY); 
        F2C_Mask1MroQnnnH[i]   = (F2C_BufferStateQnnnH[i]     == READ)      ||
                                 (C2F_BufferStateQnnnH[i]     == WRITE)     ||
                                 (C2F_BufferStateQnnnH[i]     == WRITE_BCAST);
    end //for 
end //always_comb create_mro_input_f2c
mro 
#( 
   .MRO_MSB(F2C_MSB) )
mro_F2C
(
     .Clk(QClk),
     .Rst(RstQnnnH),
     .EnAlloc((|F2C_EnRingWrQ501H)), //Review this
     .NextAlloc(F2C_EnRingWrQ501H),
     .Dealloc(F2C_DeallocMroQnnnH),
     .Mask0(F2C_Mask0MroQnnnH), // mask 0 for read response
     .Mask1(F2C_Mask1MroQnnnH), // mask 1 for all other commands  
     .Oldest0(F2C_DecodedSelRdRingQ501H),
     .Oldest1(F2C_DecodedSelRdCoreQ502H)
      ) ; 

`ONE_HOT_TO_ENC(F2C_SelRdRingQ501H , F2C_DecodedSelRdRingQ501H )
`ONE_HOT_TO_ENC(F2C_SelRdCoreQ502H , F2C_DecodedSelRdCoreQ502H )

always_comb begin : select_f2c_from_buffer
    // F2C_buferr -> Ring (Response)
    F2C_RspValidQ501H   = F2C_BufferValidQnnnH  [F2C_SelRdRingQ501H] ; 
    F2C_RspOpcodeQ501H  = F2C_BufferOpcodeQnnnH [F2C_SelRdRingQ501H] ; 
    F2C_RspAddressQ501H = F2C_BufferAddressQnnnH[F2C_SelRdRingQ501H] ; // NOTE: The 501 Cycle is due to the origin of the Request (CoreReqQ500H)
    F2C_RspDataQ501H    = F2C_BufferDataQnnnH   [F2C_SelRdRingQ501H] ;

    // F2C_buffer -> Core (Request)
    F2C_ReqValidQ502H  =  F2C_BufferValidQnnnH  [F2C_SelRdCoreQ502H];
    F2C_ReqOpcodeQ502H =  F2C_BufferOpcodeQnnnH [F2C_SelRdCoreQ502H];
    F2C_ReqAddressQ502H = F2C_BufferAddressQnnnH[F2C_SelRdCoreQ502H]; // Note: The 502 Cycle is due to the origin of the Response (RingInputQ500H->RingInputQ501H)
    F2C_ReqDataQ502H    = F2C_BufferDataQnnnH   [F2C_SelRdCoreQ502H];
    
end //always_comb


//==================================================================================
//                  Ring output Interface
//==================================================================================
//  TODO - add more detailed discription of this block
//  Select the Ring Output.
//  C2F_Req / F2C_Rsp / RingInput
//==================================================================================

always_comb begin : ventilation_counter_asserting
    NextVentilationCounterQnnnH = VentilationCounterQnnnH + 2'b01 ; 
    EnVentilationQnnnH  = (SelRingOutQ501H == C2FRequest ) ; 
    RstVentilationQnnnH =( (SelRingOutQ501H == NOP )                              || 
                          ((SelRingOutQ501H == RingInput) && (!RingInputValidQ501H))) ;
end //always_comb

`LOTR_EN_RST_MSFF(VentilationCounterQnnnH , NextVentilationCounterQnnnH , QClk, EnVentilationQnnnH, (RstVentilationQnnnH || RstQnnnH))




//FIXME - this logic should be re-writtin in a more readable way.
always_comb begin : set_the_select_next_ring_output_logic
    if (VentilationCounterQnnnH ==  2'b11 ) begin
        SelRingOutQ501H = NOP ;  
    //    VentilationCounterQnnnH = 2'b00 ; 
    end
    else if (((F2C_IsValidReqQ500H  == '0) || ((F2C_IsValidReqQ500H  == '1 )&& (F2C_FirstFreeEntryQ500H == '0)) ) && (C2F_FirstReadResponseMatchesQ501H == '0))
        SelRingOutQ501H = RingInput ;  
    else if (F2C_RspValidQ501H == 1'b1)
        SelRingOutQ501H = F2CResponse ; 
    else if (C2F_ReqValidQ501H== 1'b1)
        SelRingOutQ501H = C2FRequest ; 
    else begin 
        SelRingOutQ501H = NOP ; 
    //    VentilationCounterQnnnH= 2'b00 ; 
    end
end //always_comb



always_comb begin : select_next_ring_output
    //mux 4:1
    unique casez (SelRingOutQ501H)
        NOP   : begin // Insert Invalid Cycle
            RingOutputValidQ501H    = 1'b0; // FIXME - think and change the code to consider the valid bit 
            RingOutputOpcodeQ501H   = RD; //RD == 2'b0
            RingOutputAddressQ501H  = 32'b0;
            RingOutputDataQ501H     = 32'b0;
        end
        RingInput   : begin // Foword the Ring Input
            RingOutputValidQ501H    = RingInputValidQ501H  ;
            RingOutputOpcodeQ501H   = RingInputOpcodeQ501H ;
            RingOutputAddressQ501H  = RingInputAddressQ501H;
            RingOutputDataQ501H     = RingInputDataQ501H   ;
        end
        F2CResponse   : begin // Send the F2C Rsp
            RingOutputValidQ501H    = F2C_RspValidQ501H    ;
            RingOutputOpcodeQ501H   = F2C_RspOpcodeQ501H   ;
            RingOutputAddressQ501H  = F2C_RspAddressQ501H  ;
            RingOutputDataQ501H     = F2C_RspDataQ501H     ;
        end
        C2FRequest   : begin // Send the C2F Req
            RingOutputValidQ501H    = C2F_ReqValidQ501H    ;
            RingOutputOpcodeQ501H   = C2F_ReqOpcodeQ501H   ;
            RingOutputAddressQ501H  = C2F_ReqAddressQ501H  ;
            RingOutputDataQ501H     = C2F_ReqDataQ501H     ;
        end
    endcase
end

//The Sample before Ring Output
`LOTR_MSFF( RingOutputValidQ502H   , RingOutputValidQ501H  , QClk )
`LOTR_MSFF( RingOutputOpcodeQ502H  , RingOutputOpcodeQ501H , QClk )
`LOTR_MSFF( RingOutputAddressQ502H , RingOutputAddressQ501H, QClk )
`LOTR_MSFF( RingOutputDataQ502H    , RingOutputDataQ501H   , QClk )

endmodule // module rc

