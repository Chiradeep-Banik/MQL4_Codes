//+------------------------------------------------------------------+
//|                                                         AMkA.mq4 |
//|                                 Copyright © 2006, D&S kiriyenko. |
//|                 http://groups.google.com/group/expert-developing |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, D&S Kiriyenko."
#property link      "http://groups.google.com/group/expert-developing"
//---- 
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 2
#property indicator_color3 Blue
#property indicator_width3 2
//+------------------------------------------------------------------+
//| макроопределения                                                 |
//+------------------------------------------------------------------+
//---- строковые константы
#define INDICATOR_SHORT_NAME "AMkA"
#define MAIN "AMkA line"
#define UP   "UpTrend point"
#define DOWN "DownTrend point"
//+------------------------------------------------------------------+
//| внешние переменные                                               |
//+------------------------------------------------------------------+
//---- периоды
extern int       periodAMA    = 9;    //период расчёта к-та эффективности
extern double    nfast        = 2;    //период EMA для эффективного рынка
extern double    nslow        = 30;   //период EMA для неэффективного рынка
//---- расчёт сглаживающей константы
extern double    Pow          = 2.0;  //степень эффективности 
//---- фильтр сигналов
extern double    dK           = 1.0;  //коэффициент для фильтра
extern bool      use_stdev    = true; //использовать стандартное отклонение
//---- применять к цене
extern int       app_price    = 5;    //по умолчанию - к типической
//+------------------------------------------------------------------+
//| глобальные переменные                                            |
//+------------------------------------------------------------------+
//---- буферы
double kAMAbuffer[];
double kAMAupsig[];
double kAMAdownsig[];
//---- сглаживающие коэффициенты
double slowSC, fastSC;
//---- приращения индикатора
double ddAMA[];
//+------------------------------------------------------------------+
//| Вставка значения в массив приращений                             |
//+------------------------------------------------------------------+
bool InsertDif(double a)
  {
//---- проверка, заполнен ли массив
   for(int i = 0; i < periodAMA; i++) //для всех элементов массива
     if(ddAMA[i] == 0) //если элемент равен нулю
       {
         ddAMA[i] = a; //сохраняем значение в этот элемент
         return (true); //и удачно завершаемся
       }
//---- массив уже заполнен, нужно вставлять элемент с конца
   for(i = 0; i < periodAMA-1; i++) //все элементы массива, кроме последнего
       ddAMA[i] = ddAMA[i+1]; //сдвигаем влево на одну позицию
   ddAMA[periodAMA-1] = a; //и записываем значение в самую правую позицию
   return (true); //после чего удачно завершаемся
  }
//+------------------------------------------------------------------+
//| Запрос цены бара                                                 |
//+------------------------------------------------------------------+
double Price(int i, int app = PRICE_TYPICAL)
  {
   switch(app)
     {
       case PRICE_CLOSE:    return(Close[i]);                          break;
       case PRICE_OPEN:     return(Open[i]);                           break;
       case PRICE_HIGH:     return(High[i]);                           break;
       case PRICE_LOW:      return(Low[i]);                            break;
       case PRICE_MEDIAN:   return((High[i] + Low[i])/2);              break;
       case PRICE_TYPICAL:  return((High[i] + Low[i] + Close[i])/3);   break;
       case PRICE_WEIGHTED: return((High[i] + Low[i] + Close[i]*2)/4); break;
     }
  }
//+------------------------------------------------------------------+
//| Инициализация                                                    |
//+------------------------------------------------------------------+
int init()
  {
//---- главная линия
   SetIndexBuffer(0, kAMAbuffer);
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexLabel(0, MAIN);
   SetIndexEmptyValue(0, 0.0);
//---- подтверждение восходящего тренда
   SetIndexBuffer(1, kAMAupsig);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 159);
   SetIndexLabel(1, UP);
   SetIndexEmptyValue(1, 0.0);
//---- подтверждение нисходящего тренда
   SetIndexBuffer(2, kAMAdownsig);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 159);
   SetIndexLabel(2, DOWN);
   SetIndexEmptyValue(2, 0.0);
//---- настройки индикатора
   IndicatorDigits(4);
   string name = StringConcatenate(INDICATOR_SHORT_NAME,
                                   " (", periodAMA, "/", nfast, "/", nslow, ")");
   IndicatorShortName(name);
