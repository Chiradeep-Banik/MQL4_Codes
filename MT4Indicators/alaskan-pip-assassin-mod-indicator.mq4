//+------------------------------------------------------------------+
//|                                                 SilverTrend .mq4 |
//|                             SilverTrend  rewritten by CrazyChart |
//|                                                 http://viac.ru/  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters

extern int       CountBars=300;
extern int       SSP=7;
extern double    Kmin=1.6;
extern double    Kmax=50.6; //24 21.6 21.6 


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE,0,2,Blue);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE,0,2,Red);
   SetIndexBuffer(1,ExtMapBuffer2);
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
 
  if (CountBars>=Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars+SSP);
   SetIndexDrawBegin(1,Bars-CountBars+SSP);
  int i, i2,loopbegin,counted_bars=IndicatorCounted();
  double SsMax, SsMin, K, val1, val2, smin, smax, price; 
  
  if(Bars<=SSP+1) return(0);
  //---- initial zero

//K=33-RISK; 

/*
if (firstTime==true)   { 
   loopbegin = CountBars; 
   if (loopbegin>(Bars-2*SSP+1)) loopbegin=Bars-2*SSP+1; 
   firstTime=False; 
}; �������� ������ ��������� 
*/
  if(Bars<=SSP+1) return(0);
//---- initial zero

//+++++++
if(counted_bars<SSP+1)
   {
      for(i=1;i<=SSP;i++) ExtMapBuffer1[CountBars-i]=0.0;
      for(i=1;i<=SSP;i++) ExtMapBuffer2[CountBars-i]=0.0;
   }
//+++++++-SSP


for(i=CountBars-SSP;i>=0;i--) { 


  SsMax = High[Highest(NULL,0,MODE_HIGH,SSP,i-SSP+1)]; 
  SsMin = Low[Lowest(NULL,0,MODE_LOW,SSP,i-SSP+1)]; 
   smin = SsMin-(SsMax-SsMin)*Kmin/100; 
   smax = SsMax-(SsMax-SsMin)*Kmax/100;  
   ExtMapBuffer1[i-SSP+6]=smax; 
   ExtMapBuffer2[i-SSP-1]=smax; 
   val1 = ExtMapBuffer1[0]; 
   val2 = ExtMapBuffer2[0]; 
if (val1 > val2) Comment("������� buy ",val1); 

if (val1 < val2) Comment("������� sell ",val2); 

 
}
  

  
   
//----
   return(0);
  }
//+------------------------------------------------------------------+