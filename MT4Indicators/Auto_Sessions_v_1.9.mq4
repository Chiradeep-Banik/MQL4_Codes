//+------------------------------------------------------------------+
//|                                           Auto_Sessions_v1.9.mq4 |
//|                                                                  |
//|                                                                  |
//| README
//|  1. MAKE SURE your local PC time syncronized well
//|  2. you MUST input SessionBegins/SessionEnds based on GMT timezone
//|     reference http://forex.timezoneconverter.com/
//|  3. you MUST input LocalTimezone correctly
//| CHANGELOG                                                        |
//| 09-03-2011, Mark Pickersgill
//|   - Fixed issue with time frames crossing over midnight
//|   - Tidied up and documented some of the code
//| ver 1.8, 2011/7/24  Jani Verho
//|   - Added GMT shift
//| ver 1.81, 2011/9/10 azFin@forexfactory
//|   - shows up on charts with timeframe 1hr or less. That way the chart doesnt looks so so cluttered on 4hr and above if you change timeframes.
//| ver 1.9, 2013/3/27  Rocky Lin  linlei@gmail.com 
//|   - determining server timezone and shift time frame automatically, reboot is needed after switching server in different timezone
//|   - Simplified some codes on timezone shifting.
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, cameofx"
#property link      "cameofx@gmail.com"

#property indicator_chart_window
extern string SessionNames  = "Tokyo/Frankfurt/NY";
extern string SessionGMTInfo= "GMT=0 assumes times below";
extern string SessionBegins= "23:00/07:00/12:00";
extern string SessionEnds= "07:00/12:00/20:00";
extern int LocalTimezone        =8;

extern color  color1        = C'199,237,204'; //C'5,55,6'; 
extern color  color2        = LightBlue; //C'5,35,56'; 
extern color  color3        = MistyRose; //C'65,5,46'; 
extern color  color4        = C'5,25,34'; 
extern color  color5        = C'25,65,5'; 
extern bool   FillColor     = true;
extern int    FrameWidth    = 1; 
extern int    FrameStyle    = 1; 
//extern bool   ShowPips      = true; 
//extern bool   AppendPips    = true;
extern int    LabelSize     = 8;
extern string LabelFont     = "Arial Bold";
extern color  LabelColor    = DarkKhaki;

string sTIME_BEGIN = "1970.01.01", saName[], saBeg[], saEnd[];
datetime t0, curDate, lastDate[], t1[], t2[];
bool MidnightCross[];  // Do any of the start to end times cross midnight
double lo[], hi[], vPoint; 
color col[]; 
int pip[], pipRange, Qty;

//+------------------------------------------------------------------+
int init()
{  
int ServerTimezone=LocalTimezone - (TimeLocal() - TimeCurrent())/3600;   //Alphri UK server timezone is GMT+2, Forex LTD GMT


   // Deal with micro-pips
   if(Digits==3 || Digits==5)
      vPoint = Point*10; 
   else 
      vPoint = Point;
   
   Qty = stringExtract_(SessionNames,"/",saName);  
   stringExtract_(SessionBegins,"/",saBeg);  
   stringExtract_(SessionEnds,"/",saEnd);  
   
   if (Qty>5)
      Qty = 5; 
         
   ArrayResize(lo,Qty); 
   ArrayInitialize(lo,99999999.0);
   ArrayResize(hi,Qty); 
   ArrayInitialize(hi,0.0);
   ArrayResize(t1,Qty);
   ArrayResize(t2,Qty);
   ArrayResize(pip,Qty);
   ArrayResize(col,Qty);
   ArrayResize(lastDate,Qty);
   ArrayResize(MidnightCross, Qty);

   col[0] = color1; 
   col[1] = color2; 
   col[2] = color3; 
   col[3] = color4; 
   col[4] = color5;
   t0 = StrToTime(sTIME_BEGIN); 
   curDate  = t0; 
   
   int g = 0;
   while(g<Qty){
//      t1[g] = StrToTime(StringConcatenate(sTIME_BEGIN," ",saBeg[g]));  
//      t2[g] = StrToTime(StringConcatenate(sTIME_BEGIN," ",saEnd[g])); 
//    modifed by Rocky Lin for time shift automatically based on server time zone
      t1[g] = StrToTime(StringConcatenate(sTIME_BEGIN," ",saBeg[g])) + ServerTimezone*3600;  
      t2[g] = StrToTime(StringConcatenate(sTIME_BEGIN," ",saEnd[g])) + ServerTimezone*3600; 
      if (t1[g] > t2[g]) 
      {
         t2[g]+=86400;  //24*3600
         MidnightCross[g] = true;
      }
      else
      {
         MidnightCross[g] = false;
      }
      pip[g] = 0;
      lastDate[g] = t0; 
      g++;
   }

   return(0);
  }
//+------------------------------------------------------------------+ 
int deinit()
  {
   int g; 
   while(g<Qty)
   {
      clear_(saName[g]); 
      clear_(StringConcatenate("Pip",saName[g]));
      g++;
   } 
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iterations                                      |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars = IndicatorCounted();
   if(counted_bars< 0) 
      return(-1);
   if(counted_bars> 0) 
      counted_bars--;
   int limit = Bars-1-counted_bars; 
   

   if(Period()<=PERIOD_H1)
      {
   for(i=limit; i>=0; i--)
   {
      curDate = stripToDate_(Time[i]); 
      int g = 0;
      while(g<Qty){
         Session_(saName, curDate, lastDate, t1, t2, lo, hi, pip, col[g], g, i); 
         g++;
      }     
      }

   }  
   return(0);
  }
