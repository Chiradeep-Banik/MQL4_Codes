//+------------------------------------------------------------------+
//|                                                      MultiMA.mq4 |
//+------------------------------------------------------------------+
#property  copyright "karceWZROKIEM"
#property  link      "http://www.gkma.pl"
//---- indicator settings
#property  indicator_chart_window
//#property  indicator_separate_window
#property  indicator_buffers 8

#property  indicator_color1  Black
#property  indicator_width1  1

#property  indicator_color2  Black
#property  indicator_style2  STYLE_DOT
#property  indicator_width2  1

#property  indicator_color3  Red
#property  indicator_width3  1

#property  indicator_color4  Green
#property  indicator_width4  1

#property  indicator_color5  Red
#property  indicator_width5  1

#property  indicator_color6  Green
#property  indicator_width6  1

#property  indicator_color7  Red
#property  indicator_width7  1

#property  indicator_color8  Red
#property  indicator_width8  1
//---- indicator parameters
extern int MA_Period=233;

//---- indicator buffers
double     MABuffer[];
double     MAMABuffer[];
double     MAMABuffer2[];
double     MAMABuffer3[];
double     MAMABuffer4[];
double     MAMABuffer5[];
double     MAMABuffer6[];
double     MAMABuffer7[];

int ExtCountedBars, limit;

int WEIGHTS[10][9] ={
                     0, 0, 0 ,0 ,0 ,0 ,0 ,0 , 0,
                     08, 1, 1, 1, 1, 1, 1, 1, 1, 
                     1, 08, 1, 1, 1, 1, 1, 1, 1, 
                     1, 1, 08, 1, 1, 1, 1, 1, 1, 
                     1, 1, 1, 08, 1, 1, 1, 1, 1, 
                     1, 1, 1, 1, 08, 1, 1, 1, 1, 
                     1, 1, 1, 1, 1, 08, 1, 1, 1, 
                     1, 1, 1, 1, 1, 1, 08, 1, 1, 
                     1, 1, 1, 1, 1, 1, 1, 08, 1, 
                     1, 1, 1, 1, 1, 1, 1, 1, 08, 
                     };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexStyle(7,DRAW_LINE);

   IndicatorDigits(Digits+1);
   if(MA_Period<2) MA_Period=13;
   
   SetIndexDrawBegin(0,MA_Period-1);
//---- indicator buffers mapping
   SetIndexBuffer(0, MABuffer);
   SetIndexBuffer(1, MAMABuffer);
   SetIndexBuffer(2, MAMABuffer2);
   SetIndexBuffer(3, MAMABuffer3);
   SetIndexBuffer(4, MAMABuffer4);
   SetIndexBuffer(5, MAMABuffer5);
   SetIndexBuffer(6, MAMABuffer6);
   SetIndexBuffer(7, MAMABuffer7);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MultiMA("+MA_Period+")");
//---- initialization done
   SetIndexLabel(0,"MA");
   SetIndexLabel(1,"MAMA");
   SetIndexLabel(2,"Fib 0.2364");
   SetIndexLabel(3,"Fib 0.3824");
   SetIndexLabel(4,"Fib 0.5000");
   SetIndexLabel(5,"Fib 0.6180");
   SetIndexLabel(6,"Fib 1,3820");
   SetIndexLabel(7,"Fib 1.6180");
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int timeframe;
   double w, pip;
   int ShiftC, ShiftP;

   int MAtrend = 0;
   
   double MAc, MAp;
   if(Bars<=MA_Period) return(0);
   
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//----
   limit=Bars-ExtCountedBars;
   //mit=500;
   for(int i=0; i<limit; i++)
   {
      MABuffer[i] = iMA(NULL, 0, MA_Period, 0, MODE_SMA, PRICE_CLOSE, i);
      MAMABuffer[i] = 0;
      w=0;
      pip=1;
      for(int ii=1; ii<5; ii++)
      if(int2period(ii) != Period())
      {
         timeframe = int2period(ii);
         
         ShiftC = iBarShift(NULL,timeframe,Time[i]);
         //ShiftP = iBarShift(NULL,timeframe,Time[i+1]);
         //ShiftP = ShiftC +1;

         MAc = iMA(NULL,timeframe,MA_Period,0,MODE_SMA,PRICE_CLOSE,ShiftC);
         MAp = iMA(NULL,timeframe,MA_Period,0,MODE_SMA,PRICE_CLOSE,ShiftP);
      
         //if(MAc>MAp)             MAtrend = 1;   else MAtrend = -1;
         
         //pip = WEIGHTS[period2int(Period())][ii];
         //pip = Point/MathAbs( (MAc-iClose(NULL,timeframe,ShiftC)) ) * (1+MathAbs(iHigh(NULL,timeframe,ShiftC)-iLow(NULL,timeframe,ShiftC))) ;
         pip = pip*1.50;
         w += pip;
         MAMABuffer[i] += MAc * pip;
      }

      MAMABuffer[i] /= w;
      //MABuffer2[i] = (MABuffer[i] + MAMABuffer[i])/2;
      MAMABuffer2[i] = MABuffer[i] + (MABuffer[i] - MAMABuffer[i])* 0.2360 *(-1);
      MAMABuffer3[i] = MABuffer[i] + (MABuffer[i] - MAMABuffer[i])* 0.3820 *(-1);
      MAMABuffer4[i] = MABuffer[i] + (MABuffer[i] - MAMABuffer[i])* 0.5000 *(-1);
      MAMABuffer5[i] = MABuffer[i] + (MABuffer[i] - MAMABuffer[i])* 0.6180 *(-1);
      MAMABuffer6[i] = MABuffer[i] + (MABuffer[i] - MAMABuffer[i])* 1.3820 *(-1);
      MAMABuffer7[i] = MABuffer[i] + (MABuffer[i] - MAMABuffer[i])* 1.6180 *(-1);
   }
   //for(i=0; i<limit; i++)
   //{
   //   Buffer1[i]=iMAOnArray(Buffer,Bars,MAsmooth1,0,MODE_SMA,i);
   //   Buffer2[i]=iMAOnArray(Buffer,Bars,MAsmooth2,0,MODE_SMA,i);
   //}


//----
   return(0);
  }
//+------------------------------------------------------------------+


double int2period(int cnt)
{
   switch(cnt)
   {
      case 1:
         return (PERIOD_M1);
      case 2:
         return (PERIOD_M5);
      case 3:
         return (PERIOD_M15);
      case 4:
         return (PERIOD_M30);
      case 5:
         return (PERIOD_H1);
      case 6:
         return (PERIOD_H4);
      case 7:
         return (PERIOD_D1);
      case 8:
         return (PERIOD_W1);
      case 9:
         return (PERIOD_MN1);
      default:
         return (0);
   }
}
int period2int(double cnt)
{
   switch(cnt)
   {
      case PERIOD_M1:
         return (1);
      case PERIOD_M5:
         return (2);
      case PERIOD_M15:
         return (3);
      case PERIOD_M30:
         return (4);
      case PERIOD_H1:
         return (5);
      case PERIOD_H4:
         return (6);
      case PERIOD_D1:
         return (7);
      case PERIOD_W1:
         return (8);
      case PERIOD_MN1:
         return (9);
      default:
         return (0);
   }
}