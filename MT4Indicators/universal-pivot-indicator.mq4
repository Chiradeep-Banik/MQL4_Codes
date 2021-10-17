//+------------------------------------------------------------------+
//|                                              Universal Pivot.mq4 |
//|                               Copyright © 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+------------------------------------------------------------------+
#property  copyright ""
#property link      ""
//----
//
// PERIOD_M1   1     1 minute 
// PERIOD_M5   5     5 minute 
// PERIOD_M15  15    15 minute 
// PERIOD_M30  30    30 minute 
// PERIOD_H1   60    1 hour 
// PERIOD_H4   240   4 hour 
// PERIOD_D1   1440  1 day 
// PERIOD_W1   10080 1 weekly
// PERIOD_MN1  43200 1 mounth
//
// А так же описание для линий разных периодов от ТФ Н1 и выше.
//----
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 DarkBlue
#property indicator_color3 Maroon
#property indicator_color4 DarkBlue
#property indicator_color5 Maroon
#property indicator_color6 Green
#property indicator_color7 Green
//---- input parameters
//---- buffers

extern int period = 1440;

double PBuffer[];
double S1Buffer[];
double R1Buffer[];
double S2Buffer[];
double R2Buffer[];
double S3Buffer[];
double R3Buffer[];

     string Pv, S, SS, SSS;
     string R, RR, RRR;
     string Pivot, Sup1, Sup2, Sup3;
     string Res1, Res2, Res3;
     string txtPivot, txtSup1, txtSup2, txtSup3;
     string txtRes1, txtRes2, txtRes3;
     

double P,S1,R1,S2,R2,S3,R3;
double Q,x;
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
     
//---- TODO: add your code here
  ObjectDelete(Pivot);
   ObjectDelete(Sup1);
   ObjectDelete(Res1);
   ObjectDelete(Sup2);
   ObjectDelete(Res2);
   ObjectDelete(Sup3);
   ObjectDelete(Res3);
   
   ObjectDelete(txtPivot);
   ObjectDelete(txtSup1);
   ObjectDelete(txtRes1);
   ObjectDelete(txtSup2);
   ObjectDelete(txtRes2);
   ObjectDelete(txtSup3);
   ObjectDelete(txtRes3);
//----

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
     
     string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE,0,2,Red);
   SetIndexStyle(1,DRAW_LINE,0,0,DarkBlue);
   SetIndexStyle(2,DRAW_LINE,0,0,Maroon);
   SetIndexStyle(3,DRAW_LINE,0,0,DarkBlue);
   SetIndexStyle(4,DRAW_LINE,0,0,Maroon);
   SetIndexStyle(5,DRAW_LINE,0,0,Green);
   SetIndexStyle(6,DRAW_LINE,0,0,Green);
   SetIndexBuffer(0,PBuffer);
   SetIndexBuffer(1,S1Buffer);
   SetIndexBuffer(2,R1Buffer);
   SetIndexBuffer(3,S2Buffer);
   SetIndexBuffer(4,R2Buffer);
   SetIndexBuffer(5,S3Buffer);
   SetIndexBuffer(6,R3Buffer);
//---- name for DataWindow and indicator subwindow label
   short_name="Universal Pivot";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,1);
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    dayi, counted_bars=IndicatorCounted();
   int limit, i;
//---- indicator calculation
   if (counted_bars==0)
     {
      x=Period();
      if (x>240) return(-1);
      
     }
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   //   if(counted_bars>0) counted_bars--;
   limit=(Bars-counted_bars)-1;
