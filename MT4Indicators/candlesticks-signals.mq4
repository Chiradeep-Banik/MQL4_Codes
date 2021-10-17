//+------------------------------------------------------------------+
//|                                                    JapCandle.mq4 |
//|                                               Yuriy Tokman (YTG) |
//|                                               http://ytg.com.ua/ |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 clrLime
#property indicator_color2 clrRed

input bool   Alerts = true;
input string Text_BUY = "BUY signal text";
input string Text_SELL = "SELL signals text";
input bool   Send_Mail = false;
input string subject = "subject text";
input bool Send_Notification = false;

input double amendment = 2;
input color colir_buy = clrLime;
//цвет текста для отображения сигнала на покупку
input color colir_sell = clrRed;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];

string _name="JapCandle";
double ame =0;
string text_ = "";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorShortName(_name);
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"BUY SIGNALS");
   SetIndexDrawBegin(0,3);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"SELL SIGNALS");
   SetIndexDrawBegin(1,3);       
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   GetDell();
   Comment("");
//---   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
  ame = amendment;
  if(ame==0)ame=100;
  double rsi;
//---
   int limit=rates_total-prev_calculated-2;
   if(prev_calculated==0)limit--;
   else  limit++;  
   for( int i=limit; i>=0 && !IsStopped(); i--)
    {
     rsi = iRSI(Symbol(),0,14,0,i+2);
      if(Close[i+2]<Open[i+2] && 
         Close[i+1]>Open[i+1] &&
         Close[i+2]+(Open[i+2]-Close[i+2])/ame<Close[i+1] &&
         rsi<30){ExtMapBuffer1[i] = Low[i] - iATR(Symbol(),0,21,i)/3;
         ArrowLeftPriceCreate(0,"ytg_Price_BUY"+TimeToStr(Time[i]),0,Time[i],Open[i],colir_buy);
         TextCreate(0,"ytg_Text_BUY"+TimeToStr(Time[i]),0,Time[i],High[i],
         "Open BUY Price="+DoubleToStr(Open[i],Digits),"Arial",10,colir_buy,90,ANCHOR_LEFT);         
         }
     
      if(Close[i+2]>Open[i+2] && 
         Close[i+1]<Open[i+1] &&
         Close[i+2]-(Close[i+2]-Open[i+2])/ame>Close[i+1] &&
         rsi>70){ExtMapBuffer2[i] = High[i] + iATR(Symbol(),0,21,i)/3; 
         ArrowLeftPriceCreate(0,"ytg_Price_SELL"+TimeToStr(Time[i]),0,Time[i],Open[i],colir_sell);
         TextCreate(0,"ytg_Text_SELL"+TimeToStr(Time[i]),0,Time[i],Low[i],
         "Open SELL Price="+DoubleToStr(Open[i],Digits),"Arial",10,colir_sell,-90,ANCHOR_LEFT);                   
         }    
    }
//---
   string txt = WindowExpertName()+" "+Symbol()+"  "+GetNameTF()+"  ";
   
   if(NewBar())
    {
     rsi = iRSI(Symbol(),0,14,0,2);
      if(Close[2]<Open[2] && 
         Close[1]>Open[1] &&
         Close[2]+(Open[2]-Close[2])/ame<Close[1] &&
         rsi<30){
          text_= " Price Open = "+DoubleToStr(Ask,Digits);
          if(Alerts)Alert(txt+Text_BUY+text_);
          if(Send_Mail)SendMail(txt+subject,Text_BUY+text_);     
          if(Send_Notification)SendNotification(txt+Text_BUY+text_);         
         }
      if(Close[2]>Open[2] && 
         Close[1]<Open[1] &&
         Close[2]-(Close[2]-Open[2])/ame>Close[1] &&
         rsi>70){
          text_= " Price Open = "+DoubleToStr(Bid,Digits);
          if(Alerts)Alert(txt+Text_SELL+text_);
          if(Send_Mail)SendMail(txt+subject,Text_SELL+text_);
          if(Send_Notification)SendNotification(txt+Text_SELL+text_);         
         }             
    }   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Создает объект "Текст"                                           | 
