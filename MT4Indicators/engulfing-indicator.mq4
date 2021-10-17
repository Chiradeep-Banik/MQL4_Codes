//+------------------------------------------------------------------+
//|                                                Engulfing.mq4 |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1

extern bool  AlertON    = false;
extern color colorBulls = Blue;
extern color colorBears = Red;
extern bool  DrawCandle = true;

double BufferUP[];
double BufferLOW[];
int candle[];
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(0,241);
   SetIndexArrow(1,242);
   SetIndexBuffer(0,BufferUP);
   SetIndexBuffer(1,BufferLOW);
   SetIndexLabel(0,"UP");
   SetIndexLabel(1,"DOWN");
   SetIndexEmptyValue(0,0.0);
   IndicatorShortName("FiguresCandle");
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,OBJ_TREND);
//ObjectsDeleteAll(0,OBJ_RECTANGLE);
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int S;
   string NameFigur;
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(int i=0; i<limit-1; i++)
     {
      S=Figura(i);
      switch(S)
        {
         case 1:BufferUP[i]=Low[i];

         break;
         case -1:BufferLOW[i]=High[i];

         break;
        }
      if(AlertON && i==0 && S!=0) Alert(Symbol()+" FiguresCandle = "+NameFigur);
     }
   return(0);
  }
//-------------------------------------------------------------------
int Redraw(int bar,color col,string name)
  {
   if(!DrawCandle) return(0);
   name=StringConcatenate(name," ",TimeToStr(Time[bar],TIME_DATE|TIME_SECONDS));
   ObjectCreate(name,OBJ_TREND,0,Time[bar],High[bar],Time[bar],Low[bar]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
   name=StringConcatenate(name," o");
   ObjectCreate(name,OBJ_TREND,0,Time[bar+1],Open[bar],Time[bar],Open[bar]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
   name=StringConcatenate(name," c");
   ObjectCreate(name,OBJ_TREND,0,Time[bar],Close[bar],Time[bar]+Period()*60,Close[bar]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                       Figura.mqh |
//|                               Copyright © 2016, Vladivir Hlystov |
//|                                         http://cmillion@narod.ru |
//+------------------------------------------------------------------+
int Figura(int bar)
  {
//----------------------------------------- анализ фигур
   if(High[bar+1]<High[bar] && Low[bar+1]>Close[bar] && 
      Open[bar+1]<Close[bar+1] && Open[bar]>Close[bar])
     {
      return(-1);
     }
   if(Low[bar+1]>Low[bar] && High[bar+1]<Close[bar] && 
      Open[bar+1]>Close[bar+1] && Open[bar]<Close[bar])
     {
      return(1);
     }
   return(0);
  }
//-------------------------------------------------------------------
