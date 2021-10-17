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
//���� ������ ��� ����������� ������� �� �������
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
//| ������� ������ "�����"                                           | 
//+------------------------------------------------------------------+ 
bool TextCreate(const long              chart_ID=0,               // ID ������� 
                const string            name="Text",              // ��� ������� 
                const int               sub_window=0,             // ����� ������� 
                datetime                time=0,                   // ����� ����� �������� 
                double                  price=0,                  // ���� ����� �������� 
                const string            text="Text",              // ��� ����� 
                const string            font="Arial",             // ����� 
                const int               font_size=10,             // ������ ������ 
                const color             clr=clrRed,               // ���� 
                const double            angle=0.0,                // ������ ������ 
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // ������ �������� 
                const bool              back=false,               // �� ������ ����� 
                const bool              selection=false,          // �������� ��� ����������� 
                const bool              hidden=true,              // ����� � ������ �������� 
                const long              z_order=0)                // ��������� �� ������� ����� 
  { 
//---
 if(ObjectFind(name)>=0)ObjectDelete(name);//���� text ��� ������ ������� ���, ����� ���������� �������������� �����
//--- ������� �������� ������ 
   ResetLastError(); 
//--- �������� ������ "�����" 
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": �� ������� ������� ������ \"�����\"! ��� ������ = ",GetLastError()); 
      return(false); 
     } 
//--- ��������� ����� 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- ��������� ����� ������ 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- ��������� ������ ������ 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- ��������� ���� ������� ������ 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
//--- ��������� ������ �������� 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- ��������� ���� 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- ��������� �� �������� (false) ��� ������ (true) ����� 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- ������� (true) ��� �������� (false) ����� ����������� ������� ����� 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- ������ (true) ��� ��������� (false) ��� ������������ ������� � ������ �������� 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- ��������� ��������� �� ��������� ������� ������� ���� �� ������� 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- �������� ���������� 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| ������� ����� ������� �����                                      | 
//+------------------------------------------------------------------+ 
bool ArrowLeftPriceCreate(const long            chart_ID=0,        // ID ������� 
                          const string          name="LeftPrice",  // ��� ������� ����� 
                          const int             sub_window=0,      // ����� ������� 
                          datetime              time=0,            // ����� ����� �������� 
                          double                price=0,           // ���� ����� �������� 
                          const color           clr=clrRed,        // ���� ������� ����� 
                          const ENUM_LINE_STYLE style=STYLE_DOT, // ����� ����������� ����� 
                          const int             width=1,           // ������ ������� ����� 
                          const bool            back=false,        // �� ������ ����� 
                          const bool            selection=false,    // �������� ��� ����������� 
                          const bool            hidden=true,       // ����� � ������ �������� 
                          const long            z_order=0)         // ��������� �� ������� ����� 
  { 
//--- ��������� ���������� ����� ��������, ���� ��� �� ������ 
    if(ObjectFind(name)>=0)ObjectDelete(name);//���� ������� ����� ��� ������ ������� ��, ����� ���������� �������������� ����� 
//--- ������� �������� ������ 
   ResetLastError(); 
//--- �������� ������� ����� 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_RIGHT_PRICE,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": �� ������� ������� ����� ������� �����! ��� ������ = ",GetLastError()); 
      return(false); 
     } 
//--- ��������� ���� ����� 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- ��������� ����� ����������� ����� 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- ��������� ������ ����� 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- ��������� �� �������� (false) ��� ������ (true) ����� 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- ������� (true) ��� �������� (false) ����� ����������� ����� ����� 
//--- ��� �������� ������������ ������� �������� ObjectCreate, �� ��������� ������ 
//--- ������ �������� � ����������. ������ �� ����� ������ �������� selection 
//--- �� ��������� ����� true, ��� ��������� �������� � ���������� ���� ������ 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- ������ (true) ��� ��������� (false) ��� ������������ ������� � ������ �������� 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- ��������� ��������� �� ��������� ������� ������� ���� �� ������� 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- �������� ���������� 
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

