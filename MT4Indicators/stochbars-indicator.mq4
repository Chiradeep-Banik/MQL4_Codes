//+-------------------------------------------------------------------+
//|                                       4TFStochBars modified from: |
//|MTF NonLagMAv7.1_4TF_BarM  based on    MTF_MegaTrend_Bar_4TFNextM5 | 
//|                     from STEINITZ lee_yan_cn mod N4TF HAS Bar.mq4 |
//|                   Modified by Matsu, from #MTF Supertrend Bar.mq4 |
//| Forex-TSD.com                      Copyright © 2006-07, Eli hayun |
//|                                           http://www.elihayun.com |
//+-------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 5.5
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 Red
#property indicator_color6 Lime
#property indicator_color7 Red
#property indicator_color8 Lime

//---- parameters
extern string note1 = "Stochastic settings";
extern int       KPeriod     =  14;
extern int       DPeriod     =  3;
extern int       Slowing     =  3;
extern string note2 = "0=sma, 1=ema, 2=smma, 3=lwma";
extern int       MAMethod    =   0;
extern string note3 = "0=high/low, 1=close/close";
extern int       PriceField  =   0;
extern string note4 = "use WingDings font";
extern int BarSymbol = 110;

extern int BarWidth = 0;
extern color BarColorUp = Lime;
extern color BarColorDown = Red;
extern color TextColor = Blue;
extern int MaxBars=150;
extern int UniqueNum = 1963;

double Gap = 1; // Gap between the lines of bars
//---- buffers
double buf4_up[];
double buf4_down[];
double buf3_up[];
double buf3_down[];
double buf2_up[];
double buf2_down[];
double buf1_up[];
double buf1_down[];
double percentK;
double percentD;
string shortname = "";

int Period_1, Period_2, Period_3, Period_4;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_ARROW,0,BarWidth,BarColorUp);
   SetIndexArrow(0,BarSymbol);
   SetIndexBuffer(0,buf1_up);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW,0,BarWidth,BarColorDown);
   SetIndexArrow(1,BarSymbol);
   SetIndexBuffer(1,buf1_down);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(2,DRAW_ARROW,0,BarWidth,BarColorUp);
   SetIndexArrow(2,BarSymbol);
   SetIndexBuffer(2,buf2_up);
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_ARROW,0,BarWidth,BarColorDown);
   SetIndexArrow(3,BarSymbol);
   SetIndexBuffer(3,buf2_down);
   SetIndexEmptyValue(3,0.0);
   SetIndexStyle(4,DRAW_ARROW,0,BarWidth,BarColorUp);
   SetIndexArrow(4,BarSymbol);
   SetIndexBuffer(4,buf3_up);
   SetIndexEmptyValue(4,0.0);
   SetIndexStyle(5,DRAW_ARROW,0,BarWidth,BarColorDown);
   SetIndexArrow(5,BarSymbol);
   SetIndexBuffer(5,buf3_down);
   SetIndexEmptyValue(5,0.0);
   SetIndexStyle(6,DRAW_ARROW,0,BarWidth,BarColorUp);
   SetIndexArrow(6,BarSymbol);
   SetIndexBuffer(6,buf4_up);
   SetIndexEmptyValue(6,0.0);
   SetIndexStyle(7,DRAW_ARROW,0,BarWidth,BarColorDown);
   SetIndexArrow(7,BarSymbol);
   SetIndexBuffer(7,buf4_down);
   SetIndexEmptyValue(7,0.0);
   
   
   IndicatorDigits(0);
   getPeriod();
   shortname = "StochBars ("+KPeriod+","+DPeriod+","+Slowing+")";   
   IndicatorShortName(shortname);
 
   SetIndexLabel(0,"StochBars("+Period_1+")");
   SetIndexLabel(1,"StochBars("+Period_1+")");
   SetIndexLabel(2,"StochBars("+Period_2+")");
   SetIndexLabel(3,"StochBars("+Period_2+")");
   SetIndexLabel(4,"StochBars("+Period_3+")");
   SetIndexLabel(5,"StochBars("+Period_3+")");
   SetIndexLabel(6,"StochBars("+Period_4+")");
   SetIndexLabel(7,"StochBars("+Period_4+")");
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   //---- the last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars+Period_4/Period();
   int i,tf;

   //-------------------------------1----------------------------------------   
   double dif = Time[0] - Time[1];
   for ( i=ObjectsTotal()-1; i>-1; i--)
      {
         if (StringFind(ObjectName(i),"FF_"+UniqueNum+"_") >= 0)  ObjectDelete(ObjectName(i));
      }
   double shift = 0.2;
   for ( tf=1; tf<=4; tf++)
      {  
         string txt = "??";
         double gp;
         switch (tf)
         {
             case 1: txt = tf2txt(Period_1);  gp = 1 + Gap*3 + shift; break;
             case 2: txt = tf2txt(Period_2);  gp = 1 + Gap*2 + shift; break;
             case 3: txt = tf2txt(Period_3);  gp = 1 + Gap + shift; break;
             case 4: txt = tf2txt(Period_4);  gp = 1.5 + shift; break;
         }
         string name = "FF_"+UniqueNum+"_"+tf+"_"+txt;
         ObjectCreate(name, OBJ_TEXT, WindowFind(shortname), iTime(NULL,0,0)+dif*3, gp);
         ObjectSetText(name, txt,8,"Arial", TextColor);
      }
   //-------------------------------2----------------------------------------
   datetime TimeArray_1[], TimeArray_2[], TimeArray_3[], TimeArray_4[];
   ArrayCopySeries(TimeArray_1,MODE_TIME,Symbol(),Period_1);
   ArrayCopySeries(TimeArray_2,MODE_TIME,Symbol(),Period_2);
   ArrayCopySeries(TimeArray_3,MODE_TIME,Symbol(),Period_3); 
   ArrayCopySeries(TimeArray_4,MODE_TIME,Symbol(),Period_4);
   
   int  i1=0, i2=0, i3=0, i4=0, yy;

   for(i=0, i1=0,  i2=0,  i3=0,  i4=0;i<limit;i++)
   {
      if (Time[i]<TimeArray_1[i1]) i1++;
      if (Time[i]<TimeArray_2[i2]) i2++;
      if (Time[i]<TimeArray_3[i3]) i3++;
      if (Time[i]<TimeArray_4[i4]) i4++;

      for ( tf = 1; tf <= 4; tf++)
      {
         int prd;
         switch (tf)
         {
            case 1: prd = Period_1; yy = i1;  break;
            case 2: prd = Period_2; yy = i2;  break;
            case 3: prd = Period_3; yy = i3;   break;
            case 4: prd = Period_4; yy = i4;   break;
         }
            percentD = iStochastic(NULL,prd,KPeriod,DPeriod,Slowing,MAMethod,PriceField,MODE_MAIN,yy);
            percentK = iStochastic(NULL,prd,KPeriod,DPeriod,Slowing,MAMethod,PriceField,MODE_SIGNAL,yy);
            
         switch (tf)
         {  case 4: buf4_down[i]=EMPTY_VALUE;buf4_up[i]=EMPTY_VALUE;  if (percentK>=percentD)  buf4_down[i] = 1;           else buf4_up[i] = 1;           break;
            case 3: buf3_down[i]=EMPTY_VALUE;buf3_up[i]=EMPTY_VALUE; if (percentK>=percentD)  buf3_down[i] = 1 + Gap * 1; else buf3_up[i] = 1 + Gap * 1; break;
            case 2: buf2_down[i]=EMPTY_VALUE;buf2_up[i]=EMPTY_VALUE; if (percentK>=percentD)  buf2_down[i] = 1 + Gap * 2; else buf2_up[i] = 1 + Gap * 2; break;
            case 1: buf1_down[i]=EMPTY_VALUE;buf1_up[i]=EMPTY_VALUE; if (percentK>=percentD)  buf1_down[i] = 1 + Gap * 3; else buf1_up[i] = 1 + Gap * 3; break;
         }
      }
   }

   return(0);
  }
  
