#property strict
//#property icon //
#property link                      ""
#property copyright                 "Cro$$luck"
#property version                   "1.00"
#property description               "Monster"
#property indicator_separate_window
//#property indicator_height//
#property indicator_buffers          2
//---- plot Line 
#property indicator_label1 "Histogram" 
#property indicator_color1 clrDarkGreen 
#property indicator_width1 1 
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_label2 "Histogram" 
#property indicator_color2 clrRed 
#property indicator_width2 1 
#property indicator_type2  DRAW_HISTOGRAM
//--- indicator parameters
extern string             S1               = "Настройки индикатора";
extern int                count_highest    = 100;                        //Число элементов High 
extern int                count_lowest     = 100;                        //Число элементов Low
extern int                distance         = 100;                        //Минимальная дистанция между верхней и нижней линией BB
extern ENUM_APPLIED_PRICE applied_price    = PRICE_CLOSE;                //Применить к
extern string             S2               = "Настройки Momentum";
extern int                momentum_period  = 14;                         //Период
extern double             momentum_level   = 100;                        //Уровень
extern string             S3               = "Настройки Moving Average";
extern int                ma_period        = 14;                         //Период
extern int                ma_shift         = 0;                          //Сдвиг
extern ENUM_MA_METHOD     ma_method        = MODE_SMA;                   //Метод MA
extern string             S4               = "Настройки Bollinger Bands";
extern int                bb_period        = 14;                         //Период
extern double             bb_deviation     = 2;                          //Отклонения
extern int                bb_shift         = 0;                          //Сдвиг
extern string             S5               = "Настройки графики";
extern int                counted_bars     = 1000;                       //Подсчет баров
extern string             S6               = "Настройки звука";
extern string             sound_file       = "alert.wav";                //Звуковой файл
extern bool               use_sound        = true;                       //Использование звука
extern bool               use_notification = false;                      //Использование телефона
extern bool               use_mail         = false;                      //Использование почты
bool sound_buy  = false; 
bool sound_sell = false;
//--- indicator buffers 
double histogram_01[];
double histogram_02[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit() 
  {
//--- indicator buffers mapping 
   SetIndexBuffer(0,histogram_01,INDICATOR_DATA); 
   SetIndexBuffer(1,histogram_02,INDICATOR_DATA); 
//--- максимальные и минимальные значения в подоконе  
   IndicatorSetDouble(INDICATOR_MINIMUM,0); 
   IndicatorSetDouble(INDICATOR_MAXIMUM,1); 
//--- 
   return(INIT_SUCCEEDED); 
  } 
int OnCalculate(const int rates_total, 
                const int prev_calculated, 
                const datetime& time[], 
                const double& open[], 
                const double& high[], 
                const double& low[], 
                const double& close[], 
                const long& tick_volume[], 
                const long& volume[], 
                const int& spread[]) 
  { 
   for(int shift=0;shift<counted_bars;shift++)
   {
   double highest=iHighest(_Symbol,_Period,MODE_HIGH,count_highest,shift);
   double lowest=iLowest(_Symbol,_Period,MODE_LOW,count_lowest,shift);
   double momentum=iMomentum(_Symbol,_Period,momentum_period,applied_price,shift);
   double ma=iMA(_Symbol,_Period,ma_period,ma_shift,ma_method,applied_price,shift);
   double bands_upper=iBands(_Symbol,_Period,bb_period,bb_deviation,bb_shift,applied_price,MODE_UPPER,shift);
   double bands_main=iBands(_Symbol,_Period,bb_period,bb_deviation,bb_shift,applied_price,MODE_MAIN,shift);
   double bands_lower=iBands(_Symbol,_Period,bb_period,bb_deviation,bb_shift,applied_price,MODE_LOWER,shift);
   double o=iOpen(_Symbol,_Period,shift);
   if(highest<lowest&&momentum>momentum_level&&o>ma&&o>bands_main&&bands_upper-bands_lower>distance*Point)
   histogram_01[shift]=100;
   if(highest>lowest&&momentum<momentum_level&&o<ma&&o<bands_main&&bands_upper-bands_lower>distance*Point)
   histogram_02[shift]=100;
   if(histogram_01[0]!=EMPTY_VALUE&&histogram_01[0]!=0&&sound_buy){
   sound_buy=false;
   if(use_sound)PlaySound(sound_file);
      Alert("(Monster)" " Поступил сигнал на покупку по символу " + Symbol() + ", на тайм-фрейме " + (string)Period() + " мин.," + " по цене " + (string)Bid); 
   if(use_mail)
      SendMail("(Monster)" " Поступил сигнал на покупку по символу.. ",  " Поступил сигнал на покупку по символу " + Symbol()+ ", на тайм-фрейме " + (string)Period() + " мин" + ", по цене " + (string)Bid );
   if(use_notification)
      SendNotification("(Monster)" " Поступил сигнал на покупку по символу " + Symbol() + ", на тайм-фрейме " + (string)Period() + " мин " + ", по цене " + (string)Bid);    
   }
   if(!sound_buy&&(histogram_01[0]==EMPTY_VALUE||histogram_01[0]==0))sound_buy=true;
   if(histogram_02[0]!=EMPTY_VALUE&&histogram_02[0]!=0&&sound_sell){
   sound_sell=false;
   if(use_sound)PlaySound(sound_file);
      Alert("(Monster)" " Поступил сигнал на продажу по символу " + Symbol()+ ", на тайм-фрейе " + (string)Period() + " мин.," + " по цене " + (string)Bid);
   if(use_mail)
      SendMail("(Monster)" " Поступил сигнал на продажу по символу.. ",  " Поступил сигнал на продажу по символу " + Symbol()+ ", на тайм-фрейе " + (string)Period()+ " минут" + ", по цене " + (string)Bid );
   if(use_notification)
      SendNotification("(Monster)" " Поступил сигнал на продажу по символу " + Symbol() + ", на тайм-фрейме " + (string)Period() + " минут " + ", по цене " + (string)Bid);  
   }
   if(!sound_sell&&(histogram_02[0]==EMPTY_VALUE||histogram_02[0]==0))sound_sell=true;
   }
   return(INIT_SUCCEEDED); 
  }