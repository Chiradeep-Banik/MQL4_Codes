//+------------------------------------------------------------------+
//|                                                      rainbow.mq4 |
//|                                                            abhra |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "abhra"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 7

double ma1[],ma2[],ma3[],ma4[],ma5[],ma6[],ma7[];


#property indicator_label1  "ma1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//
#property indicator_label2  "ma2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrIndigo
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//
#property indicator_label3  "ma3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//
#property indicator_label4  "ma4"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//
#property indicator_label5  "ma5"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrYellow
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//
#property indicator_label6  "ma6"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrOrange
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1


#property indicator_label7  "ma7"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ma1);
   SetIndexBuffer(1,ma2);
   SetIndexBuffer(2,ma3);
   SetIndexBuffer(3,ma4);
   SetIndexBuffer(4,ma5);
   SetIndexBuffer(5,ma6);
   SetIndexBuffer(6,ma7);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int i;
      
      for (i=0;i<rates_total-3;i++)

 {
 ma1[i]=(high[i]+high[i+1]+high[i+2])/3;
 }

      for (i=0;i<rates_total-6;i++)
 {
 ma2[i]=(high[i]+high[i+1]+high[i+2]+high[i+3]+high[i+4]+high[i+5])/6;
 }


      for (i=0;i<rates_total-9;i++)
 
 {
 ma3[i]=(high[i]+high[i+1]+high[i+2]+high[i+3]+high[i+4]+high[i+5]+high[i+6]+high[i+7]+high[i+8])/9;
 }
 
 
       for (i=0;i<rates_total-12;i++)

 {
 ma4[i]=(high[i]+high[i+1]+high[i+2]+high[i+3]+high[i+4]+high[i+5]+high[i+6]+high[i+7]+high[i+8]+high[i+9]+high[i+10]+high[i+11])/12;
 }
 
 
       for (i=0;i<rates_total-15;i++)

 {
 ma5[i]=(high[i]+high[i+1]+high[i+2]+high[i+3]+high[i+4]+high[i+5]+high[i+6]+high[i+7]+high[i+8]+high[i+9]+high[i+10]+high[i+11]+high[i+12]+high[i+13]+high[i+14])/15;
 }
 
       for (i=0;i<rates_total-18;i++)

 {
 ma6[i]=(high[i]+high[i+1]+high[i+2]+high[i+3]+high[i+4]+high[i+5]+high[i+6]+high[i+7]+high[i+8]+high[i+9]+high[i+10]+high[i+11]+high[i+12]+high[i+13]+high[i+14]+high[i+15]+high[i+16]+high[i+17])/18;
 }
 
       for (i=0;i<rates_total-21;i++)
 {
 ma7[i]=((18*ma6[i])+high[i+18]+high[i+19]+high[i+20])/21;
 
 }
 
 
//--- return valueprev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
