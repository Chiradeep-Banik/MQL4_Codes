//+------------------------------------------------------------------+
//|                                            Heiken Ashi Ma T3.mq4 |
//+------------------------------------------------------------------+
//|                                                      mod by Raff |
//|                                               2009 mod by mladen |
//|  tools copied and pasted alerts from another HA indy so blame me |
//+------------------------------------------------------------------+
//------------------------------------------------------------------
#property copyright ""
#property link      ""
//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  clrCoral  //SandyBrown
#property indicator_color2  clrDodgerBlue
#property indicator_color3  clrCoral  //SandyBrown
#property indicator_color4  clrDodgerBlue
#property indicator_color5  clrMagenta  //SandyBrown
#property indicator_color6  clrLime  //DodgerBlue
#property indicator_width1  0
#property indicator_width2  0
#property indicator_width3  3
#property indicator_width4  3

//
//
//
//
//

enum maType   
{
   ma_sma,  // Simple moving average
   ma_ema,  // Exponential moving average
   ma_smma, // Smoothed moving average
   ma_lwma, // Linear Weighted moving average
   ma_t3    // T3 by T.Tillson
};
extern int    MaPeriod        = 12;
extern int    Step            = 0;
extern maType MaMetod         = ma_t3;
extern double T3Hot           = 1.272;   //0.786;  //0.382;   //0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.414, 1.618, 2.058, 2.618, 3.32, 4.236, 5.35, 6.853....
extern bool   BetterFormula   = false;
extern bool   T3Original      = false;
extern bool   SortedValues    = true;
extern bool   ShowHeikenAshi  = true;
extern bool   ShowDots        = true;
extern double DotsGap         = 0.99;   //Дистанция от High/Low свечи  
extern int    DotUP           = 108;
extern int    DotDN           = 108;
extern int    DotsSize        = 0;
extern string SoundFile       = "alert2.wav";   //"news.wav";  //"expert.wav";  //   //"stops.wav"   //
extern int    SIGNALBAR       = 1;   //На каком баре сигналить....
extern bool   AlertsMessage   = true;   //false,    
extern bool   AlertsSound     = true;   //false,
extern bool   AlertsEmail     = false;
extern bool   AlertsMobile    = false;  

//
//
//
//
//

