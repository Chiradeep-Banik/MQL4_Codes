

//+------------------------------------------------------------------------+
//|                                        Phoenix_4_CONTEST_indicator.ex4 |
//|                                         Copyright © 2006, fryk@tlen.pl |
//| This indicator is based on Phoenix_v4_2_CONTEST.mq4 EA © 2006 Hendrick |
//+------------------------------------------------------------------------+
#property copyright ""
 
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
 
 
 
double ExtMapBuffer1[];
double ExtMapBuffer2[];
 
 
 
extern int        SMAPeriod        = 7;
extern int        SMA2Bars         = 14;
extern double     Percent          = 0.0032;
extern int        EnvelopePeriod   = 2;
extern int        OSMAFast         = 5;
extern int        OSMASlow         = 30;
extern double     OSMASignal       = 2;
 
extern int        Fast_Period      = 25;
extern int        Fast_Price       = PRICE_OPEN;
extern int        Slow_Period      = 15;
extern int        Slow_Price       = PRICE_OPEN;
extern double     DVBuySell        = 0.003;
extern double     DVStayOut        = 0.024;
 
extern bool       PrefSettings            = true; 
 
double divergence(int F_Period, int S_Period, int F_Price, int S_Price, int mypos)
  {
    int i;
//----
    double maF1, maF2, maS1, maS2;
    double dv1, dv2;
//----
    maF1 = iMA(Symbol(), 0, F_Period, 0, MODE_SMA, F_Price, mypos);
    maS1 = iMA(Symbol(), 0, S_Period, 0, MODE_SMA, S_Price, mypos);
    dv1 = (maF1 - maS1);
 
    maF2 = iMA(Symbol(), 0, F_Period, 0, MODE_SMA, F_Price, mypos + 1);
    maS2 = iMA(Symbol(), 0, S_Period, 0, MODE_SMA, S_Price, mypos + 1);
    dv2 = ((maF1 - maS1) - (maF2 - maS2));
//----
    return(dv1 - dv2);
  }
 
int nShift=0;
 
int init()
  {
    SetIndexStyle(0, DRAW_ARROW, 0, 1);
    SetIndexArrow(0, 233);
    SetIndexBuffer(0, ExtMapBuffer1);
    SetIndexStyle(1, DRAW_ARROW, 0, 1);
    SetIndexArrow(1, 234);
    SetIndexBuffer(1, ExtMapBuffer2);
    
    if(PrefSettings == true)
{
   if((Symbol() == "USDJPY") || (Symbol() == "USDJPYm"))
      {     
      
      Percent              = 0.0032;
      EnvelopePeriod       = 2;
      SMAPeriod            = 2;
      SMA2Bars             = 18;
      OSMAFast             = 5;
      OSMASlow             = 22;
      OSMASignal           = 2;
      
      Fast_Period          = 25;
      Slow_Period          = 15;
      DVBuySell            = 0.0029;
      DVStayOut            = 0.024;
      }

   if((Symbol() == "EURJPY") || (Symbol() == "EURJPYm"))
      {  

      Percent              = 0.007;
      EnvelopePeriod       = 2;
      SMAPeriod            = 4;
      SMA2Bars             = 16;
      OSMAFast             = 11;
      OSMASlow             = 20;
      OSMASignal           = 14;
      
      Fast_Period          = 20;
      Slow_Period          = 10;
      DVBuySell            = 0.0078;
      DVStayOut            = 0.026;
      }

   if((Symbol() == "GBPJPY") || (Symbol() == "GBPJPYm"))
      {  
      Percent              = 0.0072;
      EnvelopePeriod       = 2;
      SMAPeriod            = 8;
      SMA2Bars             = 12;
      OSMAFast             = 5;
      OSMASlow             = 36;
      OSMASignal           = 10;
      
      Fast_Period          = 17;
      Slow_Period          = 28;
      DVBuySell            = 0.0034;
      DVStayOut            = 0.063;
      }
      
   if((Symbol() == "USDCHF") || (Symbol() == "USDCHFm"))
      {
      Percent              = 0.0056;
      EnvelopePeriod       = 10;
      SMAPeriod            = 5;
      SMA2Bars             = 9;
      OSMAFast             = 5;
      OSMASlow             = 12;
      OSMASignal           = 11;
      
      Fast_Period          = 5;
      Slow_Period          = 20;
      DVBuySell            = 0.00022;
      DVStayOut            = 0.0015;
      }
      
   if((Symbol() == "GBPUSD") || (Symbol() == "GBPUSDm"))
      {
      Percent              = 0.0023;
      EnvelopePeriod       = 6;
      SMAPeriod            = 3;
      SMA2Bars             = 14;
      OSMAFast             = 23;
      OSMASlow             = 17;
      OSMASignal           = 15;
      
      Fast_Period          = 25;
      Slow_Period          = 37;
      DVBuySell            = 0.00042;
      DVStayOut            = 0.05;
      }      
}
    
    
    switch(Period())
      {
        case     1: nShift = 1;   break;    
        case     5: nShift = 3;   break; 
        case    15: nShift = 5;   break; 
        case    30: nShift = 10;  break; 
        case    60: nShift = 15;  break; 
        case   240: nShift = 20;  break; 
        case  1440: nShift = 80;  break; 
        case 10080: nShift = 100; break; 
        case 43200: nShift = 200; break;               
      }
    return(0);
  }
