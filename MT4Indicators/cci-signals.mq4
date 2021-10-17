//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright ""
#property link      ""
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  LimeGreen
#property indicator_color2  Red

//
//
//
//
//

extern int    CCIPeriod       = 50;
extern int    CCIPrice        = PRICE_TYPICAL;
extern double levelOs         = -100;
extern double levelOb         = 100;
extern int    ArrowSize       = 1;

extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;
extern bool   alertsPush      = false;
extern string soundfile       = "alert2.wav";

//
//
//
//
//

double sigUp[];
double sigDn[];
double cci[];
double prices[];
double trend[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
      SetIndexBuffer(0,sigUp); SetIndexStyle(0,DRAW_ARROW,0,ArrowSize); SetIndexArrow(0, 233);
      SetIndexBuffer(1,sigDn); SetIndexStyle(1,DRAW_ARROW,1,ArrowSize); SetIndexArrow(1, 234);
      SetIndexBuffer(2,cci);
      SetIndexBuffer(3,prices);
      SetIndexBuffer(4,trend);

   IndicatorShortName(" CCI ("+CCIPeriod+")");
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   for (i=limit; i>=0; i--)
   {
      prices[i]  = iMA(NULL,0,1,0,MODE_SMA,CCIPrice,i);
      double avg = 0; for(k=0; k<CCIPeriod; k++) avg +=         prices[i+k];      avg /= CCIPeriod;
      double dev = 0; for(k=0; k<CCIPeriod; k++) dev += MathAbs(prices[i+k]-avg); dev /= CCIPeriod;
          if (dev!=0)
                cci[i] = (prices[i]-avg)/(0.015*dev);
          else  cci[i] = 0;
         
          //
          //
          //
          //
          //
         
          trend[i] = 0;
             if (cci[i]>levelOb) trend[i] = 1;
             if (cci[i]<levelOs) trend[i] =-1;
             
             //
             //
             //
             //
             //
             
             sigUp[i] = EMPTY_VALUE;
             sigDn[i] = EMPTY_VALUE;
             if (trend[i]!= trend[i+1])
             {
               if (trend[i+1] ==  1 && trend[i] != 1) sigDn[i] = High[i] + iATR(NULL,0,20,i)/2;
               if (trend[i+1] == -1 && trend[i] !=-1) sigUp[i] = Low[i]  - iATR(NULL,0,20,i)/2;
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
            if (trend[whichBar+1] ==  1 && trend[whichBar] != 1) doAlert(whichBar,"sell");
            if (trend[whichBar+1] == -1 && trend[whichBar] !=-1) doAlert(whichBar,"buy");
         }           
   }
return(0);
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," cci crossing ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," cci crossing "),message);
             if (alertsPush)    SendNotification(StringConcatenate(Symbol(), Period() ," cci crossing " +" "+message));
             if (alertsSound)   PlaySound(soundfile);
   }
}
   
   