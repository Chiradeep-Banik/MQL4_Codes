//+------------------------------------------------------------------+
//|                                                 RSI Slowdown.mq4 |
//|                                              Copyright 2015, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Tor"
#property link      "http://einvestor.ru/"
#property version   "1.00"
#property strict
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_chart_window

input int RSIPeriod=2; // RSI Period
input double LevelMax=90; // Signal Level Max
input double LevelMin=10; // Signal Level Min
input bool SeekSlowdown=true; // Seek Slowdown

input int bar=1; // Bar
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeGraph
  {
   Lines=0,// Lines
   Arrows=1,// Arrows
  };
//--- input parameters
input TypeGraph TypeGr=Arrows; // Type graph
input bool alerts=false; // Alerts

input color activeUp=clrBlue; // Buy Color
input color activeDown=clrRed; // Sell Color

double rsi[];
double UP[];
double Down[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,rsi);
   SetIndexBuffer(1,UP);
   SetIndexBuffer(2,Down);
   IndicatorShortName("RSI Slowdown");
   SetIndexStyle(0,DRAW_NONE,STYLE_SOLID,1,clrYellow);

   if(TypeGr==1)
     {
      SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1,activeUp);
      SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,activeDown);
      SetIndexArrow(1,233);
      SetIndexArrow(2,234);
      SetIndexLabel(1,"Buy");
      SetIndexLabel(2,"Sell");
        }else{
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   del("RS_");
   return(0);
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
   int limit;
   static bool alrt=false;
   static datetime altime=0;

//---
   if(rates_total<=1)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit=limit+2;

   for(int x=limit-2; x>=0; x--)
     {
      UP[x]=EMPTY_VALUE; Down[x]=EMPTY_VALUE;
      rsi[x]=iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,x+bar);
      if(rsi[x]>=LevelMax)
        {
         if(!SeekSlowdown)
           {
            if(alerts && x==0 && altime!=Time[0])
              {
               Alert("RSI Slowdown : "+_Symbol+" Signal Sell");
               altime=Time[0];
              }
            if(TypeGr==1)
              {
               Down[x]=iOpen(Symbol(),0,x);
                 }else{
               Lines(x,"Sell",activeDown);
              }
              }else{
            if(MathAbs(rsi[x+1]-rsi[x])<1)
              {
               if(alerts && x==0 && altime!=Time[0])
                 {
                  Alert("RSI Slowdown : "+_Symbol+" Signal Sell"); altime=Time[0];
                 }
               if(TypeGr==1)
                 {
                  Down[x]=iOpen(Symbol(),0,x);
                    }else{
                  Lines(x,"Sell",activeDown);
                 }
              }
           }
        }
      if(rsi[x]<=LevelMin)
        {
         if(!SeekSlowdown)
           {
            if(alerts && x==0 && altime!=Time[0])
              {
               Alert("RSI Slowdown : "+_Symbol+" Signal Buy"); altime=Time[0];
              }
            if(TypeGr==1)
              {
               UP[x]=iOpen(Symbol(),0,x);
                 }else{
               Lines(x,"Buy",activeUp);
              }
              }else{
            if(MathAbs(rsi[x+1]-rsi[x])<1)
              {
               if(alerts && x==0 && altime!=Time[0])
                 {
                  Alert("RSI Slowdown : "+_Symbol+" Signal Buy"); altime=Time[0];
                 }
               if(TypeGr==1)
                 {
                  UP[x]=iOpen(Symbol(),0,x);
                    }else{
                  Lines(x,"Buy",activeUp);
                 }
              }
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void Lines(int shift,string txt,color clr=clrRed)
  {
   datetime time=iTime(Symbol(),0,shift);
   ObjectCreate(0,"RS_"+txt+"_"+(string)time,OBJ_VLINE,0,time,0);
   ObjectSetInteger(0,"RS_"+txt+"_"+(string)time,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,"RS_"+txt+"_"+(string)time,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetString(0,"RS_"+txt+"_"+(string)time,OBJPROP_TOOLTIP,txt);
   ObjectSetInteger(0,"RS_"+txt+"_"+(string)time,OBJPROP_BACK,true);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int del(string name)
  {
   for(int n=ObjectsTotal()-1; n>=0; n--)
     {
      string Obj_Name=ObjectName(n);
      if(StringFind(Obj_Name,name,0)!=-1)
        {
         ObjectDelete(Obj_Name);
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
