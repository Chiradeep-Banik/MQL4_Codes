//+------------------------------------------------------------------+
//|                                     PipNailer DashBoard_v1.5.mq4 |
//|                                                  © 2008 SwingMan |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//+------------------------------------------------------------------+
//  v1.2  Names sorted
//        Spreads added, Alerts added
//        Entry price  = Close from last bar (+Spread for Long Entrys)
//        input ShiftSignals period for older or current signals
//        Refresh signals every minute
//  v1.3  Time frame list
//+------------------------------------------------------------------+

#property indicator_separate_window

//---- extern inputs -------------------------------------------------
//- This is where you add the currency pairs you want 
extern string PairsList1 = "AUDCAD,AUDJPY,AUDUSD,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURUSD,";
extern string PairsList2 = "GBPCHF,GBPJPY,GBPUSD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY,";
extern string PairsList3 = "GLD,SLV,OIL";
//- If your broker names the currency pairs with a suffix for a mini account (like an "m", for example), enter the suffix here
extern string SymbolSuffix = "";
extern string TimeFrameList = "5,15,30,60,240,1440,10080";
extern int ShiftSignals = 1;
extern bool SendAlert_Signals = true;
extern bool PrintAlert_Signals = true;
extern bool Draw_IntermediateSignals = false;
extern int refreshPeriod = PERIOD_M1; // refresh calcultion
extern double SAR_Step = 0.02;
extern double SAR_Max  = 0.2;
//--------------------------------------------------------------------
int TimeFrame;

//---- constants
string windowsName = "PipNailer DashBoard_v1.5";
string sLabelCode = "PipNailerDB_";
int Corner_LeftUp = 0;
int Corner_RightUp = 1;
int Corner_LeftDn = 2;
int Corner_RightDn = 3;

//---- colors
color colorTitle = DodgerBlue;
color colorTime = White;
color colorPlusIndi  = Green;
color colorMinusIndi = Red;
color colorPlusSignal  = DeepSkyBlue;
color colorMinusSignal = Magenta;
color colorNeutralSignal = SandyBrown;

//---- variables
string PairsList;
string Pair[30]; //Pairs array
double PairPrice[30];
int NumberSymbols, NumberTimeFrames;
int iWindow, iCorner;
int xCol[50], yRow[50];
string Title1[50], Title2[50];
datetime oldTime, thisTime;
bool CurrentTimeFrameOK;
double iTimeFrame[10];
string sTimeFrame[10];

//---- initialisations
int nTitles = 30;

int xLeftTitle = 20;
int xCurrentTime = 3; 

int yCurrentTime = 15;
int yTitle1 = 30;
int yTitle2 = 50;

int rowStep = 20;
int colStep = 57;
int colStepTimeFrames = 85;

int colDB_Pairs, colDB_Spread;
int colDB_Close, colDB_LastPrice;
int iColDB_First, colDB_M5, colDB_M15, colDB_M30, colDB_H1, colDB_H4, colDB_D1, colDB_W1;

//-- Signal buffers
double dSAR[30][10][5], dAC[30][10][5], dAO[30][10][5], AlertSignal[30][10];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{ 
   if (Check_ShiftSignals() == false) return(0);

   PairsList = StringConcatenate(PairsList1,PairsList2,PairsList3);
   iCorner = Corner_LeftUp;
   CurrentTimeFrameOK = false;
   TimeFrame = Period();
   oldTime = 0;

   IndicatorShortName(windowsName);
   SetIndexLabel(0,windowsName);
   
   //-- clear Titles
   for (int i=0; i<=50; i++) {
      Title1[i] = "";
      Title2[i] = "";
   }
   //-- clear Time Frames
   for (i=0; i<=10; i++) {
      iTimeFrame[i] = 0;
      sTimeFrame[i] = "";
   } 
//----
   return(0); 
}

