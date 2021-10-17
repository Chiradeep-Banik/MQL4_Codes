//+------------------------------------------------------------------+
//|                                                Perceptron AI.mq4 |
//|                                                     Ibrahim Noor |
//|                           http://winning-solution.com/?id=baim78 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_minimum 0
#property indicator_maximum 1

//---- input parameters
extern int    x1 = 135;
extern int    x2 = 127;
extern int    x3 = 16;
extern int    x4 = 93;

//---- buffers
double ExtMapBuffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"Perceptron AI");
//----
   IndicatorShortName("Perceptron AI");
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
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
   double value, x, y;
   for(int i=0;i<=Bars;i++){
      double w1 = x1 - 100;
      double w2 = x2 - 100;
      double w3 = x3 - 100;
      double w4 = x4 - 100;
      double a1 = iAC(Symbol(), 0, i+0);
      double a2 = iAC(Symbol(), 0, i+7);
      double a3 = iAC(Symbol(), 0, i+14);
      double a4 = iAC(Symbol(), 0, i+21);

      x = w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4;

      if(x>0) {
         value=1;
      } else {
         value=0;
      }
            
      ExtMapBuffer1[i]=value;
   }   
//----
   return(0);
  }
//+------------------------------------------------------------------+