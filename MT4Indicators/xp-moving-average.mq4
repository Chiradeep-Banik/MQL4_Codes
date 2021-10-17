//+------------------------------------------------------------------+
//|                       XP Moving Average                          | 
//|                                                         xpMA.mq4 |
//|                                         Developed by Coders Guru |
//|                                            http://www.xpworx.com |
//+------------------------------------------------------------------+

#property link      ""


#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red

#define MODE_DEMA 4
#define MODE_TEMA 5
#define MODE_T3MA 6

/* Moving average types constants:
------------------------------------
MODE_SMA       0     Simple moving average, 
MODE_EMA       1     Exponential moving average, 
MODE_SMMA      2     Smoothed moving average, 
MODE_LWMA      3     Linear weighted moving average.
MODE_DEMA      4     Double Exponential Moving Average. 
MODE_TEMA      5     Triple Exponential Moving Average.
MODE_T3MA      6     T3 Moving Average. 
------------------------------------*/

/* Applied price constants:
-------------------------------
PRICE_CLOSE    0     Close price. 
PRICE_OPEN     1     Open price. 
PRICE_HIGH     2     High price. 
PRICE_LOW      3     Low price. 
PRICE_MEDIAN   4     Median price, (high+low)/2. 
PRICE_TYPICAL  5     Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6     Weighted close price, (high+low+close+close)/4.
--------------------------------- */

 
extern   int      MA_Period               = 10;
extern   int      MA_Type                 = MODE_EMA;
extern   int      MA_Applied              = PRICE_CLOSE;
extern   double   T3MA_VolumeFactor       = 0.8;

double UpBuffer[];
double DownBuffer[];
double Buffer3[];
double buffer[];
double tempbuffer[];
double matriple[];

int init()
{
   IndicatorBuffers(6); 

   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,2);
   SetIndexBuffer(2,UpBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,2);
   SetIndexBuffer(1,DownBuffer);
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,2);
   SetIndexBuffer(0,Buffer3);
   SetIndexBuffer(3,buffer);
   SetIndexBuffer(4,tempbuffer);
   SetIndexBuffer(5,matriple);
   return(0);
}

int deinit()
{
   return(0);
}



void start()
{
   
   int counted_bars=IndicatorCounted();
   int i = 0;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   
   switch (MA_Type)
   {
      case 0:
      case 1:
      case 2:
      case 3:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMA(NULL,0,MA_Period,0,MA_Type,MA_Applied,i);
                  }
            }
            break;
      
      case 4:
            {
                  for(i=0; i<limit; i++)
                  {
                     tempbuffer[i] = iMA(NULL,0,MA_Period,0,MODE_EMA,MA_Applied,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     matriple[i] = iMAOnArray(tempbuffer,0,MA_Period,0,MODE_EMA,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMAOnArray(matriple,0,MA_Period,0,MODE_EMA,i);
                  }
            }
            break;
      
      case 5:
            {
                  for(i=0; i<limit; i++)
                  {
                     tempbuffer[i] = iMA(NULL,0,MA_Period,0,MODE_EMA,MA_Applied,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMAOnArray(tempbuffer,0,MA_Period,0,MODE_EMA,i);
                  }
            }
            break;
      
      case 6:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iCustom(NULL,0,"T3MA",MA_Period,T3MA_VolumeFactor,0,i);
                  }
            }
            break;
   }

   for(int shift=limit; shift>=0; shift--)
   {
       UpBuffer[shift] = buffer[shift];
       DownBuffer[shift] = buffer[shift];
       Buffer3[shift] = buffer[shift];
   }                   
   for(shift=limit; shift>=0; shift--)
   {
      if (buffer[shift+1]>buffer[shift])
      {
         UpBuffer[shift+1] = EMPTY_VALUE;
         //Buffer3[i+1] = EMPTY_VALUE;
      }
      else if (buffer[shift+1]<buffer[shift] )
      {
         DownBuffer[shift+1] = EMPTY_VALUE;
//Buffer3[i+1] = EMPTY_VALUE;      
      } 
      else
      {
         UpBuffer[shift+1] = CLR_NONE;
         DownBuffer[shift+1] = CLR_NONE;
      }
   }                   
   return(0);
}



