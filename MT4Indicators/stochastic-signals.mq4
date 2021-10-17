//+------------------------------------------------------------------+
//|                                              StochWithPoints.mq4 |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum -10
#property indicator_maximum 110
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_width1 1
#property indicator_color2 RoyalBlue
#property indicator_width2 3
#property indicator_color3 OrangeRed
#property indicator_width3 2
#property indicator_color4 Lime
#property indicator_width4 2
#property indicator_color5 Red
#property indicator_width5 0
#property indicator_color6 Blue
#property indicator_width6 0
#property indicator_level1 10
#property indicator_level2 30
#property indicator_level3 70
#property indicator_level4 90
#property indicator_levelcolor DimGray
#property indicator_levelstyle STYLE_SOLID

//---- input parameters
extern int       K=10;//5;
extern int       D=3;
extern int       S=4;//3;
extern int       Method=3;
extern int       Price=1;
extern int       MainHP=3;
extern int       SignalHP=3;
extern bool      DrawConfirmArrow=true;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,NULL);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,NULL);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,ExtMapBuffer4);
   
   if (DrawConfirmArrow)
   {
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,234);//(4,159);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,233);//(5,159);
   SetIndexBuffer(5,ExtMapBuffer6);
   }
      
   SetIndexEmptyValue(5,0.0);    
   SetIndexDrawBegin(0,K+D+S);
   SetIndexDrawBegin(1,K+D+S);   
   SetIndexDrawBegin(2,K+D+S);   
   SetIndexDrawBegin(3,K+D+S);   
   SetIndexDrawBegin(4,K+D+S);   
   SetIndexDrawBegin(5,K+D+S);   
   IndicatorShortName("S_p");
   
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
   int limit=Bars-IndicatorCounted()-1;
      for(int i=limit;i>=0;i--){
         ExtMapBuffer1[i]=iStochastic(NULL,0,K,D,S,Method,Price,0,i);
         ExtMapBuffer2[i]=iStochastic(NULL,0,K,D,S,Method,Price,1,i);         
         
         if(ArrayMaximum(ExtMapBuffer1,MainHP*2+1,i)==i+MainHP)
         ExtMapBuffer3[i+MainHP]=ExtMapBuffer1[i+MainHP];
         if(ArrayMinimum(ExtMapBuffer1,MainHP*2+1,i)==i+MainHP)
         ExtMapBuffer4[i+MainHP]=ExtMapBuffer1[i+MainHP];     
         
         if(ArrayMaximum(ExtMapBuffer2,SignalHP*2+1,i)==i+SignalHP)
         ExtMapBuffer5[i+SignalHP]=ExtMapBuffer2[i+SignalHP];
         if(ArrayMinimum(ExtMapBuffer2,SignalHP*2+1,i)==i+SignalHP)
         ExtMapBuffer6[i+SignalHP]=ExtMapBuffer2[i+SignalHP];             
      }
   return(0);
  }
//+------------------------------------------------------------------+