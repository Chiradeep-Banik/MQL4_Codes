//+------------------------------------------------------------------+
//|                                         Directional_Breakout.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2

extern string     TimeFrame = "Current time frame";  // Time frame to use
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Length=20;
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsNotify     = false;
extern bool   alertsEmail      = false;
extern string soundFile        = "alert2.wav";
extern bool   ShowArrows       = false;
extern string arrowsIdentifier = "Db Arrows";
extern double arrowsUpperGap   = 1.0;
extern double arrowsLowerGap   = 1.0;
extern color  arrowsUpColor    = LimeGreen;
extern color  arrowsDnColor    = Red;
extern color  arrowsUpCode     = 241;
extern color  arrowsDnCode     = 242;

double UP[], N1[], N2[], DN[], trend[];
string indicatorFileName;
bool   returnBars;
int    timeFrame;

int init()
{
 IndicatorBuffers(5);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,N1);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,N2);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,DN);
 SetIndexBuffer(4,trend);
            timeFrame         = stringToTimeFrame(TimeFrame);
            indicatorFileName = WindowExpertName();
            returnBars        = TimeFrame=="returnBars";  if (returnBars) return(0);
 IndicatorShortName("Directional Breakout");
 return(0);
}

int deinit()
{
  deleteArrows(); 
 return(0);
}

int start()
{
    int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
            int limit = MathMin(Bars-counted_bars,Bars-1);
            if (returnBars) { UP[0] = MathMin(limit+1,Bars-1); return(0); }
            if (timeFrame!=Period())
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,timeFrame,Time[i]);
                     UP[i]   = iCustom(NULL,timeFrame,indicatorFileName,"",Price,Method,Length,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,0,y);
                     N1[i]   = iCustom(NULL,timeFrame,indicatorFileName,"",Price,Method,Length,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,1,y);
                     N2[i]   = iCustom(NULL,timeFrame,indicatorFileName,"",Price,Method,Length,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,2,y);
                     DN[i]   = iCustom(NULL,timeFrame,indicatorFileName,"",Price,Method,Length,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,3,y);
               }
               return(0);
            }                                 

  for(int pos=limit; pos>=0; pos--)
  {
     double MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
     UP[pos]=EMPTY_VALUE;
     N1[pos]=EMPTY_VALUE;
     N2[pos]=EMPTY_VALUE;
     DN[pos]=EMPTY_VALUE;
     trend[pos] = 0;
  
     if ( Low[pos]>MA)                trend[pos] = 1;
     if (High[pos]<MA)                trend[pos] =-1;
     if (Low[pos]<MA && High[pos]>MA) trend[pos] = 0;
     if (trend[pos] == 1) UP[pos] = 2;
     if (trend[pos] ==-1) DN[pos] =-2;
     if (trend[pos] == 0) { N1[pos] = 1; N2[pos]=-1; }
     
     //
     //
     //
     //
     //
     
     if (ShowArrows)
     {
       deleteArrow(Time[pos]);
       if (trend[pos]!=trend[pos+1])
       {
         if (trend[pos] == 1)  drawArrow(pos,arrowsUpColor,arrowsUpCode,false);
         if (trend[pos] ==-1)  drawArrow(pos,arrowsDnColor,arrowsDnCode, true);
       }
     }
   
 } 
 
 //
 //
 //
 //
 //
 
 if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1)   doAlert(whichBar,"up");
         if (trend[whichBar] ==-1)   doAlert(whichBar,"down");
      }         
   }
 return(0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   StringToUpper(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+(string)iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

           message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Directional Breakout ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), " Directional Breakout "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

