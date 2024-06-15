// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtest_streamer__Syms.h"


void Vtest_streamer___024root__trace_chg_sub_0(Vtest_streamer___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtest_streamer___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root__trace_chg_top_0\n"); );
    // Init
    Vtest_streamer___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtest_streamer___024root*>(voidSelf);
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtest_streamer___024root__trace_chg_sub_0((&vlSymsp->TOP), bufp);
}

void Vtest_streamer___024root__trace_chg_sub_0(Vtest_streamer___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root__trace_chg_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[1U])) {
        bufp->chgSData(oldp+0,(vlSelf->test_streamer__DOT__x),10);
        bufp->chgSData(oldp+1,(vlSelf->test_streamer__DOT__y),9);
        bufp->chgBit(oldp+2,(vlSelf->test_streamer__DOT__first));
        bufp->chgBit(oldp+3,((0x27fU == (IData)(vlSelf->test_streamer__DOT__x))));
        bufp->chgBit(oldp+4,((0x1dfU == (IData)(vlSelf->test_streamer__DOT__y))));
        bufp->chgCData(oldp+5,((0xffU & (IData)(vlSelf->test_streamer__DOT__x))),8);
        bufp->chgCData(oldp+6,(vlSelf->test_streamer__DOT__g),8);
        bufp->chgCData(oldp+7,((0xffU & (IData)(vlSelf->test_streamer__DOT__y))),8);
        bufp->chgCData(oldp+8,(vlSelf->test_streamer__DOT__pixel_packer__DOT__state_reg),2);
        bufp->chgCData(oldp+9,(vlSelf->test_streamer__DOT__pixel_packer__DOT__state),2);
        bufp->chgBit(oldp+10,((0U == (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))));
        bufp->chgBit(oldp+11,(vlSelf->test_streamer__DOT__pixel_packer__DOT__sof_reg));
        bufp->chgCData(oldp+12,(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r),8);
        bufp->chgCData(oldp+13,(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g),8);
        bufp->chgCData(oldp+14,(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_b),8);
        bufp->chgIData(oldp+15,(((2U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
                                  ? ((1U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
                                      ? (((IData)(vlSelf->test_streamer__DOT__x) 
                                          << 0x18U) 
                                         | (((IData)(vlSelf->test_streamer__DOT__g) 
                                             << 0x10U) 
                                            | ((0xff00U 
                                                & ((IData)(vlSelf->test_streamer__DOT__y) 
                                                   << 8U)) 
                                               | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r))))
                                      : (((IData)(vlSelf->test_streamer__DOT__g) 
                                          << 0x18U) 
                                         | ((0xff0000U 
                                             & ((IData)(vlSelf->test_streamer__DOT__y) 
                                                << 0x10U)) 
                                            | (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r) 
                                                << 8U) 
                                               | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g)))))
                                  : ((1U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
                                      ? (((IData)(vlSelf->test_streamer__DOT__y) 
                                          << 0x18U) 
                                         | (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r) 
                                             << 0x10U) 
                                            | (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g) 
                                                << 8U) 
                                               | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_b))))
                                      : (((IData)(vlSelf->test_streamer__DOT__g) 
                                          << 0x18U) 
                                         | (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r) 
                                             << 0x10U) 
                                            | (((IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_b) 
                                                << 8U) 
                                               | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g))))))),32);
        bufp->chgBit(oldp+16,(vlSelf->test_streamer__DOT__pixel_packer__DOT__tvalid));
    }
    bufp->chgBit(oldp+17,(vlSelf->aclk));
    bufp->chgBit(oldp+18,(vlSelf->aresetn));
    bufp->chgIData(oldp+19,(vlSelf->out_stream_tdata),32);
    bufp->chgCData(oldp+20,(vlSelf->out_stream_tkeep),4);
    bufp->chgBit(oldp+21,(vlSelf->out_stream_tlast));
    bufp->chgBit(oldp+22,(vlSelf->out_stream_tready));
    bufp->chgBit(oldp+23,(vlSelf->out_stream_tvalid));
    bufp->chgBit(oldp+24,(vlSelf->out_stream_tuser));
    bufp->chgBit(oldp+25,(vlSelf->test_streamer__DOT__ready));
    bufp->chgBit(oldp+26,(vlSelf->test_streamer__DOT__pixel_packer__DOT__ready));
}

void Vtest_streamer___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root__trace_cleanup\n"); );
    // Init
    Vtest_streamer___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtest_streamer___024root*>(voidSelf);
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
}
