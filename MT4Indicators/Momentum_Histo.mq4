//+------------------------------------------------------------------+
//|                                               Momentum_Histo.mq4 |
//|                                              Besarion Turmanauli |
//|                             https://www.mql5.com/en/users/dos.ge |
//+------------------------------------------------------------------+
#property copyright "Besarion Turmanauli"
#property link      "https://www.mql5.com/en/users/dos.ge"
#property version   "1.10"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_width1 3
#property indicator_width2 3
#property indicator_level1 0
#property indicator_levelcolor clrBlue
#property indicator_levelwidth 2
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IndList
  {
   IndList1 = 1, //Momentum
   IndList2 = 2, //ATR (Average True Range)
   IndList3 = 3, //CCI (Commodity Channel Index)
   IndList4 = 4  //RSI (Relative Strength Index)
  };

//--- input parameter
input IndList MName= 1;//Indicator Name
input int MPeriod = 14;//Indicator Period
input double MLevel=100.0;//Level indicator
input ENUM_APPLIED_PRICE MAppliedPrice=PRICE_CLOSE;//Applied Price for Momentum, CCI or RSI
input bool Alerts= false;//Enable Alerts
input bool Email = false;//Enable Email Notification
input bool Push=false;//Enable Push Notifiction
string selectedName="Momentum";
//--- buffers
double BU0[],BU1[];
int initial_limit=0;
double par=0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string short_name;

   if(MName == 2){selectedName = "ATR";}else
   if(MName == 3){selectedName = "CCI";}else
   if(MName == 4){selectedName = "RSI";}

   short_name=selectedName+"_Histo("+IntegerToString(MPeriod)+") ";
   IndicatorShortName(short_name);

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,BU0);
   SetIndexLabel(0,"UP");

   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,BU1);
   SetIndexLabel(1,"DN");

   if(MPeriod<=0)
     {
      Print("Wrong input parameter "+selectedName+" Period=",MPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,MPeriod);
   SetIndexDrawBegin(1,MPeriod);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   int i,// Bar index
   Counted_bars; // Number of counted bars

   Counted_bars=IndicatorCounted(); // Number of counted bars
   i=Bars-Counted_bars-1;  // Index of the first uncounted

   if(initial_limit==0){initial_limit=i;}

   if(Bars<=MPeriod || MPeriod<=0)return(0);


   while(i>0) // Loop for uncounted bars
     {

      if(MName == 1){par=iMomentum(Symbol(),Period(),MPeriod,MAppliedPrice,i)-MLevel; }else
      if(MName == 2){par=iATR(Symbol(),Period(),MPeriod,i)-MLevel;}else
      if(MName == 3){par=iCCI(Symbol(),Period(),MPeriod,MAppliedPrice,i)-MLevel;}else
      if(MName == 4){par=iRSI(Symbol(),Period(),MPeriod,MAppliedPrice,i)-MLevel;}


      if(par>0)
        {

         BU0[i]=par;

         if(i<initial_limit && i==1 && BU0[i+1]==EMPTY_VALUE)BuySignal(selectedName);
           }else{

         BU1[i]=par;

         if(i<initial_limit && i==1 && BU1[i+1]==EMPTY_VALUE)SellSignal(selectedName);
        }

      i--; //Calculating index of the next bar

     }//end while
   return(0);
  }
//+------------------------------------------------------------------+

void SellSignal(string _Name)
  {
   if(Alerts)Alert(_Name+"_Histo: SELL SIGNAL ON "+Symbol());
   if(Email)SendMail(_Name+"_Histo: SELL SIGNAL ON "+Symbol(),"Signal Sent From "+_Name+"_Histo Indicator");
   if(Push)SendNotification(_Name+"_Histo: SELL SIGNAL ON "+Symbol());
  }
//+------------------------------------------------------------------+

void BuySignal(string _Name)
  {
   if(Alerts)Alert(_Name+"_Histo: BUY SIGNAL ON "+Symbol());
   if(Email)SendMail(_Name+"_Histo: BUY SIGNAL ON "+Symbol(),"Signal Sent From "+_Name+"_Histo Indicator");
   if(Push)SendNotification(_Name+"_Histo: BUY SIGNAL ON "+Symbol());
  }
//+------------------------------------------------------------------+
