//+------------------------------------------------------------------+
//|                                                   NRTR_Gator.mq4 |
//|                                                             Rosh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Tomato
#property indicator_color2 DeepSkyBlue
#property indicator_color3 DeepSkyBlue
#property indicator_color4 Tomato
#property indicator_color5 Green
#property indicator_color6 Red
//---- input parameters
extern int       PerATR=40;
extern double    kATR=2.0;
extern bool      useSendMail=false;
//---- buffers
double SellBuffer[];
double BuyBuffer[];
double Ceil[];
double Floor[];
double Trend[];
double UpBar[];
double DownBar[];
double GatorTrend[];
int sm_Bars, supervizerShift,SymbolSpread,GatorBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,251);
   SetIndexBuffer(0,SellBuffer);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"Линия продажи");

   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,251);
   SetIndexBuffer(1,BuyBuffer);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,"Линия покупки");

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,Ceil);
   SetIndexEmptyValue(2,0.0);
   SetIndexLabel(2,"Потолок");

   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,Floor);
   SetIndexEmptyValue(3,0.0);
   SetIndexLabel(3,"Пол");

   SetIndexStyle(4,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexBuffer(4,UpBar);
   SetIndexEmptyValue(4,0.0);
   SetIndexLabel(4,"Верх бара");

   SetIndexStyle(5,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexBuffer(5,DownBar);
   SetIndexEmptyValue(5,0.0);
   SetIndexLabel(5,"Низ бара");

   SetIndexBuffer(6,Trend);   
   SetIndexEmptyValue(6,0.0);
   SetIndexLabel(6,"NRTR тренд");
   
   SetIndexBuffer(7,GatorTrend);   
   SetIndexEmptyValue(7,0.0);
   SetIndexLabel(7,"Gator тренд");

   SymbolSpread=MarketInfo(Symbol(),MODE_SPREAD);

   //----
   return(0);
  }
//+------------------------------------------------------------------+
//| пробитие верха ДАУНтренда                              |
//+------------------------------------------------------------------+
bool BreakDown(int shift)
  {
   bool result=false;
   if (Close[shift]>SellBuffer[shift+1]) result=true;
   return(result);
  }

//+------------------------------------------------------------------+
//| пробитие дна АПтренда                              |
//+------------------------------------------------------------------+
bool BreakUp(int shift)
  {
   bool result=false;
   if (Close[shift]<BuyBuffer[shift+1]) result=true;
   return(result);
  }

//+------------------------------------------------------------------+
//| взятие нового минимума по ДАУНтренду                             |
//+------------------------------------------------------------------+
bool BreakFloor(int shift)
  {
   bool result=false;
   if (High[shift]<Floor[shift+1]) result=true;
   return(result);
  }

//+------------------------------------------------------------------+
//| взятие нового максимума по АПтренду                              |
//+------------------------------------------------------------------+
bool BreakCeil(int shift)
  {
   bool result=false;
   if (Low[shift]>Ceil[shift+1]) result=true;
   return(result);
  }

//+------------------------------------------------------------------+
//| определение предыдущего тренда                                   |
//+------------------------------------------------------------------+
bool Uptrend(int shift)
  {
   bool result=false;
   if (Trend[shift+1]==1.0) result=true;
   if (Trend[shift+1]==-1.0) result=false;
   if ((Trend[shift+1]!=1.0)&&(Trend[shift+1]!=-1)) Print("Внимание! Тренд не определен, такого быть не может. Бар от конца ",(Bars-shift));
   return(result);
  }

//+------------------------------------------------------------------+
//| вычисление волатильности                                         |
//+------------------------------------------------------------------+
double ATR(int iPer,int shift)
  {
   double result;
   result=iATR(NULL,0,iPer,shift);
   return(result);
  }
//+------------------------------------------------------------------+
//| установка нового уровня потолка                                  |
//+------------------------------------------------------------------+
void NewCeil(int shift)
  {
   Ceil[shift]=Close[shift];
   Floor[shift]=0.0;
  }

//+------------------------------------------------------------------+
//| установка нового уровня пола                                     |
//+------------------------------------------------------------------+
void NewFloor(int shift)
  {
   Floor[shift]=Close[shift];
   Ceil[shift]=0.0;
  }

//+------------------------------------------------------------------+
//| установка уровня поддержки АПтренда                              |
//+------------------------------------------------------------------+
void SetBuyBuffer(int shift)
  {
   BuyBuffer[shift]=Close[shift]-kATR*ATR(PerATR,shift);
   SellBuffer[shift]=0.0;
  }

//+------------------------------------------------------------------+
//| установка уровня поддержки ДАУНтренда                            |
//+------------------------------------------------------------------+
void SetSellBuffer(int shift)
  {
   SellBuffer[shift]=Close[shift]+kATR*ATR(PerATR,shift);
   BuyBuffer[shift]=0.0;
  }

//+------------------------------------------------------------------+
//| реверс тренда и установка новых уровней                          |
//+------------------------------------------------------------------+
void NewTrend(int shift)
  {
   if (Trend[shift+1]==1.0) 
      {
      Trend[shift]=-1.0;
      NewFloor(shift);
      SetSellBuffer(shift);
      }
   else 
      {
      Trend[shift]=1.0;
      NewCeil(shift);
      SetBuyBuffer(shift);
      }
   if ((Trend[shift+1]!=1)&&(Trend[shift+1]!=-1)) Print("Внимание! Тренд не определен, такого быть не может");
  }

//+------------------------------------------------------------------+
//| продолжение тренда                                               |
//+------------------------------------------------------------------+
void CopyLastValues(int shift)
  {
   SellBuffer[shift]=SellBuffer[shift+1];
   BuyBuffer[shift]=BuyBuffer[shift+1];
   Ceil[shift]=Ceil[shift+1];
   Floor[shift]=Floor[shift+1];
   Trend[shift]=Trend[shift+1];
  }

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int    counted_bars=IndicatorCounted();
   int limit;
   if (counted_bars>0) limit=Bars-counted_bars;
   if (counted_bars<0) return(0);
   if (counted_bars==0) 
      {
      limit=Bars-PerATR-1;
      if (Close[limit+1]>Open[limit+1]) {Trend[limit+1]=1.0;Ceil[limit+1]=Close[limit+1];BuyBuffer[limit+1]=Close[limit+1]-kATR*ATR(PerATR,limit+1);}
      if (Close[limit+1]<Open[limit+1]) {Trend[limit+1]=-1.0;Floor[limit+1]=Close[limit+1];SellBuffer[limit+1]=Close[limit+1]+kATR*ATR(PerATR,limit+1);}
      if (Close[limit+1]==Open[limit+1]) {Trend[limit+1]=1.0;Ceil[limit+1]=Close[limit+1];BuyBuffer[limit+1]=Close[limit+1]-kATR*ATR(PerATR,limit+1);}
      }
//----
   for (int cnt=limit;cnt>=0;cnt--)
      {
      supervizerShift=cnt;

      if ((iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,cnt)<iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,cnt))&&
         (iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,cnt)<iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,cnt)))
         GatorTrend[cnt]=1.0;
      if ((iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,cnt)>iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,cnt))&&
         (iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,cnt)>iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,cnt)))
         GatorTrend[cnt]=-1.0;

      if(GatorTrend[cnt]==1.0) {UpBar[cnt]=High[cnt];DownBar[cnt]=Low[cnt];}
      if(GatorTrend[cnt]==-1.0) {UpBar[cnt]=Low[cnt];DownBar[cnt]=High[cnt];}

      if (Uptrend(cnt))
         {
         if (BreakCeil(cnt))
            {
            NewCeil(cnt);
            SetBuyBuffer(cnt);
            Trend[cnt]=1.0;
            continue;
            }
         if (BreakUp(cnt))
            {
            NewTrend(cnt);
            continue;
            }   
         CopyLastValues(cnt);
         }
      else
         {
         if (BreakFloor(cnt))
            {
            NewFloor(cnt);
            SetSellBuffer(cnt);
            Trend[cnt]=-1.0;
            continue;
            }
         if (BreakDown(cnt))
            {
            NewTrend(cnt);
            continue;
            }   
         CopyLastValues(cnt);
         }
      } 

//----
   return(0);
  }
//+------------------------------------------------------------------+