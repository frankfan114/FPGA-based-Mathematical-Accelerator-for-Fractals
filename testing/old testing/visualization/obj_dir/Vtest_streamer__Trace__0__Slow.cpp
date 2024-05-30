// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtest_streamer__Syms.h"


VL_ATTR_COLD void Vtest_streamer___024root__trace_init_sub__TOP__0(Vtest_streamer___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+18,"aclk", false,-1);
    tracep->declBit(c+19,"aresetn", false,-1);
    tracep->declBus(c+20,"out_stream_tdata", false,-1, 31,0);
    tracep->declBus(c+21,"out_stream_tkeep", false,-1, 3,0);
    tracep->declBit(c+22,"out_stream_tlast", false,-1);
    tracep->declBit(c+23,"out_stream_tready", false,-1);
    tracep->declBit(c+24,"out_stream_tvalid", false,-1);
    tracep->declBus(c+25,"out_stream_tuser", false,-1, 0,0);
    tracep->pushNamePrefix("test_streamer ");
    tracep->declBit(c+18,"aclk", false,-1);
    tracep->declBit(c+19,"aresetn", false,-1);
    tracep->declBus(c+20,"out_stream_tdata", false,-1, 31,0);
    tracep->declBus(c+21,"out_stream_tkeep", false,-1, 3,0);
    tracep->declBit(c+22,"out_stream_tlast", false,-1);
    tracep->declBit(c+23,"out_stream_tready", false,-1);
    tracep->declBit(c+24,"out_stream_tvalid", false,-1);
    tracep->declBus(c+25,"out_stream_tuser", false,-1, 0,0);
    tracep->declBus(c+28,"X_SIZE", false,-1, 31,0);
    tracep->declBus(c+29,"Y_SIZE", false,-1, 31,0);
    tracep->declBus(c+1,"x", false,-1, 9,0);
    tracep->declBus(c+2,"y", false,-1, 8,0);
    tracep->declBit(c+26,"ready", false,-1);
    tracep->declBit(c+3,"first", false,-1);
    tracep->declBit(c+4,"lastx", false,-1);
    tracep->declBit(c+5,"lasty", false,-1);
    tracep->declBit(c+30,"valid_int", false,-1);
    tracep->declBus(c+6,"r", false,-1, 7,0);
    tracep->declBus(c+7,"g", false,-1, 7,0);
    tracep->declBus(c+8,"b", false,-1, 7,0);
    tracep->pushNamePrefix("pixel_packer ");
    tracep->declBit(c+18,"aclk", false,-1);
    tracep->declBit(c+19,"aresetn", false,-1);
    tracep->declBus(c+6,"r", false,-1, 7,0);
    tracep->declBus(c+7,"g", false,-1, 7,0);
    tracep->declBus(c+8,"b", false,-1, 7,0);
    tracep->declBit(c+4,"eol", false,-1);
    tracep->declBit(c+26,"in_stream_ready", false,-1);
    tracep->declBit(c+30,"valid", false,-1);
    tracep->declBit(c+3,"sof", false,-1);
    tracep->declBus(c+20,"out_stream_tdata", false,-1, 31,0);
    tracep->declBus(c+21,"out_stream_tkeep", false,-1, 3,0);
    tracep->declBit(c+22,"out_stream_tlast", false,-1);
    tracep->declBit(c+23,"out_stream_tready", false,-1);
    tracep->declBit(c+24,"out_stream_tvalid", false,-1);
    tracep->declBus(c+25,"out_stream_tuser", false,-1, 0,0);
    tracep->declBus(c+9,"state_reg", false,-1, 1,0);
    tracep->declBus(c+10,"state", false,-1, 1,0);
    tracep->declBit(c+11,"state0", false,-1);
    tracep->declBit(c+12,"sof_reg", false,-1);
    tracep->declBus(c+13,"last_r", false,-1, 7,0);
    tracep->declBus(c+14,"last_g", false,-1, 7,0);
    tracep->declBus(c+15,"last_b", false,-1, 7,0);
    tracep->declBus(c+16,"tdata", false,-1, 31,0);
    tracep->declBit(c+17,"tvalid", false,-1);
    tracep->declBit(c+27,"ready", false,-1);
    tracep->popNamePrefix(2);
}

