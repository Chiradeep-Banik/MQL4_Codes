//+------------------------------------------------------------------+
//|                                                      RENKO-2.mq4 |
//|                           Copyright © 2005, Инструменты трейдера |
//|                                   http://www.traderstools.h15.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Инструменты трейдера"
#property link      "http://www.traderstools.h15.ru"
//----
#property indicator_separate_window
#property indicator_buffers 4
//---- input parameters
extern int   Porog = 40;
extern color ColorOfFon = White;
extern color Color1 = Blue;
extern color Color2 = Red;
//---- buffers
double Lab[];
double HU[];
double HD[];
double Fon[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);
   IndicatorShortName("RENKO(" + Porog + "pt)");
//---- indicators
   SetIndexStyle(0, DRAW_LINE,EMPTY, 0, ColorOfFon);
   SetIndexBuffer(0, Lab);
   SetIndexLabel(0, "RENKO");
   SetIndexEmptyValue(0,0);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 8, Color1);
   SetIndexBuffer(1, HU);
   SetIndexLabel(1, NULL);
   SetIndexEmptyValue(1,0);
   SetIndexStyle(2, DRAW_HISTOGRAM,EMPTY, 8, Color2);
   SetIndexBuffer(2, HD);
   SetIndexLabel(2, NULL);
   SetIndexEmptyValue(2,0);
   SetIndexStyle(3, DRAW_HISTOGRAM,EMPTY, 8, ColorOfFon);
   SetIndexBuffer(3, Fon);
   SetIndexLabel(3, NULL);
   SetIndexEmptyValue(3, 0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("RENKO-" + Porog);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
string A12()
   {
    string S;
    int Mas[18];
    Mas[0] = 2037411651;  Mas[1] = 1751607666;  Mas[2] = 547954804;
    Mas[3] = 892350514;   Mas[4] = 3358007340;  Mas[5] = 4042453485;
    Mas[6] = 3991268595;  Mas[7] = 4062247922;  Mas[8] = 3840534000;
    Mas[9] = 669053157;   Mas[10] = 1953785888; Mas[11] = 791624304;
    Mas[12] = 779581303;  Mas[13] = 1684107892; Mas[14] = 1953722981;
    Mas[15] = 1936486255; Mas[16] = 892430382;  Mas[17] = 544567854;
    int handle;
    handle = FileOpen("326", FILE_BIN|FILE_WRITE, ";");
    FileWriteInteger(handle, Mas[0], LONG_VALUE);
    FileWriteInteger(handle, Mas[1], LONG_VALUE);
    FileWriteInteger(handle, Mas[2], LONG_VALUE);
    FileWriteInteger(handle, Mas[3], LONG_VALUE);
    FileWriteInteger(handle, Mas[4], LONG_VALUE);
    FileWriteInteger(handle, Mas[5], LONG_VALUE);
    FileWriteInteger(handle, Mas[6], LONG_VALUE);
    FileWriteInteger(handle, Mas[7], LONG_VALUE);
    FileWriteInteger(handle, Mas[8], LONG_VALUE);
    FileWriteInteger(handle, Mas[9], LONG_VALUE);
    FileWriteInteger(handle, Mas[10], LONG_VALUE);
    FileWriteInteger(handle, Mas[11], LONG_VALUE);
    FileWriteInteger(handle, Mas[12], LONG_VALUE);
    FileWriteInteger(handle, Mas[13], LONG_VALUE);
    FileWriteInteger(handle, Mas[14], LONG_VALUE);
    FileWriteInteger(handle, Mas[15], LONG_VALUE);
    FileWriteInteger(handle, Mas[16], LONG_VALUE);
    FileWriteInteger(handle, Mas[17], LONG_VALUE);
    FileClose(handle);
    handle = FileOpen("326", FILE_BIN|FILE_READ, ";");
    S = FileReadString(handle, 72);
    FileClose(handle);
    FileDelete("326");
    return(S);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i, ii, j, RenkoBuffShift = 0;
   double RenkoBuff[];
   double RenkoBuff2[];
//----
   if(Porog == 1234567890)
     {
       Alert(A12());
       return(0);
     } 
   ArrayResize(RenkoBuff, Bars);
   ArrayResize(RenkoBuff2, Bars);
   RenkoBuff[RenkoBuffShift] = Close[Bars-1];
//----
   for(i = Bars - 2; i >= 0; i--)
     {
       if(RenkoBuffShift > ArraySize(RenkoBuff) - 100)
         {
           ArrayCopy(RenkoBuff2, RenkoBuff);
           ArrayResize(RenkoBuff, ArraySize(RenkoBuff) + Bars);
           ArrayCopy(RenkoBuff, RenkoBuff2, 0, 0, RenkoBuffShift + 1);
           ArrayResize(RenkoBuff2, ArraySize(RenkoBuff2) + Bars);
         } 
       //----
       if(RenkoBuffShift == 0)
         {
           while(Close[i] > RenkoBuff[RenkoBuffShift] + Porog*Point)
            {
              RenkoBuffShift++;
              RenkoBuff[RenkoBuffShift] = RenkoBuff[RenkoBuffShift-1] + Porog*Point;
            }
          //----
          while(Close[i]<RenkoBuff[RenkoBuffShift]-Porog*Point)
            {
             RenkoBuffShift++;
             RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Porog*Point;
            } 
         }
       //----       
       if(RenkoBuff[RenkoBuffShift] > RenkoBuff[RenkoBuffShift-1])
         {
           if(Close[i] > RenkoBuff[RenkoBuffShift] + Porog*Point)
             { 
               while(Close[i] > RenkoBuff[RenkoBuffShift] + Porog*Point)
                 {
                   RenkoBuffShift++;
                   RenkoBuff[RenkoBuffShift] = RenkoBuff[RenkoBuffShift-1] + Porog*Point;
                 }
             }   
           if(Close[i] < RenkoBuff[RenkoBuffShift] - 2*Porog*Point)
             {
               RenkoBuffShift++;
               RenkoBuff[RenkoBuffShift] = RenkoBuff[RenkoBuffShift-1] - 2*Porog*Point;  
               while(Close[i] < RenkoBuff[RenkoBuffShift] - Porog*Point)
                 {
                   RenkoBuffShift++;
                   RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Porog*Point;
                 }
             }   
         }
       //----      
       if(RenkoBuff[RenkoBuffShift] < RenkoBuff[RenkoBuffShift-1])  
         {
           if(Close[i] < RenkoBuff[RenkoBuffShift] - Porog*Point)
             {
               while(Close[i] < RenkoBuff[RenkoBuffShift] - Porog*Point)
                 {
                   RenkoBuffShift++;
                   RenkoBuff[RenkoBuffShift] = RenkoBuff[RenkoBuffShift-1] - Porog*Point;
                 }
             }
           if(Close[i] > RenkoBuff[RenkoBuffShift] + 2*Porog*Point)        
             {
               RenkoBuffShift++;
               RenkoBuff[RenkoBuffShift] = RenkoBuff[RenkoBuffShift-1] + 2*Porog*Point;  
               while(Close[i] > RenkoBuff[RenkoBuffShift] + Porog*Point)
                 {
                   RenkoBuffShift++;
                   RenkoBuff[RenkoBuffShift] = RenkoBuff[RenkoBuffShift-1] + Porog*Point;
                 }
             }   
         }            
     }
//---- Рисуем график
   ObjectCreate("RENKO-" + Porog, OBJ_RECTANGLE, WindowFind("RENKO(" + Porog + "pt)"), 
                0, 0, 0, 0);
   ObjectSet("RENKO-" + Porog, OBJPROP_TIME2, Time[0]);
   ObjectSet("RENKO-" + Porog, OBJPROP_PRICE2, High[ArrayMaximum(RenkoBuff)]*2);
   ObjectSet("RENKO-" + Porog, OBJPROP_COLOR, ColorOfFon);
   for(i = 0; i < Bars; i++)
     {
       Lab[i] = 0;
       HU[i] = 0;
       HD[i] = 0;
       Fon[i] = 0;
     }  
   if(RenkoBuffShift > Bars - 100)
     {
       for(i = 0; i <= Bars - 100; i++)
           RenkoBuff[i] = RenkoBuff[i+RenkoBuffShift-(Bars-100)];
       RenkoBuffShift = Bars - 100;
     }  
   for(i = 1; i <= RenkoBuffShift; i++)
       Lab[RenkoBuffShift-i] = RenkoBuff[i];
   for(i = 1; i <= RenkoBuffShift; i++)
     {
       if(RenkoBuff[i] > RenkoBuff[i-1] && RenkoBuff[i-1] > RenkoBuff[i-2])
         {
           HU[RenkoBuffShift-i] = RenkoBuff[i];
           HD[RenkoBuffShift-i] = RenkoBuff[i-1];
           Fon[RenkoBuffShift-i] = RenkoBuff[i-1];
         }
       if(RenkoBuff[i] > RenkoBuff[i-1] && RenkoBuff[i-1] < RenkoBuff[i-2])
         {
           HU[RenkoBuffShift-i] = RenkoBuff[i];
           HD[RenkoBuffShift-i] = RenkoBuff[i] - Porog*Point;
           Fon[RenkoBuffShift-i] = RenkoBuff[i] - Porog*Point;
         }  
       if(RenkoBuff[i] < RenkoBuff[i-1] && RenkoBuff[i-1] < RenkoBuff[i-2])
         {
           HD[RenkoBuffShift-i] = RenkoBuff[i-1];
           HU[RenkoBuffShift-i] = RenkoBuff[i];
           Fon[RenkoBuffShift-i] = RenkoBuff[i];
         }   
       if(RenkoBuff[i] < RenkoBuff[i-1] && RenkoBuff[i-1] > RenkoBuff[i-2])
         {
           HD[RenkoBuffShift-i] = RenkoBuff[i] + Porog*Point;
           HU[RenkoBuffShift-i] = RenkoBuff[i];
           Fon[RenkoBuffShift-i] = RenkoBuff[i];
         }     
     }   
   return(0);
  }
//+------------------------------------------------------------------+