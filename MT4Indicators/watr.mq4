//+------------------------------------------------------------------+
//|                                                        WATR.mq4  |
//|                      Written WizardSerg under article konkop in  |
//|                                        "Modern trading" #4/2001  |
//|                                  http://www.wizardserg.inweb.ru  |
//|                                              wizardserg@mail.ru  |
//+------------------------------------------------------------------+
#property copyright "Written WizardSerg under article konkop in <Modern trading> #4/2001"
#property link      "http://www.wizardserg.inweb.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Coral
#property indicator_color2 DodgerBlue
//---- input parameters
extern int    WATR_K = 10;
extern double WATR_M = 4.0;
extern int    ATR = 21;
//---- buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {  
   IndicatorBuffers(2);  
   SetIndexBuffer(0, ExtMapBufferUp); 
   ArraySetAsSeries(ExtMapBufferUp, true);      
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(1, ExtMapBufferDown); 
   ArraySetAsSeries(ExtMapBufferDown, true);      
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   IndicatorShortName("WATR(" + WATR_K + ", " + WATR_M + ")"); 
   SetIndexLabel(0, "WATR_Up");
   SetIndexLabel(1, "WATR_Dn");    
   return(0); 
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
bool AntiTrendBar(int i)
  {
   bool res = (TrendUp(i) && (Close[i] < Open[i])) ||         
              (!TrendUp(i) && (Close[i] > Open[i]));    
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
double CalcIndicValue(int i, bool trend)
  {
   double res = Close[i];  
   if(trend)
       res -= (WATR_K*Point + WATR_M*iATR(NULL, 0, ATR, i));
   else
       res += (WATR_K*Point + WATR_M*iATR(NULL, 0, ATR, i));        
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
bool TrendUp(int i)
  {
   return((Close[i+1] > ExtMapBufferUp[i+1]) && 
          (ExtMapBufferUp[i+1] != EMPTY_VALUE));
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
//---- последний посчитанный бар будет пересчитан
//---- первое значение индикатора == цене-1 point, 
//     то есть считает тренд восходящим
   ExtMapBufferUp[Bars] = Close[Bars] - WATR_K*Point;     
// limit = (counted_bars > 0) ? (Bars - counted_bars) : (Bars - 1);
   limit = Bars - counted_bars;
//---- основной цикл
   for(int i = limit; i >= 0; i--)
     {
       if(AntiTrendBar(i))
         {
           ExtMapBufferUp[i] = ExtMapBufferUp[i+1];            
           ExtMapBufferDown[i] = ExtMapBufferDown[i+1];            
         }
       else
         {
           if(TrendUp(i))
             {
               ExtMapBufferUp[i] = CalcIndicValue(i, true);
               if(ExtMapBufferUp[i] < ExtMapBufferUp[i+1])
                   ExtMapBufferUp[i] = ExtMapBufferUp[i+1];                                 
               ExtMapBufferDown[i] = EMPTY_VALUE; 
             }
           else
             {
               ExtMapBufferDown[i] = CalcIndicValue(i, false);                        
               if(ExtMapBufferDown[i] > ExtMapBufferDown[i+1])
                   ExtMapBufferDown[i] = ExtMapBufferDown[i+1];                                             
               ExtMapBufferUp[i] = EMPTY_VALUE;
             }
         }
       // пересечения с ценой                 
       if(TrendUp(i) && (Close[i] < ExtMapBufferUp[i]))
         {
           ExtMapBufferDown[i] = CalcIndicValue(i, false);  
           ExtMapBufferUp[i] = EMPTY_VALUE;
         }
       if((!TrendUp(i)) && (Close[i] > ExtMapBufferDown[i]))
         {
           ExtMapBufferUp[i] = CalcIndicValue(i, true);                  
           ExtMapBufferDown[i] = EMPTY_VALUE; 
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+


