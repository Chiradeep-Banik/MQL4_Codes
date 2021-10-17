//+------------------------------------------------------------------+
//|                                                     BarTimer.mq4 |
//|                               Copyright � 2008, Art Royal s.r.o. |
//|                                           Author: Vasyl Gumenyak |  
//|                                           http://www.jiport.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2008, Art Royal s.r.o."
#property link      "http://www.jiport.com/"

#property indicator_chart_window
#property indicator_buffers 0

extern string FontName="Arial Narrow";
extern int FontSize=14;
extern color FontColor=Gold;
extern int Corner=0;// values [0-3] - ������� ����
extern int XDistance=250;// x ���������� �� �������� ����
extern int YDistance=0;// y ���������� �� �������� ����

int lenbase;
string s_base=":...:...:...:...:";// ������ ��� ������������ ���������� � ���������

int init()
  {
   lenbase=StringLen(s_base);
   return(0);
  }

int deinit()
  {
   if (ObjectFind("BarTimer") != -1) ObjectDelete("BarTimer");
   return(0);
  }

//+------------------------------------------------------------------+
//| �������� �������� �������� ��������� �� �������                  |
//|   ������������ ������ � ����� �������� ����,                     |
//| ������������� ������ ���� �������                                |
//|   ���������� �� ������ ���� � ���������                          |
//+------------------------------------------------------------------+
int start()
  {
   int i=0,sec=0;
   double pc=0.0;
   string time="",s_end="",s_beg="";
   if (ObjectFind("BarTimer") == -1) {// ���� ������ �� ������ - ������� � ������ ���������
     ObjectCreate("BarTimer" , OBJ_LABEL,0,0,0);
     ObjectSet("BarTimer", OBJPROP_XDISTANCE, XDistance);
     ObjectSet("BarTimer", OBJPROP_YDISTANCE, YDistance);
     ObjectSet("BarTimer", OBJPROP_CORNER, Corner);
   }
   sec=TimeCurrent()-Time[0];// ����� � �������� �� ������ ����
   i=(lenbase-1)*sec/(Period()*60);// ������� ��������
   pc=100.0*sec/(Period()*60);// ����� �� ������ ���� � ���������
   if(i>lenbase-1) i=lenbase-1;// �������� �������� �������� �������
   if(i>0) s_beg=StringSubstr(s_base,0,i);
   if(i<lenbase-1) s_end=StringSubstr(s_base,i+1,lenbase-i-1);
   time=StringConcatenate(s_beg,"|",s_end,"  ",DoubleToStr(pc,0),"%");
   ObjectSetText("BarTimer", time, FontSize, FontName, FontColor);

   return(0);
  }
//+------------------------------------------------------------------+