//----   
   for(i=limit; i>=0;i--)
     {
      dayi = iBarShift(Symbol(), period, Time[i], false);
       Q = (iHigh(Symbol(), period,dayi + 1) - iLow(Symbol(), period, dayi + 1));
       P = (iHigh(Symbol(), period, dayi + 1) + iLow(Symbol(), period, dayi + 1) + iClose(Symbol(), period, dayi + 1)) / 3; 
       
       //---
         R1=(2*P)-iLow(Symbol(), period, dayi + 1);
         S1=(2*P)-iHigh(Symbol(), period,dayi + 1);
         R2=P+(iHigh(Symbol(), period,dayi + 1) - iLow(Symbol(), period, dayi + 1));
         S2=P-(iHigh(Symbol(), period,dayi + 1) - iLow(Symbol(), period, dayi + 1));
         R3=(2*P)+(iHigh(Symbol(), period,dayi + 1)-(2*iLow(Symbol(), period, dayi + 1)));
         S3=(2*P)-((2* iHigh(Symbol(), period,dayi + 1))-iLow(Symbol(), period, dayi + 1));
       //---
//----
     if (period < 60)
     {  
       Pv = "Pivot";
       S = "S 1"; SS = "S 2"; SSS = "S 3";
       R = "R 1"; RR = "R 2"; RRR = "R 3";
       Pivot = "Pivot"; Sup1 = "Sup1"; Sup2 = "Sup2"; Sup3 = "Sup3";
       Res1 = "Res1"; Res2 = "Res2"; Res3 = "Res3";
       txtPivot = "txtPivot"; txtSup1 = "txtSup1"; txtSup2 = "txtSup2";  txtSup3 = "txtSup3";
       txtRes1 = "txtRes1"; txtRes2 = "txtRes2"; txtRes3 = "txtRes3";
       } 
         if (period == 60)
         {  
           Pv = "Hour Pivot";
           S = "S 1 Hour"; SS = "S 2 Hour"; SSS = "S 3 Hour";
           R = "R 1 Hour"; RR = "R 2 Hour"; RRR = "R 3 Hour";
           Pivot = "1HPivot"; Sup1 = "1HSup1"; Sup2 = "1HSup2"; Sup3 = "1HSup3";
           Res1 = "1HRes1"; Res2 = "1HRes2"; Res3 = "1HRes3";
           txtPivot = "txt1HPivot"; txtSup1 = "txt1HSup1"; txtSup2 = "txt1HSup2";  txtSup3 = "txt1HSup3";
           txtRes1 = "txt1HRes1"; txtRes2 = "txt1HRes2"; txtRes3 = "txt1HRes3";
           } 
             if (period == 240)
             {  
               Pv = "4Hour Pivot"; S = "S 1 4Hour"; SS = "S 2 4Hour"; SSS = "S 3 4Hour";
               R = "R 1 4Hour"; RR = "R 2 4Hour"; RRR = "R 3 4Hour";
               Pivot = "4HPivot"; Sup1 = "4HSup1"; Sup2 = "4HSup2"; Sup3 = "4HSup3";
               Res1 = "4HRes1"; Res2 = "4HRes2"; Res3 = "4HRes3";
               txtPivot = "txt4HPivot"; txtSup1 = "txt4HSup1"; txtSup2 = "txt4HSup2";  txtSup3 = "txt4HSup3";
               txtRes1 = "txt4HRes1"; txtRes2 = "txt4HRes2"; txtRes3 = "txt4HRes3";
               }
                 if (period == 1440)
                 {
                   Pv = "Day Pivot"; S = "S 1 Day"; SS = "S 2 Day"; SSS = "S 3 Day";
                   R = "R 1 Day"; RR = "R 2 Day"; RRR = "R 3 Day";
                   Pivot = "DPivot"; Sup1 = "DSup1"; Sup2 = "DSup2"; Sup3 = "DSup3";
                   Res1 = "DRes1"; Res2 = "DRes2"; Res3 = "DRes3";
                   txtPivot = "txtDPivot"; txtSup1 = "txtDSup1"; txtSup2 = "txtDSup2";  txtSup3 = "txtDSup3";
                   txtRes1 = "txtDRes1"; txtRes2 = "txtDRes2"; txtRes3 = "txtDRes3";
                   }
                     if (period == 10080)
                     {  
                       Pv = "Weekly Pivot"; S = "S 1 Weekly"; SS = "S 2 Weekly"; SSS = "S 3 Weekly";
                       R = "R 1 Weekly"; RR = "R 2 Weekly"; RRR = "R 3 Weekly"; 
                       Pivot = "WPivot"; Sup1 = "WSup1"; Sup2 = "WSup2"; Sup3 = "WSup3";
                       Res1 = "WRes1"; Res2 = "WRes2"; Res3 = "WRes3";
                       txtPivot = "txtWPivot"; txtSup1 = "txtWSup1"; txtSup2 = "txtWSup2";  txtSup3 = "txtWSup3";
                       txtRes1 = "txtWRes1"; txtRes2 = "txtWRes2"; txtRes3 = "txtWRes3";
                       }
                         if (period == 43200)
                         {  
                           Pv = "Mounth Pivot"; S = "S 1 Mounth"; SS = "S 2 Mounth"; SSS = "S 3 Mounth";
                           R = "R 1 Mounth"; RR = "R 2 Mounth"; RRR = "R 3 Mounth";
                           Pivot = "MNPivot"; Sup1 = "MNSup1"; Sup2 = "MNSup2"; Sup3 = "MNSup3";
                           Res1 = "MNRes1"; Res2 = "MNRes2"; Res3 = "MNRes3";
                           txtPivot = "txtMNPivot"; txtSup1 = "txtMNSup1"; txtSup2 = "txtMNSup2";  txtSup3 = "txtMNSup3";
                           txtRes1 = "txtMNRes1"; txtRes2 = "txtMNRes2"; txtRes3 = "txtMNRes3";
                           }
//--
 
//--
       
      PBuffer[i]=P;
      SetPrice(Pivot, Time[i], P, indicator_color1);
      SetText(txtPivot, Pv, Time[i], P, indicator_color1);
      
      S1Buffer[i]=S1;
      SetPrice(Sup1, Time[i], S1, indicator_color2);
      SetText(txtSup1, S, Time[i], S1, indicator_color2);
      
      R1Buffer[i]=R1;
      SetPrice(Res1, Time[i], R1, indicator_color3);
      SetText(txtRes1, R, Time[i], R1, indicator_color3);
      
      S2Buffer[i]=S2;
      SetPrice(Sup2, Time[i], S2, indicator_color4);
      SetText(txtSup2, SS, Time[i], S2, indicator_color4);
      
      R2Buffer[i]=R2;
      SetPrice(Res2, Time[i], R2, indicator_color5);
      SetText(txtRes2, RR, Time[i], R2, indicator_color5);
      
      S3Buffer[i]=S3;
      SetPrice(Sup3, Time[i], S3, indicator_color6);
      SetText(txtSup3, SSS, Time[i], S3, indicator_color6);
      
      R3Buffer[i]=R3;
      SetPrice(Res3, Time[i], R3, indicator_color7);
      SetText(txtRes3, RRR, Time[i], R3, indicator_color7);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetPrice(string name, datetime Tm, double Prc, color clr)
  {
   if(ObjectFind(name) == -1)
     {
       ObjectCreate(name, OBJ_ARROW, 0, Tm, Prc);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_WIDTH, 1);
       ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
     }
   else
     {
       ObjectSet(name, OBJPROP_TIME1, Tm);
       ObjectSet(name, OBJPROP_PRICE1, Prc);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_WIDTH, 1);
       ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
     } 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetText(string name, string txt, datetime Tm, double Prc, color clr)
  {
   if(ObjectFind(name) == -1)
     {
       ObjectCreate(name, OBJ_TEXT, 0, Tm, Prc);
       ObjectSetText(name, txt, 10, "Times New Roman", clr);
       ObjectSet(name, OBJPROP_CORNER, 2);
     }
   else
     {
       ObjectSet(name, OBJPROP_TIME1, Tm);
       ObjectSet(name, OBJPROP_PRICE1, Prc);
       ObjectSetText(name, txt, 10, "Times New Roman", clr);
       ObjectSet(name, OBJPROP_CORNER, 2);
     } 
  }
//+------------------------------------------------------------------+