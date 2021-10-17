//+------------------------------------------------------------------+
//|                                              Tipu Panel MACD.mq4 |
//|                                    Copyright 2018, Kaleem Haider |
//|               https://www.mql5.com/en/users/kaleem.haider/seller |
//| -----------------------------------------------------------------|
//| Update version 1.40 -                                            |
//| reduced number of buffers for faster loading                     |
//| optimized code                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Kaleem Haider"
#property link      "https://www.mql5.com/en/users/kaleem.haider/seller"
#property version   "1.40"
#property description "Tipu MACD based on the popular Tipu MACD indicator in the market."

#property strict
#property indicator_separate_window
#property indicator_buffers 6

#property indicator_label1 "MACD B1Histogram"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrLime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_label2 "MACD B2Histogram"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

#property indicator_label3 "MACD S1Histogram"
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_color3 clrLightCoral
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2

#property indicator_label4 "MACD S2Histogram"
#property indicator_type4  DRAW_HISTOGRAM
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 2

#property indicator_label5 "MACD Main"
#property indicator_type5  DRAW_LINE
#property indicator_color5 C'16,224,219'     
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1

#property indicator_label6 "MACD Signal"
#property indicator_type6  DRAW_LINE
#property indicator_color6 C'255,104,47'     
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

#property indicator_levelcolor clrSilver

#define PipsPoint Get_PipsPoint()
#define PipsValue Get_PipsValue()

static datetime prevTime;
//+------------------------------------------------------------------+
//| Enumerations for Inputs                                          |
//+------------------------------------------------------------------+
enum ENUM_PanelMode
  {
   buysell = 0,   //Buy Sell Signals
   plot    = 1,   //Macd plot
  };
//+------------------------------------------------------------------+
//| Enumerations for Inputs                                          |
//+------------------------------------------------------------------+

enum ENUM_AppliedPrice
  {
   lowhigh=0,//Low/High
   closeclose=1,//Close/Close
  };
//+------------------------------------------------------------------+
//| Enumerations for Inputs                                          |
//+------------------------------------------------------------------+
enum ENUM_SignalType
  {
   reveral = 0,      //Reversal
   cross  = 1,       //Main and Signal Cross
   divergence =  2,  //Divergence
   ddivergence = 3,  //Double Divergence
  };
//+------------------------------------------------------------------+
//| Enumerations for Inputs                                          |
//+------------------------------------------------------------------+
enum ENUM_MACDMode
  {
   Lines = 0,     //Lines
   Histogram = 1, //Histogram
   Both = 2,      //Lines + Histogram
  };
//+------------------------------------------------------------------+
//| Enumerations for Inputs                                          |
//+------------------------------------------------------------------+
enum ENUM_SignalMark
  {
   None=0,
   Arrows=1,
   VLine=2,
  };

//inputs
input ENUM_MACDMode        eMACDMode=2;   //MACD Mode
input int                  InpFastEMA     =  12;   // Fast EMA Period
input int                  InpSlowEMA     =  26;   // Slow EMA Period
input int                  InpSignalSMA=9;  // Signal SMA Period
input ENUM_APPLIED_PRICE   eAppliedPrice=PRICE_CLOSE; //Applied Price
input string               sSignalType="---Signal Types----------------------------"; //Signal Types
input ENUM_SignalMark      eMarkSignals=1;    //Mark Buy/Sell Signals
input int                  iAOffset=5;     //Arrow offset (pips)
input color          cUpCandle         =  C'31,159,192';  //Up Color
input color          cDwnCandle        =  C'230,77,69';   //Down Color
input bool                 bReversals= true;              //Zero Line Cross
input bool                 bMainSignal=true;              //Main Signal Cross
input string               sAlert="---Buy/Sell Global Alert Settings----------"; //Global Alert Settings
input int                  iAlerti=1;                 //Alert i
input bool                 bAlertM                 = false;             //Alert Mobile
input bool                 bAlertS                 = false;             //Alert Onscreen
input bool                 bAlertE                 = false;             //Alert Email

//---buffers
double MACDHistB1[],MACDHistB2[],MACDHistS1[],MACDHistS2[],MACD[],MACDSignal[],MACDHist[],Signal[],Trend[],BuySignal[],SellSignal[];

