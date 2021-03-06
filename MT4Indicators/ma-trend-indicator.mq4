//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property description ""
#property indicator_chart_window

//+------------------------------------------------------------------
extern int  Period_MA_1       = 35;
extern int  Period_MA_5       = 35;
extern int  Period_MA_15      = 35;
extern int  Period_MA_30      = 35;
extern int  Period_MA_1H      = 35;
extern int  Period_MA_4H      = 35;
extern int  Period_MA_1D      = 35;
extern int  Period_MA_1W      = 35;
extern int  Period_MA_MN      = 35;

extern int  ma_shift          = 0;
input ENUM_MA_METHOD ma_method=MODE_SMMA;
input ENUM_APPLIED_PRICE applied_price=PRICE_OPEN;
extern int X=270;
extern double size=1.0;

int Period_MA[9];
int TF[9]={1,5,15,30,60,240,1440,10080,43200};
//--------------------------------------------------------------------
int OnInit()
  {
   Comment("");
   Period_MA[0]=Period_MA_1;
   Period_MA[1]=Period_MA_5;
   Period_MA[2]=Period_MA_15;
   Period_MA[3]=Period_MA_30;
   Period_MA[4]=Period_MA_1H;
   Period_MA[5]=Period_MA_4H;
   Period_MA[6]=Period_MA_1D;
   Period_MA[7]=Period_MA_1W;
   Period_MA[8]=Period_MA_MN;
   EditCreate(0,"cm-Period",0,X-50*size,1,50*size,20*size,"Period MA","Arial",7,ALIGN_CENTER,true,CORNER_LEFT_UPPER,clrBlack,clrWhite,clrLightGray);
   ButtonCreate(0,"cm-Alert",0,X-50*size,20*size+2,50*size,20*size,"Alert",10,8);
   EditCreate(0,"cm-Trend",0,X-50*size,40*size+3,50*size,20*size,"Trend MA","Arial",7,ALIGN_CENTER,true,CORNER_LEFT_UPPER,clrBlack,clrWhite,clrLightGray);
   for(int i=0; i<9; i++)
     {
      EditCreate(0,StringConcatenate("cm-Pr",TF[i]),0,X,1,20*size,20*size,IntegerToString(Period_MA[i]),"Arial",8,ALIGN_CENTER,false,CORNER_LEFT_UPPER,clrBlack,clrWhite,clrLightGray);
      ButtonCreate(0,StringConcatenate("cm-TF",TF[i]),0,X,20*size+2,20*size,20*size,string_per(TF[i]),10,8);
      EditCreate(0,StringConcatenate("cm-MA",TF[i]),0,X,40*size+3,20*size,20*size,CharToStr(185),"Wingdings",10,ALIGN_CENTER,true);
      X+=20*size;
     }
   return(INIT_SUCCEEDED);
  }
//--------------------------------------------------------------------
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"cm");
  }
//--------------------------------------------------------------------
int Char(int i)
  {
   if(i>0) return(233);
   if(i<0) return(234);
   return(192);
  }
//--------------------------------------------------------------------
color Color(double i)
  {
   if(i==1) return(clrBlue);
   if(i==-1) return(clrRed);
   return(clrGray);
  }
//--------------------------------------------------------------------
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
   int i;
   string name;
   int s=0,MA=0,b=0;
   for(i=0; i<9; i++)
     {
      int P_MA=(int)StringToInteger(ObjectGetString(0,StringConcatenate("cm-Pr",TF[i]),OBJPROP_TEXT));
      name=StringConcatenate("cm-MA",TF[i]);
      double MA0=NormalizeDouble(iMA(NULL,TF[i],P_MA,ma_shift,ma_method,applied_price,0),Digits+1);
      double MA1=NormalizeDouble(iMA(NULL,TF[i],P_MA,ma_shift,ma_method,applied_price,1),Digits+1);
      if(MA0>MA1) {MA= 1;}
      if(MA0<MA1) {MA=-1;}
      ObjectSetInteger(0,name,OBJPROP_COLOR,Color(MA));
      ObjectSetString(0,name,OBJPROP_TEXT,CharToStr(Char(MA)));

      if(ObjectGetInteger(0,StringConcatenate("cm-TF",TF[i]),OBJPROP_STATE))
        {
         if(MA>0) b+=MA;
         if(MA<0) s+=MA;
         ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrLime);
         //Comment(P_MA,"\n",DoubleToStr(MA0,6),"\n",DoubleToStr(MA1,6));
        }
      else
        {
         ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrLightGray);
        }
     }
