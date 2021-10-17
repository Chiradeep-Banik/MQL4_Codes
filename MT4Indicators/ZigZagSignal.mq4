//+------------------------------------------------------------------+
//|                                                 ZigZagSignal.mq4 |
//|                   Copyright 2005-2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2005-2018, MetaQuotes Software Corp."
#property link        "https://www.mql5.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property description "Indicator ZigZag System with Signal and Alert"
#property description "Added Alert and modify by Roberto Jacobs 3rjfx @ 2018/12/29"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
//--
enum YN
 {
   No,
   Yes
 };
//--
//---- indicator parameters
input int               InpDepth = 38;         // Depth
input int           InpDeviation = 17;         // Deviation
input int            InpBackstep = 11;         // Backstep
input YN                  alerts = Yes;        // Display Alerts / Messages (Yes) or (No)
input YN              EmailAlert = No;         // Email Alert (Yes) or (No)
input int             alertonbar = 3;          // Alert On Bar after Limit
input YN             displayinfo = Yes;        // Display Trade Info
//---
//---- indicator buffers
double ZZBufferHi[];
double ZZBufferLo[];
//--
datetime 
   fbartime,
   pbartime,
   cbartime;
int za,zb;
int cur=5,prv=2;
int cmnt,pmnt;
static int fbar;
string posisi,
       sigpos,
       msgText;
string iname;
static bool bull,bear;
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    IndicatorBuffers(2);
    SetIndexBuffer(0,ZZBufferHi);
    SetIndexBuffer(1,ZZBufferLo);
//---- drawing settings
    SetIndexStyle(0,DRAW_ARROW);
    SetIndexArrow(0,234);
    SetIndexStyle(1,DRAW_ARROW);
    SetIndexArrow(1,233);
//----
    //-- name for DataWindow
    SetIndexLabel(0,"Upper Limit");
    SetIndexLabel(1,"Lower Limit");
    //--
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
//---- indicator short name
    IndicatorDigits(_Digits);
    iname=WindowExpertName();
    IndicatorShortName(iname);
//---
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    Comment("");
    ObjectsDeleteAll();
    GlobalVariablesDeleteAll();
//----
   return(0);
  }
//---------//
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   //--
   int    shift,back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh=0.0,lastlow=0.0;
//--- check for history and inputs
   if(rates_total<InpDepth || InpBackstep>=InpDepth)
      return(0);
   //--
   for(shift=rates_total-InpDepth; shift>=0; shift--)
     {
      val=low[iLowest(_Symbol,0,MODE_LOW,InpDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((low[shift]-val)>(InpDeviation*_Point)) val=0.0;
         else
           {
            for(back=1; back<=InpBackstep; back++)
              {
               res=ZZBufferLo[shift+back];
               if((res!=0)&&(res>val)) ZZBufferLo[shift+back]=0.0; 
              }
           }
        } 
      ZZBufferLo[shift]=val;
      //--- high
      val=high[iHighest(_Symbol,0,MODE_HIGH,InpDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-high[shift])>(InpDeviation*_Point)) val=0.0;
         else
           {
            for(back=1; back<=InpBackstep; back++)
              {
               res=ZZBufferHi[shift+back];
               if((res!=0)&&(res<val)) ZZBufferHi[shift+back]=0.0; 
              } 
           }
        }
      ZZBufferHi[shift]=val;
     }
   //--
   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;
   //--
   for(shift=rates_total-InpDepth; shift>=0; shift--)
     {
      curlow=ZZBufferLo[shift];
      curhigh=ZZBufferHi[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ZZBufferHi[lasthighpos]=0;
            else ZZBufferHi[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ZZBufferLo[lastlowpos]=0;
            else ZZBufferLo[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
   //--
   for(shift=rates_total-1; shift>=0; shift--)
     {
      if(shift>=rates_total-InpDepth) ZZBufferLo[shift]=0.0;
      else
        {
         res=ZZBufferHi[shift];
         if(res!=0.0) ZZBufferHi[shift]=res;
        }
     }
   //--
   for(int zi=360; zi>=0 && !IsStopped(); zi--)
     {
       if(high[zi]==ZZBufferHi[zi]) za=zi;
       if(low[zi]==ZZBufferLo[zi]) zb=zi;
     }
   //--
   if(za<zb && za>alertonbar)
     {
       cbartime=time[za];
       fbar=iBarShift(_Symbol,0,cbartime,false); 
       cur=-1;
     }
   if(za>zb && zb>alertonbar)
     {
       cbartime=time[zb];
       fbar=iBarShift(_Symbol,0,cbartime,false); 
       cur=1;
     }
   //--
   if((alerts==Yes||EmailAlert==Yes)&&(cur!=0 && cbartime!=pbartime)) Do_Alerts(cur,fbar);
   if(displayinfo==Yes) ChartComm();
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------//
//+------------------------------------------------------------------+

void Do_Alerts(int fcur,int fb)
  {
    //--
    cmnt=Minute();
    if(cmnt!=pmnt)
      {
        //--
        if(fcur==1)
          {
            msgText="ZigZag Lower Limit Found"+" at bars: "+string(fb);
            posisi="Bullish"; 
            sigpos="Open BUY Order";
            fbartime=iTime(_Symbol,0,fb);
          }
        if(fcur==-1)
          {
            msgText="ZigZag Upper Limit Found"+" at bars: "+string(fb);
            posisi="Bearish"; 
            sigpos="Open SELL Order";
            fbartime=iTime(_Symbol,0,fb);
          }
        //--
        if(fcur!=prv || fbartime>pbartime)
          {
            Print(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                  "\n--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(alerts==Yes)
              Alert(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                    "--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(EmailAlert==Yes) 
              SendMail(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            prv=fcur;
            pbartime=fbartime;
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
     "\n      :: Indicator Name  :  ",iname,
      "\n      :: Currency Pair    :  ",_Symbol,
      "\n      :: Current Spread  :  ",IntegerToString(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),0),
      "\n      :: Signal Start       : at bar ",string(iBarShift(_Symbol,0,cbartime,false)),
      "\n      :: Indicator Signal  :  ",posisi,
      "\n      :: Suggested         :  ",sigpos);
   //---
   ChartRedraw();
   return;
//----
  } //-end ChartComm()  
//---------//