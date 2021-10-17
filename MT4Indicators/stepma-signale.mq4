//------------------------------------------------------------------
#property copyright ""
#property link      ""
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_color4  DodgerBlue
#property indicator_color5  Magenta
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3

//
//
//
//
//

extern string TimeFrame           = "Current time frame";
extern int    PdfMaLength         = 10;      // Pdfma Length
extern double Sensitivity         = 5;       // Sensivity Factor
extern double StepSize            = 2;       // Constant Step Size
extern double Variance            = 1;       // Pdfma variance
extern double Mean                = 0.0;     // Pdfma mean
extern int    Shift               = 0;       // OShify
extern bool   HighLow             = false;   // High/Low Mode Switch (more sensitive)
extern bool   Interpolate         = true; 
extern bool   alertsOn            = false;
extern bool   alertsOnCurrent     = true;
extern bool   alertsMessage       = true;
extern bool   alertsNotification  = false;
extern bool   alertsSound         = false;
extern bool   alertsEmail         = false;

extern bool   ShowArrows          = true;
extern int    arrowSize           = 2;
extern int    uparrowCode         = 233;
extern int    dnarrowCode         = 234;
extern bool   ArrowsOnFirstBar    = true;

//
//
//
//
//

double LineBuffer[];
double DnBuffera[];
double DnBufferb[];
double arrowUp[];
double arrowDn[];
double smin[];
double smax[];
double trend[];
double _coeffs[];

string indicatorFileName;
bool   returnBars;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define maxx 3.5
int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,LineBuffer); SetIndexShift(0,Shift); SetIndexLabel(0,"StepMA("+PdfMaLength+","+Sensitivity+","+StepSize+")");
   SetIndexBuffer(1,DnBuffera);  SetIndexShift(1,Shift);
   SetIndexBuffer(2,DnBufferb);  SetIndexShift(2,Shift);
   SetIndexBuffer(3,arrowUp);   
   SetIndexBuffer(4,arrowDn);  
   SetIndexBuffer(5,smin);
   SetIndexBuffer(6,smax);
   SetIndexBuffer(7,trend);
   if (ShowArrows)
   {
     SetIndexStyle(3,DRAW_ARROW,0,arrowSize); SetIndexArrow(3,uparrowCode);
     SetIndexStyle(4,DRAW_ARROW,0,arrowSize); SetIndexArrow(4,dnarrowCode);   
   }
   else
   {
     SetIndexStyle(3,DRAW_NONE);
     SetIndexStyle(4,DRAW_NONE);
   }       
   IndicatorShortName("StepMA("+PdfMaLength+","+Sensitivity+","+StepSize+")");
      PdfMaLength = MathMax(PdfMaLength,2);
      ArrayResize(_coeffs,PdfMaLength);   
         double step = maxx/(PdfMaLength-1); for(int i=0; i<PdfMaLength; i++) _coeffs[i] = pdf(i*step,Variance,Mean*maxx);

         timeFrame         = stringToTimeFrame(TimeFrame);
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame == "returnBars"; if (returnBars) return(0);

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
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { LineBuffer[0] = limit+1; return(0); }
         if (timeFrame!=Period())
         {
            int shift = -1; if (ArrowsOnFirstBar) shift=1;
            limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
            if (trend[limit]==-1) CleanPoint(limit,DnBuffera,DnBufferb);
            for (int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,timeFrame,Time[i]);
               int x = iBarShift(NULL,timeFrame,Time[i+shift]);               
                  LineBuffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"",PdfMaLength,Sensitivity,StepSize,Variance,Mean,0,HighLow,false,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,0,y);
                  trend[i]      = iCustom(NULL,timeFrame,indicatorFileName,"",PdfMaLength,Sensitivity,StepSize,Variance,Mean,0,HighLow,false,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,7,y);
                  DnBuffera[i]  = EMPTY_VALUE;
   	            DnBufferb[i]  = EMPTY_VALUE;
               if(x!=y)
               {
                  arrowUp[i]    = iCustom(NULL,timeFrame,indicatorFileName,"",PdfMaLength,Sensitivity,StepSize,Variance,Mean,0,HighLow,false,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,3,y);
                  arrowDn[i]    = iCustom(NULL,timeFrame,indicatorFileName,"",PdfMaLength,Sensitivity,StepSize,Variance,Mean,0,HighLow,false,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,4,y);
               }
               else
               {
                  arrowUp[i]    = EMPTY_VALUE;
                  arrowDn[i]    = EMPTY_VALUE;
               }
            
               //
               //
               //
               //
               //
       
               if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

               //
               //
               //
               //
               //

               int n,w;
               datetime time = iTime(NULL,timeFrame,y);
               for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               for(w = 1; w < n; w++)
                  LineBuffer[i+w] = LineBuffer[i] + (LineBuffer[i+n] - LineBuffer[i]) * w/n;
            }               
            for (i=limit; i>=0; i--) if (trend[i]==-1) PlotPoint(i,DnBuffera,DnBufferb,LineBuffer);
            return(0);
         }

   //
   //
   //
   //
   //
        
      double useSize = Point*MathPow(10,MathMod(Digits,2));
      if (trend[limit]==-1) CleanPoint(limit,DnBuffera,DnBufferb);
      for(i=limit; i>=0; i--)
      {
         double thigh;
         double tlow;
            if (HighLow)
	               { thigh=iPdfma(Low[i ] ,PdfMaLength,_coeffs,i,0); tlow =iPdfma(High[i] ,PdfMaLength,_coeffs,i,1); } 	
	         else  { thigh=iPdfma(Close[i],PdfMaLength,_coeffs,i,0); tlow =iPdfma(Close[i],PdfMaLength,_coeffs,i,1); }
   	   LineBuffer[i] = iStepMa(Sensitivity,StepSize,useSize,thigh,tlow,Close[i],i);
   	   DnBuffera[i]  = EMPTY_VALUE;
   	   DnBufferb[i]  = EMPTY_VALUE;
   	   if (trend[i]==-1) PlotPoint(i,DnBuffera,DnBufferb,LineBuffer);
   	   
   	   //
         //
         //
         //
         //
      
         arrowUp[i] = EMPTY_VALUE;
         arrowDn[i] = EMPTY_VALUE;
         if (trend[i]!= trend[i+1])
         if (trend[i] == 1)
               arrowUp[i] = LineBuffer[i] - iATR(NULL,0,20,i)/2.0;
         else  arrowDn[i] = LineBuffer[i] + iATR(NULL,0,20,i)/2.0;
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
      else      whichBar = 1;
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("up");
      else  doAlert("down");       
   }   
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