//+------------------------------------------------------------------+
void Session_(string& ses[], datetime cu_Date, datetime& las[], datetime& at1[], datetime& bt2[], 
              double& l1[], double& h1[], int& xpip[], color col1, int g, int i)
{
   bool TimeOk;
   
   // Check to see if the Bar time is in the given range and taking into consideration time ranges crossing midnight
   if (Time[i] >= (cu_Date+at1[g]) && Time[i] <= (cu_Date+bt2[g]))
   {
      // Time is within the current day's time range
      TimeOk = true;
   }
   else if (MidnightCross[g] && (Time[i] < (cu_Date+at1[g])) && (Time[i] < (cu_Date-86400+bt2[g])))
   {
      // Time is within the current day's time range, but is within a range that stretches back to the previous day.
      TimeOk = true;
      cu_Date = cu_Date-86400;
   }
   else
      TimeOk = false;
   
   // If we are in the given time bracket, draw or update the session rectangles and pip count
   if (TimeOk)
   {
      //if (Time[i] == StartTime)
      if (cu_Date > las[g])
      {
         // Create a new session and associated objects as the session has started
         las[g] = cu_Date; 
         l1[g] = Low[i]; 
         h1[g] = High[i]; 
         pip[g] = (h1[g]-l1[g])/vPoint;
         createSes_(ses[g], cu_Date, t1[g], l1[g], t2[g], h1[g], col1);
         createPip_(ses[g], cu_Date, t1[g], h1[g]);
         reDrawPip_(ses[g], cu_Date, hi[g], xpip[g]);
      }
      if (Low[i] < l1[g]){
         // A new low has been reached, so updated the visual objects
         l1[g] = Low[i]; 
         pip[g] = (h1[g]-l1[g])/vPoint;
         reDrawSes_(ses[g], cu_Date, l1[g], h1[g]);
         reDrawPip_(ses[g], cu_Date, hi[g], xpip[g]);
      }
      if (High[i] > h1[g]){

         // A new high has been reached, so updated the visual objects
         h1[g] = High[i]; 
         pip[g] = (h1[g]-l1[g])/vPoint;
         reDrawSes_(ses[g], cu_Date, l1[g], h1[g]);
         reDrawPip_(ses[g], cu_Date, hi[g], xpip[g]);
      }
   }
}
//+------------------------------------------------------------------+
void createSes_(string name, datetime cu_Date, datetime at1, double p1, datetime bt2, double p2, color scol)
{
   name = StringConcatenate(name, cu_Date);
   //Print("Creating object ",name);
   ObjectCreate(name, OBJ_RECTANGLE, 0, cu_Date + at1, p1, cu_Date + bt2 , p2);
   ObjectSet(name, OBJPROP_COLOR, scol);
   ObjectSet(name, OBJPROP_BACK, FillColor); 
   ObjectSet(name, OBJPROP_STYLE, FrameStyle);
   ObjectSet(name, OBJPROP_WIDTH, FrameWidth);
}
//+------------------------------------------------------------------+
void reDrawSes_(string name, datetime cu_Date, double price1, double price2)
{
   name = StringConcatenate(name, cu_Date);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_PRICE2, price2);
}
//+------------------------------------------------------------------+ 
void createPip_(string name, datetime cu_Date, datetime at1, double p1)
{
   name = StringConcatenate("Pip", name, cu_Date);
   ObjectCreate(name, OBJ_TEXT, 0, cu_Date + at1, p1);
}
//+------------------------------------------------------------------+
void reDrawPip_(string name, datetime cu_Date, double p1, int xpip)
{
   name = StringConcatenate("Pip", name, cu_Date);
   ObjectSetText(name, StringConcatenate("                ", xpip, " pips"), 
   LabelSize, LabelFont, LabelColor);
   ObjectSet(name, OBJPROP_PRICE1, p1);
}
//+------------------------------------------------------------------+
int stringExtract_(string toRead, string delimChar, string& ReadValue[]) 
{
   int delimPos[]; 
   int len=StringLen(toRead); 
   int curpos; 
   int sQty=0;
   ArrayResize(delimPos,len); 
   ArrayInitialize(delimPos,  0);
   ArrayResize(ReadValue,len); 
   
   for(curpos=0; curpos<=len;)
   { 
      delimPos[sQty]=curpos-1;
      curpos = StringFind(toRead,delimChar,curpos)+1;
      if(curpos<=0) 
         break; 
      sQty++; 
   }
   if (sQty==0)
      ReadValue[0]=toRead; 
   else
   {
      for (int j=0; j<=sQty; j++)
         ReadValue[j] = StringSubstr(toRead,delimPos[j]+1,(delimPos[j+1]-delimPos[j])-1); 
   }
   return(sQty+1);
}
//+------------------------------------------------------------------+
datetime stripToDate_( datetime aTime )  
{                                           
   double ModVal = MathMod(aTime,86400);
   
   aTime -= ModVal;
           
   return(aTime);                        
}
//+------------------------------------------------------------------+
void clear_(string prefix) {
int prefix_len = StringLen(prefix);
   for(int i=ObjectsTotal(); i>=0; i--)
   {      
     string name = ObjectName(i);
        if (StringSubstr(name,0,prefix_len) == prefix) ObjectDelete(name);
   }    
}
//+------------------------------------------------------------------+