//---- расчёт к-тов    
   slowSC = (2.0 / (nslow + 1)); //медленный к-т сглаживания
   fastSC = (2.0 / (nfast + 1)); //быстрый к-т сглаживания
//---- подготовка массива
   ArrayResize(ddAMA, periodAMA);
   ArrayInitialize(ddAMA, 0.);
//---- готово
   return(0);
  }
//+------------------------------------------------------------------+
//| Деинициализация                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Итерационная функция                                             |
//+------------------------------------------------------------------+
int start()
  {
//---- оптимизация производительности   
   if(Bars <= periodAMA + 2) 
       return (0); //если баров на графике слишком мало, выходим
//---- оптимизация кода индикатора
   int counted_bars = IndicatorCounted(); //число баров, не изменённых с последнего вызова
   if(counted_bars < 0) 
       return (0); //защищаемся от ошибок
   else 
       if(counted_bars > 0) 
           counted_bars--; //последний посчитанный бар будет пересчитан
   int pos = Bars - periodAMA - 2; //позицию в начало отсчёта
   if(counted_bars > 0) 
       pos = Bars - counted_bars; //или определяем позицию
//---- подготовка переменных
   double AMA0 = Price(pos+1, app_price); //предыдущее АМА не расчитывалось
   if(kAMAbuffer[pos+1] > 0)
       AMA0 = kAMAbuffer[pos+1]; //или расчитывалось
   if(AMA0 == 0) 
       Print(Bars - pos);
//---- расчёт индикатора
   while(pos >= 0)
     {
       //---- расчёт сигнала
       double signal = MathAbs(Price(pos, app_price) - Price(pos + periodAMA, app_price));
       //---- расчёт шума
       double noise = 0.000000001;
       for(int i = 0; i < periodAMA; i++)
         {
           noise = noise + MathAbs(Price(pos+i, app_price) - Price(pos + i + 1, app_price));
         }
       //---- расчёт коэффициента сглаживания
       double ER = signal / noise; //коэффициент эффективности
       double SSC = ER*(fastSC - slowSC) + slowSC; //коэффициент сглаживания
       //---- расчёт главной линии
       double AMA = AMA0 + (MathPow(SSC, Pow)*(Price(pos, app_price) - AMA0)); //расчёт
       AMA = NormalizeDouble(AMA, Digits);
       kAMAbuffer[pos] = AMA; //вывод
       //---- расчёт фильтрации тренда
       double ddK = (AMA - AMA0) / Point; //разность
       if(use_stdev)
         {
           InsertDif(ddK); //накапливаем приращение
           if(pos < Bars - 2*(periodAMA + 2)) //если баров накопилось достаточно
             {
               //---- расчёт среднего арифметического
               double SMAdif = 0; //вначале равно нулю
               for(i = 0; i < periodAMA; i++)
                 {
                   SMAdif += ddAMA[i]; //последовательно суммируем
                 }
               SMAdif /= periodAMA; //и делим на количество
               //---- расчёт стандартного отклонения
               double StDev = 0; //вначале равно нулю
               for(i = 0; i < periodAMA; i++)
                 {
                   StDev += MathPow(ddAMA[i] - SMAdif, 2); //суммируем квадраты отклонений
                 }
               StDev = MathSqrt(StDev)/periodAMA; //извлекаем корень и делим на количество
               //---- расчёт фильтра
               double Filter = dK*StDev;
             }
           else 
               Filter = 100000;
         }
       else 
           Filter = dK;
       //---- обработка значений
       double var1 = 0, var2 = 0;
       if(ddK > Filter) 
           var1 = AMA; //есть восходящий тренд
       if(ddK < -Filter) 
           var2 = AMA; //есть нисходящий тренд
       kAMAupsig[pos] = var1; //нет восходящего тренда
       kAMAdownsig[pos] = var2; // нет нисходящего тренда
       //---- переход к концу цикла
       AMA0 = AMA; //сохраняем предыдущее значение AMA
       pos--; //переходим к сдедующему бару
     }
//---- завершение работы
   return(0); //готово
  }
//+------------------------------------------------------------------+


