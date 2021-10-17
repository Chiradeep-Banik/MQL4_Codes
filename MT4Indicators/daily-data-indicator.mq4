//+------------------------------------------------------------------+
//|                                                    DailyData.mq5 |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_color1  clrGreen
#property indicator_color2  clrCrimson
#property indicator_color3  clrOrangeRed
#property indicator_color4  clrMediumSeaGreen
#property indicator_width3  2
#property indicator_width4  2
#property strict

//
//
//
//
//

input color TextColor           = clrWhite;            // Text color
input color ButtonColor         = clrSteelBlue;        // Background color
input color AreaColor           = clrGainsboro;        // Area color
input color SymbolColor         = clrSteelBlue;        // Symbol color
input color LabelsColor         = clrDimGray;          // Labels color
input color ValuesNeutralColor  = clrDimGray;          // Color for unchanged values
input color ValuesPositiveColor = clrMediumSeaGreen;   // Color for positive values
input color ValuesNegativeColor = clrPaleVioletRed;    // Color for negative values
input int   XPosition           = 10;                  // Controls x position
input int   YPosition           = 10;                  // Controls y position
input ENUM_BASE_CORNER Corner   = CORNER_RIGHT_UPPER;  // Corner to use for display
input int   CandleShift         = 5;                   // Candle shift
input int   TimeFontSize        = 10;                  // Font size for timer
input int   TimerShift          = 7;                   // Timer shift
input int   ZonesCount          = 1;                   // Show zones for (n) days : 

//
//
//
//
//

double candleOpen[];
double candleHigh[];
double candleLow[];
double candleClose[];
double candleColor[];

//
//
//
//
//

#define bnameA "DailyDataShowBasic" 
#define bnameB "DailyDataShowSwaps" 
#define bnameC "DailyDataShowCandle" 
#define bnameD "DailyDataShowArea" 
#define bnameE "DailyDataShowTimer" 
#define cnameA "DailyDataArea" 
#define lnameA "DailyDataSymbol" 
#define lnameB "DailyDataClock" 
#define lnameC "DailyDataRange" 
#define lnameD "DailyDataChange" 
#define lnameE "DailyDataDistH" 
#define lnameS "DailyDataSpread" 
#define snameA "DailyDataSwapShort" 
#define snameB "DailyDataSwapLong" 
#define clockName "DailyDataTimer"

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,candleHigh ,INDICATOR_DATA); SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexShift(0,CandleShift);
   SetIndexBuffer(1,candleLow  ,INDICATOR_DATA); SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexShift(1,CandleShift);
   SetIndexBuffer(2,candleOpen ,INDICATOR_DATA); SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexShift(2,CandleShift);
   SetIndexBuffer(3,candleClose,INDICATOR_DATA); SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexShift(3,CandleShift);
   SetIndexBuffer(4,candleColor,INDICATOR_COLOR_INDEX);
      PlotIndexSetInteger(0,PLOT_SHIFT,CandleShift);
         createObjects(); setControls();
   return(0);
}

//
//
//
//
//

void OnDeinit(const int reason)
{
   switch(reason)
   {
      case REASON_REMOVE :
         for (int i=ObjectsTotal(); i>= 0; i--)
         {
            string name = ObjectName(ChartID(),i);
                  if (StringSubstr(name,0,9)=="DailyData") ObjectDelete(ChartID(),name);
         }
         ChartRedraw();
   }
	if (!getState(bnameE)) EventKillTimer();
}

//
//
//
//
//

