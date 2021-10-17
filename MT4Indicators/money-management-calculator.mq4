//+------------------------------------------------------------------+
//|                                              Monay Managment.mq4 |
//|                                   Copyright © 2010, Cisco Press. |
//|                                        error.detection@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Cisco Press."
#property link      "error.detection@gmail.com"

#property indicator_chart_window
#property indicator_buffers 2
extern color indicator_clr1= Gold;
extern color indicator_clr2= Aqua;

extern int       SL=40;
extern double    Risk=0.02;
extern int       Order.No=1;
extern int       Position =1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("lot");
   ObjectDelete("lot1");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
  DisplayText("Lot","Allow Lots Per "+Order.No +" trade with Risk "+DoubleToStr((Risk*100),0)+"% :","Arial",18,indicator_clr1,80,10,Position);
  DisplayText("Lot1",DoubleToStr(Lots(),2),"Arial",18,indicator_clr2,10,10,Position);
//----
   return(0);
  }
//+------------------------------------------------------------------+
double Lots()
   {
      double accfr= AccountFreeMargin();
      double PV=MarketInfo(Symbol(),MODE_TICKVALUE);
      double Lot = (accfr*Risk)/(SL*PV);
      if (Order.No==1)Lot=Lot;
      else Lot=Lot/Order.No;
      return (NormalizeDouble(Lot,2));
   }
//+------------------------------------------------------------------+
void DisplayText(string objname, string objtext, string fontname, int fontsize, int clr, int x, int y,int Cor)
   {
      ObjectCreate(objname,OBJ_LABEL,0,0,0);
      ObjectSetText(objname,objtext,fontsize,fontname,clr);
      ObjectSet(objname,OBJPROP_CORNER,Cor);
      ObjectSet(objname,OBJPROP_XDISTANCE,x);
      ObjectSet(objname,OBJPROP_YDISTANCE,y);
   }
//+------------------------------------------------------------------+   