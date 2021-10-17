//+------------------------------------------------------------------+
//|                                            EaseOfMovement_v1.mq4
//|                                  Copyright © 2009, Roman Robidet
//|                                  Copyright © 2012, Andrew Sumner
//|                                                                
//| RR - initial indicator, published on mql4.com as EMI.mq4        
//| 
//| v1 (AS):
//|    - Fixed weird values when not enough bars present
//|    - Use part of the previous bar's volume if current bar has zero 
//|      yet the price moved (happens on renko charts especially)
//|    - Make indicator value proportional to average volume rather than 
//|      absolute,generating predictable CCI-like values.
//|    - clean up code formatting.
//+------------------------------------------------------------------+
#property copyright ""

#property indicator_separate_window
//#property indicator_minimum 0
//#property indicator_maximum 100
#property indicator_buffers 1
#property indicator_color1 DodgerBlue

#property indicator_level1 0
#property indicator_levelcolor DimGray

extern int EMZPeriod = 40;
extern double MinValue = -1000;
extern double MaxValue = 1000;

double EMZBuffer[];
double PosBuffer[];
double NegBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   string short_name;

   IndicatorBuffers(1);

//---- indicator line
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, EMZBuffer);

//---- name for DataWindow and indicator subwindow label
   short_name = "EMZ(" + EMZPeriod + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
//----

//----
   return(0);
}

int start()
{
   int  k;
   double rel, negative, positive;
   double _H, sumaEMZ, EMZ;
   double _L;
   double _HP;
   double _LP;
   double _V;
//----
   int limit, i, j;
   int counted_bars = IndicatorCounted();

   if (counted_bars < 0) return(-1);

   if (counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;


//-- main loop

   if (counted_bars == 0)
   {
      for (i = Bars - EMZPeriod; i < Bars; i++)
         EMZBuffer[i] = 0;
   }

   for (i = 0; i < MathMin(limit, Bars - EMZPeriod); i++)
   {
      sumaEMZ = 0;
      double avgvolume = 0;
      int count = 0;

      for (k = 0; k < MathMin(Bars, i + EMZPeriod); k++)
      {
         avgvolume += Volume[i + k];
         count++;
      }

      avgvolume /= count;

      for (k = 0; k < EMZPeriod; k++)
      {
         _H = High[i + k];
         _L = Low[i + k];
         _HP = High[i + 1 + k];
         _LP = Low[i + 1 + k];
         _V = Volume[i + k];

         if (_V < 1 && Open[i+k] != Close[i+k])
         {
            for (j=1; j<limit; j++)
            {
               if (Volume[i + k + j] >= 1)
               {
                  _V = Volume[i + k + j] / (j + 1);
                  break;
               }
            }
         }

         _V = MathMax(_V, avgvolume / 4);
         _V = _V / avgvolume;

         EMZ = 0.0;
         if (_H > _L)
            if (_V / (_H - _L) > 0)
               EMZ = (((_H + _L ) / 2 ) - (( _HP + _LP ) / 2)) / ( _V / ( _H - _L )) * 10000000000 ;

         if (MinValue < -1)
            EMZ = MathMax(MinValue, EMZ);
         if (MaxValue > 1)
            EMZ = MathMin(MaxValue, EMZ);

         sumaEMZ = sumaEMZ + EMZ;

      }
      EMZBuffer[i] = (sumaEMZ / EMZPeriod);
   }

//----
   return(0);
}
//+------------------------------------------------------------------+