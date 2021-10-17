//+------------------------------------------------------------------+
//|                                              Critical Points.mq4 |
//|                                                         emsjoflo |
//|                                  automaticforex.invisionzone.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters
extern int       MAPeriod=157;
extern int       MAType = 0;
extern int       Fib1=23;
extern int       Fib2=38;
extern int       Fib3=50;
extern int       Fib4=61;
extern int       Fib5=100;
extern color     Color1=Khaki;
extern color     Color2=LightGreen;
extern color     Color3=LightSkyBlue;
extern color     Color4=Plum;
extern color     Color5=LightSalmon;
double Line1,Line_1,Line2,Line_2,Line3,Line_3,Line4,Line_4,Line5,Line_5,MAVal,MAValOld;

//---- buffers
double ExtMapBuffer1[];
//---- variables
int    MAMode;
string strMAType;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
//----
switch (MAType)
   {
      case 1: strMAType="EMA"; MAMode=MODE_EMA; break;
      case 2: strMAType="SMMA"; MAMode=MODE_SMMA; break;
      case 3: strMAType="LWMA"; MAMode=MODE_LWMA; break;
      case 4: strMAType="LSMA"; break;
      default: strMAType="SMA"; MAMode=MODE_SMA; break;
   }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
ObjectDelete("cp1");
ObjectDelete("cp2");
ObjectDelete("cp3");
ObjectDelete("cp4");
ObjectDelete("cp5");
ObjectDelete("cp_1");
ObjectDelete("cp_2");
ObjectDelete("cp_3");
ObjectDelete("cp_4");
ObjectDelete("cp_5");


//----
   return(0);
  }

double LSMA(int Rperiod, int shift)
{
   int i;
   double sum;
   int length;
   double lengthvar;
   double tmp;
   double wt;

   length = Rperiod;
 
   sum = 0;
   for(i = length; i >= 1  ; i--)
   {
     lengthvar = length + 1;
     lengthvar /= 3;
     tmp = 0;
     tmp = ( i - lengthvar)*Close[length-i+shift];
     sum+=tmp;
    }
    wt = sum*6/(length*(length+1));
    
    return(wt);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;

   for(int i=limit; i>=0; i--)
   {
      if (MAType == 4)
      {
        MAVal = LSMA(MAPeriod,i);
      }
      else
      {
      
        MAVal=iMA(NULL,0,MAPeriod,0,MAMode,PRICE_CLOSE,i);
      }
      ExtMapBuffer1[i] = MAVal;
   }
   Line1=MAVal+Fib1*Point;
   Line2=MAVal+Fib2*Point;
   Line3=MAVal+Fib3*Point;
   Line4=MAVal+Fib4*Point;
   Line5=MAVal+Fib5*Point;
   Line_1=MAVal-Fib1*Point;
   Line_2=MAVal-Fib2*Point;
   Line_3=MAVal-Fib3*Point;
   Line_4=MAVal-Fib4*Point;
   Line_5=MAVal-Fib5*Point;   
   
   if(ObjectFind("cp1") != 0)
      {
      ObjectCreate("cp1", OBJ_HLINE, 0, Time[20], Line1);
      ObjectSet("cp1", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp1", OBJPROP_COLOR, Color1);
      }
      else
      {
      ObjectMove("cp1", 0, Time[20], Line1);
      }
      
   if(ObjectFind("cp2") != 0)
      {
      ObjectCreate("cp2", OBJ_HLINE, 0, Time[20], Line2);
      ObjectSet("cp2", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp2", OBJPROP_COLOR, Color2);
      }
      else
      {
      ObjectMove("cp2", 0, Time[20], Line2);
      }
      
    if(ObjectFind("cp3") != 0)
      {
      ObjectCreate("cp3", OBJ_HLINE, 0, Time[20], Line3);
      ObjectSet("cp3", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp3", OBJPROP_COLOR, Color3);
      }
      else
      {
      ObjectMove("cp3", 0, Time[20], Line3);
      }
      
   if(ObjectFind("cp4") != 0)
      {
      ObjectCreate("cp4", OBJ_HLINE, 0, Time[20], Line4);
      ObjectSet("cp4", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp4", OBJPROP_COLOR, Color4);
      }
      else
      {
      ObjectMove("cp4", 0, Time[20], Line4);
      }
         
 
   if(ObjectFind("cp5") != 0)
      {
      ObjectCreate("cp5", OBJ_HLINE, 0, Time[20], Line5);
      ObjectSet("cp5", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp5", OBJPROP_COLOR, Color5);
      }
      else
      {
      ObjectMove("cp5", 0, Time[20], Line5);
      }
  
  if(ObjectFind("cp_1") != 0)
      {
      ObjectCreate("cp_1", OBJ_HLINE, 0, Time[20], Line_1);
      ObjectSet("cp_1", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp_1", OBJPROP_COLOR, Color1);
      }
      else
      {
      ObjectMove("cp_1", 0, Time[20], Line_1);
      }
      
   if(ObjectFind("cp_2") != 0)
      {
      ObjectCreate("cp_2", OBJ_HLINE, 0, Time[20], Line_2);
      ObjectSet("cp_2", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp_2", OBJPROP_COLOR, Color2);
      }
      else
      {
      ObjectMove("cp_2", 0, Time[20], Line_2);
      }
      
    if(ObjectFind("cp_3") != 0)
      {
      ObjectCreate("cp_3", OBJ_HLINE, 0, Time[20], Line_3);
      ObjectSet("cp_3", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp_3", OBJPROP_COLOR, Color3);
      }
      else ObjectMove("cp_3", 0, Time[20], Line_3);
      
      
   if(ObjectFind("cp_4") != 0)
      {
      ObjectCreate("cp_4", OBJ_HLINE, 0, Time[20], Line_4);
      ObjectSet("cp_4", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp_4", OBJPROP_COLOR, Color4);
      }
      else ObjectMove("cp_4", 0, Time[20], Line_4);
     
         
  
   if(ObjectFind("cp_5") != 0)
      {
      ObjectCreate("cp_5", OBJ_HLINE, 0, Time[20], Line_5);
      ObjectSet("cp_5", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("cp_5", OBJPROP_COLOR, Color5);
      }
      else
      {
      ObjectMove("cp_5", 0, Time[20], Line_5);
      }
  
      
//----
   return(0);
  }
  
//+------------------------------------------------------------------+