//+------------------------------------------------------------------+
//|                                                          CMO.mq4 |
//|                                      Copyright � 2007, Alexandre |
//|                      http://www.kroufr.ru/content/view/1491/124/ |
//+------------------------------------------------------------------+
/* ������� ���������� ��� ���������                                  |
CMO_1                                                                |
Sum(If(C, >, Ref(C, -1), (C - Ref(C, -1)), 0), 14)                   |
CMO_2                                                                |
Sum(If(C, <, Ref(C, -1), (Ref(C, -1) - C)), 0), 14)                  |
CMO_Final                                                            |
100 *((Fml("CMO_1") - Fml("CMO_2")) / (Fml("CMO_1") + Fml("CMO_2"))) |
��������������� �������:                                             |
Chande's Momentum Oscillator                                         |
100 *                                                                |
((Sum(If(C, >, Ref(C, -1), (C - Ref(C,-1)), 0), 14)) -               |
 (Sum(If(C, <, REF(C, -1), (REF(C,-1) - C), 0), 14))) /              |
((Sum(If(C, >, Ref(C, -1), (C - Ref(C, -1)), 0), 14) +               |
 (Sum(If(C, <, REF(C, -1), (REF(C, -1) - C), 0), 14))))              |
//+------------------------------------------------------------------+
��������-���������� ����� �������������� ����� ������� ������� ����� |  
��������� ����������� ��� � ����������� ��� �� ����� ����� ��������� |
����������� ��� � ����������� ���. ���������� ��������� ���������� ��|
100. � ���������� �� �������� ���������, ��� �������� ����������� �� |     
-100 �� 100.                                                         |
��������, ���������� ������� ������ � �������� �������.              |
���� ����������� ���� �������� ���� ��������� ���� ��������,         |
�� ����������� ���� ��������� ���������� ����, �����������           |
����������� ��� ������� ������� ����� ����������� ����� � ���������  |
�����, ���������� ���������� ��������� ������ 0. ���������������     |
�����, ���� ����������� �������� ���� ���������� ��������.           |
    CMO = ((�������� �������������� ����)/(�������� ����� +          |
           �������� ����)) * 100                                     |
������ ������� �������� ������ � �������� ���������.                 |
�������:                                                             |
  1. ��������� ������� ������� �� �������� ���������� ����, �����    |
     ����, ��� ���14 ���������� ���� ������� -50;                    |
  2. ������� ������� �����������, ���� ���14 ���������� �����        |
     ������� +50;                                                    |
  3. ������� ������� ����������� ��� ���������� ���� ������� 0.2 %;  |
  4. ������� ������� �����������, ���� �� 20 ���� ����� ��������     |
     ������� ���� ��������� ���� ������ �����.                       |
//+------------------------------------------------------------------+
*/ 
#property copyright ""
#property link      ""
//----                                                            
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_minimum -100 
#property indicator_maximum  100
#property indicator_level1   50 
#property indicator_level2  -50 
//---- input parameters
extern bool LastBarOnly = true; 
extern int  CMO_Range   = 14; 
//---- buffers
double CMO_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
 {
//---- indicators
  IndicatorShortName("Chande`s Momentum Oscillator (" + CMO_Range + ")"); 
  SetLevelStyle(STYLE_DASHDOT, 1, DodgerBlue); 
  SetIndexStyle(0, DRAW_LINE);
  SetIndexLabel(0, "CMO"); 
  SetIndexBuffer(0, CMO_Buffer); 
  SetIndexDrawBegin(0, CMO_Range); 
 //----
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
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted(); 
   int i, j, Limit, cnt_bars; 
   double dif_close, cmo_up, cmo_dw; 
   static bool run_once; 
// to prevent possible error 
   if(counted_bars < 0) 
     { 
       return(-1); 
     } 
   Limit = Bars - counted_bars;
// run once on start
   if(run_once == false) 
       cnt_bars = Limit - CMO_Range; 
   else
      if(LastBarOnly == false) 
          cnt_bars = Limit; 
      else
          cnt_bars = 0; 
//----
   for(i = cnt_bars; i >= 0; i--) 
     { 
       cmo_up = 0.0; 
       cmo_dw = 0.0; 
       //----
       for(j = i + CMO_Range - 1; j >= i; j--) 
         { 
           dif_close = Close[j] - Close[j+1]; 
           if(dif_close > 0) 
               cmo_up += dif_close; 
           else 
               if(dif_close < 0) 
                   cmo_dw -= dif_close; 
         } 
       CMO_Buffer[i] = 100 * (cmo_up - cmo_dw) / (cmo_up + cmo_dw); 
     } 
//----
   if(run_once == false) 
       run_once = true; 
//----
   return(0);
  }
//+------------------------------------------------------------------+