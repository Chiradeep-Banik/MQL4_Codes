//+------------------------------------------------------------------+
//|                                               ParabolicAlert.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property version     "1.00"
#property description "Parabolic Stop-And-Reversal system with Alert"
#property description "Added Alert and modify by Roberto Jacobs 3rjfx @ 2018/09/26"
#property strict
//---
enum YN
 {
   No,
   Yes
 };
//--
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  Lime
//--- input parameters
input double    InpSARStep = 0.02;    // Step
input double InpSARMaximum = 0.2;     // Maximum
input YN            alerts = Yes;     // Display Alerts / Messages (Yes) or (No)
input YN        EmailAlert = No;      // Email Alert (Yes) or (No)
input YN       displayinfo = Yes;     // Display Trade Info
//---- buffers
double       ExtSARBuffer[];
//--- global variables
double       ExtSarStep;
double       ExtSarMaximum;
int          ExtLastReverse;
bool         ExtDirectionLong;
double       ExtLastStep,ExtLastEP,ExtLastSAR;
double       ExtLastHigh,ExtLastLow;
//---
int cur,prv;
int cmnt,pmnt;
string posisi,
       sigpos,
       msgText;
//-------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- checking input data
   if(InpSARStep<0.0)
     {
      ExtSarStep=0.02;
      Print("Input parametr InpSARStep has incorrect value. Indicator will use value ",
            ExtSarStep," for calculations.");
     }
   else
      ExtSarStep=InpSARStep;
   if(InpSARMaximum<0.0)
     {
      ExtSarMaximum=0.2;
      Print("Input parametr InpSARMaximum has incorrect value. Indicator will use value ",
            ExtSarMaximum," for calculations.");
     }
   else
      ExtSarMaximum=InpSARMaximum;
//--- drawing settings
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
//---- indicator buffers
   SetIndexBuffer(0,ExtSARBuffer);
//--- set short name
   IndicatorShortName("SAR("+DoubleToString(ExtSarStep,2)+","+DoubleToString(ExtSarMaximum,2)+")");
//--- set global variables
   ExtLastReverse=0;
   ExtDirectionLong=false;
   ExtLastStep=ExtLastEP=ExtLastSAR=0.0;
   ExtLastHigh=ExtLastLow=0.0;
//----
  }
//---------//
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
    Comment("");
    ObjectsDeleteAll();
    GlobalVariablesDeleteAll();
    //--
//----
   return;
  }
//---------//
//+------------------------------------------------------------------+
//| Parabolic SAR                                                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   bool   dir_long;
   double last_high,last_low,ep,sar,step;
   int    i;
//--- check for minimum rates count
   if(rates_total<3)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtSARBuffer,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
//--- detect current position for calculations 
   i=prev_calculated-1;
//--- calculations from start?
   if(i<1)
     {
      ExtLastReverse=0;
      dir_long=true;
      step=ExtSarStep;
      last_high=-10000000.0;
      last_low=10000000.0;
      sar=0;
      i=1;
      while(i<rates_total-1)
        {
         ExtLastReverse=i;
         if(last_low>low[i])
            last_low=low[i];
         if(last_high<high[i])
            last_high=high[i];
         if(high[i]>high[i-1] && low[i]>low[i-1])
            break;
         if(high[i]<high[i-1] && low[i]<low[i-1])
           {
            dir_long=false;
            break;
           }
         i++;
        }
      //--- initialize with zero
      ArrayInitialize(ExtSARBuffer,0.0);
      //--- go check
      if(dir_long)
        {
         ExtSARBuffer[i]=low[i-1];
         ep=high[i];
        }
      else
        {
         ExtSARBuffer[i]=high[i-1];
         ep=low[i];
        }
      i++;
     }
   else
     {
      //--- calculations to be continued. restore last values
      i=ExtLastReverse;
      step=ExtLastStep;
      dir_long=ExtDirectionLong;
      last_high=ExtLastHigh;
      last_low=ExtLastLow;
      ep=ExtLastEP;
      sar=ExtLastSAR;
     }