//---shortname
string short_name="Tipu MACD";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   int n=0;

   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   IndicatorBuffers(11);

   SetIndexBuffer(n,MACDHistB1,INDICATOR_DATA);
   if(!eMACDMode) SetIndexStyle(n,DRAW_NONE);
   SetIndexDrawBegin(n,InpSignalSMA);
   SetIndexEmptyValue(n,0.0);
   n++;

   SetIndexBuffer(n,MACDHistB2,INDICATOR_DATA);
   if(!eMACDMode) SetIndexStyle(n,DRAW_NONE);
   SetIndexDrawBegin(n,InpSignalSMA);
   SetIndexEmptyValue(n,0.00);
   n++;

   SetIndexBuffer(n,MACDHistS1,INDICATOR_DATA);
   if(!eMACDMode) SetIndexStyle(n,DRAW_NONE);
   SetIndexDrawBegin(n,InpSignalSMA);
   SetIndexEmptyValue(n,0.00);
   n++;

   SetIndexBuffer(n,MACDHistS2,INDICATOR_DATA);
   if(!eMACDMode) SetIndexStyle(n,DRAW_NONE);
   SetIndexDrawBegin(n,InpSignalSMA);
   SetIndexEmptyValue(n,0.00);
   n++;

   SetIndexBuffer(n,MACD,INDICATOR_DATA);
   SetIndexEmptyValue(n,0.00);
   if(eMACDMode==1) SetIndexStyle(n,DRAW_NONE);
   n++;

   SetIndexBuffer(n,MACDSignal,INDICATOR_DATA);
   SetIndexDrawBegin(n,InpSignalSMA);
   if(eMACDMode==1) SetIndexStyle(n,DRAW_NONE);
   SetIndexEmptyValue(n,0.00);
   n++;

   SetIndexBuffer(n,MACDHist,INDICATOR_CALCULATIONS);
   SetIndexDrawBegin(n,InpSignalSMA);
   SetIndexStyle(n,DRAW_NONE);
   SetIndexEmptyValue(n,0.00);
   n++;

   SetIndexBuffer(n,Signal,INDICATOR_CALCULATIONS);   n++;
   SetIndexBuffer(n,Trend,INDICATOR_CALCULATIONS);   n++;
   SetIndexBuffer(n,BuySignal,INDICATOR_CALCULATIONS);   n++;
   SetIndexBuffer(n,SellSignal,INDICATOR_CALCULATIONS);   

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   ObjectsDeleteAll(0,short_name);
   return;
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
   ArraySetAsSeries(MACDHistB1,true);
   ArraySetAsSeries(MACDHistB2,true);
   ArraySetAsSeries(MACDHistS1,true);
   ArraySetAsSeries(MACDHistS2,true);
   ArraySetAsSeries(MACD,true);
   ArraySetAsSeries(MACDSignal,true);
   ArraySetAsSeries(Signal,true);
   ArraySetAsSeries(Trend,true);

   if( prev_calculated < 0 )  return(0);

   if(prev_calculated>0) limit=rates_total-prev_calculated+1;
   else limit=rates_total-1;

//--- load ExtPrice for the indicator
   for(int i=limit-1; i>=0 && !IsStopped(); i--)
     {
      MACD[i]=iMACD(_Symbol,_Period,InpFastEMA,InpSlowEMA,InpSignalSMA,eAppliedPrice,MODE_MAIN,i);
      MACDSignal[i]=iMACD(_Symbol,_Period,InpFastEMA,InpSlowEMA,InpSignalSMA,eAppliedPrice,MODE_SIGNAL,i);
      MACDHist[i]=MACD[i]-MACDSignal[i];

      MACDHistB1[i]=(MACDHist[i]>0 && MACDHist[i+1]>MACDHist[i])?MACDHist[i]:0;
      MACDHistB2[i]=(MACDHist[i]>0 && MACDHist[i+1]<MACDHist[i])?MACDHist[i]:0;

      MACDHistS1[i]=(MACDHist[i]<0 && MACDHist[i+1]<MACDHist[i])?MACDHist[i]:0;
      MACDHistS2[i]=(MACDHist[i]<0 && MACDHist[i+1]>MACDHist[i])?MACDHist[i]:0;

      //---build Signal and Trend Buffer
      bool bReversals_Buy=(bReversals && MACD[i]>0 && MACD[i+1]<0);
      bool bReversals_Sell=(bReversals && MACD[i]<0 && MACD[i+1]>0);

      bool bMainSignal_Buy  = (bMainSignal &&  (MACD[i]-MACDSignal[i])>0 && (MACD[i+1]-MACDSignal[i+1])<0);
      bool bMainSignal_Sell = (bMainSignal && (MACD[i]-MACDSignal[i])<0 && (MACD[i+1]-MACDSignal[i+1])>0);

      bool bOC_Buy  = (bReversals_Buy || bMainSignal_Buy);
      bool bOC_Sell = (bReversals_Sell || bMainSignal_Sell);

      //Reset
      if(!bOC_Buy && !bOC_Sell)
        {
         Trend[i]=Trend[i+1];
         Signal[i]=EMPTY_VALUE;
         BuySignal[i]=0;
         SellSignal[i]=0;
        }

      //Buy Condition 
      if(bOC_Buy)
        {
         Trend[i]=OP_BUY;
         Signal[i]=OP_BUY;
         BuySignal[i]=1;
         if(eMarkSignals==1 && !(ObjectFind(0,short_name+(string)time[i])>=0))
            ArrowCreate(0,short_name+(string)time[i],0,time[i],low[i]-iAOffset*PipsPoint,233,ANCHOR_TOP,cUpCandle,0,1,false,false,false);
         if(eMarkSignals==2 && !(ObjectFind(0,short_name+(string)time[i])>=0))
           {
            ObjectCreate(0,short_name+(string)time[i],OBJ_VLINE,0,time[i],close[i]);
            ObjectSetInteger(0,short_name+(string)time[i],OBJPROP_COLOR,cUpCandle);
           }
        }

      //Sell Condition 
      if(bOC_Sell)
        {
         Trend[i]=OP_SELL;
         Signal[i]=OP_SELL;
         SellSignal[i]=1;
         if(eMarkSignals==1 && !(ObjectFind(0,short_name+(string)time[i])>=0))
            ArrowCreate(0,short_name+(string)time[i],0,time[i],high[i]+iAOffset*PipsPoint,234,ANCHOR_BOTTOM,cDwnCandle,0,1,false,false,false);
         if(eMarkSignals==2 && !(ObjectFind(0,short_name+(string)time[i])>=0))
           {
            ObjectCreate(0,short_name+(string)time[i],OBJ_VLINE,0,time[i],close[i]);
            ObjectSetInteger(0,short_name+(string)time[i],OBJPROP_COLOR,cDwnCandle);
           }
        }

      //final cut, delete false arrows
      if(Signal[i]==EMPTY_VALUE && (ObjectFind(0,short_name+(string)time[i])>=0))
         ObjectDelete(0,short_name+(string)time[i]);

     }
