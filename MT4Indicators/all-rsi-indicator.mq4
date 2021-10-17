//+------------------------------------------------------------------+
//|                                                      All RSI.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright   ""
#property link        ""
#define indicatorName ""
//----
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 1
#property indicator_color1 Gold
#property indicator_level1 30
#property indicator_level2 70
#property indicator_levelcolor DimGray
//---- input parameters
extern int    RSIperiod            =14;
extern int    AppliedPrice        =0;
extern bool   showHigherTimeframes=true;
extern int    barsPerTimeFrame    =35;
extern bool   shiftRight          =False;
extern color  txtColor            =Silver;
extern color  separatorColor      =DimGray;
//---- buffers
double ExtMapBuffer1[];
//----
string shortName;
string labelsShort[] ={"M1","M5","M15","M30","H1","H4","D1"};
string labelsLong[]  ={"M15","M30","H1","H4","D1","W1","MN1"};
string labels[];
int    periodsShort[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1};
int    periodsLong[] ={PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
int    periods[];
int    Shift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if (shiftRight) Shift=1;
   else            Shift=0;
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexShift(0,Shift*(barsPerTimeFrame+1));
   SetIndexLabel(0,"RSI");
   //----
   barsPerTimeFrame   =MathMax(barsPerTimeFrame,30);
   shortName=indicatorName+" ("+RSIperiod+")";
   IndicatorShortName(shortName);
     if (showHigherTimeframes) 
     {
      ArrayCopy(labels,labelsLong);
      ArrayCopy(periods,periodsLong);
     }
     else  
     {
      ArrayCopy(labels,labelsShort);
      ArrayCopy(periods,periodsShort);
     }
   //----
   for(int i=1;i<7;i++)
      if (Period()==periods[i])
        {
         string tmpLbl=labels[i];
         int    tmpPer=periods[i];
         //----
         for(int k=i ;k>0; k--)
           {
            labels[k] =labels[k-1];
            periods[k]=periods[k-1];
           }
         labels[0] =tmpLbl;
         periods[0]=tmpPer;
        }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int l=0;l<7;l++)
     {
      ObjectDelete(indicatorName+l);
      ObjectDelete(indicatorName+l+1);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   string on;
   int    wn=WindowFind(shortName);
   int    k=0;
   //----
   for(int p=0; p<7;p++)
     {
      for(int i=0; i<barsPerTimeFrame;i++,k++)
         ExtMapBuffer1[k]=iRSI(NULL,periods[p],RSIperiod,AppliedPrice,i);
      ExtMapBuffer1[k]=EMPTY_VALUE; k+=1;
      //----
      on=indicatorName+p;
      if(ObjectFind(on)==-1)
         ObjectCreate(on,OBJ_TREND,wn,0,0);
      ObjectSet(on,OBJPROP_TIME1,myTime(k-Shift*(barsPerTimeFrame+1)-1));
      ObjectSet(on,OBJPROP_TIME2,myTime(k-Shift*(barsPerTimeFrame+1)-1));
      ObjectSet(on,OBJPROP_PRICE1,  0);
      ObjectSet(on,OBJPROP_PRICE2,100);
      ObjectSet(on,OBJPROP_COLOR ,separatorColor);
      ObjectSet(on,OBJPROP_WIDTH ,2);
      on=indicatorName+p+1;
      if(ObjectFind(on)==-1)
         ObjectCreate(on,OBJ_TEXT,wn,0,0);
      ObjectSet(on,OBJPROP_TIME1,myTime(k-Shift*(barsPerTimeFrame+1)-6));
      ObjectSet(on,OBJPROP_PRICE1,100);
      ObjectSetText(on,labels[p],9,"Arial",txtColor);
     }
   //----
   SetIndexDrawBegin(0,Bars-k);
   return(0);
  }
//+------------------------------------------------------------------+
//+ Custom functions and procedures                                  +
//+------------------------------------------------------------------+
int myTime(int a)
  {
   if(a<0)
      return(Time[0]+Period()*60*MathAbs(a));
   else  return(Time[a]);
  }
//+------------------------------------------------------------------+