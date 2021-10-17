//+------------------------------------------------------------------+
//|                                  	      Natuseko Protrader.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 DarkGray
#property indicator_color2 DodgerBlue
#property indicator_color3 DodgerBlue
#property indicator_color4 DodgerBlue
#property indicator_color5 Red
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double macd[1000];

int init()
  {

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);

   return(0);
  }

int start()
  {
  ArraySetAsSeries(macd,true); 
  int i;
        for( i=1000; i>=0; i--)          
        {
        macd[i]=iMACD(NULL,0,5,200,1,PRICE_CLOSE,MODE_MAIN,i);
        ExtMapBuffer1[i]=iMACD(NULL,0,5,200,1,PRICE_CLOSE,MODE_MAIN,i);
        }
        
 

 if(i<=1)
 {     
     for( i=0; i<=1000; i++)          
        {
         ExtMapBuffer2[i]=iBandsOnArray(macd,0,20,1,0,MODE_MAIN,i);
         ExtMapBuffer3[i]=iBandsOnArray(macd,0,20,1,0,MODE_UPPER,i);
         ExtMapBuffer4[i]=iBandsOnArray(macd,0,20,1,0,MODE_LOWER,i);
         ExtMapBuffer5[i]=iMAOnArray(macd,0,3,0,MODE_SMA,i);
         }
 }
   return(0);
  }

