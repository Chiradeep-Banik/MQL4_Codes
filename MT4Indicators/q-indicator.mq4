//+--------------------------------------------------------------------------------------------+
//|                                                            Trend-Quality - Q-indicator.mq4 |
//|                                                             Copyright © 2009, Serega Lykov |
//|                                                                 http://mtexperts.narod.ru/ |
//+--------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2009, Serega Lykov"
#property link      "http://mtexperts.narod.ru/"

/*
{Trend-Quality - Q-indicator}
m:=Input("% Scalar trend period",1,25,4);
n:=Input("% Scalar noise period",1,500,250);
cf:=Input("% Scalar correction factor",1,250,2);
p1:=Input("First moving average periods",1,200,7);
p2:=Input("Second moving average periods",1,200,15);
rev:=Mov(C,p1,E)-Mov(C,p2,E);
pds:=If(rev>0,1,-1);
dc:=ROC(C,1,$);
cpc:=If(pds<>Ref(pds,-1),0,(dc*pds)+PREV);
trend:=If(pds<>Ref(pds,-1),0,(cpc*(1/m))+(PREV*(1-(1/m))));
dt:=cpc-trend;
noise:=cf*Sqrt(Mov(dt*dt,n,S));
trend/noise
*/

//---- свойства индикатора --------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  Blue

//---- внешние параметры ----------------------------------------------------------------------+
extern double TrendPeriod                     = 4;     // m:=Input("% Scalar trend period",1,25,4);
extern int    NoisePeriod                     = 250;   // n:=Input("% Scalar noise period",1,500,250);
extern double CorrectionFactor                = 2;     // cf:=Input("% Scalar correction factor",1,250,2);
extern int    MA1_Period                      = 7;     // p1:=Input("First moving average periods",1,200,7);
extern int    MA2_Period                      = 15;    // p2:=Input("Second moving average periods",1,200,15);

//---- внутренние параметры -------------------------------------------------------------------+
static int    NoiseMethod                     = 0;     // тип MA "Noise": 0 = Simple, 1 = Exponential, 2 = Smoothed, 3 = Weighted
static int    MA1_Method                      = 1;     // тип MA #1: 0 = Simple, 1 = Exponential, 2 = Smoothed, 3 = Weighted
static int    MA1_Price                       = 0;     // цена для MA #1: 0 = Close, 1 = Open, 2 = High, 3 = Low, 4 = Median, 5 = Typical, 6 = Weighted
static int    MA2_Method                      = 1;     // тип MA #2: 0 = Simple, 1 = Exponential, 2 = Smoothed, 3 = Weighted
static int    MA2_Price                       = 0;     // цена для MA #2: 0 = Close, 1 = Open, 2 = High, 3 = Low, 4 = Median, 5 = Typical, 6 = Weighted
static int    DigitsAfterDot                  = 4;     // количество цифр после десятичной точки (максимум 8)

//---- буфферы --------------------------------------------------------------------------------+
static double TQQ[];
static double pds[];
static double cpc[];
static double trend[];
static double dt2[];

//----- глобальные переменные -----------------------------------------------------------------+
static double point;
static double koef_1;
static double koef_2;

//---------------------------------------------------------------------------------------------+
//---- инициализация индикатора ---------------------------------------------------------------+
//---------------------------------------------------------------------------------------------+
int init()
  {
   //---- установка "короткого" имени индикатора ----------------------------------------------+
   IndicatorShortName("Q-indicator");
   //---- 4 дополниетльных буффера ------------------------------------------------------------+
   IndicatorBuffers(5);
   //---- установка точности значений индикатора ----------------------------------------------+
   if(DigitsAfterDot > 8) DigitsAfterDot = 8;
   IndicatorDigits(DigitsAfterDot);
   //---- установка стиля линий индикатора ----------------------------------------------------+
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   //---- установка массивов для линий индикатора ---------------------------------------------+
   SetIndexBuffer(0,TQQ);
   SetIndexBuffer(1,pds);
   SetIndexBuffer(2,cpc);
   SetIndexBuffer(3,trend);
   SetIndexBuffer(4,dt2);
   //---- установка названий для линий --------------------------------------------------------+
   SetIndexLabel(0,"Q-indicator");
   //---- определение констант ----------------------------------------------------------------+
   if(Digits < 4) point = 0.01;
   else point = 0.0001;
   koef_1 = 1.0 / TrendPeriod;
   koef_2 = 1.0 - koef_1;
   //---- конец инициализации -----------------------------------------------------------------+
   return(0);
   Print("---- Programming by Serega Lykov, http://mtexperts.narod.ru/ ----");
  }

//---------------------------------------------------------------------------------------------+
//---- деинициализация индикатора -------------------------------------------------------------+
//---------------------------------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }

//---------------------------------------------------------------------------------------------+
//---- Trend-Quality - Q-indicator ------------------------------------------------------------+
//---------------------------------------------------------------------------------------------+
int start()
  {
   //---- количество неизменённых после последнего вызова индикатора баров --------------------+
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   //---- последний посчитанный бар будет пересчитан ------------------------------------------+
   if(counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   for(int i=limit; i>=0; i--)
     {
      // rev:=Mov(C,p1,E)-Mov(C,p2,E);
      double rev = iMA(NULL,0,MA1_Period,0,MA1_Method,MA1_Price,i) - iMA(NULL,0,MA2_Period,0,MA2_Method,MA2_Price,i);
      if(rev > 0) pds[i] = 1;                           // pds:=If(rev>0,1,-1);
      else pds[i] = -1;
      int dc = (Close[i] - Close[i+1]) / point;         // dc:=ROC(C,1,$);
      if(pds[i] != pds[i+1])
        {
         cpc[i] = 0;                                    // cpc:=If(pds<>Ref(pds,-1),0,(dc*pds)+PREV);
         trend[i] = 0;                                  // trend:=If(pds<>Ref(pds,-1),0,(cpc*(1/m))+(PREV*(1-(1/m))));
        }
      else
        {
         cpc[i] = dc + cpc[i+1];                        // cpc:=If(pds<>Ref(pds,-1),0,(dc*pds)+PREV);
         trend[i] = cpc[i]*koef_1 + trend[i+1]*koef_2;  // trend:=If(pds<>Ref(pds,-1),0,(cpc*(1/m))+(PREV*(1-(1/m))));
        }
      double dt = cpc[i] - trend[i];                    // dt:=cpc-trend;
      dt2[i] = dt * dt;                                 // noise:=cf*Sqrt(Mov(dt*dt,n,S));
     }
   for(i=limit; i>=0; i--)
     {
      double noise = CorrectionFactor * MathSqrt(iMAOnArray(dt2,0,NoisePeriod,0,NoiseMethod,i));
      if(noise != 0) TQQ[i] = trend[i] / noise;         // trend/noise;
      else TQQ[i] = EMPTY_VALUE;
     }
   //---- завершение итерации -----------------------------------------------------------------+
   return(0);
  }

//-------------------------------- programming by Serega Lykov, http://mtexperts.narod.ru/ ----+