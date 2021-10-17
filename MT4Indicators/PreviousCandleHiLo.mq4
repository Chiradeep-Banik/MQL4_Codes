//+------------------------------------------------------------------+
//|                                           PreviousCandleHiLo.mq4 |
//|                                                            hairi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "hairi"
#property link      "https://www.mql5.com/en/users/hairi"
#property version   "1.00"
#property description   "Previous Candle Hi-Lo"
#property strict
#property indicator_chart_window

//+------------------------------------------------------------------+
//| Input variable                                                   |
//+------------------------------------------------------------------+
input ENUM_LINE_STYLE   linestyle   = STYLE_DOT;         // Line Style
input color             H1_color    = clrRed,            // Prev H1 color
                        H4_color    = clrGreen,          // Prev H4 color
                        D1_color    = clrBlue,           // Prev Day color
                        W1_color    = clrGold;           // Prev Week color

int         CalcDay = 7;
int         CalcBar = 0;
string      Objname,
ObjIdentifier="IN_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}   
//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDeleteAll();
   return (0);
  }

//+------------------------------------------------------------------+
//| Indicator Start                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int BarCheck=IndicatorCounted();
   if(BarCheck < 0) return (-1);
   if(BarCheck>0) BarCheck--;
   int TotalBar=Bars-BarCheck;

   for(int BarMeasure=0; BarMeasure<=240; BarMeasure++)
     {
      double H1_High = 0, H1_Low = 0;
      double H4_High = 0, H4_Low = 0;
      double D1_High = 0, D1_Low = 0;
      double W1_High = 0, W1_Low = 0;

      PrevPeriod(PERIOD_H1,H1_Low,H1_High,"Prev H1 High","Prev H1 Low",linestyle,H1_color,1);
      PrevPeriod(PERIOD_H4,H4_Low,H4_High,"Prev H4 High","Prev H4 Low",linestyle,H4_color,1);
      PrevPeriod(PERIOD_D1,D1_Low,D1_High,"Prev Day High","Prev Day Low",linestyle,D1_color,1);
      PrevPeriod(PERIOD_W1,W1_Low,W1_High,"Prev Week High","Prev Week Low",linestyle,W1_color,1);
     }
   return (0);
  }

//+------------------------------------------------------------------+
//| Object Delete all function                                       |
//+------------------------------------------------------------------+
void ObjectDeleteAll()
  {
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
  }
  
//+------------------------------------------------------------------+
//| Draw line function                                               |
//+------------------------------------------------------------------+
void DrawShortHLine(string nameX,int time1,double P0,int style,color clr,int width)
  {
   string objName;

   datetime T0 = iTime(Symbol(),PERIOD_H1,time1);
   datetime T1 = iTime(Symbol(),PERIOD_M1,1);

   objName=nameX;
   if(ObjectFind(0,ObjIdentifier+objName)!=0)
      ObjectCreate(ObjIdentifier+objName,OBJ_TREND,0,T0,P0,T1,P0);
   else
     {
      ObjectDelete(ObjIdentifier+objName);
      ObjectCreate(ObjIdentifier+objName,OBJ_TREND,0,T0,P0,T1,P0);
     }
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_RAY,false);
   ObjectSetInteger(0,ObjIdentifier+objName,OBJPROP_BACK,true);
//ObjectSetString (0,name,name);
  }

//+------------------------------------------------------------------+
//| Draw complete line function                                      |
//+------------------------------------------------------------------+
void HLine(string name,string desc,int pShiftTime,double pPrice,int pStyle,color pColor,int pWidth) export
  {
   DrawShortHLine(name,pShiftTime,pPrice,pStyle,pColor,pWidth);
   CreatePriceLabel(name+" Label",desc,pPrice,pColor);
   CreatePriceFlag(name+" Price",pPrice,pColor);
  }

//+------------------------------------------------------------------+
//| scale the view                                                   |
//+------------------------------------------------------------------+
int ChartScaleGet() export
  {
   long result=-1;
   ChartGetInteger(0,CHART_SCALE,0,result);
   return((int)result);
  }

//+------------------------------------------------------------------+
//| Create price flag function                                       |
//+------------------------------------------------------------------+
void CreatePriceFlag(string name,double price,color col) export
  {
   datetime time=Time[0]+Period()*60;

   if(ObjectFind(0,ObjIdentifier+name)!=0)
     {
      ObjectCreate(ObjIdentifier+name,OBJ_ARROW_RIGHT_PRICE,0,time,price);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,col);
     }

   else ObjectMove(ObjIdentifier+name,0,time,price);

  }

//+------------------------------------------------------------------+
//| Create price label function                                      |
//+------------------------------------------------------------------+
void CreatePriceLabel(string name,string desc,double price,color col) export
  {
   int Chart_Scale,Bar_Width;
   Chart_Scale=ChartScaleGet();

   if(Chart_Scale==0) Bar_Width=64;
   else if(Chart_Scale == 1) Bar_Width = 32;
   else if(Chart_Scale == 2) Bar_Width = 16;
   else if(Chart_Scale == 3) Bar_Width = 9;
   else if(Chart_Scale == 4) Bar_Width = 5;
   else if(Chart_Scale == 5) Bar_Width = 3;
   else Bar_Width=2;

   datetime time=Time[0]+Period()*60*Bar_Width;

   if(ObjectFind(0,ObjIdentifier+name)!=0)
     {
      ObjectCreate(ObjIdentifier+name,OBJ_TEXT,0,time,price);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetString(0,ObjIdentifier+name,OBJPROP_TEXT,desc);
      ObjectSetString(0,ObjIdentifier+name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,col);
     }

   else ObjectMove(ObjIdentifier+name,0,time,price);
  }

//+------------------------------------------------------------------+
//| Previous period function                                         |
//+------------------------------------------------------------------+
void PrevPeriod(int period,double high,double low,string hiname,string lowname,int style,color col,int width)
  {
   PrevCandle(period,low,high);
   HLine(hiname,hiname,10,high,style,col,width);
   HLine(lowname,lowname,10,low,style,col,width);
  }

//+------------------------------------------------------------------+
//| Previous candle function                                         |
//+------------------------------------------------------------------+
void PrevCandle(int period,double &low,double &high)
  {
   low=iLow(_Symbol,period,1);
   high=iHigh(_Symbol,period,1);
  }
//+------------------------------------------------------------------+
