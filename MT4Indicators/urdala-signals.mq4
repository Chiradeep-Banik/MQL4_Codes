//+------------------------------------------------------------------+
//|                                                    Urdala_MA.mq4 |
//|                                        Сергей (urdala) Рашевский |
//|                                        http://urdala-forex.at.ua |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_style1 2
#property indicator_color2 Red
#property indicator_style2 2
#property indicator_color3 Red
#property indicator_style3 2
#property indicator_color4 Red
#property indicator_style4 2
#property indicator_color5 Red
#property indicator_style5 2


extern bool HourMA   = true;//индикация средней за час
extern bool DayMa    = true;//индикация средней за день
extern bool WeekMA   = true;//индикация средней за неделю
extern bool MonthMA  = true;//индикация средней за месяц
extern bool YearMA   = true;//индикация средней за год
extern int MinPeriod = 5;   //минимальный период
extern int MaxPeriod = 300; //максимальный мериод

double MAH[],MAD[],MAW[],MAM[],MAY[];
int PeriodH,PeriodD,PeriodW,PeriodM,PeriodY;
int i,i1;
///////////////////////////////////////////////////////////////////////
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MAH);
   PeriodH=PeriodFunc(3600);
   SetIndexLabel(0,"Hour_"+PeriodH);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MAD);
   PeriodD=PeriodFunc(86400);
   SetIndexLabel(1,"Day_"+PeriodD);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,MAW);
   PeriodW=PeriodFunc(604800);
   SetIndexLabel(2,"Week_"+PeriodW);

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,MAM);
   PeriodM=PeriodFunc(2592000);
   SetIndexLabel(3,"Month_"+PeriodM);

   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,MAY);
   PeriodY=PeriodFunc(31536000);
   SetIndexLabel(4,"Year_"+PeriodY);
   
   return(0);
  }
////////////////////////////////////////////////////////////////////////
int deinit()
  {
   
   return(0);
  }
////////////////////////////////////////////////////////////////////////
int start()
  {
   int pos=Bars-IndicatorCounted()-1;
   for (i=0;i<=pos;i++)
      {
       if(PeriodH>=MinPeriod && PeriodH<=MaxPeriod && HourMA)MAH[i]=SMA(i,PeriodH);
       if(PeriodD>=MinPeriod && PeriodD<=MaxPeriod && DayMa)MAD[i]=SMA(i,PeriodD);
       if(PeriodW>=MinPeriod && PeriodW<=MaxPeriod && WeekMA)MAW[i]=SMA(i,PeriodW);
       if(PeriodM>=MinPeriod && PeriodM<=MaxPeriod && MonthMA)MAM[i]=SMA(i,PeriodM);
       if(PeriodY>=MinPeriod && PeriodY<=MaxPeriod && YearMA)MAY[i]=SMA(i,PeriodY);
      }
   return(0);
  }
/////////////////////////////////////////////////////////////////////////
double SMA(int sh, int per)
   {
    double sma=0;
    if (Bars<=sh+per)return(EMPTY_VALUE);
    for(i1=sh; i1<sh+per; i1++)
      {
       sma+=Close[i1];
      }
    return(NormalizeDouble(sma/per,Digits));
   }
//////////////////////////////////////////////////////////////////////////
int PeriodFunc(int second)
   {
    int per,sh;
    while(!IsStopped())
      {
       per=iBarShift(Symbol(),NULL,Time[sh]-second,true);
       if(per>0)break;
       if(sh>=Bars)break;
       sh++;
      }
    return(per);
   }