//+------------------------------------------------------------------+ 
bool TextCreate(const long              chart_ID=0,               // ID графика 
                const string            name="Text",              // имя объекта 
                const int               sub_window=0,             // номер подокна 
                datetime                time=0,                   // время точки привязки 
                double                  price=0,                  // цена точки привязки 
                const string            text="Text",              // сам текст 
                const string            font="Arial",             // шрифт 
                const int               font_size=10,             // размер шрифта 
                const color             clr=clrRed,               // цвет 
                const double            angle=0.0,                // наклон текста 
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки 
                const bool              back=false,               // на заднем плане 
                const bool              selection=false,          // выделить для перемещений 
                const bool              hidden=true,              // скрыт в списке объектов 
                const long              z_order=0)                // приоритет на нажатие мышью 
  { 
//---
 if(ObjectFind(name)>=0)ObjectDelete(name);//если text уже создан удаляем его, ввиду случайного перетаскивания мышью
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим объект "Текст" 
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать объект \"Текст\"! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
//--- установим текст 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- установим шрифт текста 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- установим размер шрифта 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- установим угол наклона текста 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
//--- установим способ привязки 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- установим цвет 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- включим (true) или отключим (false) режим перемещения объекта мышью 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- установим приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- успешное выполнение 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Создает левую ценовую метку                                      | 
//+------------------------------------------------------------------+ 
bool ArrowLeftPriceCreate(const long            chart_ID=0,        // ID графика 
                          const string          name="LeftPrice",  // имя ценовой метки 
                          const int             sub_window=0,      // номер подокна 
                          datetime              time=0,            // время точки привязки 
                          double                price=0,           // цена точки привязки 
                          const color           clr=clrRed,        // цвет ценовой метки 
                          const ENUM_LINE_STYLE style=STYLE_DOT, // стиль окаймляющей линии 
                          const int             width=1,           // размер ценовой метки 
                          const bool            back=false,        // на заднем плане 
                          const bool            selection=false,    // выделить для перемещений 
                          const bool            hidden=true,       // скрыт в списке объектов 
                          const long            z_order=0)         // приоритет на нажатие мышью 
  { 
//--- установим координаты точки привязки, если они не заданы 
    if(ObjectFind(name)>=0)ObjectDelete(name);//если ценовая метка уже создан удаляем ее, ввиду случайного перетаскивания мышью 
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим ценовую метку 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_RIGHT_PRICE,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать левую ценовую метку! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
//--- установим цвет метки 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- установим стиль окаймляющей линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- установим размер метки 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- включим (true) или отключим (false) режим перемещения метки мышью 
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект 
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection 
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- установим приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- успешное выполнение 
   return(true); 
}
void GetDell( string name = "ytg_")
 {
  string vName;
  for(int i=ObjectsTotal()-1; i>=0;i--)
   {
    vName = ObjectName(i);
    if (StringFind(vName,name) !=-1) ObjectDelete(vName);
   }
 }
//----
bool NewBar(int TF = 0)
  {
   static datetime NewTime=0;
   if(NewTime!=iTime(Symbol(),TF,0))
    {      
     NewTime=iTime(Symbol(),TF,0);
     return(true);
    }
   return(false);     
  }
//----
string GetNameTF(int TimeFrame=0) {
  if (TimeFrame==0) TimeFrame=Period();
  switch (TimeFrame) {
    case PERIOD_M1:  return("M1");
    case PERIOD_M5:  return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M30");
    case PERIOD_H1:  return("H1");
    case PERIOD_H4:  return("H4");
    case PERIOD_D1:  return("Daily");
    case PERIOD_W1:  return("Weekly");
    case PERIOD_MN1: return("Monthly");
    default:         return("UnknownPeriod");
  }
}
//----