bool Check_ShiftSignals()
{
   if (ShiftSignals < 0) {
      Alert("ShiftSignals must be greater or equal 0!");
      return(false);
   }
   return(true);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{  
   Delete_TextObjects();
   Sleep(500);
   Delete_TextObjects();   
//----
   return(0);
}

void Delete_TextObjects()
{
   ObjectsDeleteAll(1,OBJ_LABEL);
   ObjectsDeleteAll(1,OBJ_TEXT);
   ObjectsDeleteAll(1,OBJ_ARROW);
   return;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
//-- refresh every minute
   thisTime = iTime(Symbol(), refreshPeriod, 0);
   if (thisTime == oldTime) return(0);
   oldTime = thisTime;

//----   
   iWindow = WindowFind(windowsName);
   if (iWindow==-1) iWindow=1;

   //---- titles
   Get_PairListNames();   
   Get_TimeFrameListValues();
   Set_Initialisations();   
   Show_TitlesUpper();
   Show_TitlesLeft();   
   
   //---- indicators 
   Get_IndicatorValues();
      
   Write_CurrentTime(xCurrentTime, yCurrentTime);   
//----
   return(0);
}
//+------------------------------------------------------------------+

//####################################################################
//+------------------------------------------------------------------+
//|   Initialisations
//+------------------------------------------------------------------+

void Set_ColumnNumbers()
{
   int iCol = 1;
   colDB_Pairs  = iCol; iCol = iCol +1;
   colDB_Spread = iCol; iCol = iCol +1;

   colDB_Close = iCol; iCol = iCol +1;
   colDB_LastPrice = iCol; iCol = iCol +1;
   colDB_M5  = iCol; iCol = iCol +1;
   colDB_M15 = iCol; iCol = iCol +1;
   colDB_M30 = iCol; iCol = iCol +1;
   colDB_H1  = iCol; iCol = iCol +1;
   colDB_H4  = iCol; iCol = iCol +1;
   colDB_D1  = iCol; iCol = iCol +1;
   colDB_W1  = iCol; iCol = iCol +1;
}

void Set_Initialisations()
{
   int i;
   Set_ColumnNumbers();
   string thisTimeFrame = Get_sPeriod(Period());   
   //-- Titles 1 .....................................................
   Title1[colDB_Pairs] = "Pairs:";
   Title1[colDB_Spread] = "Pair";
   Title1[colDB_Close] = "Last "+thisTimeFrame;
   Title1[colDB_LastPrice] = "Current";   
   
   //-- Title 1 => TimeFrames
   iColDB_First = colDB_LastPrice + 1;
   for (i=0; i<=NumberTimeFrames; i++) {
      sTimeFrame[i] = Get_sPeriod(iTimeFrame[i]);   
      Title1[iColDB_First + i] = sTimeFrame[i];
   }   
 
   //-- Titles 2   
   Title2[colDB_Spread] = "Sprd";
   Title2[colDB_Close] = "Close";
   Title2[colDB_LastPrice] = "Price";   

   //---- x Columns ..................................................  
   xCol[colDB_Pairs]  = xLeftTitle;
   xCol[colDB_Spread] = xCol[colDB_Pairs] + colStep + 40;
   xCol[colDB_Close]  = xCol[colDB_Spread] + colStep;
   xCol[colDB_LastPrice] = xCol[colDB_Close] + colStep;

   if (Draw_IntermediateSignals) int newColStep = colStepTimeFrames;
   else  newColStep = colStep;
   
   int iCol = colDB_LastPrice+1;   
   xCol[iCol] = xCol[iCol-1] + colStepTimeFrames;
   
   for (i=iCol+1; i<nTitles; i++)
      xCol[i] = xCol[i-1] + newColStep;

   //---- y Rows .....................................................
   yRow[0] = yTitle2 + rowStep;
   for (i=1; i<=NumberSymbols; i++)
      yRow[i] = yRow[i-1] + rowStep;
}

void Show_TitlesUpper()   
{  
   int xx1, xx2;
   for (int i=1; i<nTitles; i++) {
      xx1 = xCol[i];
      xx2 = xx1;
      //-- Adjust xCol
      if (i==colDB_Close) xx1 = xx1 - 10;
     
      if (Title1[i] != "") 
        SetLabelObject(sLabelCode+"Title1_"+i, Title1[i],  colorTitle, xx1, yTitle1);
      if (Title2[i] != "")
        SetLabelObject(sLabelCode+"Title2_"+i, Title2[i],  colorTitle, xx2, yTitle2);        
   }      
}

void Show_TitlesLeft()
{
   for (int i=0; i<NumberSymbols; i++) { 
      string sSymbol = Pair[i];
      int j = i+1;
      if (j<10) string sNr = "0" + j + ". "; else sNr = j + ". ";
      string sNrSymbol = sNr + sSymbol;
      //-- Names
      SetLabelObject(sLabelCode+sSymbol, sNrSymbol, colorTitle, xLeftTitle, yRow[i]);
      //-- Spreads
      string Spread = DoubleToStr(MarketInfo(sSymbol, MODE_SPREAD),0);
      SetLabelObject(sLabelCode+sSymbol+"_Spread", Spread, colorTitle, xCol[colDB_Spread]+10, yRow[i]);
   }   
   Show_OnlyPrices();
}

void Show_OnlyPrices()
{
   for (int i=0; i<NumberSymbols; i++) { 
      string sSymbol = Pair[i];
     
      //-- Last Close
      int iDigits = MarketInfo(sSymbol,MODE_DIGITS);
      double dClose = iClose(sSymbol,TimeFrame,ShiftSignals);
      double dOpen  = iOpen(sSymbol,TimeFrame,ShiftSignals);
      if (dClose >= dOpen) color dColor = Green; else dColor = Red;      
      SetLabelObject(sLabelCode+Pair[i]+"_LastClose", DoubleToStr(dClose,iDigits),  dColor, xCol[colDB_Close], yRow[i]);
      
      //-- Current Price
      dClose = iClose(sSymbol,TimeFrame,0);
      dOpen = iOpen(sSymbol,TimeFrame,0);
      PairPrice[i] = dClose;
      if (dClose >= dOpen) dColor = Green; else dColor = Red;      
      SetLabelObject(sLabelCode+Pair[i]+"_CurrClose", DoubleToStr(dClose,iDigits),  dColor, xCol[colDB_LastPrice], yRow[i]);
   }   
}

void Write_CurrentTime(int xx, int yy)
{
   string sTime = TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
   string sTimeFrame = Get_sPeriod(TimeFrame);
   string st = sTime+"   "+Symbol() + " ," + sTimeFrame;
   SetTimeObject(sLabelCode+"time", st, colorTime, xx, yy);
}



//####################################################################
//+------------------------------------------------------------------+
//| Create Title
//+------------------------------------------------------------------+
void SetLabelObject(string sName, string sText, color dColor, int xx, int yy)
{
   ObjectCreate(sName, OBJ_LABEL, iWindow, 0, 0);
        ObjectSetText(sName,sText,10, "Arial Bold", dColor);
        ObjectSet(sName, OBJPROP_CORNER, iCorner);
        ObjectSet(sName, OBJPROP_XDISTANCE, xx);
        ObjectSet(sName, OBJPROP_YDISTANCE, yy);
}

void SetTimeObject(string sName, string sText, color dColor, int xx, int yy)
{
   ObjectCreate(sName, OBJ_LABEL, iWindow, 0, 0);
        ObjectSetText(sName,sText,7, "Arial Bold", dColor);
        ObjectSet(sName, OBJPROP_CORNER, iCorner);
        ObjectSet(sName, OBJPROP_XDISTANCE, xx);
        ObjectSet(sName, OBJPROP_YDISTANCE, yy);
}

//+------------------------------------------------------------------+
//| Set Arrow Object
//+------------------------------------------------------------------+
void SetArrowObject(string sName, int ArrowCode, int iHeight, color dColor, int xx, int yy)
{
   ObjectCreate(sName, OBJ_LABEL, iWindow, 0, 0);
   ObjectSetText(sName,CharToStr(ArrowCode),iHeight, "Wingdings", dColor);
        ObjectSet(sName, OBJPROP_CORNER, iCorner);
        ObjectSet(sName, OBJPROP_XDISTANCE, xx);
        ObjectSet(sName, OBJPROP_YDISTANCE, yy);
}

//####################################################################
//+------------------------------------------------------------------+
//|      Get PairList Names
//+------------------------------------------------------------------+
void Get_PairListNames()
{
   int i,j,k;
   string CurSymbol;
   
   for (i=0, j=0, k=1; i<nTitles && k>0;)
   {
      k=StringFind(PairsList,",",j);
      if (k==0) CurSymbol=StringSubstr(PairsList,j,0);
      else CurSymbol=StringSubstr(PairsList,j,k-j);
      CurSymbol = CurSymbol + SymbolSuffix;
      //---- check if the pair is allowable
      double dClose = iClose(CurSymbol,TimeFrame,0);      
      if (dClose > 0.0) {
         Pair[i]=CurSymbol;
         i++;
      }
     
      j=StringFind(PairsList,",",j)+1;
      if (j==0) break;
   }
   NumberSymbols = i;

   return;
}

void Get_TimeFrameListValues()
{
   int i,j,k;
   string CurTimeFrame;
   
   for (i=0, j=0, k=1; i<nTitles && k>0;)
   {
      k=StringFind(TimeFrameList,",",j);
      if (k==0) CurTimeFrame=StringSubstr(TimeFrameList,j,0);
      else CurTimeFrame=StringSubstr(TimeFrameList,j,k-j);   
        
      iTimeFrame[i] = StrToInteger(CurTimeFrame);
      i++;
          
      j=StringFind(TimeFrameList,",",j)+1;
      if (j==0) break;
   }
   NumberTimeFrames = i-1;

   return;
}

//####################################################################
//+------------------------------------------------------------------+
//|      Get Indicator Values
//+------------------------------------------------------------------+
void Get_IndicatorValues()
{
   int iArrow, iHeight=8, iHeightSignal = 10, xStep=8;
   color dColor;
   for (int i=NumberSymbols-1; i>=0; i--) { 
      string sSymbol = Pair[i];
      
      for (int col = 0; col <= NumberTimeFrames; col++) {         
         double dClose1 = iClose(sSymbol,iTimeFrame[col],ShiftSignals);
         double dClose2 = iClose(sSymbol,iTimeFrame[col],ShiftSignals+1);
         
         //-- SAR values
         int xSAR = xCol[iColDB_First + col];
         dSAR[i][col][1] = iSAR(sSymbol,iTimeFrame[col],SAR_Step,SAR_Max,ShiftSignals);
         dSAR[i][col][2] = iSAR(sSymbol,iTimeFrame[col],SAR_Step,SAR_Max,ShiftSignals+1);
         if (dClose1 >= dSAR[i][col][1]) int iValue_SAR1 = 1; else iValue_SAR1 = -1;
         if (dClose2 >= dSAR[i][col][2]) int iValue_SAR2 = 1; else iValue_SAR2 = -1;
         switch (iValue_SAR1) {
            case  1: iArrow = 217; dColor = colorPlusIndi;  break;
            case -1: iArrow = 218; dColor = colorMinusIndi; break;
         } 
         if (Draw_IntermediateSignals)
         SetArrowObject(sLabelCode+sSymbol+"_iSAR"+sTimeFrame[col], iArrow, iHeight, dColor, xSAR, yRow[i]);
         
         //-- AC values
         int xAC = xCol[iColDB_First + col] + xStep;
         dAC[i][col][1] = iAC(sSymbol,iTimeFrame[col],ShiftSignals);
         dAC[i][col][2] = iAC(sSymbol,iTimeFrame[col],ShiftSignals+1);
         dAC[i][col][3] = iAC(sSymbol,iTimeFrame[col],ShiftSignals+2);
         if (dAC[i][col][1] >= dAC[i][col][2]) int iValue_AC1 = 1; else iValue_AC1 = -1;
         if (dAC[i][col][2] >= dAC[i][col][3]) int iValue_AC2 = 1; else iValue_AC2 = -1;
         switch (iValue_AC1) {
            case  1: iArrow = 217; dColor = colorPlusIndi;  break;
            case -1: iArrow = 218; dColor = colorMinusIndi; break;
         } 
         if (Draw_IntermediateSignals)
         SetArrowObject(sLabelCode+sSymbol+"_iAC"+sTimeFrame[col], iArrow, iHeight, dColor, xAC, yRow[i]);
         
         //-- AO values
         int xAO = xCol[iColDB_First + col] + 2*xStep;         
         dAO[i][col][1] = iAO(sSymbol,iTimeFrame[col],ShiftSignals);
         dAO[i][col][2] = iAO(sSymbol,iTimeFrame[col],ShiftSignals+1);
         dAO[i][col][3] = iAO(sSymbol,iTimeFrame[col],ShiftSignals+2);
         if (dAO[i][col][1] >= dAO[i][col][2]) int iValue_AO1 = 1; else iValue_AO1 = -1;
         if (dAO[i][col][2] >= dAO[i][col][3]) int iValue_AO2 = 1; else iValue_AO2 = -1;
         switch (iValue_AO1) {
            case  1: iArrow = 217; dColor = colorPlusIndi;  break;
            case -1: iArrow = 218; dColor = colorMinusIndi; break;
         }
         if (Draw_IntermediateSignals) 
         SetArrowObject(sLabelCode+sSymbol+"_iAO"+sTimeFrame[col], iArrow, iHeight, dColor, xAO, yRow[i]);
         
         //-- Signals ................................................
         if (Draw_IntermediateSignals)
            int xSignal = xCol[iColDB_First + col] + 3*xStep;
         else
            xSignal = xCol[iColDB_First + col];
         int iSignal_SAR=0, iSignal_AC=0, iSignal_AO=0, iOrderType=0;
         if (iValue_SAR1 == 1 && iValue_SAR2 ==-1) iSignal_SAR = 1;
         if (iValue_SAR1 == -1 && iValue_SAR2 ==1) iSignal_SAR = -1;
         
         if (iValue_AC1 == 1 && iValue_AC2 ==-1) iSignal_AC = 1;
         if (iValue_AC1 == -1 && iValue_AC2 ==1) iSignal_AC = -1;
         
         if (iValue_AO1 == 1 && iValue_AO2 ==-1) iSignal_AO = 1;
         if (iValue_AO1 == -1 && iValue_AO2 ==1) iSignal_AO = -1;
         
         if(iSignal_SAR ==1 && iSignal_AC ==1 && iSignal_AO==1) iOrderType=1;
         if(iSignal_SAR ==-1 && iSignal_AC ==-1 && iSignal_AO==-1) iOrderType=-1;
         
         int xOffset = 15; 
         int yOffset = 2;
         int xx = xSignal + xOffset;         
         if (iOrderType == 1) {
            iArrow = 233;
            dColor = colorPlusSignal;
            string sPrice = Get_EntryPrice(iOrderType, sSymbol, iTimeFrame[col]);
            SetArrowObject(sLabelCode+sSymbol+"_iSignal"+sTimeFrame[col], iArrow, iHeightSignal, dColor, xSignal, yRow[i]);
            int yy = yRow[i];
            SetLabelObject(sLabelCode+sSymbol+"_dEntry"+sTimeFrame[col], sPrice, dColor, xx, yy);
            if (SendAlert_Signals)  function_SendAlert(iOrderType, sSymbol, iTimeFrame[col], sTimeFrame[col], sPrice, i, col);
            else
            if (PrintAlert_Signals) function_PrintAlert(iOrderType, sSymbol, iTimeFrame[col], sTimeFrame[col], sPrice, i, col);
         }
         else
         if (iOrderType == -1) {
            iArrow = 234;
            dColor = colorMinusSignal;
            sPrice = Get_EntryPrice(iOrderType, sSymbol, iTimeFrame[col]);
            SetArrowObject(sLabelCode+sSymbol+"_iSignal"+sTimeFrame[col], iArrow, iHeightSignal, dColor, xSignal, yRow[i]);  
            yy = yRow[i] - yOffset;
            SetLabelObject(sLabelCode+sSymbol+"_dEntry"+sTimeFrame[col], sPrice, dColor, xx, yy);
            if (SendAlert_Signals)  function_SendAlert(iOrderType, sSymbol, iTimeFrame[col], sTimeFrame[col], sPrice, i, col);
            else
            if (PrintAlert_Signals) function_PrintAlert(iOrderType, sSymbol, iTimeFrame[col], sTimeFrame[col], sPrice, i, col);
         }
         else {
            SetLabelObject(sLabelCode+sSymbol+"_iSignal"+sTimeFrame[col], " ", Black, xSignal, yRow[i]);
            SetLabelObject(sLabelCode+sSymbol+"_dEntry"+sTimeFrame[col], " ", Black, xx, yy);
            AlertSignal[i][col] = 0;
            
            iArrow = 251; dColor = colorNeutralSignal;         
            if (Draw_IntermediateSignals==false)
               SetArrowObject(sLabelCode+sSymbol+"_iSignal"+sTimeFrame[col], iArrow, iHeight, dColor, xSAR, yRow[i]);
            else   
               SetLabelObject(sLabelCode+sSymbol+"_iSignal"+sTimeFrame[col], " ", Black, xSignal, yRow[i]);         
         }
      }
   }
}


//####################################################################
//+------------------------------------------------------------------+
//    function SendAlert
//+------------------------------------------------------------------+
void function_SendAlert(int iOrderType, string symbol, int iPeriod, string sPeriod, string sPrice, int i, int col)
{   
   string st, sTime;
      
   switch (iOrderType)
   {
      case 1:
         if (AlertSignal[i][col] == 1) return;
         sTime  = TimeToStr(TimeCurrent(),TIME_MINUTES);
         st = "Buy "+symbol + "  " + sPrice + "   (" + sPeriod + ")" + "  PipNailer DashBoard  " + sTime;
         break;
      case -1:
         if (AlertSignal[i][col] == -1) return;
         sTime  = TimeToStr(TimeCurrent(),TIME_MINUTES);
         st = "Sell "+symbol + "  " + sPrice + "   (" + sPeriod + ")" + "  PipNailer DashBoard  " + sTime;
         break;   
   }
   Alert(st);
   AlertSignal[i][col] = iOrderType;
}

void function_PrintAlert(int iOrderType, string symbol, int iPeriod, string sPeriod, string sPrice, int i, int col)
{   
   string st, sTime;
      
   switch (iOrderType)
   {
      case 1:
         if (AlertSignal[i][col] == 1) return;
         sTime  = TimeToStr(TimeCurrent(),TIME_MINUTES);
         st = "Alert: Buy "+symbol + "  " + sPrice + "   (" + sPeriod + ")" + "  PipNailer DashBoard  " + sTime;
         break;
      case -1:
         if (AlertSignal[i][col] == -1) return;
         sTime  = TimeToStr(TimeCurrent(),TIME_MINUTES);
         st = "Alert: Sell "+symbol + "  " + sPrice + "   (" + sPeriod + ")" + "  PipNailer DashBoard  " + sTime;
         break;   
   }
   Print(st);
   AlertSignal[i][col] = iOrderType;
}


//+------------------------------------------------------------------+
//    Get Entry Price, Send Alert
//+------------------------------------------------------------------+
string Get_EntryPrice(int iOrderType, string symbol, int iTimeFrame)
{   
   string sPrice;
   int iDigits   = MarketInfo(symbol, MODE_DIGITS);
   double dPoint = MarketInfo(symbol, MODE_POINT);
   
   switch (iOrderType)
   {
      case 1:
         double Spread = MarketInfo(symbol, MODE_SPREAD) * dPoint;
         double dValue = iClose(symbol, iTimeFrame, ShiftSignals) + Spread;
         sPrice = DoubleToStr(dValue, iDigits);
         return(sPrice);
         break;
      case -1:
         dValue = iClose(symbol, iTimeFrame, ShiftSignals);
         sPrice = DoubleToStr(dValue, iDigits);
         return(sPrice);
         break;   
   }
}

string Get_sPeriod(int timeframe)
{
   if (timeframe == PERIOD_M1) return("M1");
   if (timeframe == PERIOD_M5) return("M5");
   if (timeframe == PERIOD_M15) return("M15");
   if (timeframe == PERIOD_M30) return("M30");
   if (timeframe == PERIOD_H1) return("H1");
   if (timeframe == PERIOD_H4) return("H4");
   if (timeframe == PERIOD_D1) return("D1");
   if (timeframe == PERIOD_W1) return("W1");
   if (timeframe == PERIOD_MN1) return("MN1");
}