void OnTimer( ) {	refreshData(); }
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   refreshData(); 
   return(rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void refreshData()
{
   static bool inRefresh = false;
           if (inRefresh) return;
               inRefresh = true;
   
   //
   //
   //
   //
   //
   
   int bars = ArraySize(candleClose);
   ENUM_TIMEFRAMES period = PERIOD_D1;
      if (Period()>= PERIOD_D1) period=PERIOD_W1;
      if (Period()>= PERIOD_W1) period=PERIOD_MN1;
         static datetime times[1]; CopyTime(Symbol(),0,0,1,times);
         static MqlRates rates[];
            if (CopyRates( Symbol(),period,0,ZonesCount,rates)<ZonesCount) { inRefresh=false; return; }

         //
         //
         //
         //
         //
      
            
            candleOpen [0] = rates[ZonesCount-1].open;
            candleClose[0] = rates[ZonesCount-1].close;
            if (candleClose[0]>candleOpen[0])
            {
               candleHigh [0] = rates[ZonesCount-1].high;
               candleLow  [0] = rates[ZonesCount-1].low;     
            }               
            else               
            {
               candleHigh [0] = rates[ZonesCount-1].low;
               candleLow  [0] = rates[ZonesCount-1].high;     
            }               
            for (int k=0; k<4; k++) SetIndexDrawBegin(k,Bars-1);               

            //
            //
            //
            //
            //
         
            for (int i=0; i<ZonesCount; i++)
            {
               ObjectSetDouble(0,cnameA+":"+(string)i,OBJPROP_PRICE,0,rates[i].high);
               ObjectSetDouble(0,cnameA+":"+(string)i,OBJPROP_PRICE,1,rates[i].low );
               ObjectSetInteger(0,cnameA+":"+(string)i,OBJPROP_TIME,0,rates[i].time);
               if (i==ZonesCount-1)
                     ObjectSetInteger(0,cnameA+":"+(string)i,OBJPROP_TIME,1,times[0]);
               else  ObjectSetInteger(0,cnameA+":"+(string)i,OBJPROP_TIME,1,rates[i+1].time-1);
            }               

   //
   //
   //
   //
   //
            
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,bars-1);
   double pipModifier=1;
      if (_Digits==3 || _Digits==5) pipModifier=10;
   double ask = (double)SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = (double)SymbolInfoDouble(_Symbol,SYMBOL_BID);
      setBasicValue(lnameA,DoubleToString(rates[ZonesCount-1].close,_Digits)                                        ,XPosition,YPosition+20 ,Corner);
      setBasicValue(lnameB,DoubleToString((rates[ZonesCount-1].high-rates[ZonesCount-1].low)  /_Point/pipModifier,1),XPosition,YPosition+38 ,Corner);
      setBasicValue(lnameC,DoubleToString((rates[ZonesCount-1].close-rates[ZonesCount-1].open)/_Point/pipModifier,1),XPosition,YPosition+56 ,Corner);
      setBasicValue(lnameD,DoubleToString((rates[ZonesCount-1].high-rates[ZonesCount-1].close)/_Point/pipModifier,1),XPosition,YPosition+74 ,Corner);
      setBasicValue(lnameE,DoubleToString((rates[ZonesCount-1].close-rates[ZonesCount-1].low) /_Point/pipModifier,1),XPosition,YPosition+92 ,Corner);
      setBasicValue(lnameS,DoubleToString((ask-bid)/_Point/pipModifier,1)                                           ,XPosition,YPosition+110,Corner);
         if (rates[ZonesCount-1].close<rates[ZonesCount-1].open)
               ObjectSetInteger(0,lnameA+"v",OBJPROP_COLOR,ValuesNegativeColor);


      setSwapValue(snameA,DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT),1),XPosition,YPosition+20,Corner);
      setSwapValue(snameB,DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG) ,1),XPosition,YPosition+38,Corner);

   //
   //
   //
   //
   //
   
   if (!getState(bnameE)) ShowClock(); ChartRedraw();
   inRefresh=false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if (sparam==bnameA) setControls();
      if (sparam==bnameB) setControls();
      if (sparam==bnameC) setControls();
      if (sparam==bnameD) setControls();
      if (sparam==bnameE) setControls();
   }      
}

//
//
//
//
//

