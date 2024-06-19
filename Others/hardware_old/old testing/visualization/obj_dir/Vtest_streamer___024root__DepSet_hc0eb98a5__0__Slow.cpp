// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtest_streamer.h for the primary calling header

#include "verilated.h"

#include "Vtest_streamer___024root.h"

VL_ATTR_COLD void Vtest_streamer___024root___initial__TOP__0(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___initial__TOP__0\n"); );
    // Body
    vlSelf->out_stream_tkeep = 0xfU;
    vlSelf->test_streamer__DOT__pixel_packer__DOT__state_reg = 0U;
    vlSelf->test_streamer__DOT__ready = 1U;
}

VL_ATTR_COLD void Vtest_streamer___024root___settle__TOP__0(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___settle__TOP__0\n"); );
    // Body
    vlSelf->test_streamer__DOT__lastx = (0x27fU == (IData)(vlSelf->test_streamer__DOT__x));
    vlSelf->test_streamer__DOT__lasty = (0x1dfU == (IData)(vlSelf->test_streamer__DOT__y));
    vlSelf->out_stream_tlast = (0x27fU == (IData)(vlSelf->test_streamer__DOT__x));
    vlSelf->out_stream_tuser = vlSelf->test_streamer__DOT__pixel_packer__DOT__sof_reg;
    vlSelf->test_streamer__DOT__g = (0xffU & ((0x7fU 
                                               & (IData)(vlSelf->test_streamer__DOT__x)) 
                                              + (0x7fU 
                                                 & (IData)(vlSelf->test_streamer__DOT__y))));
    vlSelf->test_streamer__DOT__first = ((0U == (IData)(vlSelf->test_streamer__DOT__x)) 
                                         & (0U == (IData)(vlSelf->test_streamer__DOT__y)));
    vlSelf->test_streamer__DOT__pixel_packer__DOT__state 
        = ((IData)(vlSelf->test_streamer__DOT__first)
            ? 0U : (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state_reg));
    if ((2U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))) {
        vlSelf->out_stream_tdata = ((1U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
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
                                              | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g)))));
        vlSelf->test_streamer__DOT__pixel_packer__DOT__ready 
            = (1U & (IData)(vlSelf->out_stream_tready));
    } else {
        vlSelf->out_stream_tdata = ((1U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
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
                                              | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g)))));
        vlSelf->test_streamer__DOT__pixel_packer__DOT__ready 
            = (1U & ((~ (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state)) 
                     | (IData)(vlSelf->out_stream_tready)));
    }
    vlSelf->test_streamer__DOT__pixel_packer__DOT__tvalid 
        = (IData)((0U != (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state)));
    vlSelf->out_stream_tvalid = vlSelf->test_streamer__DOT__pixel_packer__DOT__tvalid;
    vlSelf->test_streamer__DOT__ready = vlSelf->test_streamer__DOT__pixel_packer__DOT__ready;
}

VL_ATTR_COLD void Vtest_streamer___024root___eval_initial(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___eval_initial\n"); );
    // Body
    Vtest_streamer___024root___initial__TOP__0(vlSelf);
    vlSelf->__Vm_traceActivity[1U] = 1U;
    vlSelf->__Vm_traceActivity[0U] = 1U;
    vlSelf->__Vclklast__TOP__aclk = vlSelf->aclk;
}

VL_ATTR_COLD void Vtest_streamer___024root___eval_settle(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___eval_settle\n"); );
    // Body
    Vtest_streamer___024root___settle__TOP__0(vlSelf);
    vlSelf->__Vm_traceActivity[1U] = 1U;
    vlSelf->__Vm_traceActivity[0U] = 1U;
}

VL_ATTR_COLD void Vtest_streamer___024root___final(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___final\n"); );
}

VL_ATTR_COLD void Vtest_streamer___024root___ctor_var_reset(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->aclk = VL_RAND_RESET_I(1);
    vlSelf->aresetn = VL_RAND_RESET_I(1);
    vlSelf->out_stream_tdata = VL_RAND_RESET_I(32);
    vlSelf->out_stream_tkeep = VL_RAND_RESET_I(4);
    vlSelf->out_stream_tlast = VL_RAND_RESET_I(1);
    vlSelf->out_stream_tready = VL_RAND_RESET_I(1);
    vlSelf->out_stream_tvalid = VL_RAND_RESET_I(1);
    vlSelf->out_stream_tuser = VL_RAND_RESET_I(1);
    vlSelf->test_streamer__DOT__x = VL_RAND_RESET_I(10);
    vlSelf->test_streamer__DOT__y = VL_RAND_RESET_I(9);
    vlSelf->test_streamer__DOT__ready = VL_RAND_RESET_I(1);
    vlSelf->test_streamer__DOT__first = VL_RAND_RESET_I(1);
    vlSelf->test_streamer__DOT__lastx = VL_RAND_RESET_I(1);
    vlSelf->test_streamer__DOT__lasty = VL_RAND_RESET_I(1);
    vlSelf->test_streamer__DOT__g = VL_RAND_RESET_I(8);
    vlSelf->test_streamer__DOT__pixel_packer__DOT__state_reg = VL_RAND_RESET_I(2);
    vlSelf->test_streamer__DOT__pixel_packer__DOT__state = VL_RAND_RESET_I(2);
    vlSelf->test_streamer__DOT__pixel_packer__DOT__sof_reg = VL_RAND_RESET_I(1);
    vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r = VL_RAND_RESET_I(8);
    vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g = VL_RAND_RESET_I(8);
    vlSelf->test_streamer__DOT__pixel_packer__DOT__last_b = VL_RAND_RESET_I(8);
    vlSelf->test_streamer__DOT__pixel_packer__DOT__tvalid = VL_RAND_RESET_I(1);
    vlSelf->test_streamer__DOT__pixel_packer__DOT__ready = VL_RAND_RESET_I(1);
    for (int __Vi0=0; __Vi0<2; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }
}
