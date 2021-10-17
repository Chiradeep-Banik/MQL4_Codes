//+------------------------------------------------------------------+
//|                                               KeltnerChannel.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1  Gray
#property indicator_color2  DeepSkyBlue
#property indicator_color3  Magenta
#property indicator_color4  Magenta
#property indicator_color5  Gray
#property indicator_color6  Blue//DarkGreen//OrangeRed
#property indicator_color7  MediumVioletRed//PaleVioletRed
#property indicator_color8  MediumVioletRed//PaleVioletRed
#property indicator_style1  STYLE_DASH
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DASH
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2

//
//
//
//
//

extern string TimeFrame        = "current time frame";
extern int    MA_PERIOD        = 14;//34;
extern int    MA_MODE          = 3;
extern int    PRICE_MODE       = 0;
extern int    ATR_PERIOD       = 21;
extern double K                = 0.628;
extern bool   ATR_MODE         = false;
extern int    Length           = 5;
extern int    Price            = 0;
extern double Phase            = 100;
extern bool   Interpolate      = true;
extern bool   MultiColor       = true;

extern bool   ShowArrows       = true;
extern bool   arrowsOnJurik    = true;
extern string arrowsIdentifier = "jurik arrows";
extern color  arrowsUpColor    = Blue;//Aqua;
extern color  arrowsUpWidth    = 5;
extern color  arrowsDnColor    = SaddleBrown;//Magenta;
extern color  arrowsDnWidth    = 3;

extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;

//
//
//
//
//

double upper[];
double middle[];
double middleda[];
double middledb[];
double lower[];
double jur[];
double jurDa[];
double jurDb[];
double slope[];
double slopm[];

//
//
//
//

string IndicatorFileName;
int    timeFrame;
bool   calculateKcn;
bool   returningBars;

//+------------------------------------------------------------------+
//|                                                                   
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
      IndicatorBuffers(10);
      SetIndexBuffer(0,upper);
      SetIndexBuffer(1,middle);
      SetIndexBuffer(2,middleda);
      SetIndexBuffer(3,middledb);
      SetIndexBuffer(4,lower);
      SetIndexBuffer(5,jur);
      SetIndexBuffer(6,jurDa);
      SetIndexBuffer(7,jurDb);
      SetIndexBuffer(8,slope);
      SetIndexBuffer(9,slopm);
      
      //
      //
      //
      //
      //
      
      IndicatorFileName = WindowExpertName();
      calculateKcn      = (TimeFrame=="calculateKcn");
      returningBars     = (TimeFrame=="returnBars");
      timeFrame         = stringToTimeFrame(TimeFrame);
   return(0);
}
int deinit(){  if (!calculateKcn && ShowArrows) deleteArrows();  return(0); }

//+------------------------------------------------------------------+
//|                                                                   
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit=MathMin(Bars-counted_bars,Bars-1);
         if (returningBars)  { upper[0] = limit; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateKcn || timeFrame==Period())
   {
      if (MultiColor && slope[limit]==-1) CleanPoint(limit,jurDa,jurDb);
      if (MultiColor && slopm[limit]==-1) CleanPoint(limit,middleda,middledb);
      for(i=limit; i>=0; i--)
      {
         middle[i] = iMA(NULL,0,MA_PERIOD,0,MA_MODE,PRICE_MODE,i);

         if (ATR_MODE) double avg  = iATR(NULL,0,ATR_PERIOD,i);
         else 
         {
               double sum=0;
               for (int x=0; x<ATR_PERIOD; x++) sum += High[i+x]-Low[i+x];
                                                avg = sum/ATR_PERIOD;
         }
         upper[i]    = middle[i] + K*avg;
         lower[i]    = middle[i] - K*avg;
         jur[i]      = iSmooth(iMA(NULL,0,1,0,MODE_SMA,Price,i),Length,Phase,i);
         jurDa[i]    = EMPTY_VALUE;
         jurDb[i]    = EMPTY_VALUE;
         middleda[i] = EMPTY_VALUE;
         middledb[i] = EMPTY_VALUE;
         slope[i]    = slope[i+1];
         slopm[i]    = slopm[i+1];
     
         if (jur[i]<lower[i])       slope[i] = -1;
         if (jur[i]>upper[i])       slope[i] =  1;
         if (middle[i]<middle[i+1]) slopm[i] = -1;
         if (middle[i]>middle[i+1]) slopm[i] =  1;
         if (MultiColor && slope[i] == -1) PlotPoint(i,jurDa,jurDb,jur);
         if (MultiColor && slopm[i] == -1) PlotPoint(i,middleda,middledb,middle);
         if (!calculateKcn) manageArrow(i);
      }
       manageAlerts();
      return(0);
   }      
   
   //
   //
   //
   //
   //
   
   if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,IndicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (MultiColor && slope[i] == -1) CleanPoint(limit,jurDa,jurDb);
   if (MultiColor && slopm[i] == -1) CleanPoint(limit,middleda,middledb);
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         upper[i]    = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,Length,Price,Phase,0,y);
         middle[i]   = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,Length,Price,Phase,1,y);
         lower[i]    = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,Length,Price,Phase,4,y);
         jur[i]      = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,Length,Price,Phase,5,y);
         slope[i]    = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,Length,Price,Phase,8,y);
         slopm[i]    = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,Length,Price,Phase,9,y);
         jurDa[i]    = EMPTY_VALUE;
         jurDb[i]    = EMPTY_VALUE;
         middleda[i] = EMPTY_VALUE;
         middledb[i] = EMPTY_VALUE;
         manageArrow(i);
         
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
         
         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int j = 1; j < n; j++)
            {
               upper[i+j]  = upper[i]  + (upper[i+n]  - upper[i])  * j/n;
               middle[i+j] = middle[i] + (middle[i+n] - middle[i]) * j/n;  
               lower[i+j]  = lower[i]  + (lower[i+n]  - lower[i])  * j/n;
               jur[i+j]    = jur[i]    + (jur[i+n]    - jur[i])    * j/n;   
            }                            
   }
   
   if (MultiColor)
   for (i=limit;i>=0;i--)
   {
      if (slope[i]==-1) PlotPoint(i,jurDa,jurDb,jur);
      if (slopm[i]==-1) PlotPoint(i,middleda,middledb,middle);
   }      
   manageAlerts(); 
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string StringUpperCase(string str)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------
//|                                                                 
//+------------------------------------------------------------------
//
//
//
//
//