double workStep[][3];
#define _smin   0
#define _smax   1
#define _trend  2

double iStepMa(double sensitivity, double stepSize, double stepMulti, double phigh, double plow, double pprice, int r)
{
   if (ArrayRange(workStep,0)!=Bars) ArrayResize(workStep,Bars);
   if (sensitivity == 0) sensitivity = 0.0001; r = Bars-r-1;
   if (stepSize    == 0) stepSize    = 0.0001;
      double result; 
	   double size = sensitivity*stepSize;

      //
      //
      //
      //
      //
      
      if (r==0)
      {
         workStep[r][_smax]  = phigh+2.0*size*stepMulti;
         workStep[r][_smin]  = plow -2.0*size*stepMulti;
         workStep[r][_trend] = 1;
         return(pprice);
      }

      //
      //
      //
      //
      //
      
      workStep[r][_smax]  = phigh+2.0*size*stepMulti;
      workStep[r][_smin]  = plow -2.0*size*stepMulti;
      workStep[r][_trend] = workStep[r-1][_trend];
            if (pprice>workStep[r-1][_smax]) workStep[r][_trend] =  1;
            if (pprice<workStep[r-1][_smin]) workStep[r][_trend] = -1;
            if (workStep[r][_trend] ==  1) { if (workStep[r][_smin] < workStep[r-1][_smin]) workStep[r][_smin]=workStep[r-1][_smin]; result = workStep[r][_smin]+size*stepMulti; }
            if (workStep[r][_trend] == -1) { if (workStep[r][_smax] > workStep[r-1][_smax]) workStep[r][_smax]=workStep[r-1][_smax]; result = workStep[r][_smax]-size*stepMulti; }
      trend[Bars-r-1] = workStep[r][_trend]; 

   return(result); 
} 

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" StepMa pdf changed trend to "+doWhat;
             if (alertsMessage)      Alert(message);
             if (alertsNotification) SendNotification(message);
             if (alertsEmail)        SendMail(StringConcatenate(Symbol()," StepMa pdf "),message);
             if (alertsSound)        PlaySound("alert2.wav");
      }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//    normal probability density function
//
//

#define Pi 3.141592653589793238462643

double pdf(double x, double variance=1.0, double mean=0) { return((1.0/MathSqrt(2*Pi*MathPow(variance,2))*MathExp(-MathPow(x-mean,2)/(2*MathPow(variance,2))))); }
double workPdfma[][2];
double iPdfma(double price, double period, double& coeffs[], int r, int instanceNo=0)
{
   if (ArraySize(workPdfma)!= Bars) ArrayResize(workPdfma,Bars); r = Bars-r-1;
   
   //
   //
   //
   //
   //
   
   workPdfma[r][instanceNo] = price;
      double sumw = coeffs[0];
      double sum  = coeffs[0]*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = coeffs[k];
                sumw  += weight;
                sum   += weight*workPdfma[r-k][instanceNo];  
      }             
      return(sum/sumw);
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

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

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