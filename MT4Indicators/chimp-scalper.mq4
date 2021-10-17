//+------------------------------------------------------------------+
//|                                                     Chimp2_1.mq4 |                                     
//+------------------------------------------------------------------+
//Revision history; 
//Chimp2_1 is a hybrid between earlier Chimp1_n and Chimp2_2 which uses Price/Volume instead of price.
//
#property indicator_separate_window
#property indicator_buffers   3
#property indicator_color1    Aqua
#property indicator_width1    2
#property indicator_color2    Lime
#property indicator_color3    Red

//---- input parameters
extern double  WeightDM=2.5;
extern double  WeightDI=2.0;
extern double  WeightDX=1.0;
extern double  WeightOut=1.0;

//---- buffers
double MA[];
double UP[];
double DN[];
double PDM[];//Not displayed
double MDM[];//Not displayed
double PDI[];//Not displayed
double MDI[];//Not displayed
double DX[];//Not displayed

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,UP);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,DN);
   SetIndexBuffer(3,PDM); 
   SetIndexBuffer(4,MDM);   
   SetIndexBuffer(5,PDI);
   SetIndexBuffer(6,MDI); 
   SetIndexBuffer(7,DX);
   
   //---- name for DataWindow and indicator subwindow label
   string short_name="Chimp2_1";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Chimp2_1");
   SetIndexLabel(1,"Chimp2_1");
   SetIndexLabel(2,"Chimp2_1");
   //----
   SetIndexDrawBegin(0,4);
   SetIndexDrawBegin(1,4);
   SetIndexDrawBegin(2,4);
   SetLevelStyle(STYLE_DOT,1,White);  
   SetLevelValue(0,0.6);
   SetLevelValue(1,0.3);
   SetLevelValue(2,-0.3);
   SetLevelValue(3,-0.6);  
    
//--------- Safety overrides on user settings
   if (WeightDM<1.0)WeightDM=1.0;
   if (WeightDI<1.0)WeightDI=1.0;
   if (WeightDX<1.0)WeightDX=1.0;
   if (WeightOut<1.0)WeightOut=1.0;
      
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    i, counted_bars=IndicatorCounted();
   double TR,DI_Diff, DI_Sum, DI_Factor, VI; 

//---- 
     
   if (counted_bars<0) return(-1);  //MT4 error exit.

   for(i=Bars-counted_bars-1;i>Bars-4;i--) //Fill the oldest bars with safe data for any averaging.
   {
   MA[i]=0;
   UP[i]=0;
   DN[i]=0;    
   PDM[i]=Close[i];
   MDM[i]=Close[i];
   PDI[i]=0;
   MDI[i]=0;
   DX[i]=0;
   }
   
   for(i=i; i>=0; i--) //Main loop begins after history bars filled.
   {     
   PDM[i]=0;
   MDM[i]=0;
   if(Close[i]>Close[i+1])PDM[i]=Close[i]-Close[i+1];
   else MDM[i]=Close[i+1]-Close[i];
   PDM[i]*=PDM[i];
   PDM[i]/=Volume[i];
   MDM[i]*=MDM[i];
   MDM[i]/=Volume[i];    
   PDM[i]=((WeightDM-1)*PDM[i+1] + PDM[i])/WeightDM;//ema.
   MDM[i]=((WeightDM-1)*MDM[i+1] + MDM[i])/WeightDM;//ema.
   
   TR=PDM[i]+MDM[i];
   if (TR>0) {PDI[i]=PDM[i]/TR; MDI[i]=MDM[i]/TR;}//Avoid division by zero. Minimum step size is one unnormalized price pip.
   else {PDI[i]=0; MDI[i]=0;}
   
   PDI[i]=((WeightDI-1)*PDI[i+1] + PDI[i])/WeightDI;//ema.
   MDI[i]=((WeightDI-1)*MDI[i+1] + MDI[i])/WeightDI;//ema.
   DI_Diff=PDI[i]-MDI[i];  
   if (DI_Diff<0) DI_Diff= -DI_Diff;//Only positive momentum signals are used.
   DI_Sum=PDI[i]+MDI[i];
   DI_Factor=0;//Zero case, DI_Diff will also be zero when DI_Sum is zero.
   if (DI_Sum>0) DX[i]=DI_Diff/DI_Sum;//Factional, near zero when PDM==MDM (horizonal), near 1 for laddering.
   else MA[i]=0;
   DX[i]=((WeightDX-1)*DX[i+1] + DX[i])/WeightDX;
                        
   if(MDI[i]>PDI[i])DX[i]=-DX[i];//Liable to cause sudden directional change if large WeightDX or WeightOut numbers used.
   MA[i]=((WeightOut-1)*MA[i+1]+DX[i])/WeightOut;
     
   UP[i]=0;
   DN[i]=0;
   if(MA[i]>0)UP[i]=MA[i];//Bulls histogram
   if(MA[i]<0)DN[i]=MA[i];//Bears histogram
   
   }
  
//----
   return(0);
  }
//+------------------------------------------------------------------+

