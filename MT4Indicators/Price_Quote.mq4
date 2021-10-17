//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
   Created by Asteris, modified by Cubicrey [March, 2010]
   Website: http://www.indo-investasi.com
   
   Converted to Pivot Star by rkdius [Dec 2016]
*/

#property indicator_chart_window
//--- input parameters
enum lbCorner
  {
   TopLeft=0,       // Top Left
   TopRight=1,      // Top Right
   BottomLeft=2,    // Bottom Left
   BottomRight=3    // Bottom Right
  };
extern ENUM_TIMEFRAMES inpPeriod=PERIOD_D1;    // Period
extern int Shift=0;                                // Shift
extern int xOffset = 5;                          // X-Offset
extern int yOffset = 5;                          // Y-Offset
extern lbCorner LabelCorner = TopRight;          // Label Corner
extern color  ColorUp= MediumSeaGreen;           // Text Color
extern color  ColorDn= Crimson;
extern string Font="Arial";                    // Font
extern int FontSize=22;                         // Font Size
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BidPrice;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   ObjectMakeLabel("PriceQuoteInfo",xOffset,yOffset);
   ObjectMakeLabel("PriceQuoteMinMax",xOffset,yOffset+FontSize+5);
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("PriceQuoteInfo");
   ObjectDelete("PriceQuoteMinMax");
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double xOpen=iOpen(0,inpPeriod,Shift);
   double xHigh= iHigh(0,inpPeriod,Shift);
   double xLow=iLow(0,inpPeriod,Shift);
   double PercentChange=(Bid-xOpen)/xOpen*100;
   string sPcChange="";
   color TextColor;
   int smallfont=FontSize*3/7;
   if(smallfont<6) smallfont=6;
   if(Shift>0)
     {
      xHigh=iHigh(0,inpPeriod,iHighest(0,inpPeriod,MODE_HIGH,Shift,0));
      xLow=iLow(0,inpPeriod,iLowest(0,inpPeriod,MODE_LOW,Shift,0));
     }

   if(PercentChange>0)
     {
      sPcChange=/*" "+CharToStr(236)+*/" +"+DoubleToStr(PercentChange,2);
      TextColor=ColorUp;
     }
   else
     {
      sPcChange=/*" "+CharToStr(238)+*/" "+DoubleToStr(PercentChange,2);
      TextColor=ColorDn;
     }

   double xRange=(xHigh-xLow)*pow(10,Digits-1);
   if(Digits<1)
     {
      xRange=(xHigh-xLow);
     }
   string pivPeriod="M"+IntegerToString(inpPeriod);
   if(inpPeriod>=60) pivPeriod = "H"+IntegerToString(inpPeriod/60);
   if(inpPeriod>=1440) pivPeriod = "D1";
   if(inpPeriod>=10080) pivPeriod = "WK";
   if(inpPeriod>=43200) pivPeriod = "MN";

   ObjectSetText("PriceQuoteInfo",DoubleToStr(Bid,Digits)+" "+sPcChange+"%",FontSize,Font,TextColor);
   ObjectSetText("PriceQuoteMinMax","("+pivPeriod+"/"+IntegerToString(Shift)+") L: "+DoubleToStr(xLow,Digits)+" | H: "+DoubleToStr(xHigh,Digits)+" | R: "
                 +DoubleToStr(xRange,1)+"p",smallfont,Font,Black);

   return (0);
  }
//+--------------------------------------------------------------------------+
//| ObjectMakeLabel:                                                         |
//|                                                            P4L Clock.mq4 |
//| New rewrite by: Pips4life, a user at forexfactory.com                    |
//| 2014-Mar-19: v2_12  P4L Clock.mq4                                        |
//| For lastest version: http://www.forexfactory.com/showthread.php?t=109305 |
//| Previous names: Clock_v1_3.mq4, Clock.mq4, ...                           |
//| Previous version:   Jerome,  4xCoder@gmail.com, ...                      |
///+-------------------------------------------------------------------------+
int ObjectMakeLabel(string n,int xoff,int yoff)
  {
   if(!WindowIsVisible(0)) return(-1);
   ObjectCreate(n,OBJ_LABEL,0,0,0);
   ObjectSet(n,OBJPROP_CORNER,LabelCorner);
   ObjectSet(n,OBJPROP_XDISTANCE,xoff);
   ObjectSet(n,OBJPROP_YDISTANCE,yoff);
   ObjectSet(n,OBJPROP_BACK,false);
   ObjectSet(n,OBJPROP_SELECTABLE,false);
   ObjectSet(n,OBJPROP_HIDDEN,true);
   return(0);
  }// end of ObjectMakeLabel
