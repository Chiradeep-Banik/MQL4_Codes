//+------------------------------------------------------------------+
//|                                              KeltnerChannels.mq4 |
//|                   Copyright 2005-2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2005-2018, MetaQuotes Software Corp."
#property link        "https://www.mql5.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property description "Indicator Keltner Channels system with Alert"
#property description "Added Alert and modify by Roberto Jacobs 3rjfx @ 2018/12/05"
#property version     "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrAqua
#property indicator_color2 clrYellow
#property indicator_color3 clrMagenta
//---
enum YN
 {
   No,
   Yes
 };
//--
//--
input int                 period = 10;         // Amount of Periods Calculation
input YN                  alerts = Yes;        // Display Alerts / Messages (Yes) or (No)
input YN              EmailAlert = No;         // Email Alert (Yes) or (No)
input YN             displayinfo = Yes;        // Display Trade Info
//---
//--
double upper[], 
       middle[], 
       lower[];
//---
int cur,prv;
int cmnt,pmnt;
string posisi,
       sigpos,
       msgText;
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 
   //-- Indicator buffers mapping
   SetIndexBuffer(0,upper);
   SetIndexBuffer(1,middle);
   SetIndexBuffer(2,lower);
   //--
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,clrAqua);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,clrYellow);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,clrMagenta);
   //--
//---- name for DataWindow label
   SetIndexLabel(0,"KChanUp(" + string(period) + ")");    
   SetIndexLabel(1,"KChanMid(" + string(period) + ")"); 
   SetIndexLabel(2,"KChanLow(" + string(period) + ")");
   //--
   IndicatorShortName("KeltnerChannels("+string(period)+")");
   IndicatorDigits(Digits);
   //--
//---
   return(INIT_SUCCEEDED);
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
    int kcbars;
    double avg; 
    //--
//--- last counted bar will be recounted
    int limit=rates_total;
    if(prev_calculated==0) 
      limit=rates_total-prev_calculated;
    if(prev_calculated>0) limit--;
    kcbars=limit-period;
    //--
    ArrayResize(upper,limit);
    ArrayResize(middle,limit);
    ArrayResize(lower,limit);
    ArraySetAsSeries(upper,true);
    ArraySetAsSeries(middle,true);    
    ArraySetAsSeries(lower,true);
    //--
    for(int x=kcbars-1; x>=0; x--) 
      {
       middle[x] = iMA(_Symbol,0,period,0,MODE_SMA,PRICE_TYPICAL,x);
       avg = findAvg(period,x);
       upper[x] = middle[x]+avg;
       lower[x] = middle[x]-avg;
      }
    //--
   if(alerts==Yes||EmailAlert==Yes) Do_Alerts(middle[0],upper[0],lower[0]);
   //--
   if(displayinfo==Yes) ChartComm();
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------//

double findAvg(int peri,int shift) 
  {
//---
   double sum=0;
   for(int x=shift; x<(shift+peri); x++) 
     {     
       sum += iHigh(_Symbol,0,x) - iLow(_Symbol,0,x);
     }
   sum = sum / peri;
   //--
   return(sum);
//---
  } 
//---------//

void Do_Alerts(double& mid,double& up,double& lo)
  {
    //--
    cmnt=Minute();
    if(cmnt!=pmnt)
      {
        //--
        if((iClose(_Symbol,0,0)>up)&&(iSAR(_Symbol,0,0.02,0.2,0)<iLow(_Symbol,0,0)))  cur=2;
        else
        if((iClose(_Symbol,0,0)<lo)&&(iSAR(_Symbol,0,0.02,0.2,0)>iHigh(_Symbol,0,0))) cur=-2;
        else
        if((iClose(_Symbol,0,0)<up))  cur=1;
        else
        if((iClose(_Symbol,0,0)>lo)) cur=-1;
        else {posisi="Not Significant"; sigpos="Wait Confirmation"; msgText="Trend Sideways"+" - "+posisi+" - "+sigpos;}
        //--
        if(cur==2)
          {
            posisi="Bullish Strong"; 
            sigpos="Open BUY Order";
            msgText="Trend was Up"+" - "+posisi+" - "+sigpos;
          }
        if(cur==-2)
          {
            posisi="Bearish Strong"; 
            sigpos="Open SELL Order";
            msgText="Trend was Down"+" - "+posisi+" - "+sigpos;
          }
        if(cur==1)
          {
            posisi="Bullish Weak"; 
            sigpos="Wait Confirmation";
            msgText="Trend was Up"+" - "+posisi+" - "+sigpos;
          }
        if(cur==-1)
          {
            posisi="Bearish Weak"; 
            sigpos="Wait Confirmation";
            msgText="Trend was Down"+" - "+posisi+" - "+sigpos;
          }
        //--
        //---
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

string TF2Str(int peri)
  {
   switch(peri)
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
   return(string(peri));
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
