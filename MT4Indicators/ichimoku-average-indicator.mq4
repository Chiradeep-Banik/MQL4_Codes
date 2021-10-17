//+------------------------------------------------------------------+
//|                             ICHIMOKU AVERAGE.mq4 |
//                               BY SOHOCOOL 2012  //
/////////////////////////http://sohocool.over-blog.com////////////
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/
//// ICHIMOKU MODIFIED BY SOHOCOOL TO DO ICHIMOKU AVERAGE IN 2012
//+------------------------------------------------------------------+


#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 SandyBrown
#property indicator_color2 Thistle
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Lime
#property indicator_color6 SandyBrown
#property indicator_color7 Thistle

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2

//---- input parameters
extern int MA_Type =1;
extern int Price =0;
extern int MA_Tenkan=8;
extern int MA_Kijun=24;
extern int MA_Senkou=48;
//---- buffers
double Tenkan_Buffer[];
double Kijun_Buffer[];
double SpanA_Buffer[];
double SpanB_Buffer[];
double Chinkou_Buffer[];
double SpanA2_Buffer[];
double SpanB2_Buffer[];
//----
int a_begin;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  // a_begin=MA_Kijun; if(a_begin<MA_Tenkan) a_begin=MA_Tenkan;
//----
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Tenkan_Buffer);
   SetIndexDrawBegin(2,MA_Tenkan-1);
   SetIndexLabel(2,"Tenkan Sen");
//----
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Kijun_Buffer);
   SetIndexDrawBegin(3,MA_Kijun-1);
   SetIndexLabel(3,"Kijun Sen");
//----
   a_begin=MA_Kijun; if(a_begin<MA_Tenkan) a_begin=MA_Tenkan;
   
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexBuffer(0,SpanA_Buffer);
   SetIndexDrawBegin(0,MA_Kijun+a_begin-1);
   SetIndexShift(0,MA_Kijun);
   SetIndexLabel(0,NULL);
   
   SetIndexStyle(5,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(5,SpanA2_Buffer);
   SetIndexDrawBegin(5,MA_Kijun+a_begin-1);
   SetIndexShift(5,MA_Kijun);
   SetIndexLabel(5,"Senkou Span A");
//----
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexBuffer(1,SpanB_Buffer);
   SetIndexDrawBegin(1,MA_Kijun+MA_Senkou-1);
   SetIndexShift(1,MA_Kijun);
   SetIndexLabel(1,NULL);
   
   SetIndexStyle(6,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(6,SpanB2_Buffer);
   SetIndexDrawBegin(6,MA_Kijun+MA_Senkou-1);
   SetIndexShift(6,MA_Kijun);
   SetIndexLabel(6,"Senkou Span B");
//----
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Chinkou_Buffer);
   SetIndexShift(4,-MA_Kijun);
   SetIndexLabel(4,"Chinkou Span");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Ichimoku Kinko Hyo  AVERAGE                                      |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double high,low,price;
//----
   if(Bars<=MA_Tenkan || Bars<=MA_Kijun || Bars<=MA_Senkou) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=MA_Tenkan;i++)    Tenkan_Buffer[Bars-i]=0;
      for(i=1;i<=MA_Kijun;i++)     Kijun_Buffer[Bars-i]=0;
      for(i=1;i<=a_begin;i++) { SpanA_Buffer[Bars-i]=0; SpanA2_Buffer[Bars-i]=0; }
      for(i=1;i<=MA_Senkou;i++)  { SpanB_Buffer[Bars-i]=0; SpanB2_Buffer[Bars-i]=0; }
     }
//---- Tenkan Sen
   i=Bars-MA_Tenkan;
   if(counted_bars>MA_Tenkan) i=Bars-counted_bars-1;
   while(i>=0)
     {
     
      Tenkan_Buffer[i]=iMA(Symbol(), 0, MA_Tenkan, 0, MA_Type, Price, i);
      i--;
     }
//---- Kijun Sen
   i=Bars-MA_Kijun;
   if(counted_bars>MA_Kijun) i=Bars-counted_bars-1;
   while(i>=0)
    {
    
      Kijun_Buffer[i]=iMA(Symbol(), 0, MA_Kijun, 0, MA_Type, Price, i);
      i--;
     }
//---- Senkou Span A
   i=Bars-a_begin+1;
   if(counted_bars>a_begin-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      price=(Kijun_Buffer[i]+Tenkan_Buffer[i])/2;
      SpanA_Buffer[i]=price;
      SpanA2_Buffer[i]=price;
      i--;
     }
//---- Senkou Span B
   i=Bars-MA_Senkou;
   if(counted_bars>MA_Senkou) i=Bars-counted_bars-1;
   while(i>=0)
     {
    
      price=iMA(Symbol(), 0, MA_Senkou, 0, MA_Type, Price, i);
      SpanB_Buffer[i]=price;
      SpanB2_Buffer[i]=price;
      i--;
     }
//---- Chinkou Span
   i=Bars-1;
   if(counted_bars>1) i=Bars-counted_bars-1;
   while(i>=0) { Chinkou_Buffer[i]=Close[i]; i--; }
//----
   return(0);
  }
//+------------------------------------------------------------------+