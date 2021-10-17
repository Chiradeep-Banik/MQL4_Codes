//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  PaleVioletRed
#property indicator_color4  Red
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_style4  STYLE_DOT
#property indicator_level1  0

//
//
//
//
//

extern string TimeFrame = "Current time frame";
extern int    FastEMA   = 12;
extern int    SlowEMA   = 26;
extern int    SignalEMA =  9;
extern int    Price     = PRICE_CLOSE;

//
//
//
//
//

double macd[];
double macdDa[];
double macdDb[];
double signal[];
double colors[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int init()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,macd);
   SetIndexBuffer(1,macdDa);
   SetIndexBuffer(2,macdDb);
   SetIndexBuffer(3,signal);
   SetIndexBuffer(4,colors);
   
      indicatorFileName = WindowExpertName();
      calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
      returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
      timeFrame         = stringToTimeFrame(TimeFrame);
   
      IndicatorShortName(timeFrameToString(timeFrame)+" MACD ("+FastEMA+","+SlowEMA+","+SignalEMA+")");
   return(0);
}
int deinit()
{
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double emas[][2];
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { macd[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      double alphaSign = 2.0/(1.0+SignalEMA);
      double alphaFast = 2.0/(1.0+FastEMA);
      double alphaSlow = 2.0/(1.0+SlowEMA);
      
      if (ArrayRange(emas,0) != Bars) ArrayResize(emas,Bars);
      if (colors[limit]==-1) CleanPoint(limit,macdDa,macdDb);
      for(i = limit, r=Bars-i-1; i >= 0 ; i--,r++)
      {
         double price = iMA(NULL,0,1,0,MODE_SMA,Price,i);
         if (i>Bars-2)
         {
            emas[r][0] = price;
            emas[r][1] = price;
            macd[i]    = 0;
            signal[i]  = 0;
            continue;
         }

         emas[r][0] = emas[r-1][0]+alphaFast*(price-emas[r-1][0]);
         emas[r][1] = emas[r-1][1]+alphaSlow*(price-emas[r-1][1]);
         macd[i]    = emas[r][0]-emas[r][1];
         macdDa[i]  = EMPTY_VALUE;
         macdDb[i]  = EMPTY_VALUE;
         signal[i]  = signal[i+1]+alphaSign*(macd[i]-signal[i+1]);
         colors[i]  = colors[i+1];
            if (macd[i]>macd[i+1]) colors[i] =  1;
            if (macd[i]<macd[i+1]) colors[i] = -1;
            if (colors[i]==-1) PlotPoint(i,macdDa,macdDb,macd);
      }         
      return(0);
   }
   
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (colors[limit]==-1) CleanPoint(limit,macdDa,macdDb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         macd[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastEMA,SlowEMA,SignalEMA,Price,0,y);
         signal[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastEMA,SlowEMA,SignalEMA,Price,3,y);
         colors[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastEMA,SlowEMA,SignalEMA,Price,4,y);
         macdDa[i]  = EMPTY_VALUE;
         macdDb[i]  = EMPTY_VALUE;
            if (colors[i]==-1) PlotPoint(i,macdDa,macdDb,macd);
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

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
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
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
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

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int char = StringGetChar(s, length);
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                     s = StringSetChar(s, length, char - 32);
         else if(char > -33 && char < 0)
                     s = StringSetChar(s, length, char + 224);
   }
   return(s);
}