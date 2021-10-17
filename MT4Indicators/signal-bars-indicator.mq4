//+------------------------------------------------------------------+
//|                                        #Signal_Bars_v3_Daily.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property link      " cja "
#property indicator_chart_window

extern bool Corner_of_Chart_RIGHT_TOP = true;
extern bool Show_Price = true;
extern bool Show_Xtra_Details = true;
extern bool Show_Smaller_Size = true;
extern int Shift_UP_DN =0; 
extern int Adjust_Side_to_side  = 20;
extern color BarLabel_color = LightSteelBlue;
extern color CommentLabel_color = LightSteelBlue;


//****************************************
extern int MACD_Fast = 8;
extern int MACD_Slow = 17;
extern int MACD_Signal = 9;
extern int MACD_PRICE_TYPE = 0;

extern int RSI_Period = 14;
extern int RSI_PRICE_TYPE = 0;

extern int CCI_Period = 14;
extern int CCI_PRICE_TYPE = 0;

extern int STOCH_K_Period = 5;
extern int STOCH_D_Period = 3;
extern int STOCH_Slowing = 3;
extern int STOCH_MA_MODE = 1;

extern int MA_Fast = 5;
extern int MA_Slow = 9;
extern int MA_MODE = 1;
extern int MA_PRICE_TYPE = 0;

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
   ObjectsDeleteAll(0,OBJ_LABEL); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {    
   //***********************************************************************************************************************
   //MACD Signals
   int    counted_bars=IndicatorCounted();
//----
      string SSignalMACDD1="",SSignalMACDH1="",SSignalMACDH4="",SSignalMACDM1="", SSignalMACDM5="",SSignalMACDM15="",SSignalMACDM30="";   
      color  colMACDD1,colMACDH1,colMACDH4,colMACDM1,colMACDM5,colMACDM15,colMACDM30;  
      
      double MACDM1=iMACD(NULL,1,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_MAIN,0); 
      double MACD_SIGM1=iMACD(NULL,1,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_SIGNAL,0);    
      double MACDM5=iMACD(NULL,5,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_MAIN,0); 
      double MACD_SIGM5=iMACD(NULL,5,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_SIGNAL,0);
      double MACDM15=iMACD(NULL,15,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_MAIN,0); 
      double MACD_SIGM15=iMACD(NULL,15,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_SIGNAL,0);       
      double MACDM30=iMACD(NULL,30,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_MAIN,0); 
      double MACD_SIGM30=iMACD(NULL,30,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_SIGNAL,0);    
      double MACDH1=iMACD(NULL,60,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_MAIN,0); 
      double MACD_SIGH1=iMACD(NULL,60,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_SIGNAL,0); 
      double MACDH4=iMACD(NULL,240,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_MAIN,0); 
      double MACD_SIGH4=iMACD(NULL,240,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_SIGNAL,0); 
      double MACDD1=iMACD(NULL,1440,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_MAIN,0); 
      double MACD_SIGD1=iMACD(NULL,1440,MACD_Fast,MACD_Slow,MACD_Signal,MACD_PRICE_TYPE,MODE_SIGNAL,0); 
      
      if (MACDM1>MACD_SIGM1){SSignalMACDM1 = "-"; colMACDM1 = Green;} 
      if (MACDM1<=MACD_SIGM1){SSignalMACDM1 = "-"; colMACDM1 = Tomato;} 
      if ((MACDM1>MACD_SIGM1)&&(MACDM1>0)){SSignalMACDM1 = "-"; colMACDM1 = Lime;} 
      if ((MACDM1<=MACD_SIGM1)&&(MACDM1<0)){SSignalMACDM1 = "-"; colMACDM1 = Red;} 
         
      if (MACDM5>MACD_SIGM5){SSignalMACDM5 = "-"; colMACDM5 = Green;} 
      if (MACDM5<=MACD_SIGM5){SSignalMACDM5 = "-"; colMACDM5 = Tomato;}
      if ((MACDM5>MACD_SIGM5)&&(MACDM5>0)){SSignalMACDM5 = "-"; colMACDM5 = Lime;} 
      if ((MACDM5<=MACD_SIGM5)&&(MACDM5<0)){SSignalMACDM5 = "-"; colMACDM5 = Red;} 
      
      if (MACDM15>MACD_SIGM15){SSignalMACDM15 = "-"; colMACDM15 = Green;} 
      if (MACDM15<=MACD_SIGM15){SSignalMACDM15 = "-"; colMACDM15 = Tomato;}
      if ((MACDM15>MACD_SIGM15)&&(MACDM15>0)){SSignalMACDM15 = "-"; colMACDM15 = Lime;} 
      if ((MACDM15<=MACD_SIGM15)&&(MACDM15<0)){SSignalMACDM15 = "-"; colMACDM15 = Red;} 
          
      if (MACDM30>MACD_SIGM30){SSignalMACDM30 = "-"; colMACDM30 = Green;} 
      if (MACDM30<=MACD_SIGM30){SSignalMACDM30 = "-"; colMACDM30 = Tomato;}
      if ((MACDM30>MACD_SIGM30)&&(MACDM30>0)){SSignalMACDM30 = "-"; colMACDM30 = Lime;} 
      if ((MACDM30<=MACD_SIGM30)&&(MACDM30<0)){SSignalMACDM30 = "-"; colMACDM30 = Red;}  
           
      if (MACDH1>MACD_SIGH1){SSignalMACDH1 = "-"; colMACDH1 = Green;} 
      if (MACDH1<=MACD_SIGH1){SSignalMACDH1 = "-"; colMACDH1 = Tomato;}
      if ((MACDH1>MACD_SIGH1)&&(MACDH1>0)){SSignalMACDH1 = "-"; colMACDH1 = Lime;} 
      if ((MACDH1<=MACD_SIGH1)&&(MACDH1<0)){SSignalMACDH1 = "-"; colMACDH1 = Red;}  
         
      if (MACDH4>MACD_SIGH4){SSignalMACDH4 = "-"; colMACDH4 = Green;} 
      if (MACDH4<=MACD_SIGH4){SSignalMACDH4 = "-"; colMACDH4 = Tomato;}
      if ((MACDH4>MACD_SIGH4)&&(MACDH4>0)){SSignalMACDH4 = "-"; colMACDH4 = Lime;} 
      if ((MACDH4<=MACD_SIGH4)&&(MACDH4<0)){SSignalMACDH4 = "-"; colMACDH4 = Red;}    
      
      if (MACDD1>MACD_SIGD1){SSignalMACDD1 = "-"; colMACDD1 = Green;} 
      if (MACDD1<=MACD_SIGD1){SSignalMACDD1 = "-"; colMACDD1 = Tomato;}
      if ((MACDD1>MACD_SIGD1)&&(MACDD1>0)){SSignalMACDD1 = "-"; colMACDD1 = Lime;} 
      if ((MACDD1<=MACD_SIGD1)&&(MACDD1<0)){SSignalMACDD1 = "-"; colMACDD1 = Red;}    
  
      
    if (Corner_of_Chart_RIGHT_TOP == true)
    {  
/*           ObjectCreate("Numbers", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Numbers", " M1     M5    M15   M30   H1    H4    D1", 6, "Tahoma Narrow", BarLabel_color);
   ObjectSet("Numbers", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("Numbers", OBJPROP_XDISTANCE, 19+Adjust_Side_to_side);
   ObjectSet("Numbers", OBJPROP_YDISTANCE, 25+Shift_UP_DN); 
*/
   }
    if (Corner_of_Chart_RIGHT_TOP == false)
    { 
/*           ObjectCreate("Numbers", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Numbers", "D1     H4    H1    M30   M15    M5    M1", 6, "Tahoma Narrow", BarLabel_color);
   ObjectSet("Numbers", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("Numbers", OBJPROP_XDISTANCE, 15+Adjust_Side_to_side);
   ObjectSet("Numbers", OBJPROP_YDISTANCE, 25+Shift_UP_DN); 
*/   
    } 
/*           ObjectCreate("SSignalMACDM1t", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SSignalMACDM1t", "MACD", 6, "Tahoma Narrow", BarLabel_color);
   ObjectSet("SSignalMACDM1t", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SSignalMACDM1t", OBJPROP_XDISTANCE, 155+Adjust_Side_to_side);
   ObjectSet("SSignalMACDM1t", OBJPROP_YDISTANCE, 35+Shift_UP_DN); 
   
           ObjectCreate("SSignalMACDM1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SSignalMACDM1", SSignalMACDM1, 45, "Tahoma Narrow", colMACDM1);
   ObjectSet("SSignalMACDM1", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SSignalMACDM1", OBJPROP_XDISTANCE, 130+Adjust_Side_to_side);
   ObjectSet("SSignalMACDM1", OBJPROP_YDISTANCE, 2+Shift_UP_DN); 
   
     
           ObjectCreate("SSignalMACDM5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SSignalMACDM5", SSignalMACDM5, 45, "Tahoma Narrow", colMACDM5);
   ObjectSet("SSignalMACDM5", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SSignalMACDM5", OBJPROP_XDISTANCE, 110+Adjust_Side_to_side);
   ObjectSet("SSignalMACDM5", OBJPROP_YDISTANCE, 2+Shift_UP_DN); 
   
      
           ObjectCreate("SSignalMACDM15", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SSignalMACDM15", SSignalMACDM15, 45, "Tahoma Narrow", colMACDM15);
   ObjectSet("SSignalMACDM15", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SSignalMACDM15", OBJPROP_XDISTANCE, 90+Adjust_Side_to_side);
   ObjectSet("SSignalMACDM15", OBJPROP_YDISTANCE, 2+Shift_UP_DN); 
   
      
           ObjectCreate("SSignalMACDM30", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SSignalMACDM30", SSignalMACDM30, 45, "Tahoma Narrow", colMACDM30);
   ObjectSet("SSignalMACDM30", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SSignalMACDM30", OBJPROP_XDISTANCE, 70+Adjust_Side_to_side);
   ObjectSet("SSignalMACDM30", OBJPROP_YDISTANCE, 2+Shift_UP_DN); 
   
              
          ObjectCreate("SSignalMACDH1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SSignalMACDH1", SSignalMACDH1, 45, "Tahoma Narrow", colMACDH1);
   ObjectSet("SSignalMACDH1", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SSignalMACDH1", OBJPROP_XDISTANCE, 50+Adjust_Side_to_side);
   ObjectSet("SSignalMACDH1", OBJPROP_YDISTANCE, 2+Shift_UP_DN); 
   
            ObjectCreate("SSignalMACDH4", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SSignalMACDH4", SSignalMACDH4, 45, "Tahoma Narrow", colMACDH4);
   ObjectSet("SSignalMACDH4", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SSignalMACDH4", OBJPROP_XDISTANCE, 30+Adjust_Side_to_side);
   ObjectSet("SSignalMACDH4", OBJPROP_YDISTANCE, 2+Shift_UP_DN); 
   
             ObjectCreate("SSignalMACDD1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SSignalMACDD1", SSignalMACDD1, 45, "Tahoma Narrow", colMACDD1);
   ObjectSet("SSignalMACDD1", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SSignalMACDD1", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("SSignalMACDD1", OBJPROP_YDISTANCE, 2+Shift_UP_DN); 
*/   
 
    
   //*************************************************************************************************************** 
   //STR Signals 
   double rsi_d1 = iRSI(NULL, PERIOD_D1, RSI_Period , RSI_PRICE_TYPE, 0);
   double rsi_h4 = iRSI(NULL, PERIOD_H4, RSI_Period , RSI_PRICE_TYPE, 0);
   double rsi_h1 = iRSI(NULL, PERIOD_H1, RSI_Period , RSI_PRICE_TYPE, 0);
   double rsi_m30 = iRSI(NULL, PERIOD_M30, RSI_Period , RSI_PRICE_TYPE, 0);
   double rsi_m15 = iRSI(NULL, PERIOD_M15, RSI_Period , RSI_PRICE_TYPE, 0);
   double rsi_m5 = iRSI(NULL, PERIOD_M5, RSI_Period , RSI_PRICE_TYPE, 0);
   double rsi_m1 = iRSI(NULL, PERIOD_M1, RSI_Period , RSI_PRICE_TYPE, 0);
   
   double stoc_D1 = iStochastic(NULL, PERIOD_D1, STOCH_K_Period,STOCH_D_Period,STOCH_Slowing, STOCH_MA_MODE, 0, MODE_MAIN, 0);
   double stoc_H4 = iStochastic(NULL, PERIOD_H4, STOCH_K_Period,STOCH_D_Period,STOCH_Slowing, STOCH_MA_MODE, 0, MODE_MAIN, 0);
   double stoc_H1 = iStochastic(NULL, PERIOD_H1, STOCH_K_Period,STOCH_D_Period,STOCH_Slowing, STOCH_MA_MODE, 0, MODE_MAIN, 0);
   double stoc_M30 = iStochastic(NULL, PERIOD_M30, STOCH_K_Period,STOCH_D_Period,STOCH_Slowing, STOCH_MA_MODE, 0, MODE_MAIN, 0);
   double stoc_M15 = iStochastic(NULL, PERIOD_M15, STOCH_K_Period,STOCH_D_Period,STOCH_Slowing, STOCH_MA_MODE, 0, MODE_MAIN, 0);//sto was 15,5,5
   double stoc_M5 = iStochastic(NULL, PERIOD_M5, STOCH_K_Period,STOCH_D_Period,STOCH_Slowing, STOCH_MA_MODE, 0, MODE_MAIN, 0);
   double stoc_M1 = iStochastic(NULL, PERIOD_M1, STOCH_K_Period,STOCH_D_Period,STOCH_Slowing, STOCH_MA_MODE, 0, MODE_MAIN, 0);// was mode signal now gets value off main line
   
   double cci_DD1 = iCCI(NULL, PERIOD_D1,CCI_Period , CCI_PRICE_TYPE, 0);
   double cci_HH4 = iCCI(NULL, PERIOD_H4,CCI_Period , CCI_PRICE_TYPE, 0);
   double cci_HH1 = iCCI(NULL, PERIOD_H1,CCI_Period , CCI_PRICE_TYPE, 0); 
   double cci_MM30 = iCCI(NULL, PERIOD_M30,CCI_Period , CCI_PRICE_TYPE, 0);     
   double cci_MM15 = iCCI(NULL, PERIOD_M15,CCI_Period , CCI_PRICE_TYPE, 0);    
   double cci_MM5 = iCCI(NULL, PERIOD_M5,CCI_Period , CCI_PRICE_TYPE, 0);       
   double cci_MM1 = iCCI(NULL, PERIOD_M1,CCI_Period , CCI_PRICE_TYPE, 0);
   
    
   string STR_h1 = "", STR_m15 = "", STR_m5 = "", STR_m1 = "", STR_h4 ="",STR_m30= "",STR_d1= "",STR_w1= "";
 
   color  color_signal,color_m1,color_m5,color_m15,color_m30,color_m60,color_m240,color_m1440;
   
   if ((rsi_d1 > 50) && (stoc_D1 > 40) && (cci_DD1 > 0)) { STR_d1 = "-";color_m1440 = Lime;}  
   if ((rsi_h4 > 50) && (stoc_H4 > 40) && (cci_HH4 > 0)) { STR_h4 = "-";color_m240 = Lime;}  
   if ((rsi_h1 > 50) && (stoc_H1 > 40) && (cci_HH1 > 0)) { STR_h1 = "-";color_m60 = Lime;}
   if ((rsi_m30 > 50) && (stoc_M30 > 40) && (cci_MM30 > 0)) { STR_m30 = "-";color_m30 = Lime; }
   if ((rsi_m15 > 50) && (stoc_M15 > 40) && (cci_MM15 > 0)) { STR_m15 = "-";color_m15 = Lime; }
   if ((rsi_m5 > 50) && (stoc_M5 > 40) && (cci_MM5 > 0)) { STR_m5 = "-"; color_m5 = Lime;}
   if ((rsi_m1 > 50) && (stoc_M1 > 40) && (cci_MM1 > 0)) { STR_m1 = "-";  color_m1 = Lime;}
   
  
   if ((rsi_d1 < 50) && (stoc_D1 < 60) && (cci_DD1 < 0)) { STR_d1 = "-";color_m1440 = Red;}
   if ((rsi_h4 < 50) && (stoc_H4 < 60) && (cci_HH4 < 0)) { STR_h4 = "-";color_m240 = Red;}
   if ((rsi_h1 < 50) && (stoc_H1 < 60) && (cci_HH1 < 0)) { STR_h1 = "-";color_m60 = Red;}
   if ((rsi_m30 < 50) && (stoc_M30 < 60) && (cci_MM30 < 0)) { STR_m30 = "-";color_m30 = Red;}
   if ((rsi_m15 < 50) && (stoc_M15 < 60) && (cci_MM15 < 0)) { STR_m15 = "-";color_m15 = Red;}
   if ((rsi_m5 < 50) && (stoc_M5 < 60) && (cci_MM5 < 0)) { STR_m5 = "-";color_m5 = Red;}
   if ((rsi_m1 < 50) && (stoc_M1 < 60) && (cci_MM1 < 0)) { STR_m1 = "-"; color_m1 = Red;}
   
     
   if ((rsi_m1 < 50) && (stoc_M1 > 40) && (cci_MM1 > 0)) { STR_m1 = "-";  color_m1 = Orange;}
   if ((rsi_m1 > 50) && (stoc_M1 < 60) && (cci_MM1 < 0)) { STR_m1 = "-";  color_m1 = Orange;}
   if ((rsi_m1 < 50) && (stoc_M1 > 40) && (cci_MM1 < 0)) { STR_m1 = "-";  color_m1 = Orange;}
   if ((rsi_m1 > 50) && (stoc_M1 < 60) && (cci_MM1 > 0)) { STR_m1 = "-";  color_m1 = Orange;}
   if ((rsi_m1 > 50) && (stoc_M1 > 40) && (cci_MM1 < 0)) { STR_m1 = "-";  color_m1 = Orange;}  
   if ((rsi_m1 > 50) && (stoc_M1 < 60) && (cci_MM1 < 0)) { STR_m1 = "-";  color_m1 = Orange;}
   
   
   if ((rsi_m5 < 50) && (stoc_M5 > 40) && (cci_MM5 > 0)) { STR_m5 = "-";  color_m5 = Orange;}
   if ((rsi_m5 > 50) && (stoc_M5 < 60) && (cci_MM5 < 0)) { STR_m5 = "-";  color_m5 = Orange;}
   if ((rsi_m5 < 50) && (stoc_M5 > 40) && (cci_MM5 < 0)) { STR_m5 = "-";  color_m5 = Orange;}
   if ((rsi_m5 > 50) && (stoc_M5 < 60) && (cci_MM5 > 0)) { STR_m5 = "-";  color_m5 = Orange;}
   if ((rsi_m5 > 50) && (stoc_M5 > 40) && (cci_MM5 < 0)) { STR_m5 = "-";  color_m5 = Orange;}  
   if ((rsi_m5 > 50) && (stoc_M5 < 60) && (cci_MM5 < 0)) { STR_m5 = "-";  color_m5 = Orange;}
   
   if ((rsi_m15 < 50) && (stoc_M15 > 40) && (cci_MM15 > 0)) { STR_m15 = "-";  color_m15 = Orange;}
   if ((rsi_m15 > 50) && (stoc_M15 < 60) && (cci_MM15 < 0)) { STR_m15 = "-";  color_m15 = Orange;}
   if ((rsi_m15 < 50) && (stoc_M15 > 40) && (cci_MM15 < 0)) { STR_m15 = "-";  color_m15 = Orange;}
   if ((rsi_m15 > 50) && (stoc_M15 < 60) && (cci_MM15 > 0)) { STR_m15 = "-";  color_m15 = Orange;}
   if ((rsi_m15 > 50) && (stoc_M15 > 40) && (cci_MM15 < 0)) { STR_m15 = "-";  color_m15 = Orange;}  
   if ((rsi_m15 > 50) && (stoc_M15 < 60) && (cci_MM15 < 0)) { STR_m15 = "-";  color_m15 = Orange;}
      
   if ((rsi_m30 < 50) && (stoc_M30 > 40) && (cci_MM30 > 0)) { STR_m30 = "-";  color_m30 = Orange;}
   if ((rsi_m30 > 50) && (stoc_M30 < 60) && (cci_MM30 < 0)) { STR_m30 = "-";  color_m30 = Orange;}
   if ((rsi_m30 < 50) && (stoc_M30 > 40) && (cci_MM30 < 0)) { STR_m30 = "-";  color_m30 = Orange;}
   if ((rsi_m30 > 50) && (stoc_M30 < 60) && (cci_MM30 > 0)) { STR_m30 = "-";  color_m30 = Orange;}
   if ((rsi_m30 > 50) && (stoc_M30 > 40) && (cci_MM30 < 0)) { STR_m30 = "-";  color_m30 = Orange;}  
   if ((rsi_m30 > 50) && (stoc_M30 < 60) && (cci_MM30 < 0)) { STR_m30 = "-";  color_m30 = Orange;}
   
   if ((rsi_h1 < 50) && (stoc_H1 > 40) && (cci_HH1 > 0)) { STR_h1 = "-";  color_m60 = Orange;}
   if ((rsi_h1 > 50) && (stoc_H1 < 60) && (cci_HH1 < 0)) { STR_h1 = "-";  color_m60 = Orange;}
   if ((rsi_h1 < 50) && (stoc_H1 > 40) && (cci_HH1 < 0)) { STR_h1 = "-";  color_m60 = Orange;}
   if ((rsi_h1 > 50) && (stoc_H1 < 60) && (cci_HH1 > 0)) { STR_h1 = "-";  color_m60 = Orange;}
   if ((rsi_h1 > 50) && (stoc_H1 > 40) && (cci_HH1 < 0)) { STR_h1 = "-";  color_m60 = Orange;}  
   if ((rsi_h1 > 50) && (stoc_H1 < 60) && (cci_HH1 < 0)) { STR_h1 = "-";  color_m60 = Orange;}
   
   if ((rsi_h4 < 50) && (stoc_H4 > 40) && (cci_HH4 > 0)) { STR_h4 = "-";  color_m240 = Orange;}
   if ((rsi_h4 > 50) && (stoc_H4 < 60) && (cci_HH4 < 0)) { STR_h4 = "-";  color_m240 = Orange;}
   if ((rsi_h4 < 50) && (stoc_H4 > 40) && (cci_HH4 < 0)) { STR_h4 = "-";  color_m240 = Orange;}
   if ((rsi_h4 > 50) && (stoc_H4 < 60) && (cci_HH4 > 0)) { STR_h4 = "-";  color_m240 = Orange;}
   if ((rsi_h4 > 50) && (stoc_H4 > 40) && (cci_HH4 < 0)) { STR_h4 = "-";  color_m240 = Orange;}  
   if ((rsi_h4 > 50) && (stoc_H4 < 60) && (cci_HH4 < 0)) { STR_h4 = "-";  color_m240 = Orange;}
   
   if ((rsi_d1 < 50) && (stoc_D1 > 40) && (cci_DD1 > 0)) { STR_d1 = "-";  color_m1440 = Orange;}
   if ((rsi_d1 > 50) && (stoc_D1 < 60) && (cci_DD1 < 0)) { STR_d1 = "-";  color_m1440 = Orange;}
   if ((rsi_d1 < 50) && (stoc_D1 > 40) && (cci_DD1 < 0)) { STR_d1 = "-";  color_m1440 = Orange;}
   if ((rsi_d1 > 50) && (stoc_D1 < 60) && (cci_DD1 > 0)) { STR_d1 = "-";  color_m1440 = Orange;}
   if ((rsi_d1 > 50) && (stoc_D1 > 40) && (cci_DD1 < 0)) { STR_d1 = "-";  color_m1440 = Orange;}  
   if ((rsi_d1 > 50) && (stoc_D1 < 60) && (cci_DD1 < 0)) { STR_d1 = "-";  color_m1440 = Orange;}
   
               
       
/*           ObjectCreate("SignalSTRM1t", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalSTRM1t","STR", 6, "Tahoma Narrow",  BarLabel_color);
   ObjectSet("SignalSTRM1t", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalSTRM1t", OBJPROP_XDISTANCE, 155+Adjust_Side_to_side);
   ObjectSet("SignalSTRM1t", OBJPROP_YDISTANCE, 43+Shift_UP_DN); 
    
           ObjectCreate("SignalSTRM1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalSTRM1", STR_m1, 45, "Tahoma Narrow",  color_m1);
   ObjectSet("SignalSTRM1", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalSTRM1", OBJPROP_XDISTANCE, 130+Adjust_Side_to_side);
   ObjectSet("SignalSTRM1", OBJPROP_YDISTANCE, 10+Shift_UP_DN); 
        
           ObjectCreate("SignalSTRM5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalSTRM5", STR_m5, 45, "Tahoma Narrow",  color_m5);
   ObjectSet("SignalSTRM5", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalSTRM5", OBJPROP_XDISTANCE, 110+Adjust_Side_to_side);
   ObjectSet("SignalSTRM5", OBJPROP_YDISTANCE, 10+Shift_UP_DN); 
      
           ObjectCreate("SignalSTRM15", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalSTRM15", STR_m15, 45, "Tahoma Narrow",  color_m15);
   ObjectSet("SignalSTRM15", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalSTRM15", OBJPROP_XDISTANCE, 90+Adjust_Side_to_side);
   ObjectSet("SignalSTRM15", OBJPROP_YDISTANCE, 10+Shift_UP_DN); 
      
           ObjectCreate("SignalSTRM30", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalSTRM30", STR_m30, 45, "Tahoma Narrow",  color_m30);
   ObjectSet("SignalSTRM30", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalSTRM30", OBJPROP_XDISTANCE, 70+Adjust_Side_to_side);
   ObjectSet("SignalSTRM30", OBJPROP_YDISTANCE, 10+Shift_UP_DN); 
      
           ObjectCreate("SignalSTRM60", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalSTRM60", STR_h1, 45, "Tahoma Narrow",  color_m60);
   ObjectSet("SignalSTRM60", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalSTRM60", OBJPROP_XDISTANCE, 50+Adjust_Side_to_side);
   ObjectSet("SignalSTRM60", OBJPROP_YDISTANCE, 10+Shift_UP_DN); 
         
           ObjectCreate("SignalSTRM240", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalSTRM240", STR_h4, 45, "Tahoma Narrow",  color_m240);
   ObjectSet("SignalSTRM240", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalSTRM240", OBJPROP_XDISTANCE, 30+Adjust_Side_to_side);
   ObjectSet("SignalSTRM240", OBJPROP_YDISTANCE, 10+Shift_UP_DN); 
   
            ObjectCreate("SignalSTRM1440", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalSTRM1440", STR_d1, 45, "Tahoma Narrow",  color_m1440);
   ObjectSet("SignalSTRM1440", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalSTRM1440", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("SignalSTRM1440", OBJPROP_YDISTANCE, 10+Shift_UP_DN); 
*/   
   //******************************************************************************************************************
   //EMA Signals
   
   
    double EMA_M1 = iMA(Symbol(),1,MA_Fast,0,MA_MODE,MA_PRICE_TYPE,0);
    double ema_m1 = iMA(Symbol(),1,MA_Slow,0,MA_MODE,MA_PRICE_TYPE,0);
    double EMA_M5 = iMA(Symbol(),5,MA_Fast,0,MA_MODE,MA_PRICE_TYPE,0);
    double ema_m5 = iMA(Symbol(),5,MA_Slow,0,MA_MODE,MA_PRICE_TYPE,0);
    double EMA_M15 = iMA(Symbol(),15,MA_Fast,0,MA_MODE,MA_PRICE_TYPE,0);
    double ema_m15 = iMA(Symbol(),15,MA_Slow,0,MA_MODE,MA_PRICE_TYPE,0);
    double EMA_M30 = iMA(Symbol(),30,MA_Fast,0,MA_MODE,MA_PRICE_TYPE,0);
    double ema_m30 = iMA(Symbol(),30,MA_Slow,0,MA_MODE,MA_PRICE_TYPE,0);
    double EMA_H1 = iMA(Symbol(),60,MA_Fast,0,MA_MODE,MA_PRICE_TYPE,0);
    double ema_h1 = iMA(Symbol(),60,MA_Slow,0,MA_MODE,MA_PRICE_TYPE,0);
    double EMA_H4 = iMA(Symbol(),240,MA_Fast,0,MA_MODE,MA_PRICE_TYPE,0);
    double ema_h4 = iMA(Symbol(),240,MA_Slow,0,MA_MODE,MA_PRICE_TYPE,0);
    double EMA_D1 = iMA(Symbol(),1440,MA_Fast,0,MA_MODE,MA_PRICE_TYPE,0);
    double ema_d1 = iMA(Symbol(),1440,MA_Slow,0,MA_MODE,MA_PRICE_TYPE,0);
   // double EMA_W1 = iMA(Symbol(),10080,MA_Fast,0,MA_MODE,MA_PRICE_TYPE,0);
   // double ema_w1 = iMA(Symbol(),10080,MA_Slow,0,MA_MODE,MA_PRICE_TYPE,0);
    
    string M1_EMA= "",M5_EMA= "", M15_EMA= "", M30_EMA= "", H1_EMA= "", H4_EMA= "", D1_EMA= "",PRC1;
    color  color_EMAm1,color_EMAm5,color_EMAm15,color_EMAm30,color_EMAm60,color_EMAm240,color_EMAm1440;     
         
    
    if (EMA_M1 > ema_m1) {M1_EMA= "-";color_EMAm1 = Lime; }
    if (EMA_M1 <= ema_m1) {M1_EMA= "-";color_EMAm1 = Red; }
    
    if (EMA_M5 > ema_m5) {M5_EMA= "-";color_EMAm5 = Lime; }
    if (EMA_M5 <= ema_m5) {M5_EMA= "-";color_EMAm5 = Red; }
    
    if (EMA_M15 > ema_m15) {M15_EMA= "-";color_EMAm15 = Lime; }
    if (EMA_M15 <= ema_m15) {M15_EMA= "-";color_EMAm15 = Red; }
    
    if (EMA_M30 > ema_m30) {M30_EMA= "-";color_EMAm30 = Lime; }
    if (EMA_M30 <= ema_m30) {M30_EMA= "-";color_EMAm30 = Red; }
    
    if (EMA_H1 > ema_h1) {H1_EMA= "-";color_EMAm60 = Lime; }
    if (EMA_H1 <= ema_h1) {H1_EMA= "-";color_EMAm60 = Red; }
    
    if (EMA_H4 > ema_h4) {H4_EMA= "-";color_EMAm240 = Lime; }
    if (EMA_H4 <= ema_h4) {H4_EMA= "-";color_EMAm240 = Red; }
         
    if (EMA_D1 > ema_d1) {D1_EMA= "-";color_EMAm1440 = Lime; }
    if (EMA_D1 <= ema_d1) {D1_EMA= "-";color_EMAm1440 = Red; }
    
          
/*           ObjectCreate("SignalEMAM1t", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalEMAM1t","EMA", 6, "Tahoma Narrow",  BarLabel_color);
   ObjectSet("SignalEMAM1t", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalEMAM1t", OBJPROP_XDISTANCE, 155+Adjust_Side_to_side);
   ObjectSet("SignalEMAM1t", OBJPROP_YDISTANCE, 51+Shift_UP_DN);  
       
           ObjectCreate("SignalEMAM1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalEMAM1", M1_EMA, 45, "Tahoma Narrow",  color_EMAm1);
   ObjectSet("SignalEMAM1", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalEMAM1", OBJPROP_XDISTANCE, 130+Adjust_Side_to_side);
   ObjectSet("SignalEMAM1", OBJPROP_YDISTANCE, 18+Shift_UP_DN); 
        
           ObjectCreate("SignalEMAM5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalEMAM5", M5_EMA, 45, "Tahoma Narrow",  color_EMAm5);
   ObjectSet("SignalEMAM5", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalEMAM5", OBJPROP_XDISTANCE, 110+Adjust_Side_to_side);
   ObjectSet("SignalEMAM5", OBJPROP_YDISTANCE, 18+Shift_UP_DN); 
      
           ObjectCreate("SignalEMAM15", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalEMAM15", M15_EMA, 45, "Tahoma Narrow",  color_EMAm15);
   ObjectSet("SignalEMAM15", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalEMAM15", OBJPROP_XDISTANCE, 90+Adjust_Side_to_side);
   ObjectSet("SignalEMAM15", OBJPROP_YDISTANCE, 18+Shift_UP_DN); 
      
           ObjectCreate("SignalEMAM30", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalEMAM30", M30_EMA, 45, "Tahoma Narrow",  color_EMAm30);
   ObjectSet("SignalEMAM30", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalEMAM30", OBJPROP_XDISTANCE, 70+Adjust_Side_to_side);
   ObjectSet("SignalEMAM30", OBJPROP_YDISTANCE, 18+Shift_UP_DN); 
      
           ObjectCreate("SignalEMAM60", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalEMAM60", H1_EMA, 45, "Tahoma Narrow",  color_EMAm60);
   ObjectSet("SignalEMAM60", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalEMAM60", OBJPROP_XDISTANCE, 50+Adjust_Side_to_side);
   ObjectSet("SignalEMAM60", OBJPROP_YDISTANCE, 18+Shift_UP_DN); 
         
           ObjectCreate("SignalEMAM240", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalEMAM240", H4_EMA, 45, "Tahoma Narrow",  color_EMAm240);
   ObjectSet("SignalEMAM240", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalEMAM240", OBJPROP_XDISTANCE, 30+Adjust_Side_to_side);
   ObjectSet("SignalEMAM240", OBJPROP_YDISTANCE, 18+Shift_UP_DN);
   
           ObjectCreate("SignalEMAM1440", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SignalEMAM1440", D1_EMA, 45, "Tahoma Narrow",  color_EMAm1440);
   ObjectSet("SignalEMAM1440", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("SignalEMAM1440", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("SignalEMAM1440", OBJPROP_YDISTANCE, 18+Shift_UP_DN);
*/
    
   //*****************************************************************************************************
   //Info
   
   double Price1 = iMA(Symbol(),0,1,0,MODE_EMA,PRICE_CLOSE,0);   
    PRC1 = DoubleToStr(Price1,Digits);
    
        
    if (Show_Smaller_Size  == false)
    {  
      
    if (Show_Price  == true)
    {      
           ObjectCreate("Signalprice", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Signalprice",""+PRC1+"", 33, "Arial",  color_m30);
   ObjectSet("Signalprice", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("Signalprice", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("Signalprice", OBJPROP_YDISTANCE, 25+Shift_UP_DN);     // 58
   }}
          
    if (Show_Smaller_Size  == true)
    {  
     if (Show_Price  == true)
    {     
           ObjectCreate("Signalprice", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Signalprice",""+PRC1+"", 15, "Arial",  color_m30);
   ObjectSet("Signalprice", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("Signalprice", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("Signalprice", OBJPROP_YDISTANCE, 15+Shift_UP_DN);  // 60
   }}
   int R1=0,R5=0,R10=0,R20=0,RAvg=0,i=0;
   R1 =  (iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1))/Point;
   for(i=1;i<=5;i++)
      R5    =    R5  +  (iHigh(NULL,PERIOD_D1,i)-iLow(NULL,PERIOD_D1,i))/Point;
   for(i=1;i<=10;i++)
      R10   =    R10 +  (iHigh(NULL,PERIOD_D1,i)-iLow(NULL,PERIOD_D1,i))/Point;
   for(i=1;i<=20;i++)
      R20   =    R20 +  (iHigh(NULL,PERIOD_D1,i)-iLow(NULL,PERIOD_D1,i))/Point;

   R5 = R5/5;
   R10 = R10/10;
   R20 = R20/20;
   RAvg  =  (R1+R5+R10+R20)/4;    
   
   string HI="",LO="",SPREAD="",PIPS="",DAV="",HILO="",PRC,Pips="",Av="",AV_Yest="";
   color color_pip,color_av;
   double OPEN = iOpen(NULL,1440,0);
   double CLOSE = iClose(NULL,1440,0);
   double SPRD = (Ask - Bid)/Point;
   double High_Today = iHigh(NULL,1440,0);
   double Low_Today = iLow(NULL,1440,0);
   PIPS =  DoubleToStr((CLOSE-OPEN)/Point,0);
   SPREAD = (DoubleToStr(SPRD,Digits-4));
   DAV = (DoubleToStr(RAvg,Digits-4));
   AV_Yest =  (iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1))/Point;
   HILO = DoubleToStr((High_Today-Low_Today)/Point,0);
  
     if (CLOSE >= OPEN) {Pips= "-";color_pip = Lime; }
     if (CLOSE < OPEN) {Pips= "-";color_pip = OrangeRed; }
      if (DAV > AV_Yest) {Av= "-";color_av = Lime; }
     if (DAV < AV_Yest) {Av= "-";color_av = OrangeRed; }
     
        
    if (Show_Smaller_Size  == false)
    {     
    if (Show_Xtra_Details == true)
    {
     if (Show_Price  == true)
    {  
    
                ObjectCreate("MMLEVELS7", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS7","Spread", 12, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS7", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS7", OBJPROP_XDISTANCE, 65+Adjust_Side_to_side);  // 45
   ObjectSet("MMLEVELS7", OBJPROP_YDISTANCE, 70+Shift_UP_DN);  // 100
   
               ObjectCreate("MMLEVELS8", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS8",""+SPREAD+"", 12, "Arial Bold", Gold);
   ObjectSet("MMLEVELS8", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS8", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side); // 10
   ObjectSet("MMLEVELS8", OBJPROP_YDISTANCE, 70+Shift_UP_DN);        // 100
   
     
                ObjectCreate("MMLEVELS9", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS9","Pips to Open", 12, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS9", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS9", OBJPROP_XDISTANCE, 65+Adjust_Side_to_side); // 45
   ObjectSet("MMLEVELS9", OBJPROP_YDISTANCE, 85+Shift_UP_DN);        // 115
   
               ObjectCreate("MMLEVELS10", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS10",""+PIPS+"", 12, "Arial Bold", color_pip);
   ObjectSet("MMLEVELS10", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS10", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS10", OBJPROP_YDISTANCE, 85+Shift_UP_DN);  // 115
      
                ObjectCreate("MMLEVELS11", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS11","Hi to Low", 12, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS11", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS11", OBJPROP_XDISTANCE, 65+Adjust_Side_to_side);
   ObjectSet("MMLEVELS11", OBJPROP_YDISTANCE, 100+Shift_UP_DN);  // 130 
   
               ObjectCreate("MMLEVELS12", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS12",""+HILO+"", 12, "Arial Bold", Gold);
   ObjectSet("MMLEVELS12", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS12", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS12", OBJPROP_YDISTANCE, 100+Shift_UP_DN);  // 130
   
                 ObjectCreate("MMLEVELS13", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS13","Daily Av", 12, "Arial",CommentLabel_color);
   ObjectSet("MMLEVELS13", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS13", OBJPROP_XDISTANCE, 65+Adjust_Side_to_side);
   ObjectSet("MMLEVELS13", OBJPROP_YDISTANCE, 115+Shift_UP_DN);  // 145
   
               ObjectCreate("MMLEVELS14", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS14",""+DAV+"", 12, "Arial Bold", color_av);
   ObjectSet("MMLEVELS14", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS14", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS14", OBJPROP_YDISTANCE, 115+Shift_UP_DN);  // 145
 }}}
 //*****************************************************************
 //Shift if price not wanted
  if (Show_Smaller_Size  == false)
    {     
    if (Show_Xtra_Details == true)
    {
     if (Show_Price  == false)
    {  
    
                ObjectCreate("MMLEVELS7", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS7","Spread", 12, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS7", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS7", OBJPROP_XDISTANCE, 45+Adjust_Side_to_side);
   ObjectSet("MMLEVELS7", OBJPROP_YDISTANCE, 20+Shift_UP_DN);   // 60
   
               ObjectCreate("MMLEVELS8", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS8",""+SPREAD+"", 12, "Arial Bold", Gold);
   ObjectSet("MMLEVELS8", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS8", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS8", OBJPROP_YDISTANCE, 20+Shift_UP_DN);     // 60
   
     
                ObjectCreate("MMLEVELS9", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS9","Pips to Open", 12, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS9", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS9", OBJPROP_XDISTANCE, 45+Adjust_Side_to_side);
   ObjectSet("MMLEVELS9", OBJPROP_YDISTANCE, 45+Shift_UP_DN);     // 75
   
               ObjectCreate("MMLEVELS10", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS10",""+PIPS+"", 12, "Arial Bold", color_pip);
   ObjectSet("MMLEVELS10", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS10", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS10", OBJPROP_YDISTANCE, 45+Shift_UP_DN);   // 75
      
                ObjectCreate("MMLEVELS11", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS11","Hi to Low", 12, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS11", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS11", OBJPROP_XDISTANCE, 45+Adjust_Side_to_side);
   ObjectSet("MMLEVELS11", OBJPROP_YDISTANCE, 150+Shift_UP_DN);   // 90
   
               ObjectCreate("MMLEVELS12", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS12",""+HILO+"", 12, "Arial Bold", Gold);
   ObjectSet("MMLEVELS12", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS12", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS12", OBJPROP_YDISTANCE, 150+Shift_UP_DN);    // 90
   
                 ObjectCreate("MMLEVELS13", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS13","Daily Av", 12, "Arial",CommentLabel_color);
   ObjectSet("MMLEVELS13", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS13", OBJPROP_XDISTANCE, 45+Adjust_Side_to_side);
   ObjectSet("MMLEVELS13", OBJPROP_YDISTANCE, 200+Shift_UP_DN);    // 105
   
               ObjectCreate("MMLEVELS14", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS14",""+DAV+"", 12, "Arial Bold", color_av);
   ObjectSet("MMLEVELS14", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS14", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS14", OBJPROP_YDISTANCE, 75+Shift_UP_DN);   // 105
 }}}
 
  //***********************************************************************
  //Smaller type option     
    if (Show_Smaller_Size  == true)
    {     
    if (Show_Xtra_Details == true)
    {
     if (Show_Price  == true)
    {  
    
                ObjectCreate("MMLEVELS7", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS7","Spread", 9, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS7", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS7", OBJPROP_XDISTANCE, 55+Adjust_Side_to_side);  // 40
   ObjectSet("MMLEVELS7", OBJPROP_YDISTANCE, 40+Shift_UP_DN);           // 80
   
               ObjectCreate("MMLEVELS8", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS8",""+SPREAD+"", 9, "Arial Bold", Gold);
   ObjectSet("MMLEVELS8", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS8", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);  // 10
   ObjectSet("MMLEVELS8", OBJPROP_YDISTANCE, 40+Shift_UP_DN);          // 80
   
     
                ObjectCreate("MMLEVELS9", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS9","Pips to Open", 9, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS9", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS9", OBJPROP_XDISTANCE, 55+Adjust_Side_to_side);  //40
   ObjectSet("MMLEVELS9", OBJPROP_YDISTANCE, 55+Shift_UP_DN);     // 95
   
               ObjectCreate("MMLEVELS10", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS10",""+PIPS+"", 9, "Arial Bold", color_pip);
   ObjectSet("MMLEVELS10", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS10", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS10", OBJPROP_YDISTANCE, 55+Shift_UP_DN);   // 95
      
                ObjectCreate("MMLEVELS11", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS11","Hi to Low", 9, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS11", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS11", OBJPROP_XDISTANCE, 55+Adjust_Side_to_side);  // 40
   ObjectSet("MMLEVELS11", OBJPROP_YDISTANCE, 70+Shift_UP_DN);     // 110
   
               ObjectCreate("MMLEVELS12", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS12",""+HILO+"", 9, "Arial Bold", Gold);
   ObjectSet("MMLEVELS12", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS12", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);   // 10
   ObjectSet("MMLEVELS12", OBJPROP_YDISTANCE, 70+Shift_UP_DN);    // 110
   
                 ObjectCreate("MMLEVELS13", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS13","Daily Av", 9, "Arial",CommentLabel_color);
   ObjectSet("MMLEVELS13", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS13", OBJPROP_XDISTANCE, 55+Adjust_Side_to_side);    // 40
   ObjectSet("MMLEVELS13", OBJPROP_YDISTANCE, 85+Shift_UP_DN);     // 125
   
               ObjectCreate("MMLEVELS14", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS14",""+DAV+"", 9, "Arial Bold", color_av);
   ObjectSet("MMLEVELS14", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS14", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);    // 10
   ObjectSet("MMLEVELS14", OBJPROP_YDISTANCE, 85+Shift_UP_DN);     // 125
 }}}
 
 //****************************************************************
 // Shift if Price not needed
  if (Show_Smaller_Size  == true)
    {     
    if (Show_Xtra_Details == true)
    {
     if (Show_Price  == false)
    {  
    
                ObjectCreate("MMLEVELS7", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS7","Spread", 9, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS7", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS7", OBJPROP_XDISTANCE, 40+Adjust_Side_to_side);
   ObjectSet("MMLEVELS7", OBJPROP_YDISTANCE, 60+Shift_UP_DN);          // 60
   
               ObjectCreate("MMLEVELS8", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS8",""+SPREAD+"", 9, "Arial Bold", Gold);
   ObjectSet("MMLEVELS8", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS8", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS8", OBJPROP_YDISTANCE, 60+Shift_UP_DN);  
   
     
                ObjectCreate("MMLEVELS9", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS9","Pips to Open", 9, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS9", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS9", OBJPROP_XDISTANCE, 40+Adjust_Side_to_side);
   ObjectSet("MMLEVELS9", OBJPROP_YDISTANCE, 75+Shift_UP_DN); 
   
               ObjectCreate("MMLEVELS10", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS10",""+PIPS+"", 9, "Arial Bold", color_pip);
   ObjectSet("MMLEVELS10", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS10", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS10", OBJPROP_YDISTANCE, 75+Shift_UP_DN);  
      
                ObjectCreate("MMLEVELS11", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS11","Hi to Low", 9, "Arial", CommentLabel_color);
   ObjectSet("MMLEVELS11", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS11", OBJPROP_XDISTANCE, 40+Adjust_Side_to_side);
   ObjectSet("MMLEVELS11", OBJPROP_YDISTANCE, 90+Shift_UP_DN); 
   
               ObjectCreate("MMLEVELS12", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS12",""+HILO+"", 9, "Arial Bold", Gold);
   ObjectSet("MMLEVELS12", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS12", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS12", OBJPROP_YDISTANCE, 90+Shift_UP_DN);  
   
                 ObjectCreate("MMLEVELS13", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS13","Daily Av", 9, "Arial",CommentLabel_color);
   ObjectSet("MMLEVELS13", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS13", OBJPROP_XDISTANCE, 40+Adjust_Side_to_side);
   ObjectSet("MMLEVELS13", OBJPROP_YDISTANCE, 105+Shift_UP_DN); 
   
               ObjectCreate("MMLEVELS14", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("MMLEVELS14",""+DAV+"", 9, "Arial Bold", color_av);
   ObjectSet("MMLEVELS14", OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet("MMLEVELS14", OBJPROP_XDISTANCE, 10+Adjust_Side_to_side);
   ObjectSet("MMLEVELS14", OBJPROP_YDISTANCE, 105+Shift_UP_DN); 
 }}}
 //----
   return(0);
  }
//+------------------------------------------------------------------+