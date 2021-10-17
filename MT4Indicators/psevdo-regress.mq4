//+------------------------------------------------------------------+
//|                                               Psevdo_regress.mq4 |
//|                                                            Grell |
//|                                                dwgrell@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property indicator_chart_window
//--- input parameters
extern int       period=16;
extern color     main_line=Yellow;
extern color     sup_line=Red;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  ObjectCreate ("line1"+period, OBJ_TREND, 0, 0, 0);// ???????? ???.
  ObjectCreate ("line2"+period, OBJ_TREND, 0, 0, 0);// ???????? ???.
  ObjectCreate ("line3"+period, OBJ_TREND, 0, 0, 0);// ???????? ???.
  return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
  ObjectDelete ("line1"+period);
  ObjectDelete ("line2"+period);
  ObjectDelete ("line3"+period);
  return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int max1index=iHighest(NULL,0,MODE_HIGH,3*period,period);
   int max0index=iHighest(NULL,0,MODE_HIGH,2*period,0);
   int min1index=iLowest(NULL,0,MODE_LOW,3*period,period);
   int min0index=iLowest(NULL,0,MODE_LOW,2*period,0);
   double max1=High[max1index];
   double max0=High[max0index];
   double min1=Low[min1index];
   double min0=Low[min0index];
   int aver1=(max1index+min1index)/2;
   int aver0=(max0index+min0index)/2;
   ObjectSet("line1"+period,OBJPROP_TIME1,Time[max1index]); 
   ObjectSet("line1"+period,OBJPROP_TIME2,Time[max0index]); 
   ObjectSet("line1"+period,OBJPROP_PRICE1,max1); 
   ObjectSet("line1"+period,OBJPROP_PRICE2,max0); 
   ObjectSet("line1"+period,OBJPROP_COLOR,sup_line); 
   ObjectSet("line2"+period,OBJPROP_TIME1,Time[min1index]); 
   ObjectSet("line2"+period,OBJPROP_TIME2,Time[min0index]); 
   ObjectSet("line2"+period,OBJPROP_PRICE1,min1); 
   ObjectSet("line2"+period,OBJPROP_PRICE2,min0); 
   ObjectSet("line2"+period,OBJPROP_COLOR,sup_line); 
   ObjectSet("line3"+period,OBJPROP_TIME1,Time[aver1]); 
   ObjectSet("line3"+period,OBJPROP_TIME2,Time[aver0]); 
   ObjectSet("line3"+period,OBJPROP_PRICE1,(min1+max1)/2); 
   ObjectSet("line3"+period,OBJPROP_PRICE2,(min0+max0)/2); 
   ObjectSet("line3"+period,OBJPROP_COLOR,main_line); 
   return(0);
  }
//+------------------------------------------------------------------+