void createObjects()
{
   if (ObjectFind(0,bnameA)<0) { ObjectCreate(0,bnameA,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,bnameB)<0) { ObjectCreate(0,bnameB,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,bnameC)<0) { ObjectCreate(0,bnameC,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,bnameD)<0) { ObjectCreate(0,bnameD,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,bnameE)<0) { ObjectCreate(0,bnameE,OBJ_BUTTON   ,0,0,0,0,0); }
   for (int i = 0; i<ZonesCount; i++)
      if (ObjectFind(0,cnameA+":"+(string)i)<0) 
         {
            ObjectCreate(0,cnameA+":"+(string)i,OBJ_RECTANGLE,0,0,0,0,0); 
            ObjectSetInteger(0,cnameA+":"+(string)i,OBJPROP_FILL,true); 
         }
                     
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

bool getState(string name)
{
   bool ans = (int)ObjectGetInteger(0,name,OBJPROP_STATE);
   return(ans);
}
void setVisibleState(string control, bool state)
{
   if (state)
         ObjectSetInteger(0,control,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   else  ObjectSetInteger(0,control,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define heightForBasic 128
#define heightForSwap  56
int     heightTotal; 

//
//
//
//
//

void setControls()
{
   int heightBasic  = 20; if (!getState(bnameA)) heightBasic = heightForBasic;
   int heightSwap   = 20; if (!getState(bnameB)) heightSwap  = heightForSwap;
   int heightCandle = 20;
   int heightArea   = 20;
   int heightTimer  = 20;
       heightTotal  =  YPosition+heightArea+heightBasic+heightCandle+heightSwap+heightTimer;

   //
   //
   //
   //
   //
   
   int pos = YPosition;
   string caption;
      if (!getState(bnameA))
            caption = "Hide basic data";
      else  caption = "Show basic data";
      setButton(bnameA,caption,XPosition,pos,TextColor,ButtonColor,Corner);
      
      pos+=heightBasic;
      if (!getState(bnameB))
            caption = "Hide swaps";
      else  caption = "Show swaps";
      setButton(bnameB,caption,XPosition,pos,TextColor,ButtonColor,Corner);

      pos+=heightSwap;
      if (!getState(bnameC))
            caption = "Hide candle";
      else  caption = "Show candle";
      setButton(bnameC,caption,XPosition,pos,TextColor,ButtonColor,Corner);
      
      pos+=heightCandle;
      if (!getState(bnameD))
            caption = "Hide area(s)";
      else  caption = "Show area(s)";
      setButton(bnameD,caption,XPosition,pos,TextColor,ButtonColor,Corner);

      pos+=heightArea;
      if (!getState(bnameE))
            caption = "Hide timer";
      else  caption = "Show timer";
      setButton(bnameE,caption,XPosition,pos,TextColor,ButtonColor,Corner);
      setVisibleState(clockName,!getState(bnameE));
            if (!getState(bnameE))
                  EventSetTimer(1);
            else  EventKillTimer();
            string name = "back";

   //
   //
   //
   //
   //
   
      for (int i=0; i<ZonesCount; i++)
      {
         ObjectSetInteger(0,cnameA+":"+(string)i,OBJPROP_COLOR,AreaColor);
         ObjectSetInteger(0,cnameA+":"+(string)i,OBJPROP_SELECTABLE,0);
         ObjectSetInteger(0,cnameA+":"+(string)i,OBJPROP_BACK,true);
         ObjectSetInteger(0,cnameA+":"+(string)i,OBJPROP_HIDDEN,true);
            setVisibleState(cnameA+":"+(string)i,!getState(bnameD));
      }            

      //
      //
      //
      //
      //
      
         setBasicLabel(lnameA,Symbol()            ,XPosition,YPosition+20 ,Corner,SymbolColor,13);
         setBasicLabel(lnameB,"range"             ,XPosition,YPosition+38 ,Corner,LabelsColor);
         setBasicLabel(lnameC,"change"            ,XPosition,YPosition+56 ,Corner,LabelsColor);
         setBasicLabel(lnameD,"distance from high",XPosition,YPosition+74 ,Corner,LabelsColor);
         setBasicLabel(lnameE,"distance from low" ,XPosition,YPosition+92 ,Corner,LabelsColor);
         setBasicLabel(lnameS,"spread"            ,XPosition,YPosition+110,Corner,LabelsColor);
         setVisibleState(lnameA+"v",!getState(bnameA));
         setVisibleState(lnameB+"v",!getState(bnameA));
         setVisibleState(lnameC+"v",!getState(bnameA));
         setVisibleState(lnameD+"v",!getState(bnameA));
         setVisibleState(lnameE+"v",!getState(bnameA));
         setVisibleState(lnameS+"v",!getState(bnameA));
            ObjectSetInteger(0,lnameA+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameA,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameB+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameB,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameC+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameC,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameD+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameD,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameE+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameE,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameS+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameS,OBJPROP_YDISTANCE));
      
      //
      //
      //
      //
      //
      
         setSwapLabel(snameA,"swap short",XPosition,YPosition+20,Corner,LabelsColor);
         setSwapLabel(snameB,"swap long" ,XPosition,YPosition+38,Corner,LabelsColor);
         setVisibleState(snameA+"v",!getState(bnameB));
         setVisibleState(snameB+"v",!getState(bnameB));
            ObjectSetInteger(0,snameA+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,snameA,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,snameB+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,snameB,OBJPROP_YDISTANCE));
   
   //
   //
   //
   //
   //

      if (getState(bnameC))
      {
         SetIndexStyle(0,DRAW_NONE);
         SetIndexStyle(1,DRAW_NONE);
         SetIndexStyle(2,DRAW_NONE);
         SetIndexStyle(3,DRAW_NONE);
      }            
      else
      {
         SetIndexStyle(0,DRAW_HISTOGRAM);
         SetIndexStyle(1,DRAW_HISTOGRAM);
         SetIndexStyle(2,DRAW_HISTOGRAM);
         SetIndexStyle(3,DRAW_HISTOGRAM);
      }        
      ChartRedraw();
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void setButton(string name, string caption, int xposition, int yposition, color textColor, color backColor, int corner)
{
   int relXPosition = xposition; if (corner==1 || corner==3) relXPosition  = 190+xposition; 
   int relYPosition = yposition; if (corner==2 || corner==3) relYPosition  = heightTotal-yposition+YPosition;
   
      ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,relXPosition);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,relYPosition);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,190);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,18);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
         ObjectSetString(0,name,OBJPROP_FONT,"Arial");
         ObjectSetString(0,name,OBJPROP_TEXT,caption);
}

