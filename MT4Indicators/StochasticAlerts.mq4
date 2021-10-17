//+------------------------------------------------------------------+
//|                                             StochasticAlerts.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2018, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property version     "1.00"
#property description "Stochastic Oscillator with Alerts"
#property description "Added Alert and modify by Roberto Jacobs 3rjfx @ 2018/09/26"
#property strict
//---
#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    2
#property indicator_color1     clrLightSeaGreen
#property indicator_color2     clrRed
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--
enum YN
 {
   No,
   Yes
 };
//--- input parameters
input int          InpKPeriod = 5;           // K Period
input int          InpDPeriod = 3;           // D Period
input int          InpSlowing = 3;           // Slowing
input YN    SoundAlerts       = Yes;         //Play Sound Alerts
input YN    UseAlerts         = Yes;         // Use Alerts
input YN    eMailAlerts       = No;          // Use Alerts via eMail
input YN    PushNotifications = No;          // Use Push Notifications
input YN          displayinfo = Yes;         // Display Trade Info
input string  SoundAlertFile  = "alert.wav"; // The Alerts Sound
//--- buffers
double ExtMainBuffer[];
double ExtSignalBuffer[];
double ExtHighesBuffer[];
double ExtLowesBuffer[];
//---
int draw_begin1=0;
int draw_begin2=0;
//---
//-- Alerts Variables
int cmnt;
int pmnt;
int cral;
int pral;
string alBase,alSubj,alMsg;
string posisi,
       sigpos,
       msgText;
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string short_name;
//--- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
   SetIndexBuffer(2, ExtHighesBuffer);
   SetIndexBuffer(3, ExtLowesBuffer);
//--- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, ExtMainBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, ExtSignalBuffer);
//--- name for DataWindow and indicator subwindow label
   short_name="StochAlert("+IntegerToString(InpKPeriod)+","+IntegerToString(InpDPeriod)+","+IntegerToString(InpSlowing)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Signal");
//---
   draw_begin1=InpKPeriod+InpSlowing;
   draw_begin2=draw_begin1+InpDPeriod;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);
//--- initialization done
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
//| Stochastic oscillator                                            |
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
   int    i,k,pos;
   cral=-1;
//--- check for bars count
   if(rates_total<=InpKPeriod+InpDPeriod+InpSlowing)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtMainBuffer,false);
   ArraySetAsSeries(ExtSignalBuffer,false);
   ArraySetAsSeries(ExtHighesBuffer,false);
   ArraySetAsSeries(ExtLowesBuffer,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(close,false);
//---
   pos=InpKPeriod-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         ExtLowesBuffer[i]=0.0;
         ExtHighesBuffer[i]=0.0;
        }
     }
//--- calculate HighesBuffer[] and ExtHighesBuffer[]
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      double dmin=1000000.0;
      double dmax=-1000000.0;
      for(k=i-InpKPeriod+1; k<=i; k++)
        {
         if(dmin>low[k])
            dmin=low[k];
         if(dmax<high[k])
            dmax=high[k];
        }
      ExtLowesBuffer[i]=dmin;
      ExtHighesBuffer[i]=dmax;
     }
//--- %K line
   pos=InpKPeriod-1+InpSlowing-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
         ExtMainBuffer[i]=0.0;
     }
//--- main cycle
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      double sumlow=0.0;
      double sumhigh=0.0;
      for(k=(i-InpSlowing+1); k<=i; k++)
        {
         sumlow +=(close[k]-ExtLowesBuffer[k]);
         sumhigh+=(ExtHighesBuffer[k]-ExtLowesBuffer[k]);
        }
      if(sumhigh==0.0)
         ExtMainBuffer[i]=100.0;
      else
         ExtMainBuffer[i]=sumlow/sumhigh*100.0;
     }