//---main cycle
   while(i<rates_total)
     {
      //--- check for reverse
      if(dir_long && low[i]<ExtSARBuffer[i-1])
        {
         SaveLastReverse(i,true,step,low[i],last_high,ep,sar);
         step=ExtSarStep;
         dir_long=false;
         ep=low[i];
         last_low=low[i];
         ExtSARBuffer[i++]=last_high;
         continue;
        }
      if(!dir_long && high[i]>ExtSARBuffer[i-1])
        {
         SaveLastReverse(i,false,step,last_low,high[i],ep,sar);
         step=ExtSarStep;
         dir_long=true;
         ep=high[i];
         last_high=high[i];
         ExtSARBuffer[i++]=last_low;
         continue;
        }
      //---
      sar=ExtSARBuffer[i-1]+step*(ep-ExtSARBuffer[i-1]);
      //--- LONG?
      if(dir_long)
        {
         if(ep<high[i])
           {
            if((step+ExtSarStep)<=ExtSarMaximum)
               step+=ExtSarStep;
           }
         if(high[i]<high[i-1] && i==2)
            sar=ExtSARBuffer[i-1];
         if(sar>low[i-1])
            sar=low[i-1];
         if(sar>low[i-2])
            sar=low[i-2];
         if(sar>low[i])
           {
            SaveLastReverse(i,true,step,low[i],last_high,ep,sar);
            step=ExtSarStep; dir_long=false; ep=low[i];
            last_low=low[i];
            ExtSARBuffer[i++]=last_high;
            continue;
           }
         if(ep<high[i])
            ep=last_high=high[i];
         //--
        }
      else // SHORT
        {
         if(ep>low[i])
           {
            if((step+ExtSarStep)<=ExtSarMaximum)
               step+=ExtSarStep;
           }
         if(low[i]<low[i-1] && i==2)
            sar=ExtSARBuffer[i-1];
         if(sar<high[i-1])
            sar=high[i-1];
         if(sar<high[i-2])
            sar=high[i-2];
         if(sar<high[i])
           {
            SaveLastReverse(i,false,step,last_low,high[i],ep,sar);
            step=ExtSarStep;
            dir_long=true;
            ep=high[i];
            last_high=high[i];
            ExtSARBuffer[i++]=last_low;
            continue;
           }
         if(ep>low[i])
            ep=last_low=low[i];
         //--
        }
      ExtSARBuffer[i++]=sar;
     }
   //--
   if(alerts==Yes||EmailAlert==Yes) Do_Alerts();
   //---
   if(displayinfo==Yes) ChartComm();
     //---
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//-------//
//+------------------------------------------------------------------+
//|  save last values to continue further calculations               |
//+------------------------------------------------------------------+
void SaveLastReverse(int reverse,bool dir,double step,double last_low,double last_high,double ep,double sar)
  {
   ExtLastReverse=reverse;
   if(ExtLastReverse<2)
      ExtLastReverse=2;
   ExtDirectionLong=dir;
   ExtLastStep=step;
   ExtLastLow=last_low;
   ExtLastHigh=last_high;
   ExtLastEP=ep;
   ExtLastSAR=sar;
  }
//-------//

void Do_Alerts(void)
  {
    //--
    cmnt=Minute();
    if(cmnt!=pmnt)
      {
        //--
        if(iSAR(_Symbol,0,InpSARStep,InpSARMaximum,0)<Low[0])  cur=1;
        if(iSAR(_Symbol,0,InpSARStep,InpSARMaximum,0)>High[0]) cur=-1;
        //--
        if(cur==1)
          {
            msgText="Parabolic Trend was Up";
            posisi="Bullish"; 
            sigpos="Open BUY Order";
          }
        if(cur==-1)
          {
            msgText="Parabolic Trend was Down";
            posisi="Bearish"; 
            sigpos="Open SELL Order";
          }
        //--
        if(cur!=prv)
          {
            Print("--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                  "\n--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES));
            //--
            if(alerts==Yes)
              Alert("--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                    "--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES));
            //--
            if(EmailAlert==Yes) 
              SendMail(WindowExpertName(),"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES));
            //--
            prv=cur;
          }
        //--
        pmnt=cmnt;
      }
    //--
    return;
    //---
  }
//---------//

string TF2Str(int period)
  {
   switch(period)
     {
       //--
       case PERIOD_M1: return("M1");
       case PERIOD_M5: return("M5");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_H1: return("H1");
       case PERIOD_H4: return("H4");
       case PERIOD_D1: return("D1");
       case PERIOD_W1: return("W1");
       case PERIOD_MN1: return("MN");
       //--
     }
   return(string(period));
  }  
//---------//

string AccountMode() // function: to known account trade mode
   {
//----
//--- Demo, Contest or Real account 
   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
 //---
   string trade_mode;
   //--
   switch(account_type) 
     { 
      case  ACCOUNT_TRADE_MODE_DEMO: 
         trade_mode="Demo"; 
         break; 
      case  ACCOUNT_TRADE_MODE_CONTEST: 
         trade_mode="Contest"; 
         break; 
      default: 
         trade_mode="Real"; 
         break; 
     }
   //--
   return(trade_mode);
//----
   } //-end AccountMode()
//---------//

void ChartComm() // function: write comments on the chart
  {
//----
   //--
   Comment("\n     :: Server Date Time : ",(string)Year(),".",(string)Month(),".",(string)Day(), "   ",TimeToString(TimeCurrent(),TIME_SECONDS), 
      "\n     ------------------------------------------------------------", 
      "\n      :: Broker             :  ", TerminalCompany(), 
      "\n      :: Acc. Name       :  ", AccountName(), 
      "\n      :: Acc, Number    :  ", (string)AccountNumber(),
      "\n      :: Acc,TradeMode :  ", AccountMode(),
      "\n      :: Acc. Leverage   :  1 : ", (string)AccountLeverage(), 
      "\n      :: Acc. Balance     :  ", DoubleToString(AccountBalance(),2),
      "\n      :: Acc. Equity       :  ", DoubleToString(AccountEquity(),2), 
      "\n     --------------------------------------------",
     "\n      :: Indicator Name  :  ",WindowExpertName(),
      "\n      :: Currency Pair    :  ",_Symbol,
      "\n      :: Current Spread  :  ",IntegerToString(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),0),
      "\n      :: BIG WAVES     :  ",posisi,
      "\n      :: Suggested         :  ",sigpos);
   //---
   ChartRedraw();
   return;
//----
  } //-end ChartComm()  
//---------//
//+------------------------------------------------------------------+
