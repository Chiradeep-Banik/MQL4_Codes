//+------------------------------------------------------------------+
//|                                                   inside_bar.mq4 |
//|                                                  © Tecciztecatl  |
//+------------------------------------------------------------------+
#property copyright     "© Tecciztecatl 2016"
#property link          "https://www.mql5.com/en/users/tecciztecatl"
#property version       "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_width1 2
#property indicator_width2 2

//---- input parameters
extern ENUM_TIMEFRAMES TF_find=PERIOD_H1;   //Period to find Inside Bar

//---- buffers
double HighBuff[];
double LowBuff[];

double LastHigh;
double LastLow;
int    length=5, len=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if (TF_find==PERIOD_CURRENT) TF_find=(ENUM_TIMEFRAMES)_Period;

   LoadHist();
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   
   SetIndexBuffer(0,HighBuff);
   SetIndexBuffer(1,LowBuff);

   IndicatorShortName("Inside Bar ("+TFtoStr(TF_find)+")");
   SetIndexLabel(0,"High");
   SetIndexLabel(1,"Low");
   
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   ArrayInitialize(HighBuff,EMPTY_VALUE); 
   ArrayInitialize(LowBuff,EMPTY_VALUE);
   
   IndicatorDigits(_Digits);

   return(0);
  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
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
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (rates_total-prev_calculated<=0) return(0);

   if (TF_find<_Period) 
      {
      Comment("Time frame must be not more than 'Period to find Inside Bar' "+TFtoStr(TF_find)); 
      return (0);
      }
   
   int limit=1;
   if (prev_calculated==0 || rates_total-prev_calculated>1) 
      {
      ArrayInitialize(HighBuff,EMPTY_VALUE); 
      ArrayInitialize(LowBuff,EMPTY_VALUE);
      limit=iBars(_Symbol,TF_find)-2;
      }
      
   for (int i=limit; i>=1; i--)
      { 
       datetime time1=iTime(_Symbol,TF_find,i);
       datetime time2=time1+PeriodSeconds(TF_find);
       int bar_now=iBarShift(_Symbol,_Period,time1,false);

       if (iLow(_Symbol,TF_find,i) > iLow(_Symbol,TF_find,i+1) && 
           iHigh(_Symbol,TF_find,i) < iHigh(_Symbol,TF_find,i+1) && 
           iHigh(_Symbol,TF_find,i)-iLow(_Symbol,TF_find,i)>_Point/2)
         {
         LastHigh = iHigh(_Symbol,TF_find,i);
         LastLow = iLow(_Symbol,TF_find,i);
         len=1;
         
         if (bar_now<rates_total-3 && 
             ((HighBuff[bar_now+1]!=LastHigh && HighBuff[bar_now+2]!=EMPTY_VALUE) ||
             (LowBuff[bar_now+1]!=LastLow && LowBuff[bar_now+2]!=EMPTY_VALUE)) )
               {
               HighBuff[bar_now+1] = EMPTY_VALUE;
               LowBuff[bar_now+1] = EMPTY_VALUE;
               }

         while (bar_now<rates_total-2 && time[bar_now]>=time1 && time[bar_now]<time2)
            {
            HighBuff[bar_now] = LastHigh;
            LowBuff[bar_now] = LastLow;
            bar_now--;
            }
         } 
      
      else
         {
         if (len>0 && len<length)
            {
            while (bar_now<rates_total-2 && time[bar_now]>=time1 && time[bar_now]<time2)
               {
               HighBuff[bar_now] = HighBuff[bar_now+1];
               LowBuff[bar_now] = LowBuff[bar_now+1];
               bar_now--;
               }
            len++;
            }
         else if (len>length)
            {
            len=0;
            HighBuff[bar_now] = EMPTY_VALUE;
            LowBuff[bar_now] = EMPTY_VALUE;
            }
         }
      } 
  return(rates_total);
}
//+------------------------------------------------------------------+


string TFtoStr(int n)
  {
   if(n==0)n=Period();
   switch(n)
     {
      case PERIOD_M1:  return ("M1");
      case PERIOD_M5:  return ("M5");
      case PERIOD_M15: return ("M15");
      case PERIOD_M30: return ("M30");
      case PERIOD_H1:  return ("H1");
      case PERIOD_H4:  return ("H4");
      case PERIOD_D1:  return ("D1");
      case PERIOD_W1:  return ("W1");
      case PERIOD_MN1: return ("MN1");
     }
   return("TF?");
  }


void LoadHist()
{
int iPeriod[2]; 
iPeriod[0]=TF_find;
iPeriod[1]=_Period;

for (int i=0;i<2;i++)
   {
   datetime open = iTime(_Symbol, iPeriod[i], 0);
   int error=GetLastError();
   while(error==4066)
      {   
      Comment("Loading history "+TFtoStr(iPeriod[i]));
      Sleep(1000);
      open = iTime(_Symbol, iPeriod[i], 0);
      error=GetLastError();
      }
   Comment("");
   }
}