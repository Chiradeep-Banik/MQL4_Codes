
//----
#property  indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_style1 STYLE_SOLID
#property indicator_color2 Yellow
#property indicator_style2 STYLE_SOLID
#property indicator_color3 Aqua
#property indicator_style3 STYLE_SOLID
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2



//---- input parameters
extern int MA_Period = 8;
extern int MA_method = 1;

//---- buffers


double mahup[];
double mahdown[];
double maheven[];
double Hp[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
   IndicatorBuffers(4);
   SetIndexBuffer(3, Hp);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, mahdown);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, mahup);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, maheven);



   return(0);
  }
//+------------------------------------------------------------------+
//|                                          |
//+------------------------------------------------------------------+
int start()
  {
   int i;
   double mahp , mahpre;
   int limit;
   int counted_bars=IndicatorCounted();
   
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(i=0; i < limit; i++)
   {
    Hp[i] = ((Open[i+2] + Close[i+2] + Open[i+1] + Close[i+1])/4 +
              (Open[i] + Close[i] + High[i] + Low[i])/4)/2;
    
   }
   for(i=0; i < limit; i++)
   {
    mahp = iMAOnArray(Hp,0,MA_Period,0,MA_method,i);
    mahpre = iMAOnArray(Hp,0,MA_Period,0,MA_method,i+1);
    
       mahup[i] = mahp; 
       mahdown[i] = mahp; 
       maheven[i] = mahp;
       
        if (mahpre > mahp)
        {
        mahup[i] = EMPTY_VALUE;
        
        }
       else if (mahpre < mahp) 
        {
        mahdown[i] = EMPTY_VALUE; 
        
        }
         else 
         {
         
         mahup[i]=EMPTY_VALUE;
         mahdown[i]=EMPTY_VALUE;
         }
   }



   return(0);
  }
//+------------------------------------------------------------------+