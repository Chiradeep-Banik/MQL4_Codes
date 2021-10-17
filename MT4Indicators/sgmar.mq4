//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 1999-2008, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 5
//----
#property indicator_color1 Lime
#property indicator_color2 Aqua
#property indicator_color3 Red
#property indicator_color4 DarkTurquoise
#property indicator_color5 Red
//----
#property indicator_level1 70
#property indicator_level2 50
#property indicator_level3 30
#property indicator_levelcolor Gray
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DASH
//----
extern int    Rsi  =14;
extern int    Ma  =8;
extern int    cbars  =0;
//----
double RsiBuf[];
double MaP[];
double MaF[];
double Up[];
double Dn[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void init() 
  {
   SetIndexStyle (0, DRAW_LINE,0, 2);
   SetIndexStyle (1, DRAW_LINE,0,2);
   SetIndexStyle (2, DRAW_LINE,0,2);
   SetIndexStyle (3, DRAW_ARROW);
   SetIndexStyle (4, DRAW_ARROW);
   SetIndexBuffer(0, RsiBuf);
   SetIndexBuffer(1, MaP);
   SetIndexBuffer(2, MaF);
   SetIndexBuffer(3, Up);
   SetIndexBuffer(4, Dn);
   SetIndexEmptyValue(3,0);
   SetIndexEmptyValue(4,0);
   SetIndexArrow(3,108);
   SetIndexArrow(4,108);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void deinit() 
  {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int start() 
  {
   int shift,limit=cbars;
   if(limit==0) limit=Bars;
     for(shift=limit-1; shift>=0; shift--) 
     {
      RsiBuf[shift]=iRSI(NULL,0,Rsi,PRICE_CLOSE,shift);
     }
     for(shift=limit-1; shift>=0; shift--) 
     {
      // First Indicator Data
      MaF[shift]=iMAOnArray(RsiBuf,0,Ma,0,MODE_SMA,shift);
      // Previous Indicator Data
      MaP[shift]=iMAOnArray(RsiBuf,0,Ma,0,MODE_EMA,shift);
        if((MaF[shift]-MaP[shift])*(MaF[shift+1]-MaP[shift+1])<0)
        {
         if(MaF[shift]-MaP[shift]<0) Up[shift]=MaP[shift];
         else Dn[shift]=MaF[shift];
        }
     }
  }
//+------------------------------------------------------------------+