int start()
  {
    int limit;
    int counted_bars = IndicatorCounted();
    if(counted_bars < 0) return(-1);
    if(counted_bars > 0) counted_bars--;
    limit = Bars - counted_bars;
    for(int i = 0; i < limit; i++)
      {
         bool BuySignal1=false, SellSignal1=false;
 
         double HighEnvelope1 = iEnvelopes(NULL,0,EnvelopePeriod,MODE_SMA,0,PRICE_CLOSE,Percent,MODE_UPPER,i+1);
         double LowEnvelope1  = iEnvelopes(NULL,0,EnvelopePeriod,MODE_SMA,0,PRICE_CLOSE,Percent,MODE_LOWER,i+1);
         double CloseBar1     = Close[i+1];
         
         if(CloseBar1 > HighEnvelope1) {SellSignal1 = true;} 
         if(CloseBar1 < LowEnvelope1)   {BuySignal1  = true;}
 
         bool BuySignal2=false, SellSignal2=false;
 
         double SMA1=iMA(NULL,0,SMAPeriod,0,MODE_SMA,5,i+1);
         double SMA2=iMA(NULL,0,SMAPeriod,0,MODE_SMA,5,i+SMA2Bars);
 
         if(SMA2-SMA1>0) {BuySignal2  = true;}
         if(SMA2-SMA1<0) {SellSignal2 = true;}
 
         bool BuySignal3=false, SellSignal3=false;
 
         double OsMABar2=iOsMA(NULL,0,OSMASlow,OSMAFast,OSMASignal,PRICE_CLOSE,i+2);
         double OsMABar1=iOsMA(NULL,0,OSMASlow,OSMAFast,OSMASignal,PRICE_CLOSE,i+1);
 
         if(OsMABar2 > OsMABar1)  {SellSignal3 = true;}
         if(OsMABar2 < OsMABar1)  {BuySignal3  = true;}
 
         double diverge;
         bool BuySignal4=false,SellSignal4=false;
 
         diverge = divergence(Fast_Period, Slow_Period, Fast_Price, Slow_Price,i);
 
         if(diverge >= DVBuySell && diverge <= DVStayOut)
             {BuySignal4 = true;}
         if(diverge <= (DVBuySell*(-1)) && diverge >= (DVStayOut*(-1))) 
             {SellSignal4 = true;} 
 
 
         if((SellSignal1==true) && (SellSignal2==true) && (SellSignal3==true) && (SellSignal4==true) )   
              {
                     ExtMapBuffer2[i] = High[i] + nShift*Point;
              }
 
         if((BuySignal1==true) && (BuySignal2==true) && (BuySignal3==true) && (BuySignal4==true) ) 
              {
                     ExtMapBuffer1[i] = Low[i] - nShift*Point;
              }
        
      }
//----
    return(0);
  }
//+------------------------------------------------------------------+