VL_ATTR_COLD void Vtest_streamer___024root__trace_init_top(Vtest_streamer___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root__trace_init_top\n"); );
    // Body
    Vtest_streamer___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vtest_streamer___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtest_streamer___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtest_streamer___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vtest_streamer___024root__trace_register(Vtest_streamer___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&Vtest_streamer___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&Vtest_streamer___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&Vtest_streamer___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vtest_streamer___024root__trace_full_sub_0(Vtest_streamer___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vtest_streamer___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root__trace_full_top_0\n"); );
    // Init
    Vtest_streamer___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtest_streamer___024root*>(voidSelf);
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vtest_streamer___024root__trace_full_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtest_streamer___024root__trace_full_sub_0(Vtest_streamer___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root__trace_full_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullSData(oldp+1,(vlSelf->test_streamer__DOT__x),10);
    bufp->fullSData(oldp+2,(vlSelf->test_streamer__DOT__y),9);
    bufp->fullBit(oldp+3,(vlSelf->test_streamer__DOT__first));
    bufp->fullBit(oldp+4,((0x27fU == (IData)(vlSelf->test_streamer__DOT__x))));
    bufp->fullBit(oldp+5,((0x1dfU == (IData)(vlSelf->test_streamer__DOT__y))));
    bufp->fullCData(oldp+6,((0xffU & (IData)(vlSelf->test_streamer__DOT__x))),8);
    bufp->fullCData(oldp+7,(vlSelf->test_streamer__DOT__g),8);
    bufp->fullCData(oldp+8,((0xffU & (IData)(vlSelf->test_streamer__DOT__y))),8);
    bufp->fullCData(oldp+9,(vlSelf->test_streamer__DOT__pixel_packer__DOT__state_reg),2);
    bufp->fullCData(oldp+10,(vlSelf->test_streamer__DOT__pixel_packer__DOT__state),2);
    bufp->fullBit(oldp+11,((0U == (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))));
    bufp->fullBit(oldp+12,(vlSelf->test_streamer__DOT__pixel_packer__DOT__sof_reg));
    bufp->fullCData(oldp+13,(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r),8);
    bufp->fullCData(oldp+14,(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g),8);
    bufp->fullCData(oldp+15,(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_b),8);
    bufp->fullIData(oldp+16,(((2U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
                               ? ((1U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
                                   ? (((IData)(vlSelf->test_streamer__DOT__x) 
                                       << 0x18U) | 
                                      (((IData)(vlSelf->test_streamer__DOT__g) 
                                        << 0x10U) | 
                                       ((0xff00U & 
                                         ((IData)(vlSelf->test_streamer__DOT__y) 
                                          << 8U)) | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r))))
                                   : (((IData)(vlSelf->test_streamer__DOT__g) 
                                       << 0x18U) | 
                                      ((0xff0000U & 
                                        ((IData)(vlSelf->test_streamer__DOT__y) 
                                         << 0x10U)) 
                                       | (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r) 
                                           << 8U) | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g)))))
                               : ((1U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
                                   ? (((IData)(vlSelf->test_streamer__DOT__y) 
                                       << 0x18U) | 
                                      (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r) 
                                        << 0x10U) | 
                                       (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g) 
                                         << 8U) | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_b))))
                                   : (((IData)(vlSelf->test_streamer__DOT__g) 
                                       << 0x18U) | 
                                      (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r) 
                                        << 0x10U) | 
                                       (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_b) 
                                         << 8U) | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g))))))),32);
    bufp->fullBit(oldp+17,(vlSelf->test_streamer__DOT__pixel_packer__DOT__tvalid));
    bufp->fullBit(oldp+18,(vlSelf->aclk));
    bufp->fullBit(oldp+19,(vlSelf->aresetn));
    bufp->fullIData(oldp+20,(vlSelf->out_stream_tdata),32);
    bufp->fullCData(oldp+21,(vlSelf->out_stream_tkeep),4);
    bufp->fullBit(oldp+22,(vlSelf->out_stream_tlast));
    bufp->fullBit(oldp+23,(vlSelf->out_stream_tready));
    bufp->fullBit(oldp+24,(vlSelf->out_stream_tvalid));
    bufp->fullBit(oldp+25,(vlSelf->out_stream_tuser));
    bufp->fullBit(oldp+26,(vlSelf->test_streamer__DOT__ready));
    bufp->fullBit(oldp+27,(vlSelf->test_streamer__DOT__pixel_packer__DOT__ready));
    bufp->fullIData(oldp+28,(0x280U),32);
    bufp->fullIData(oldp+29,(0x1e0U),32);
    bufp->fullBit(oldp+30,(1U));
}
