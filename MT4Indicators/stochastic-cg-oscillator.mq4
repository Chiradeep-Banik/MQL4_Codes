//------------------------------------------------------------------
#property copyright ""
#property link      ""
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  PaleVioletRed
#property indicator_color4  Silver
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    Length          = 25;
extern int    Price           = PRICE_TYPICAL;
extern bool   AlertsOn        = false;
extern bool   AlertsOnCurrent = true;
extern bool   AlertsMessage   = true;
extern bool   AlertsSound     = false;
extern bool   AlertsEmail     = false;
extern bool   Interpolate     = true;

double cg[];
double storaw[];
double stocg[];
double stocgda[];
double stocgdb[];
double stosig[];
double trend[];

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
//

int init()
{
   IndicatorBuffers(7);
      SetIndexBuffer(0,stocg);
      SetIndexBuffer(1,stocgda);
      SetIndexBuffer(2,stocgdb);
      SetIndexBuffer(3,stosig);
      SetIndexBuffer(4,cg);
      SetIndexBuffer(5,storaw);
      SetIndexBuffer(6,trend);

      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
               
   IndicatorShortName(timeFrameToString(timeFrame)+" Stochastic CG ("+Length+")");
   return(0); 
}
int deinit() { return(0); }

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
   int n,k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { stocg[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (trend[limit]==-1) CleanPoint(limit,stocgda,stocgdb);
      for(int i=limit; i>=0; i--)
      {
         double num = 0;
         double den = 0;
            for (k=0; k<Length; k++)
            {
               double price = iMA(NULL,0,1,0,MODE_SMA,Price,i+k);
                      num += price*(k+1);
                      den += price;
            }
            if (den!=0)
                  cg[i] = -num/den+(Length+1)/2.0;
            else  cg[i] = 0;
         
            //
            //
            //
            //
            //
         
            double hh = cg[ArrayMaximum(cg,Length,i)];          
            double ll = cg[ArrayMinimum(cg,Length,i)];
            if (hh!=ll)
                  storaw[i] = (cg[i]-ll)/(hh-ll);
            else  storaw[i] = 0;
            double smtcg = (4.0*storaw[i]+3.0*storaw[i+1]+2.0*storaw[i+2]+storaw[i+3])/10.0;
         
            //
            //
            //
            //
            //
            
            stocg[i]   = 0.5*MathLog((1+1.98*(smtcg-0.5))/(1-1.98*(smtcg-0.5)));
            stosig[i]  = stocg[i+1];
            stocgda[i] = EMPTY_VALUE;
            stocgdb[i] = EMPTY_VALUE;
            trend[i]   = trend[i+1];
               if (stocg[i]>stosig[i]) trend[i] =  1;
               if (stocg[i]<stosig[i]) trend[i] = -1;
               if (trend[i]==-1) PlotPoint(i,stocgda,stocgdb,stocg);
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,stocgda,stocgdb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         stocg[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,0,y);
         stosig[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,3,y);
         trend[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,6,y);
         stocgda[i] = EMPTY_VALUE;
         stocgdb[i] = EMPTY_VALUE;

         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

            datetime time = iTime(NULL,timeFrame,y);
               for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               for(k = 1; k < n; k++)
               {
                  stocg[i+k]  = stocg[i]  + (stocg[i+n]  - stocg[i] )*k/n;
                  stosig[i+k] = stosig[i] + (stosig[i+n] - stosig[i])*k/n;
               }                  
   }
   for (i=limit;i>=0;i--) if (trend[i]==-1) PlotPoint(i,stocgda,stocgdb,stocg);
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

void manageAlerts()
{
   if (AlertsOn)
   {
      if (AlertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;

      if (trend[whichBar]!= trend[whichBar+1])
      {
         static datetime time1 = 0;
         static string   mess1 = "";
            if (trend[whichBar] ==  1) doAlert(time1,mess1," stochastic CG trend changed to up");
            if (trend[whichBar] == -1) doAlert(time1,mess1," stochastic CG trend changed to down");
      }
   }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message = timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+doWhat;
          if (AlertsMessage) Alert(message);
          if (AlertsEmail)   SendMail(Symbol()+" stochastic CG",message);
          if (AlertsSound)   PlaySound("alert2.wav");
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
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}