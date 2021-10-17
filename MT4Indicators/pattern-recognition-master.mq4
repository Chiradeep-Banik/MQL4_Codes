//+------------------------------------------------------------------+
//|        Pattern Recognition Hammer & Shooting ShootStar v1.0      |
//|                                                                  |
//|           Original logic taken from Jason Robinson's             |
//|             Pattern recognition indicator                        |
//|       Updated pattern formulas by Carl Sanders to match          |
//|                 candle formulas used by RET,                     |
//|                 Refined Elliottician Trader                      |
//|   Alert logic fixed by Hartono Setiono  groups@mitrakom.com      |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2007, Carl Sanders (traden4x)."
#property link      "traden4x@gmail.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Yellow

//Turn it to true if you broker uses extra digit in quotes
extern bool UseExtraDigit = false;

extern bool Show_Alert = true;

extern bool Display_ShootStar_2 = true;
extern bool Show_ShootStar_Alert_2 = true;
extern bool Display_ShootStar_3 = true;
extern bool Show_ShootStar_Alert_3 = true;
extern bool Display_ShootStar_4 = true;
extern bool Show_ShootStar_Alert_4 = true;
extern color Color_ShootStar = Red;
int Text_ShootStar = 8;

extern bool Display_Hammer_2 = true;
extern bool Show_Hammer_Alert_2 = true;
extern bool Display_Hammer_3 = true;
extern bool Show_Hammer_Alert_3 = true;
extern bool Display_Hammer_4 = true;
extern bool Show_Hammer_Alert_4 = true;
extern color Color_Hammer = Blue;
int Text_Hammer = 8;

extern bool Display_Doji = true;
extern bool Show_Doji_Alert = true;
extern color Color_Doji = Red;
int Text_Doji = 8;

extern bool Display_Stars = true;
extern bool Show_Stars_Alert = true;
extern int  Star_Body_Length = 5;
extern color Color_Star = Blue;
int Text_Star = 8;

extern bool Display_Dark_Cloud_Cover = true;
extern bool Show_DarkCC_Alert = true;
extern color Color_DarkCC = Red;
int Text_DarkCC = 8;

extern bool Display_Piercing_Line = true;
extern bool Show_Piercing_Line_Alert = true;
extern color Color_Piercing_Line = Blue;
int Text_Piercing_Line = 8;

extern bool Display_Bearish_Engulfing = true;
extern bool Show_Bearish_Engulfing_Alert = true;
extern color Color_Bearish_Engulfing = Red;
int Text_Bearish_Engulfing = 8;

extern bool Display_Bullish_Engulfing = false;
extern bool Show_Bullish_Engulfing_Alert = false;
extern color Color_Bullish_Engulfing = Blue;
int Text_Bullish_Engulfing = 8;