//--- signal
   pos=InpDPeriod-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
         ExtSignalBuffer[i]=0.0;
     }
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      double sum=0.0;
      for(k=0; k<InpDPeriod; k++)
         sum+=ExtMainBuffer[i-k];
      ExtSignalBuffer[i]=sum/InpDPeriod;
     }
   //---
   double stcm0=iStochastic(_Symbol,0,InpKPeriod,InpDPeriod,InpSlowing,MODE_SMA,0,MODE_MAIN,0);
   double stcs0=iStochastic(_Symbol,0,InpKPeriod,InpDPeriod,InpSlowing,MODE_SMA,0,MODE_SIGNAL,0);
   double stcm1=iStochastic(_Symbol,0,InpKPeriod,InpDPeriod,InpSlowing,MODE_SMA,0,MODE_MAIN,1);
   double stcs1=iStochastic(_Symbol,0,InpKPeriod,InpDPeriod,InpSlowing,MODE_SMA,0,MODE_SIGNAL,1);
   if((stcm1<=stcs1)&&(stcm0>stcs0)) cral=12;
   if((stcm1>=stcs1)&&(stcm0<stcs0)) cral=8;
   if((stcm1<=stcs1)&&(stcm0>stcs0)&&(stcm0>20.0)&&(stcs0<=20.0)) cral=11;
   if((stcm1>=stcs1)&&(stcm0<stcs0)&&(stcm0<80.0)&&(stcs0>=80.0)) cral=9;
   if(cral!=-1) pos_alerts(cral);
   if(displayinfo==Yes) ChartComm();
   //---
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+

void doAlerts(string msText,string eMailSub)
  {
    //--
    if(SoundAlerts==Yes) PlaySound(SoundAlertFile);
    if(UseAlerts==Yes) Alert(msText);
    if(eMailAlerts==Yes) SendMail(eMailSub,msText);
    if(PushNotifications==Yes) SendNotification(eMailSub);
    //--
  }
//---------//

string strTF(int period)
  {
   string periodcur;
   switch(period)
     {
       //--
       case PERIOD_M1: periodcur="M1"; break;
       case PERIOD_M5: periodcur="M5"; break;
       case PERIOD_M15: periodcur="M15"; break;
       case PERIOD_M30: periodcur="M30"; break;
       case PERIOD_H1: periodcur="H1"; break;
       case PERIOD_H4: periodcur="H4"; break;
       case PERIOD_D1: periodcur="D1"; break;
       case PERIOD_W1: periodcur="W1"; break;
       case PERIOD_MN1: periodcur="MN"; break;
       //--
     }
   //--
   return(periodcur);
  }  
//---------//

void pos_alerts(int alert)
   {
     //--
     cmnt=(int)Minute();
     if(cmnt!=pmnt)
       {
         //--
         if((cral!=pral)&&(alert==12))
           {     
             alBase="*"+WindowExpertName()+": "+_Symbol+", TF: "+strTF(_Period)+" @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
             alSubj=alBase+". Main Line change direction from Down";
             alMsg=alSubj+" to Up the Signal Line.!!";
             pral=cral;
             pmnt=cmnt;
             posisi="Bullish"; 
             sigpos="Open BUY Order";
             msgText="Trend was Up"+" - "+posisi+" - "+sigpos;
             doAlerts(alMsg,alSubj);
           }
         //--
         if((cral!=pral)&&(alert==8))
           {     
             alBase="*"+WindowExpertName()+": "+_Symbol+", TF: "+strTF(_Period)+" @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
             alSubj=alBase+". Main Line change direction from Up";
             alMsg=alSubj+" to Down the Signal Line.!!";
             pral=cral;
             pmnt=cmnt;
             posisi="Bearish"; 
             sigpos="Open SELL Order";
             msgText="Trend was Down"+" - "+posisi+" - "+sigpos;
             doAlerts(alMsg,alSubj);
           }
         //--
         //--
         if((cral!=pral)&&(alert==11))
           {     
             alBase="*"+WindowExpertName()+": "+_Symbol+", TF: "+strTF(_Period)+" @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
             alSubj=alBase+". Main Line change direction from Down";
             alMsg=alSubj+" to Up the Line 20.!!";
             pral=cral;
             pmnt=cmnt;
             posisi="Bullish"; 
             sigpos="Open BUY Order";
             msgText="Trend was Up"+" - "+posisi+" - "+sigpos;
             doAlerts(alMsg,alSubj);
           }
         //--
         if((cral!=pral)&&(alert==9))
           {     
             alBase="*"+WindowExpertName()+": "+_Symbol+", TF: "+strTF(_Period)+" @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
             alSubj=alBase+". Main Line change direction from Up";
             alMsg=alSubj+" to Down the Line 80.!!";
             pral=cral;
             pmnt=cmnt;
             posisi="Bearish"; 
             sigpos="Open SELL Order";
             msgText="Trend was Down"+" - "+posisi+" - "+sigpos;
             doAlerts(alMsg,alSubj);
           }
         //--
         //---
       }
     //--
     return;
     //--
   //----
   } //-end pos_alerts()
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