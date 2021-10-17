//+------------------------------------------------------------------+
//|                                                FiguresCandle.mq4 |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1

extern bool  AlertON    = true;
extern color colorBulls = Blue;
extern color colorBears = Red;
extern bool  DrawCandle = true;

double BufferUP[],P;
double BufferDN[];
int candle[],Timei;
color Color;
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(0,236);
   SetIndexArrow(1,238);
   SetIndexBuffer(0,BufferUP);
   SetIndexBuffer(1,BufferDN);
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
   ObjectsDeleteAll(0,OBJ_TEXT);
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   string NameFigur;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+2;

   for(int i=1; i<limit; i++)
     {
      bool up=false,down=false;
      double MA0 = iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,i);
      double MA1 = iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,i);
      double MA2 = iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,i+1);
      double MA3 = iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,i+2);

      if(MA0>MA1 && MA1>MA2 && MA2>MA3) up=true;
      else up=false;
      if(MA0<MA1 && MA1<MA2 && MA2<MA3) down=true;
      else down=false;
      //---
      NameFigur="";
      if(Close[i]>Close[i+1] && Close[i]>Open[i+1])
        {
         if(down && Open[i+1]>Close[i+1] && Open[i]>Close[i+1] && Close[i]<Open[i+1] && Close[i]>Open[i])
           {
            NameFigur="BullHarami";
            Redraw(i,colorBulls,NameFigur); Redraw(i+1,colorBulls,NameFigur);
           }
         if(Open[i+1]>Close[i+1] && Open[i]>Close[i+1] && Open[i]<Open[i+1] && Close[i]>Open[i+1])
           {
            NameFigur="BullCross";
            Redraw(i,colorBulls,NameFigur); Redraw(i+1,colorBulls,NameFigur);
           }
         if(Close[i+1]<Open[i+1] && Open[i]<Close[i+1] && Close[i]>Open[i+1])
           {
            NameFigur="Bullish Engulfing";
            if(Close[i+1]<Open[i+1] && Close[i]>Open[i] && Open[i]<Close[i+1] && Close[i]>Close[i+1]+((Open[i+1]-Close[i+1])/2))
              {
               NameFigur="BullPierce";
              }
            Redraw(i,colorBulls,NameFigur); Redraw(i+1,colorBulls,NameFigur);
           }
         if(Close[i+2]<Open[i+2] && Open[i+1]<Close[i+2] && Close[i+1]<Close[i+2] && Open[i]>Close[i+1] && Open[i]>Open[i+1] && Close[i]>=Close[i+2])
           {
            NameFigur="Morning Star";
            Redraw(i,colorBulls,NameFigur); Redraw(i+1,colorBulls,NameFigur); Redraw(i+2,colorBulls,NameFigur);
           }
        }
      if(Open[i]-Low[i]>MathMax(High[i]-Close[i],Close[i]-Open[i])*3 && Close[i]-Low[i]>MathMax(High[i]-Close[i],Close[i]-Open[i])*3)
        {
         NameFigur="Hammer";
         if(up) {Redraw(i,colorBulls,NameFigur); Redraw(i+1,colorBulls,NameFigur);}
         if(down) {Redraw(i,colorBears,NameFigur); Redraw(i+1,colorBears,NameFigur);}
        }
      ///// медведи ///// медведи ///// медведи ///// медведи ///// медведи ///// медведи ///// медведи ///// медведи ///// медведи
      if(Close[i]<Close[i+1] && Close[i]<Open[i+1])
        {
         if(up && Open[i+1]<Close[i+1] && Open[i]<Close[i+1] && Close[i]>Open[i+1] && Close[i]<Open[i])
           {
            NameFigur="BearHarami";
            Redraw(i,colorBears,NameFigur); Redraw(i+1,colorBears,NameFigur);
           }
         if(Open[i+1]<Close[i+1] && Open[i]<Close[i+1] && Open[i]>Open[i+1] && Close[i]<Open[i+1])
           {
            NameFigur="BearCross";
            Redraw(i,colorBears,NameFigur); Redraw(i+1,colorBears,NameFigur);
           }
         if(Close[i+1]>Open[i+1] && Close[i]<Open[i] && Open[i]>Close[i+1] && Close[i]<Open[i+1])
           {
            NameFigur="BearEngulf";
            if(Close[i+1]>Open[i+1] && Open[i]>Close[i+1] && Close[i]<Close[i+1]-((Close[i+1]-Open[i+1])/2))
              {
               NameFigur="DarkCloud";
              }
            Redraw(i,colorBears,NameFigur); Redraw(i+1,colorBears,NameFigur);
           }

         if(Close[i+2]>Open[i+2] && Open[i+1]>Close[i+2] && Close[i+1]>Close[i+2] && Open[i]<Close[i+1] && Open[i]<Open[i+1] && Close[i]<Close[i+2])
           {
            NameFigur="EveningStar";
            Redraw(i,colorBears,NameFigur); Redraw(i+1,colorBears,NameFigur); Redraw(i+2,colorBears,NameFigur);
           }
         if(up && High[i]-Open[i]>MathMax(Close[i]-Low[i],Open[i]-Close[i])*3 && High[i]-Close[i]>MathMax(Close[i]-Low[i],Open[i]-Close[i])*3)
           {
            NameFigur="Shooter";
            Redraw(i,colorBears,NameFigur); Redraw(i+1,colorBears,NameFigur);
           }
        }
      if(NameFigur!="")
        {
         double DELTA=(MathMax(High[i],High[i+1])-MathMin(Low[i],Low[i+1]))/2;
         if(Color==colorBears) {BufferDN[i]=MathMax(High[i],High[i+1]);P=BufferDN[i]+DELTA;}
         else {BufferUP[i]=MathMin(Low[i],Low[i+1]);P=BufferUP[i]-DELTA;}
         DrawTEXT(StringConcatenate(NameFigur," ",TimeToStr(Time[i],TIME_DATE|TIME_MINUTES)),NameFigur,Color,Time[i+1],P);
        }
     }
   if(Timei!=Time[0] && AlertON && i==0 && NameFigur!="") {Alert(Symbol()+" FiguresCandle = "+NameFigur);Timei=Time[0];}
   return(0);
  }
//-------------------------------------------------------------------
void Redraw(int i,color col,string name)
  {
   Color=col;
   if(!DrawCandle) return;
   name=StringConcatenate(name," ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
   ObjectCreate(name,OBJ_TREND,0,Time[i],High[i],Time[i],Low[i]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
   name=StringConcatenate(name," o");
   ObjectCreate(name,OBJ_TREND,0,Time[i],Open[i],Time[i],Open[i]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
   name=StringConcatenate(name," c");
   ObjectCreate(name,OBJ_TREND,0,Time[i],Close[i],Time[i]+Period()*60,Close[i]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
  }
//-------------------------------------------------------------------
void DrawTEXT(string NT,string Name,color col,datetime t1,double p1)
  {
   ObjectDelete(NT);
   ObjectCreate(NT,OBJ_TEXT,0,t1,p1,0,0,0,0);
   ObjectSet(NT,OBJPROP_COLOR,col);
   ObjectSetText(NT,Name,10,"Arial");
  }
//--------------------------------------------------------------------