//if (b==0 && s==0) Comment("Не выбраны ТФ");
//if (b>0 && s<0) Comment("Нет совпадений");
   if(b==0 && s<0)
     {
      if(ObjectGetInteger(0,"cm-Alert",OBJPROP_STATE))
        {
         ObjectSetInteger(0,"cm-Alert",OBJPROP_STATE,false);
         Alert(Symbol()," SELL");
        }
      //Comment("Продажи");
     }
   if(b>0 && s==0)
     {
      if(ObjectGetInteger(0,"cm-Alert",OBJPROP_STATE))
        {
         ObjectSetInteger(0,"cm-Alert",OBJPROP_STATE,false);
         Alert(Symbol()," BUY");
        }
      //Comment("Покупки");
     }
   return(rates_total);
  }
//--------------------------------------------------------------------
string string_per(int per)
  {
   if(per == 1)     return("M1");
   if(per == 5)     return("M5");
   if(per == 15)    return("15");
   if(per == 30)    return("30");
   if(per == 60)    return("H1");
   if(per == 240)   return("H4");
   if(per == 1440)  return("D1");
   if(per == 10080) return("W1");
   if(per == 43200) return("MN");
   return("ошибка периода");
  }
//--------------------------------------------------------------------
bool ButtonCreate(const long              chart_ID=0,               // ID графика
                  const string            name="Button",            // имя кнопки
                  const int               sub_window=0,             // номер подокна
                  const long               x=0,                     // координата по оси X
                  const long               y=0,                     // координата по оси Y
                  const int               width=50,                 // ширина кнопки
                  const int               height=18,                // высота кнопки
                  const string            text="Button",            // текст
                  const string            font="Arial",             // шрифт
                  const int               font_size=10,             // размер шрифта
                  const color             clr=clrBlack,             // цвет текста
                  const color             back_clr=clrLightGray,    // цвет фона
                  const color            border_clr=clrNONE,// цвет границы 
                  const bool              state=false) // нажата/отжата
  {
   if(ObjectFind(chart_ID,name)==-1)
     {
      ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,1);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,clrNONE);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);

   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
  }
//--------------------------------------------------------------------
bool EditCreate(const long             chart_ID=0,               // ID графика 
                const string           name="Edit",              // имя объекта 
                const int              sub_window=0,             // номер подокна 
                const int              x=0,                      // координата по оси X 
                const int              y=0,                      // координата по оси Y 
                const int              width=50,                 // ширина 
                const int              height=18,                // высота 
                const string           text="Text",              // текст 
                const string           font="Arial",             // шрифт 
                const int              font_size=8,             // размер шрифта 
                const ENUM_ALIGN_MODE  align=ALIGN_RIGHT,       // способ выравнивания 
                const bool             read_only=true,           // возможность редактировать 
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // угол графика для привязки 
                const color            clr=clrBlack,             // цвет текста 
                const color            back_clr=clrWhite,        // цвет фона 
                const color            border_clr=clrWhite,// цвет границы 
                const bool             back=false,               // на заднем плане 
                const bool             selection=false,          // выделить для перемещений 
                const bool             hidden=true,              // скрыт в списке объектов 
                const long             z_order=0)                // приоритет на нажатие мышью 
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+ 