//
//
//
//
//

void setBasicLabel(string name, string label, int xposition, int yposition, int corner, color labelColor, int fontSize=10, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, string statusCheck = bnameA, int displacement=0)
{
   int relXPosition = xposition;              if (corner==1 || corner==3) relXPosition = 190+xposition;
   int relYPosition = yposition+displacement; if (corner==2 || corner==3) relYPosition = heightTotal-yposition-displacement+YPosition;

   //
   //
   //
   //
   //
   
   if (ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
      ObjectSetInteger(0,name,OBJPROP_COLOR,labelColor);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,relXPosition);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,relYPosition);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
            ObjectSetString(0,name,OBJPROP_FONT,"Arial");
            ObjectSetString(0,name,OBJPROP_TEXT,label);
      setVisibleState(name,!getState(statusCheck));
}

//
//
//
//
//

void setBasicValue(string name, string value, int xposition, int yposition, int corner, int fontSize=12, string statusCheck = bnameA, int displacement=0)
{
   double dvalue = StringToDouble(value);
   color  cvalue = ValuesNeutralColor;
   
      if (dvalue>0) cvalue = ValuesPositiveColor;
      if (dvalue<0) cvalue = ValuesNegativeColor;
      if (corner==0 || corner==2) xposition += 190;
      if (corner==1 || corner==3) xposition -= 190;
         setBasicLabel(name+"v",value,xposition,yposition,corner,cvalue,fontSize,ANCHOR_RIGHT_UPPER,statusCheck,displacement);
}

//
//
//
//
//

