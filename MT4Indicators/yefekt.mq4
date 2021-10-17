//+------------------------------------------------------------------+
//| Web:                                                Y(Efekt).mq4 |
//|                                                           MNS777 |
//|                                                mns777.ru@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Mns777"
#property link      ""
//----
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_minimum -1
#property indicator_maximum 1
//----
#property indicator_color5 Lime
#property indicator_color6 Red
//---- толщина индикаторных линий
#property indicator_width5 3
#property indicator_width6 3
//---- параметры горизонтальных уровней индикатора
#property indicator_level1  0
#property indicator_level2  0.5
#property indicator_level3  -0.5
//---- Внешние параметры
//---- Буферы индикатора
double IndexBuffer[];
double IndexBar[];
double Buf1[];
double Buf2[];
double ExtBuffer1[];
double ExtBuffer2[];
//---- Переменные
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,IndexBuffer);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,IndexBar);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(2,Buf1);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(3,Buf2);
   SetIndexStyle(3,DRAW_NONE);
   //
   SetIndexBuffer(4,ExtBuffer1);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(5,ExtBuffer2);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   //
   IndicatorShortName("Y(Efekt)");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,"Y(Efekt)");
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL);
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
   int limit,i,a;
   int counted_bars=IndicatorCounted();
   double current,X1;
   datetime TimeBar;
//---- проверка на возможные ошибки
   if(counted_bars<0) return(-1);
//---- последний посчитанный бар будет пересчитан
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- основной цикл
//---- 
   for(i=limit;i>=0;i--)
     {
      //Задание значений индекса индикатора
      X1=(High[i]-Low[i+4]);
      IndexBuffer[i]=(High[i]-Low[i])+(High[i+1]-Low[i+1]) +(High[i+2]-Low[i+2]) +(High[i+3]-Low[i+3])  +(High[i+4]-Low[i+4]) ;
      if(High[i] > Low[i+4] )IndexBar[i]=X1/IndexBuffer[i];
      if(Low[i] < High[i+4] )IndexBar[i]=(Low[i] - High[i+4] )/IndexBuffer[i];
     }
//---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=IndexBar[i];
      if(current>0) up=true;
      if(current<0) up=false;
      if(!up)
        {
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
        }
      else
        {
         ExtBuffer1[i]=current;
         ExtBuffer2[i]=0.0;
        }
      IndexBar[i]=current;
     }
//---- done    
   return(0);
  }
//+------------------------------------------------------------------+