//---- buffers
double upArrow[];
double downArrow[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {

//---- indicators
   
   SetIndexStyle(0,DRAW_ARROW, EMPTY);
   SetIndexArrow(0,72);
   SetIndexBuffer(0, downArrow);
      
   SetIndexStyle(1,DRAW_ARROW, EMPTY);
   SetIndexArrow(1,71);
   SetIndexBuffer(1, upArrow);
      
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   ObjectsDeleteAll(0, OBJ_TEXT);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

Comment("\n", "\n", "Bearish",
"\n", "SS 2,3,4 - Shooting Star", 
"\n", "E_Star   - Evening Star",
"\n", "E_Doji   - Evening Doji Star",
"\n", "DCC      - Dark Cloud Pattern",
"\n", "S_E      - Bearish Engulfing Pattern", 
"\n", "\n", "Bullish",
"\n", "HMR 2,3,4 - Bullish Hammer",
"\n", "M_Star    - Morning Star",
"\n", "M_Doji    - Morning Doji Star",
"\n", "P_L       - Piercing Line Pattern",
"\n", "L_E       - Bullish Engulfing Pattern");


   double Range, AvgRange;
   int counter, setalert;
   static datetime prevtime = 0;
   int shift;
   int shift1;
   int shift2;
   int shift3;
   int shift4;
   string pattern, period;
   int setPattern = 0;
   int alert = 0;
   int arrowShift;
   int textShift;
   double O, O1, O2, C, C1, C2, C3, L, L1, L2, L3, H, H1, H2, H3;
   double CL, CLmin, CL1, CL2, BL, BLa, BL90, BL1, BL2, UW, UWa, UW1, UW2, LW, LWa, LW1, LW2, BodyHigh, BodyLow;
   BodyHigh = 0;
   BodyLow = 0;
   double Doji_Star_Ratio = 0;
   double Doji_MinLength = 0;
   double Star_MinLength = 0;
   int  Pointer_Offset = 0;         // The offset value for the arrow to be located off the candle high or low point.
   int  High_Offset = 0;            // The offset value added to the high arrow pointer for correct plotting of the pattern label.
   int  Offset_ShootStar = 0;       // The offset value of the shooting star above or below the pointer arrow.
   int  Offset_Hammer = 0;          // The offset value of the hammer above or below the pointer arrow.
   int  Offset_Doji = 0;            // The offset value of the doji above or below the pointer arrow.
   int  Offset_Star = 0;            // The offset value of the star above or below the pointer arrow.
   int  Offset_Piercing_Line = 0;   // The offset value of the piercing line above or below the pointer arrow.
   int  Offset_DarkCC = 0;          // The offset value of the dark cloud cover above or below the pointer arrow.
   int  Offset_Bullish_Engulfing = 0;
   int  Offset_Bearish_Engulfing = 0;
   int  CumOffset = 0;              // The counter value to be added to as more candle types are met.
   int  IncOffset = 0;              // The offset value that is added to a cummaltive offset value for each pass through the routine so any 
                                    // additional candle patterns that are also met, the label will print above the previous label. 
   double Piercing_Line_Ratio = 0;      
   int Piercing_Candle_Length = 0;  
   int Engulfing_Length = 0;
   double Candle_WickBody_Percent = 0;
   int CandleLength = 0;  
   
   if(prevtime == Time[0]) {
      return(0);
   }
   prevtime = Time[0];
   
   switch (Period()) {
      case 1:
         period = "M1";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 10;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;  
         Pointer_Offset = 9;
         High_Offset = 15;
         Offset_Hammer = 5;
         Offset_ShootStar = 5;
         Offset_Doji = 5;
         Offset_Star = 5;
         Offset_Piercing_Line = 5;
         Offset_DarkCC = 5;
         Offset_Bearish_Engulfing = 5;
         Offset_Bullish_Engulfing = 5;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 16;
         break;
      case 5:
         period = "M5";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 10;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;
         Pointer_Offset = 9;
         High_Offset = 15;
         Offset_Hammer = 5;
         Offset_ShootStar = 5;
         Offset_Doji = 5;
         Offset_Star = 5;
         Offset_Piercing_Line = 5;
         Offset_DarkCC = 5;
         Offset_Bearish_Engulfing = 5;
         Offset_Bullish_Engulfing = 5;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 16;
         break;
      case 15:
         period = "M15";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 0;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;
         Pointer_Offset = 9;
         High_Offset = 15;
         Offset_Hammer = 5;
         Offset_ShootStar = 5;
         Offset_Doji = 5;
         Offset_Star = 5;
         Offset_Piercing_Line = 5;
         Offset_DarkCC = 5;
         Offset_Bearish_Engulfing = 5;
         Offset_Bullish_Engulfing = 5;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 16;
         break;
      case 30:
         period = "M30";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 15;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;
         Pointer_Offset = 9;
         High_Offset = 15;
         Offset_Hammer = 5;
         Offset_ShootStar = 5;
         Offset_Doji = 5;
         Offset_Star = 5;
         Offset_Piercing_Line = 5;
         Offset_DarkCC = 5;
         Offset_Bearish_Engulfing = 5;
         Offset_Bullish_Engulfing = 5;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 16;
         break;      
      case 60:
         period = "H1";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 25;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;
         Pointer_Offset = 9;
         High_Offset = 20;
         Offset_Hammer = 8;
         Offset_ShootStar = 8;
         Offset_Doji = 8;
         Offset_Star = 8;
         Offset_Piercing_Line = 8;
         Offset_DarkCC = 8;
         Offset_Bearish_Engulfing = 8;
         Offset_Bullish_Engulfing = 8;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 18;
         break;
      case 240:
         period = "H4";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 20;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;
         Pointer_Offset = 20;
         High_Offset = 40;
         Offset_Hammer = 10;
         Offset_ShootStar = 10;
         Offset_Doji = 10;
         Offset_Star = 10;
         Offset_Piercing_Line = 10;
         Offset_DarkCC = 10;
         Offset_Bearish_Engulfing = 10;
         Offset_Bullish_Engulfing = 10;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 25;
         break;
      case 1440:
         period = "D1";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 30;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;
         Pointer_Offset = 9;
         High_Offset = 80;
         Offset_Hammer = 15;
         Offset_ShootStar = 15;
         Offset_Doji = 15;
         Offset_Star = 15;
         Offset_Piercing_Line = 15;
         Offset_DarkCC = 15;
         Offset_Bearish_Engulfing = 15;
         Offset_Bullish_Engulfing = 15;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 60;
         break;
      case 10080:
         period = "W1";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 40;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;
         Pointer_Offset = 9;
         High_Offset = 35;
         Offset_Hammer = 20;
         Offset_ShootStar = 20;
         Offset_Doji = 20;
         Offset_Star = 20;
         Offset_Piercing_Line = 20;
         Offset_DarkCC = 20;
         Offset_Bearish_Engulfing = 20;
         Offset_Bullish_Engulfing = 20;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 35;
         break;
      case 43200:
         period = "MN";
         Doji_Star_Ratio = 0;
         Piercing_Line_Ratio = 0.5;
         Piercing_Candle_Length = 10;
         Engulfing_Length = 50;
         Candle_WickBody_Percent = 0.9;
         CandleLength = 12;
         Pointer_Offset = 9;
         High_Offset = 45;
         Offset_Hammer = 30;
         Offset_ShootStar = 30;
         Offset_Doji = 30;
         Offset_Star = 30;
         Offset_Piercing_Line = 30;
         Offset_DarkCC = 30;
         Offset_Bearish_Engulfing = 30;
         Offset_Bullish_Engulfing = 30;
         Text_ShootStar = 8;
         Text_Hammer = 8;
         Text_Star = 8;
         Text_DarkCC = 8;
         Text_Piercing_Line = 8;
         Text_Bearish_Engulfing = 8;
         Text_Bullish_Engulfing = 8;
         IncOffset = 45;
         break;
   }
   
   //ADDED: Check if 5-digit quotes are used and multiply basic offsets
   if (UseExtraDigit)
   {
         Piercing_Candle_Length *= 10;
         Engulfing_Length *= 10;
         Candle_WickBody_Percent *= 10;
         CandleLength *= 10;  
         Pointer_Offset *= 10;
         High_Offset *= 10;
         Offset_Hammer *= 10;
         Offset_ShootStar *= 10;
         Offset_Doji *= 10;
         Offset_Star *= 10;
         Offset_Piercing_Line *= 10;
         Offset_DarkCC = 10;
         Offset_Bearish_Engulfing *= 10;
         Offset_Bullish_Engulfing *= 10;
         IncOffset *= 10;
   }
   
   for (shift = 0; shift < Bars; shift++) {
      
      CumOffset = 0;
      setalert = 0;
      counter=shift;
      Range=0;
      AvgRange=0;
      for (counter=shift ;counter<=shift+9;counter++) {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      shift1 = shift + 1;
      shift2 = shift + 2;
      shift3 = shift + 3;
      shift4 = shift + 4;
      
      
      O = Open[shift1];
      O1 = Open[shift2];
      O2 = Open[shift3];
      H = High[shift1];
      H1 = High[shift2];
      H2 = High[shift3];
      H3 = High[shift4];
      L = Low[shift1];
      L1 = Low[shift2];
      L2 = Low[shift3];
      L3 = Low[shift4];
      C = Close[shift1];
      C1 = Close[shift2];
      C2 = Close[shift3];
      C3 = Close[shift4];
      if (O>C) {
         BodyHigh = O;
         BodyLow = C;  }
      else {
         BodyHigh = C;
         BodyLow = O; }
      CL = High[shift1]-Low[shift1];
      CL1 = High[shift2]-Low[shift2];
      CL2 = High[shift3]-Low[shift3];
      BL = Open[shift1]-Close[shift1];
      UW = High[shift1]-BodyHigh;
      LW = BodyLow-Low[shift1];
      BLa = MathAbs(BL);
      BL90 = BLa*Candle_WickBody_Percent;
            
         
 // Bearish Patterns  
 
      // Check for Bearish Shooting ShootStar
      if ((H>=H1)&&(H>H2)&&(H>H3))  {
         if (((UW/2)>LW)&&(UW>(2*BL90))&&(CL>=(CandleLength*Point))&&(O!=C)&&((UW/3)<=LW)&&((UW/4)<=LW)/*&&(L>L1)&&(L>L2)*/)  {
         if (Display_ShootStar_2 == true)  {
            ObjectCreate(GetName("SS 2",shift), OBJ_TEXT, 0, Time[shift1], High[shift1] + (Pointer_Offset+Offset_ShootStar+High_Offset+CumOffset)*Point);
            ObjectSetText(GetName("SS 2",shift), "SS 2", Text_ShootStar, "Times New Roman", Color_ShootStar);
            CumOffset = CumOffset+IncOffset;
            downArrow[shift1] = High[shift1] + (Pointer_Offset*Point);
         }
         if (Show_ShootStar_Alert_2) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Shooting ShootStar 2";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Bearish Shooting ShootStar
      if ((H>=H1)&&(H>H2)&&(H>H3))  {
         if (((UW/3)>LW)&&(UW>(2*BL90))&&(CL>=(CandleLength*Point))&&(O!=C)&&((UW/4)<=LW)/*&&(L>L1)&&(L>L2)*/)  {
         if (Display_ShootStar_3 == true)  {
            ObjectCreate(GetName("SS 3",shift), OBJ_TEXT, 0, Time[shift1], High[shift1] + (Pointer_Offset+Offset_ShootStar+High_Offset+CumOffset)*Point);
            ObjectSetText(GetName("SS 3",shift), "SS 3", Text_ShootStar, "Times New Roman", Color_ShootStar);
            CumOffset = CumOffset+IncOffset;
            downArrow[shift1] = High[shift1] + (Pointer_Offset*Point);
         }
         if (Show_ShootStar_Alert_3) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Shooting ShootStar 3";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Bearish Shooting ShootStar
      if ((H>=H1)&&(H>H2)&&(H>H3))  {
         if (((UW/4)>LW)&&(UW>(2*BL90))&&(CL>=(CandleLength*Point))&&(O!=C)/*&&(L>L1)&&(L>L2)*/)  {
         if (Display_ShootStar_4 == true)  {
            ObjectCreate(GetName("SS 4",shift), OBJ_TEXT, 0, Time[shift1], High[shift1] + (Pointer_Offset+Offset_ShootStar+High_Offset+CumOffset)*Point);
            ObjectSetText(GetName("SS 4",shift), "SS 4", Text_ShootStar, "Times New Roman", Color_ShootStar);
            CumOffset = CumOffset+IncOffset;
            downArrow[shift1] = High[shift1] + (Pointer_Offset*Point);
         }
          if (Show_ShootStar_Alert_4) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Shooting ShootStar 4";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Evening Star pattern
      if ((H>=H1)&&(H1>H2)&&(H1>H3))  {
         if (/*(L>O1)&&*/(BLa<(Star_Body_Length*Point))&&(C2>O2)&&(!O==C)&&((C2-O2)/(/*0.001+*/H2-L2)>Doji_Star_Ratio)/*&&(C2<O1)*/&&(C1>O1)/*&&((H1-L1)>(3*(C1-O1)))*/&&(O>C)&&(CL>=(Star_MinLength*Point))){
         if (Display_Stars == true) {
            ObjectCreate(GetName("Star",shift), OBJ_TEXT, 0, Time[shift1], High[shift1] + (Pointer_Offset+Offset_Star+High_Offset+CumOffset)*Point);
            ObjectSetText(GetName("Star",shift), "E_Star", Text_Star, "Times New Roman", Color_Star);
            CumOffset = CumOffset+IncOffset;
            downArrow[shift1] = High[shift1] + (Pointer_Offset*Point);
         }
         if (Show_Stars_Alert) {
         if (setalert == 0 && Show_Alert == true) {
            pattern="Evening Star Pattern";
            setalert = 1;
         }
         }
         }
      }  
      
      // Check for Evening Doji Star pattern
      if ((H>=H1)&&(H1>H2)&&(H1>H3))  {
         if (/*(L>O1)&&*/(O==C)&&((C2>O2)&&(C2-O2)/(/*0.001+*/H2-L2)>Doji_Star_Ratio)/*&&(C2<O1)*/&&(C1>O1)/*&&((H1-L1)>(3*(C1-O1)))*/&&(CL>=(Doji_MinLength*Point))) {
         if (Display_Doji == true) {
            ObjectCreate(GetName("Doji",shift), OBJ_TEXT, 0, Time[shift1], High[shift1] + (Pointer_Offset+Offset_Doji+High_Offset+CumOffset)*Point);
            ObjectSetText(GetName("Doji",shift), "E_Doji", Text_Doji, "Times New Roman", Color_Doji);
            CumOffset = CumOffset+IncOffset;
            downArrow[shift1] = High[shift1] + (Pointer_Offset*Point);
         }
         if (Show_Doji_Alert) {
         if (setalert == 0 && Show_Alert == true) {
            pattern="Evening Doji Star Pattern";
            setalert = 1;
         }
         }
         }
      } 
      
      // Check for a Dark Cloud Cover pattern
      if ((C1>O1)&&(((C1+O1)/2)>C)&&(O>C)/*&&(O>C1)*/&&(C>O1)&&((O-C)/(/*0.001+*/(H-L))>Piercing_Line_Ratio)&&((CL>=Piercing_Candle_Length*Point))) {
         if (Display_Dark_Cloud_Cover == true) {   
            ObjectCreate(GetName("DCC",shift), OBJ_TEXT, 0, Time[shift1], High[shift1] + (Pointer_Offset+Offset_DarkCC+High_Offset+CumOffset)*Point);
            ObjectSetText(GetName("DCC",shift), "DCC", Text_DarkCC, "Times New Roman", Color_DarkCC);
            CumOffset = CumOffset+IncOffset;
            downArrow[shift1] = High[shift1] + (Pointer_Offset*Point);
         }
         if (Show_DarkCC_Alert) {
         if (setalert == 0 && Show_Alert == true) {
            pattern="Dark Cloud Cover Pattern";
            setalert = 1;
         }
         }
      }

      // Check for Bearish Engulfing pattern
      if ((C1>O1)&&(O>C)&&(O>=C1)&&(O1>=C)&&((O-C)>(C1-O1))&&(CL>=(Engulfing_Length*Point))) {
         if (Display_Bearish_Engulfing == true) {
            ObjectCreate(GetName("S_E",shift), OBJ_TEXT, 0, Time[shift1], High[shift1] + (Pointer_Offset+Offset_Bearish_Engulfing+High_Offset+CumOffset)*Point);
            ObjectSetText(GetName("S_E",shift), "S_E", Text_Bearish_Engulfing, "Times New Roman", Color_Bearish_Engulfing);
            CumOffset = CumOffset+IncOffset;
            downArrow[shift1] = High[shift1] + (Pointer_Offset*Point);
         }
         if (Show_Bearish_Engulfing_Alert) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bearish Engulfing Pattern";
            setalert = 1;
         }
         }
      }
 
 // End of Bearish Patterns
   
 // Bullish Patterns
   
      // Check for Bullish Hammer   
      if ((L<=L1)&&(L<L2)&&(L<L3))  {
      if (((LW/2)>UW)&&(LW>BL90)&&(CL>=(CandleLength*Point))&&(O!=C)&&((LW/3)<=UW)&&((LW/4)<=UW)/*&&(H<H1)&&(H<H2)*/)  {
         if (Display_Hammer_2 == true)  {
            ObjectCreate(GetName("HMR 2",shift), OBJ_TEXT, 0, Time[shift1], Low[shift1] - (Pointer_Offset+Offset_Hammer+CumOffset)*Point);
            ObjectSetText(GetName("HMR 2",shift), "HMR 2", Text_Hammer, "Times New Roman", Color_Hammer);
            CumOffset = CumOffset+IncOffset;
            upArrow[shift1] = Low[shift1] - (Pointer_Offset*Point);
         }
         if (Show_Hammer_Alert_2) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bullish Hammer 2";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Bullish Hammer   
      if ((L<=L1)&&(L<L2)&&(L<L3))  {
         if (((LW/3)>UW)&&(LW>BL90)&&(CL>=(CandleLength*Point))&&(O!=C)&&((LW/4)<=UW)/*&&(H<H1)&&(H<H2)*/)  {
         if (Display_Hammer_3 == true)  {
            ObjectCreate(GetName("HMR 3",shift), OBJ_TEXT, 0, Time[shift1], Low[shift1] - (Pointer_Offset+Offset_Hammer+CumOffset)*Point);
            ObjectSetText(GetName("HMR 3",shift), "HMR 3", Text_Hammer, "Times New Roman", Color_Hammer);
            CumOffset = CumOffset+IncOffset;
            upArrow[shift1] = Low[shift1] - (Pointer_Offset*Point);
         }
         if (Show_Hammer_Alert_3) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bullish Hammer 3";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Bullish Hammer   
      if ((L<=L1)&&(L<L2)&&(L<L3))  {
         if (((LW/4)>UW)&&(LW>BL90)&&(CL>=(CandleLength*Point))&&(O!=C)/*&&(H<H1)&&(H<H2)*/)  {
         if (Display_Hammer_4 == true)  {
            ObjectCreate(GetName("HMR 4",shift), OBJ_TEXT, 0, Time[shift1], Low[shift1] - (Pointer_Offset+Offset_Hammer+CumOffset)*Point);
            ObjectSetText(GetName("HMR 4",shift), "HMR 4", Text_Hammer, "Times New Roman", Color_Hammer);
            CumOffset = CumOffset+IncOffset;
            upArrow[shift1] = Low[shift1] - (Pointer_Offset*Point);
         }
         if (Show_Hammer_Alert_4) {
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bullish Hammer 4";
            setalert = 1;
         }
         }
         }
      }      

     // Check for Morning Star
      
      if ((L<=L1)&&(L1<L2)&&(L1<L3))  {
      if (/*(H1<(BL/2))&&*/(BLa<(Star_Body_Length*Point))&&(!O==C)&&((O2>C2)&&((O2-C2)/(/*0.001+*/H2-L2)>Doji_Star_Ratio))/*&&(C2>O1)*/&&(O1>C1)/*&&((H1-L1)>(3*(C1-O1)))*/&&(C>O)&&(CL>=(Star_MinLength*Point))) {
         if (Display_Stars == true) {   
            ObjectCreate(GetName("Star",shift), OBJ_TEXT, 0, Time[shift1], Low[shift1] - (Pointer_Offset+Offset_Star+CumOffset)*Point);
            ObjectSetText(GetName("Star",shift), "M_Star", Text_Star, "Times New Roman", Color_Star);
            CumOffset = CumOffset+IncOffset;
            upArrow[shift1] = Low[shift1] - (Pointer_Offset*Point);
         }
         if (Show_Stars_Alert) {
         if (shift == 0 && Show_Alert == true) {
            pattern="Morning Star Pattern";
            setalert = 1;
         }
         }
         }
      }

      // Check for Morning Doji Star
      
      if ((L<=L1)&&(L1<L2)&&(L1<L3))  {
      if (/*(H1<(BL/2))&&*/(O==C)&&((O2>C2)&&((O2-C2)/(/*0.001+*/H2-L2)>Doji_Star_Ratio))/*&&(C2>O1)*/&&(O1>C1)/*&&((H1-L1)>(3*(C1-O1)))*/&&(CL>=(Doji_MinLength*Point))) {
         if (Display_Doji == true) {   
            ObjectCreate(GetName("Doji",shift), OBJ_TEXT, 0, Time[shift1], Low[shift1] - (Pointer_Offset+Offset_Doji+CumOffset)*Point);
            ObjectSetText(GetName("Doji",shift), "M_Doji", Text_Doji, "Times New Roman", Color_Doji);
            CumOffset = CumOffset+IncOffset;
            upArrow[shift1] = Low[shift1] - (Pointer_Offset*Point);
         }
         if (Show_Doji_Alert) {
         if (shift == 0 && Show_Alert == true) {
            pattern="Morning Doji Pattern";
            setalert = 1;
         }
         }
         }
      }
      
      // Check for Piercing Line pattern
      
      if ((C1<O1)&&(((O1+C1)/2)<C)&&(O<C)/*&&(O<C1)*//*&&(C<O1)*/&&((C-O)/(/*0.001+*/(H-L))>Piercing_Line_Ratio)&&(CL>=(Piercing_Candle_Length*Point))) {
         if (Display_Piercing_Line == true) {   
            ObjectCreate(GetName("PrcLn",shift), OBJ_TEXT, 0, Time[shift1], Low[shift1] - (Pointer_Offset+Offset_Piercing_Line+CumOffset)*Point);
            ObjectSetText(GetName("PrcLn",shift), "P_L", Text_Piercing_Line, "Times New Roman", Color_Piercing_Line);
            CumOffset = CumOffset+IncOffset;
            upArrow[shift1] = Low[shift1] - (Pointer_Offset*Point);
         }
         if (Show_Piercing_Line_Alert) {
         if (shift == 0 && Show_Alert == true) {
            pattern="Piercing Line Pattern";
            setalert = 1;
         }
         }
      }   

      // Check for Bullish Engulfing pattern
      
      if ((O1>C1)&&(C>O)&&(C>=O1)&&(C1>=O)&&((C-O)>(O1-C1))&&(CL>=(Engulfing_Length*Point))) {
         if (Display_Bullish_Engulfing) {   
            ObjectCreate(GetName("L_E",shift), OBJ_TEXT, 0, Time[shift1], Low[shift1] - (Pointer_Offset+Offset_Bullish_Engulfing+CumOffset)*Point);
            ObjectSetText(GetName("L_E",shift), "L_E", Text_Bullish_Engulfing, "Times New Roman", Color_Bullish_Engulfing);
            CumOffset = CumOffset+IncOffset;
            upArrow[shift1] = Low[shift1] - (Pointer_Offset*Point);
         }
         if (Show_Bullish_Engulfing_Alert) {
         if (shift == 0 && Show_Alert == true) {
            pattern="Bullish Engulfing Pattern";
            setalert = 1;
         }
         }
      }
      
 // End of Bullish Patterns          
      if (setalert == 1 && shift == 0) {
         Alert(Symbol(), " ", period, " ", pattern);
         setalert = 0;
      }
      CumOffset = 0;
   } // End of for loop
     
   
      
   return(0);
}
//+------------------------------------------------------------------+

string GetName(string aName,int shift)
{
  return(aName+DoubleToStr(Time[shift],0));
}