void setSwapLabel(string name, string label, int xposition, int yposition, int corner, color labelColor, int fontSize=10)
{
   int heightBasic = !getState(bnameA) ? heightForBasic : 20;
         setBasicLabel(name,label,xposition,yposition,corner,labelColor,fontSize,ANCHOR_LEFT_UPPER,bnameB,heightBasic);
}
void setSwapValue(string name, string value, int xposition, int yposition, int corner, int fontSize=12)
{
   int heightBasic = !getState(bnameA) ? heightForBasic : 20;
         setBasicValue(name,value,xposition,yposition,corner,fontSize,bnameB,heightBasic);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void ShowClock()
{
   int periodMinutes = _Period;
   int shift         = periodMinutes*TimerShift*60;
   int currentTime   = (int)TimeCurrent();
   int localTime     = (int)TimeLocal();
   int barTime       = (int)iTime();
   int diff          = (int)MathMax(round((currentTime-localTime)/3600.0)*3600,-24*3600);

   //
   //
   //
   //
   //

      color  theColor;
      string time = getTime(barTime+periodMinutes*60-localTime-diff,theColor);
             time = (TerminalInfoInteger(TERMINAL_CONNECTED)) ? time : time+" x";

      //
      //
      //
      //
      //
                          
      if(ObjectFind(0,clockName) < 0)
         ObjectCreate(0,clockName,OBJ_TEXT,0,barTime+shift,0);
         ObjectSetString(0,clockName,OBJPROP_TEXT,time);
         ObjectSetString(0,clockName,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,clockName,OBJPROP_FONTSIZE,TimeFontSize);
         ObjectSetInteger(0,clockName,OBJPROP_COLOR,theColor);
         ObjectSetInteger(0,clockName,OBJPROP_HIDDEN,true);
         if (ChartGetInteger(0,CHART_SHIFT,0)==0 && (shift >=0))
               ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime-shift*3);
         else  ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime+shift+CandleShift*_Period*60);

      //
      //
      //
      //
      //

      double price  = Close[0];
      double atr    = iATR(NULL,0,10,0);
             price += 3.0*atr/4.0;
             
      //
      //
      //
      //
      //

      bool visible = ((ChartGetInteger(0,CHART_VISIBLE_BARS,0)-ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0)) > 0);
      if ( visible && price>=ChartGetDouble(0,CHART_PRICE_MAX,0))
            ObjectSetDouble(0,clockName,OBJPROP_PRICE,price-1.5*atr);
      else  ObjectSetDouble(0,clockName,OBJPROP_PRICE,price);
}


//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

string getTime(int times, color& theColor)
{
   string stime = "";
   int    seconds;
   int    minutes;
   int    hours;
   
   //
   //
   //
   //
   //
   
   if (times < 0) {
         theColor = ValuesNegativeColor; times = (int)fabs(times); }
   else  theColor = ValuesPositiveColor;
   seconds = (times%60);
   hours   = (times-times%3600)/3600;
   minutes = (times-seconds)/60-hours*60;

   //
   //
   //
   //
   //
   
   if (hours>0)
   if (minutes < 10)
         stime = stime+(string)hours+":0";
   else  stime = stime+(string)hours+":";
         stime = stime+(string)minutes;
   if (seconds < 10)
         stime = stime+":0"+(string)seconds;
   else  stime = stime+":" +(string)seconds;
   return(stime);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

datetime iTime(ENUM_TIMEFRAMES forPeriod=PERIOD_CURRENT)
{
   datetime times[]; if (CopyTime(Symbol(),forPeriod,0,1,times)<=0) return(TimeLocal());
   return(times[0]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int periodToMinutes(int period)
{
   int i;
   static int _per[]={1,2,3,4,5,6,10,12,15,20,30,0x4001,0x4002,0x4003,0x4004,0x4006,0x4008,0x400c,0x4018,0x8001,0xc001};
   static int _min[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};

   if (period==PERIOD_CURRENT) 
       period = Period();   
            for(i=0;i<20;i++) if(period==_per[i]) break;
   return(_min[i]);   
}
