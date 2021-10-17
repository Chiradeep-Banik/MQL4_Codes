//+------------------------------------------------------------------+
//|                                                    TRADE_DAY.mq4 |
//|                                                     Yuriy Tokman |
//|                                         http://www.mql-design.ru |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "http://www.mql-design.ru"

#property indicator_chart_window

extern color _color2 = Gainsboro;
extern int limit = 30;
extern bool Sho_bars = true;

string txt = "TRADE_DAY ";
color CL[5]={Red,Red,Red,Red,Lime};

extern string Copyright = "Yuriy Tokman";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   GetDellName (txt);
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   int limits;
   int counted_bars=IndicatorCounted();   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limits=Bars-counted_bars;   
//----
   if(Period()<1440 && limits>0){
    for(int i=limit; i>=0; i--){
     double   h = iHigh(Symbol(),1440,i);
     double   l = iLow(Symbol(),1440,i);
     double   o = iOpen(Symbol(),1440,i);
     double   c = iClose(Symbol(),1440,i);               
     datetime t = iTime(Symbol(),1440,i);
     datetime t_p = 11*60*60;
     datetime t_a = 1440*60;    
     string tx = TimeToStr(t,TIME_DATE );    
     int day = TimeDayOfWeek(t);
     TxtGraf(txt+tx, GetDayOfWeek(day), t+t_p, h+200*Point,CL[day-1]);    
     
     if(Sho_bars)
      {
       TrendLineGraff(txt+tx+" l",t,h,t,l);       
       TrendLineGraff(txt+tx+" k",t+t_a,h,t+t_a,l);            
       TrendLineGraff(txt+tx+" h",t,h,t+t_a,h);       
       TrendLineGraff(txt+tx+" w",t,l,t+t_a,l);       
       RICE_ARROW(txt+tx+" l1",t+(t-t+t_a)/2-60*60*2,h,_color2,1);       
       RICE_ARROW(txt+tx+" l2",t+(t-t+t_a)/2-60*60*2,l,_color2,1);     
       double p_1 = l;
       double p_2 = h;     
       if(o>c){p_1=h;p_2=l;}     
       TrendLineGraff(txt+tx+" z",t,o,t+t_a,c);
      }          
   }}  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Функция отображения текста                                       |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
 void TxtGraf(string labebe, string txt, datetime time1, double price1, color colir)
  {
   if (ObjectFind(labebe)!=-1) ObjectDelete(labebe);
   ObjectCreate(labebe, OBJ_TEXT, 0, time1, price1);
   ObjectSetText(labebe, txt, 10, "Times New Roman", colir); 
   ObjectSet(labebe, OBJPROP_BACK, true);     
  }
//+------------------------------------------------------------------+
//| Функция возвращает день недели для указанной даты.               |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
string GetDayOfWeek(int Day_Week) {
  switch (Day_Week ) {
    case 0  : return("7.Sunday");
    case 1  : return("1.Monday");
    case 2  : return("2.Tuesday");
    case 3  : return("3.Wednesday");
    case 4  : return("4.Thyrsday");
    case 5  : return("5.Friday");
    case 6  : return("6.Saturday");    
    default : return("Unknown Operation");
  }
}
//+------------------------------------------------------------------+
//| Функция удаляет объекты                                          |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
 void GetDellName (string name_n = "ytg_")
  {
   string vName;
   for(int i=ObjectsTotal()-1; i>=0;i--)
    {
     vName = ObjectName(i);
     if (StringFind(vName,name_n) !=-1) ObjectDelete(vName);
    }  
  }
//+------------------------------------------------------------------+
//| Функция отображения трендовой линии                              |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
 void TrendLineGraff(string labebe,datetime time1,double price1,datetime time2,double price2)
  {
   if (ObjectFind(labebe)!=-1) ObjectDelete(labebe);
   ObjectCreate(labebe, OBJ_TREND, 0,time1,price1,time2,price2);
   ObjectSet(labebe, OBJPROP_COLOR, _color2);
   ObjectSet(labebe, OBJPROP_STYLE,0);
   ObjectSet(labebe, OBJPROP_RAY,0);
   ObjectSet(labebe, OBJPROP_BACK, true);
  }
//+------------------------------------------------------------------+
//| Функция отображения ценовой метки                                |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
 void RICE_ARROW(string label,datetime time1,double price1,color colir,int WIDTH )
  {
   if (ObjectFind(label)!=-1) ObjectDelete(label);
   ObjectCreate(label,OBJ_ARROW, 0,time1,price1);
   ObjectSet(label,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
   ObjectSet(label, OBJPROP_COLOR, colir);
   ObjectSet(label, OBJPROP_WIDTH,WIDTH);
   ObjectSet(label, OBJPROP_BACK, false);
  }