double wrk[][10];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i)
{
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[0][k]=price; for(; k<10; k++) wrk[0][k]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax];
      double del2   = price - wrk[r-1][bsmin];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty] = MathAbs(del2); 
         wrk[r][vsum] =	wrk[r-1][vsum] + (wrk[r][volty]-wrk[r-forBar][volty])*div;
   
         //
         //
         //
         //
         //
   
         wrk[r][avolty] = wrk[r-1][avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum]-wrk[r-1][avolty]);
            if (wrk[r][avolty] > 0)
               double dVolty = wrk[r][volty]/wrk[r][avolty]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax] = price; else wrk[r][bsmax] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin] = price; else wrk[r][bsmin] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0] = price + alpha*(wrk[r-1][0]-price);
         wrk[r][1] = (price - wrk[r][0])*(1-beta) + beta*wrk[r-1][1];
         wrk[r][2] = (wrk[r][0] + R*wrk[r][1]);
         wrk[r][3] = (wrk[r][2] - wrk[r-1][4])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3];
         wrk[r][4] = (wrk[r-1][4] + wrk[r][3]); 

   //
   //
   //
   //
   //

   return(wrk[r][4]);
}

//
//
//
//
//

void manageAlerts()
{
   if (!calculateKcn && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (arrowsOnJurik)
      {
         if (slope[whichBar] != slope[whichBar+1])
         {
            if (slope[whichBar] ==  1) doAlert(whichBar,"crossed upper channel");
            if (slope[whichBar] == -1) doAlert(whichBar,"crossed lower channel");
         }
      }
      else
      {
         if (slopm[whichBar] != slopm[whichBar+1])
         {
            if (slopm[whichBar] ==  1) doAlert(whichBar,"slope changed to up");
            if (slopm[whichBar] == -1) doAlert(whichBar,"slope changed to down");
         }
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

       message =  StringConcatenate(Period(),"  ",Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Jurik ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Period(),Symbol()," Jurik  "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//
//
//
//
//

void manageArrow(int i)
{
   if (ShowArrows)
   {
      deleteArrow(Time[i]);
      if (arrowsOnJurik)
      {
         if (slope[i]!=slope[i+1])
         {
            if (slope[i] == 1) drawArrow(i,arrowsUpColor,171,false);
            if (slope[i] ==-1) drawArrow(i,arrowsDnColor,170,true);
         }
      }
      else
      {
         if (slopm[i]!=slopm[i+1])
         {
            if (slopm[i] == 1) drawArrow(i,arrowsUpColor,171,false);
            if (slopm[i] ==-1) drawArrow(i,arrowsDnColor,170,true);
         }
      }
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
   double gap  =5.0*iATR(NULL,0,30,i)/4.0;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,arrowsUpWidth);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
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