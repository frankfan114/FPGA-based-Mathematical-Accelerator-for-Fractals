// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtest_streamer.h for the primary calling header

#include "verilated.h"

#include "Vtest_streamer___024root.h"

VL_INLINE_OPT void Vtest_streamer___024root___sequent__TOP__0(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___sequent__TOP__0\n"); );
    // Init
    SData/*9:0*/ __Vdly__test_streamer__DOT__x;
    // Body
    __Vdly__test_streamer__DOT__x = vlSelf->test_streamer__DOT__x;
    if (vlSelf->aresetn) {
        vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g 
            = vlSelf->test_streamer__DOT__g;
        if (vlSelf->test_streamer__DOT__first) {
            vlSelf->test_streamer__DOT__pixel_packer__DOT__sof_reg = 1U;
        } else if (vlSelf->out_stream_tready) {
            vlSelf->test_streamer__DOT__pixel_packer__DOT__sof_reg = 0U;
        }
        vlSelf->test_streamer__DOT__pixel_packer__DOT__last_b 
            = (0xffU & (IData)(vlSelf->test_streamer__DOT__y));
        vlSelf->test_streamer__DOT__pixel_packer__DOT__last_r 
            = (0xffU & (IData)(vlSelf->test_streamer__DOT__x));
        if (((0U == (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state)) 
             | (IData)(vlSelf->out_stream_tready))) {
            vlSelf->test_streamer__DOT__pixel_packer__DOT__state_reg 
                = ((0x27fU == (IData)(vlSelf->test_streamer__DOT__x))
                    ? 0U : (3U & ((IData)(1U) + (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))));
        }
        if (vlSelf->test_streamer__DOT__ready) {
            __Vdly__test_streamer__DOT__x = ((IData)(vlSelf->test_streamer__DOT__lastx)
                                              ? 0U : 
                                             (0x3ffU 
                                              & ((IData)(1U) 
                                                 + (IData)(vlSelf->test_streamer__DOT__x))));
            if ((0x27fU == (IData)(vlSelf->test_streamer__DOT__x))) {
                vlSelf->test_streamer__DOT__y = ((IData)(vlSelf->test_streamer__DOT__lasty)
                                                  ? 0U
                                                  : 
                                                 (0x1ffU 
                                                  & ((IData)(1U) 
                                                     + (IData)(vlSelf->test_streamer__DOT__y))));
            }
        }
    } else {
        vlSelf->test_streamer__DOT__pixel_packer__DOT__sof_reg = 0U;
        vlSelf->test_streamer__DOT__pixel_packer__DOT__state_reg = 0U;
        __Vdly__test_streamer__DOT__x = 0U;
        vlSelf->test_streamer__DOT__y = 0U;
    }
    vlSelf->test_streamer__DOT__x = __Vdly__test_streamer__DOT__x;
    vlSelf->out_stream_tuser = vlSelf->test_streamer__DOT__pixel_packer__DOT__sof_reg;
    vlSelf->test_streamer__DOT__lasty = (0x1dfU == (IData)(vlSelf->test_streamer__DOT__y));
    vlSelf->test_streamer__DOT__lastx = (0x27fU == (IData)(vlSelf->test_streamer__DOT__x));
    vlSelf->out_stream_tlast = (0x27fU == (IData)(vlSelf->test_streamer__DOT__x));
    vlSelf->test_streamer__DOT__g = (0xffU & ((0x7fU 
                                               & (IData)(vlSelf->test_streamer__DOT__x)) 
                                              + (0x7fU 
                                                 & (IData)(vlSelf->test_streamer__DOT__y))));
    vlSelf->test_streamer__DOT__first = ((0U == (IData)(vlSelf->test_streamer__DOT__x)) 
                                         & (0U == (IData)(vlSelf->test_streamer__DOT__y)));
    vlSelf->test_streamer__DOT__pixel_packer__DOT__state 
        = ((IData)(vlSelf->test_streamer__DOT__first)
            ? 0U : (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state_reg));
    vlSelf->out_stream_tdata = ((2U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
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
                                              | (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__last_g))))));
    vlSelf->test_streamer__DOT__pixel_packer__DOT__tvalid 
        = (IData)((0U != (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state)));
    vlSelf->out_stream_tvalid = vlSelf->test_streamer__DOT__pixel_packer__DOT__tvalid;
}

VL_INLINE_OPT void Vtest_streamer___024root___combo__TOP__0(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___combo__TOP__0\n"); );
    // Body
    vlSelf->test_streamer__DOT__pixel_packer__DOT__ready 
        = (1U & ((2U & (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state))
                  ? (IData)(vlSelf->out_stream_tready)
                  : ((~ (IData)(vlSelf->test_streamer__DOT__pixel_packer__DOT__state)) 
                     | (IData)(vlSelf->out_stream_tready))));
    vlSelf->test_streamer__DOT__ready = vlSelf->test_streamer__DOT__pixel_packer__DOT__ready;
}

void Vtest_streamer___024root___eval(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___eval\n"); );
    // Body
    if (((IData)(vlSelf->aclk) & (~ (IData)(vlSelf->__Vclklast__TOP__aclk)))) {
        Vtest_streamer___024root___sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
    }
    Vtest_streamer___024root___combo__TOP__0(vlSelf);
    // Final
    vlSelf->__Vclklast__TOP__aclk = vlSelf->aclk;
}

#ifdef VL_DEBUG
void Vtest_streamer___024root___eval_debug_assertions(Vtest_streamer___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtest_streamer___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->aclk & 0xfeU))) {
        Verilated::overWidthError("aclk");}
    if (VL_UNLIKELY((vlSelf->aresetn & 0xfeU))) {
        Verilated::overWidthError("aresetn");}
    if (VL_UNLIKELY((vlSelf->out_stream_tready & 0xfeU))) {
        Verilated::overWidthError("out_stream_tready");}
}
#endif  // VL_DEBUG