//+------------------------------------------------------------------+
void getPeriod()
{
   switch(Period()) 
      {
         case 1: 
            Period_1=1; Period_2=5; Period_3=15; Period_4=30;
            break;
         case 5: 
            Period_1=5; Period_2=15; Period_3=30; Period_4=60;
            break;
         case 15: 
            Period_1=15; Period_2=30; Period_3=60; Period_4=240;
            break;
         case 30: 
            Period_1=30; Period_2=60; Period_3=240; Period_4=1440;
            break;
         case 60: 
            Period_1=60; Period_2=240; Period_3=1440; Period_4=10080;
            break;
         case 240: 
            Period_1=240; Period_2=1440; Period_3=10080; Period_4=43200;
            break;
         case 1440: 
            Period_1=1440; Period_2=10080; Period_3=43200; Period_4=43200;
            break;
         case 10080: 
            Period_1=10080; Period_2=43200; Period_3=43200; Period_4=43200;
            break;
         case 43200: 
            Period_1=43200; Period_2=43200; Period_3=43200; Period_4=43200;
            break;
         
      }
}

string tf2txt(int tf)
{
   if (tf == PERIOD_M1)    return("M1");
   if (tf == PERIOD_M5)    return("M5");
   if (tf == PERIOD_M15)   return("M15");
   if (tf == PERIOD_M30)   return("M30");
   if (tf == PERIOD_H1)    return("H1");
   if (tf == PERIOD_H4)    return("H4");
   if (tf == PERIOD_D1)    return("D1");
   if (tf == PERIOD_W1)    return("W1");
   if (tf == PERIOD_MN1)   return("MN");
  
  //----  Refresh buffers ++++++++++++++++++++ upgrade by Raff  
   int TimeFrame,TimeArray[],i;
   if (TimeFrame>Period()) {
     int PerINT=TimeFrame/Period()+1;
     datetime TimeArr[]; ArrayResize(TimeArr,PerINT);
     ArrayCopySeries(TimeArr,MODE_TIME,Symbol(),Period()); 
     for(i=0;i<PerINT+1;i++) {if (TimeArr[i]>=TimeArray[0]) {
 /********************************************************  
    Refresh buffers:         buffer[i] = buffer[0];
 ********************************************************/  
buf4_up[i]=buf4_up[0];
buf4_down[i]=buf4_down[0];
buf3_up[i]=buf3_up[0];
buf3_down[i]=buf3_down[0];
buf2_up[i]= buf2_up[0];
buf2_down[i]= buf2_down[0];
buf1_up[i]=buf1_up[0];
buf1_down[i]= buf1_down[0];

//----
   } } }
//+++++++++++++++++++++++++++++++++++++++++++++++ Raff  
 
//+-------------
  
   return("??");
}