double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double DnArrow[];
double UpArrow[];
double trend[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
      MaPeriod = MathMax(1,MaPeriod);
      DotsGap = MathMax(DotsGap,0.0001);
   IndicatorBuffers(7);   IndicatorDigits(Digits);   if (Digits==3 || Digits==5) IndicatorDigits(Digits-1);  
   int HAT = DRAW_NONE; if (ShowHeikenAshi) HAT = DRAW_HISTOGRAM;
   SetIndexBuffer(0, Buffer1); SetIndexStyle(0,HAT);  SetIndexLabel(0,NULL);
   SetIndexBuffer(1, Buffer2); SetIndexStyle(1,HAT);  SetIndexLabel(1,NULL);
   SetIndexBuffer(2, Buffer3); SetIndexStyle(2,HAT);  SetIndexLabel(2,"SELL ["+(string)MaPeriod+"+"+(string)Step+"*"+DoubleToStr(T3Hot,2)+"]");
   SetIndexBuffer(3, Buffer4); SetIndexStyle(3,HAT);  SetIndexLabel(3,"BUY ["+(string)MaPeriod+"+"+(string)Step+"*"+DoubleToStr(T3Hot,2)+"]");
   int ART = DRAW_NONE; if (ShowDots) ART = DRAW_ARROW;
   SetIndexBuffer(4, DnArrow); SetIndexStyle(4,ART,EMPTY,DotsSize); SetIndexArrow(4,DotDN);  SetIndexLabel(4,"Dot SELL");
   SetIndexBuffer(5, UpArrow); SetIndexStyle(5,ART,EMPTY,DotsSize); SetIndexArrow(5,DotUP);  SetIndexLabel(5,"Dot BUY");
   SetIndexBuffer(6, trend);
   IndicatorShortName("Heiken Ashi T3 ["+(string)MaPeriod+"+"+(string)Step+"*"+DoubleToStr(T3Hot,2)+"]");
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           int pointModifier = 1;if (Digits==3 || Digits==5) pointModifier = 10;

   //
   //
   //
   //
   //
   
   for(int pos=limit; pos >= 0; pos--)
   {
      if (MaMetod==ma_t3)
         {
            double maOpen  = iT3(Open[pos] ,MaPeriod,T3Hot,T3Original,pos,0);
            double maClose = iT3(Close[pos],MaPeriod,T3Hot,T3Original,pos,1);
            double maLow   = iT3(Low[pos]  ,MaPeriod,T3Hot,T3Original,pos,2);
            double maHigh  = iT3(High[pos] ,MaPeriod,T3Hot,T3Original,pos,3);
         }
      else
         {
            maOpen  = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_OPEN ,pos);
            maClose = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_CLOSE,pos);
            maLow   = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_LOW  ,pos);
            maHigh  = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_HIGH ,pos);
         }
     
      if (SortedValues)
         {
            double sort[4];
                   sort[0] = maOpen;
                   sort[1] = maClose;
                   sort[2] = maLow;
                   sort[3] = maHigh;
                     ArraySort(sort);
                        maLow  = sort[0];
                        maHigh = sort[3];
                        if (Open[pos]>Close[pos])
                              { maOpen = sort[2]; maClose = sort[1]; }
                        else  { maOpen = sort[1]; maClose = sort[2]; }
         }                        
   
      //
      //
      //
      //
      //
        
         if (BetterFormula) {
               if (maHigh!=maLow)
                     double haClose  = (maOpen+maClose)/2+(((maClose-maOpen)/(maHigh-maLow))*MathAbs((maClose-maOpen)/2));
                     else  haClose   = (maOpen+maClose)/2; }
               else        haClose   = (maOpen+maHigh+maLow+maClose)/4;
                     double haOpen   = (Buffer3[pos+1]+Buffer4[pos+1])/2;
                     double haHigh   = MathMax(maHigh, MathMax(haOpen,haClose));
                     double haLow    = MathMin(maLow,  MathMin(haOpen,haClose));

         if (haOpen<haClose) { Buffer1[pos]=haLow;  Buffer2[pos]=haHigh; } 
         else                { Buffer1[pos]=haHigh; Buffer2[pos]=haLow;  } 
                               Buffer3[pos]=haOpen;
                               Buffer4[pos]=haClose;
         
         //
         //
         //
         //
         //
            
         if (Step>0)
         {
            if( MathAbs(Buffer1[pos]-Buffer1[pos+1]) < Step*pointModifier*Point ) Buffer1[pos]=Buffer1[pos+1];
            if( MathAbs(Buffer2[pos]-Buffer2[pos+1]) < Step*pointModifier*Point ) Buffer2[pos]=Buffer2[pos+1];
            if( MathAbs(Buffer3[pos]-Buffer3[pos+1]) < Step*pointModifier*Point ) Buffer3[pos]=Buffer3[pos+1];
            if( MathAbs(Buffer4[pos]-Buffer4[pos+1]) < Step*pointModifier*Point ) Buffer4[pos]=Buffer4[pos+1];
         }         
        
         trend[pos] = trend[pos+1];
         if (Buffer3[pos] < Buffer4[pos]) trend[pos] =  1;
         if (Buffer3[pos] > Buffer4[pos]) trend[pos] = -1;
         
         if (ShowDots)
         {
               UpArrow[pos] = EMPTY_VALUE; 
               DnArrow[pos] = EMPTY_VALUE;
               if (trend[pos]!=trend[pos+1])
               {
                  if (trend[pos]== 1) UpArrow[pos] = Buffer1[pos] - iATR(NULL,0,20,pos)/DotsGap;
                  if (trend[pos]==-1) DnArrow[pos] = Buffer1[pos] + iATR(NULL,0,20,pos)/DotsGap;
               }                  
         }
      }
      manageAlerts();
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

void manageAlerts()
{
   if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
   {
      //if (alertsOnCurrent)
           int whichBar = SIGNALBAR;
      /*else     whichBar = 1;*/ whichBar = iBarShift(NULL,0,iTime(NULL,0,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"UP >> BUY");
         if (trend[whichBar] ==-1) doAlert(whichBar,"DN << SELL");
      }         
   }
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

          message =  StringConcatenate( "Heiken Ashi T3: ",_Symbol+", "+stringMTF(_Period),": trend changed to ",doWhat);   ///Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS),"HAMA
             if (AlertsMessage) Alert(message);
             if (AlertsEmail)   SendMail(_Symbol,message);
             if (AlertsMessage) SendNotification(message);
             if (AlertsSound)   PlaySound(SoundFile);  //"alert2.wav");
      }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workT3[][24];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int instanceNo=0)
{
   if (ArrayRange(workT3,0) !=Bars)                 ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);

   if (workT3Coeffs[instanceNo][_period] != period)
   {
     workT3Coeffs[instanceNo][_period] = period;
        double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = instanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
      }
   else
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
}

   //
   //
   //
   //
   //
   
string stringMTF(int perMTF)
{  
   if (perMTF==0)      perMTF=_Period;
   if (perMTF==1)      return("M1");
   if (perMTF==5)      return("M5");
   if (perMTF==15)     return("M15");
   if (perMTF==30)     return("M30");
   if (perMTF==60)     return("H1");
   if (perMTF==240)    return("H4");
   if (perMTF==1440)   return("D1");
   if (perMTF==10080)  return("W1");
   if (perMTF==43200)  return("MN1");
   if (perMTF== 2 || 3  || 4  || 6  || 7  || 8  || 9 ||       /// нестандартные периоды для грфиков Renko
               10 || 11 || 12 || 13 || 14 || 16 || 17 || 18)  return("M"+(string)_Period);
//------
   return("Ошибка периода");
}