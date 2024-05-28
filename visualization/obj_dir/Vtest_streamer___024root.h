// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtest_streamer.h for the primary calling header

#ifndef VERILATED_VTEST_STREAMER___024ROOT_H_
#define VERILATED_VTEST_STREAMER___024ROOT_H_  // guard

#include "verilated.h"

class Vtest_streamer__Syms;

class Vtest_streamer___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(aclk,0,0);
    VL_IN8(aresetn,0,0);
    VL_OUT8(out_stream_tkeep,3,0);
    VL_OUT8(out_stream_tlast,0,0);
    VL_IN8(out_stream_tready,0,0);
    VL_OUT8(out_stream_tvalid,0,0);
    VL_OUT8(out_stream_tuser,0,0);
    CData/*0:0*/ test_streamer__DOT__ready;
    CData/*0:0*/ test_streamer__DOT__first;
    CData/*0:0*/ test_streamer__DOT__lastx;
    CData/*0:0*/ test_streamer__DOT__lasty;
    CData/*7:0*/ test_streamer__DOT__g;
    CData/*1:0*/ test_streamer__DOT__pixel_packer__DOT__state_reg;
    CData/*1:0*/ test_streamer__DOT__pixel_packer__DOT__state;
    CData/*0:0*/ test_streamer__DOT__pixel_packer__DOT__sof_reg;
    CData/*7:0*/ test_streamer__DOT__pixel_packer__DOT__last_r;
    CData/*7:0*/ test_streamer__DOT__pixel_packer__DOT__last_g;
    CData/*7:0*/ test_streamer__DOT__pixel_packer__DOT__last_b;
    CData/*0:0*/ test_streamer__DOT__pixel_packer__DOT__tvalid;
    CData/*0:0*/ test_streamer__DOT__pixel_packer__DOT__ready;
    CData/*0:0*/ __Vclklast__TOP__aclk;
    SData/*9:0*/ test_streamer__DOT__x;
    SData/*8:0*/ test_streamer__DOT__y;
    VL_OUT(out_stream_tdata,31,0);
    VlUnpacked<CData/*0:0*/, 2> __Vm_traceActivity;

    // INTERNAL VARIABLES
    Vtest_streamer__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vtest_streamer___024root(Vtest_streamer__Syms* symsp, const char* name);
    ~Vtest_streamer___024root();
    VL_UNCOPYABLE(Vtest_streamer___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