//Alert Settings 
   if(Signal[iAlerti]==OP_BUY)
     {
      string sMsg=short_name+" "+_Symbol+"\n "+"Buy Alert: "+ChartPeriodString(_Period)
                  +"\n "+"Time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
      string sSub=short_name+" "+_Symbol+" "+"Buy Alert: "+ChartPeriodString(_Period);
      SendAlert(bAlertM,bAlertS,bAlertE,sMsg,sSub);
     }

   if(Signal[iAlerti]==OP_SELL)
     {
      string sMsg=short_name+" "+_Symbol+"\n "+"Sell Alert: "+ChartPeriodString(_Period)
                  +"\n "+"Time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
      string sSub=short_name+" "+_Symbol+" "+"Sell Alert: "+ChartPeriodString(_Period);
      SendAlert(bAlertM,bAlertS,bAlertE,sMsg,sSub);
     }

//--- return value of prev _calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Create the arrow                                                 |
//| copied from https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_arrow
//+------------------------------------------------------------------+
bool ArrowCreate(const long              chart_ID=0,           // chart's ID
                 const string            name="Arrow",         // arrow name
                 const int               sub_window=0,         // subwindow index
                 datetime                time=0,               // anchor point time
                 double                  price=0,              // anchor point price
                 const uchar             arrow_code=252,       // arrow code
                 const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor point position
                 const color             clr=clrRed,           // arrow color
                 const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                 const int               width=3,              // arrow size
                 const bool              back=false,           // in the background
                 const bool              selection=true,       // highlight to move
                 const bool              hidden=true,          // hidden in the object list
                 const long              z_order=0)            // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create an arrow
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ",GetLastError());
      return(false);
     }
//--- set the arrow code
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,arrow_code);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set the arrow color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the arrow's size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the arrow by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| copied from https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_arrow  |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ChartPeriodString(int iperiod)
  {
   switch(iperiod)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN1");
      default: return("M"+IntegerToString(iperiod));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(bool bMobile,bool bScreen,bool bEmail,string sMsg,string sSub)
  {
   if(bMobile || bScreen || bEmail)
     {
      if(sMsg!="")
        {
         if(prevTime<iTime(_Symbol,_Period,0))
           {
            prevTime=iTime(_Symbol,_Period,0);
            if(bMobile) SendNotification(sSub);
            if(bScreen) Alert(sSub);
            if(bEmail) SendMail(sSub,sMsg);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| use PipsPoint to use this function                              |
//+------------------------------------------------------------------+
double Get_PipsPoint()
  {
   double PP=(_Digits==5 || _Digits==3)?_Point*10:_Point;
   return (PP);
  }
//+------------------------------------------------------------------+
//| use PipsValue to use this function                              |
//+------------------------------------------------------------------+
double Get_PipsValue()
  {
   double PV=(MarketInfo(_Symbol,MODE_TICKVALUE)*PipsPoint)/MarketInfo(_Symbol,MODE_TICKSIZE);
   return(PV);
  }
//+------------------------------------------------------------------+
