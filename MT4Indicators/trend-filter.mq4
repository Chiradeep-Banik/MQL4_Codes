#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Lime
#property indicator_color3 OrangeRed
#property indicator_level1  -0.9
#property indicator_level2   0
#property indicator_level3   0.9
#property indicator_minimum -1.05
#property indicator_maximum  1.05
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

extern int  Nbars=89;
extern int  MA_Period =9;
int  MA_Method =3;

double Value[];
double MA[];
double iFish[];
double Buy[];
double Sell[];

int init() 
{ 
   IndicatorBuffers(5);
   SetIndexBuffer(0, iFish); 
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1, Buy); 
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2, Sell); 
   SetIndexStyle(2,DRAW_LINE);
   
   SetIndexBuffer(3, Value);
   SetIndexBuffer(4, MA);
   
   IndicatorShortName("TREND FILTER ("+Nbars+","+MA_Period+")" );
   
   return(0); 
}  
int deinit() { return(0); } 

int start() 
{ 
   int counted_bars = IndicatorCounted(), i; 
   if (counted_bars < 0) return(-1); 
   if (counted_bars > 0) counted_bars--;  
   int limit=Bars - counted_bars+2*Nbars;
   double up,dn,osc;
   
   for(i = limit; i >= 0; i--) 
   {      
      up = High[iHighest(NULL,0,MODE_HIGH,Nbars,i)];
      dn = Low[iLowest(NULL,0,MODE_LOW,Nbars,i)]; 
      
      if (up>dn)osc = 100*(Close[i]-dn)/(up-dn);
      else osc = 0;
      if (osc < 0) osc = 0.1;
      if (osc > 100) osc = 99.9;
      Value[i]=0.1*(osc-50.0);      
   }   
   for(i = limit; i >= 0; i--)    
   {
      MA[i]=iMAOnArray(Value,0,MA_Period,0,MA_Method,i);
      iFish[i]=(MathExp(2.0*MA[i])-1.0)/(MathExp(2.0*MA[i])+1.0);
      if (iFish[i]> 0.9) {Buy[i] =iFish[i]; Buy[i+1] =iFish[i+1];}
      if (iFish[i]<-0.9) {Sell[i]=iFish[i]; Sell[i+1]=iFish[i+1];}
   } 
   return(0); 
} 


