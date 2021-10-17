//+------------------------------------------------------------------+
//|                           CCI - Nrp - Mtf Advanced Alerts 01.mq4 |
//+------------------------------------------------------------------+
 
 
#property indicator_separate_window
#property indicator_buffers 5

#property indicator_color1  DeepSkyBlue
#property indicator_color2  RoyalBlue
#property indicator_color3  PaleVioletRed
#property indicator_color4  Coral
#property indicator_color5  DimGray

#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  4

//
//
//
//
//

extern string TimeFrame           = "current time frame";
extern int    CCIPeriod           = 14;
extern int    CCIPrice            = PRICE_TYPICAL;
extern int    OverSold            = -100;
extern int    OverBought          =  100;
extern double SmoothLength        =    5;
extern double SmoothPhase         =    0; 
extern bool   ShowArrows          = true;
extern bool   ShowArrowsZoneEnter = true;
extern bool   ShowArrowsZoneExit  = true;
extern string arrowsIdentifier    = "cci arrows";
extern color  arrowsUpColor       = Aqua;
extern color  arrowsDnColor       = Red;

extern string note                = "CCI Arrow Type";
extern string note1               = "1=Thick UpCode:233 DnCode:234, 2=Thin UpCode:225 DnCode:226";
extern string note2               = "3=Hollow UpCode:241 DnCode:242, 4=Fractal UpCode:217 DnCode:218";
extern string note3               = "5=Diagonal Thick UpCode:236 DnCode:238";
extern int    arrowsUpCode        = 233;
extern int    arrowsDnCode        = 234;
extern int    arrowsUpSize        = 1;
extern int    arrowsDnSize        = 1;
extern double arrowsUpperGap      = 1.0;
extern double arrowsLowerGap      = 1.0;
extern bool   Interpolate         = true;
extern bool   alertsOn            = true;
extern bool   alertsOnZoneEnter   = true;
extern bool   alertsOnZoneExit    = true;
extern bool   alertsOnCurrent     = true;
extern bool   alertsMessage       = true;
extern bool   alertsSound         = false;
extern bool   alertsEmail         = false;
extern int    History             = 1000;

double cci[];
double cciUpa[];
double cciUpb[];
double cciDna[];
double cciDnb[];
double prices[];
double trend[];
 
string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;
 
int init()
{
   IndicatorBuffers(7);
      SetIndexBuffer(4,cci);
      SetIndexBuffer(0,cciUpa); SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,"cciUpa");
      SetIndexBuffer(1,cciUpb); SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"cciUpb");
      SetIndexBuffer(2,cciDna); SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexLabel(2,"cciDna");
      SetIndexBuffer(3,cciDnb); SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexLabel(3,"cciDnb");
      SetIndexBuffer(5,prices);
      SetIndexBuffer(6,trend);  SetIndexLabel(6,"trend");
         SetLevelValue(0,OverBought);
         SetLevelValue(1,OverSold);

         //
         //
         //
         //
         //
                  
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="CalculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
         
         //
         //
         //
         //
         //
         
   IndicatorShortName(timeFrameToString(timeFrame)+" CCI ("+CCIPeriod+")");
   return(0);
}
int deinit()
{Comment("");
   if (!calculateValue && ShowArrows) deleteArrows();
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
   int i,k,n,limit;
   int whichBar;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   if(History==0) History=Bars-1;
         limit = MathMin(Bars-counted_bars,History);
         if (returnBars) { cci[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      for(i=limit; i>=0; i--)
      {
         prices[i]  = iMA(NULL,0,1,0,MODE_SMA,CCIPrice,i);
         double avg = 0; for(k=0; k<CCIPeriod; k++) avg +=         prices[i+k];      avg /= CCIPeriod;
         double dev = 0; for(k=0; k<CCIPeriod; k++) dev += MathAbs(prices[i+k]-avg); dev /= CCIPeriod;
            if (dev!=0)
                  cci[i] = iSmooth((prices[i]-avg)/(0.015*dev),SmoothLength,SmoothPhase,i);
            else  cci[i] = iSmooth(0                          ,SmoothLength,SmoothPhase,i);
         
            //
            //
            //
            //
            //
         
            cciUpa[i] = EMPTY_VALUE;
            cciUpb[i] = EMPTY_VALUE;
            cciDna[i] = EMPTY_VALUE;
            cciDnb[i] = EMPTY_VALUE;
            trend[i] = trend[i+1];
            
               if (cci[i]>OverBought)                    trend[i] =  1;
               if (cci[i]<OverSold)                      trend[i] = -1;               
               if (cci[i]>0 && cci[i]<OverBought)        trend[i] =  2;
               if (cci[i]<0 && cci[i]>OverSold)          trend[i] = -2;
                                          
               if (trend[i] ==  1) cciUpa[i] = cci[i];
               if (trend[i] == -1) cciDna[i] = cci[i];
               if (trend[i] ==  2) cciUpb[i] = cci[i];
               if (trend[i] == -2) cciDnb[i] = cci[i];
               
               if (!calculateValue) manageArrow(i);
      }
      if (alertsOn)
      {
         if (alertsOnCurrent)
            whichBar = 0;
         else     whichBar = 1; 
         whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
         
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (alertsOnZoneEnter && trend[whichBar]   == 1)                         doAlert(whichBar,DoubleToStr(OverBought,2)+" crossed up");
            if (alertsOnZoneEnter && trend[whichBar]   ==-1)                         doAlert(whichBar,DoubleToStr(OverSold  ,2)+" crossed down");
            if (alertsOnZoneExit  && trend[whichBar+1] == -1 && trend[whichBar]!=-1) doAlert(whichBar,DoubleToStr(OverBought,2)+" crossed down");
            if (alertsOnZoneExit  && trend[whichBar+1] ==1 && trend[whichBar]!= 1)   doAlert(whichBar,DoubleToStr(OverSold  ,2)+" crossed up");
         }         
      }

   return(0);
   }      
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(History,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]== 1) CleanPoint(limit,cciUpa,cciUpb);
   if (trend[limit]==-1) CleanPoint(limit,cciDna,cciDnb);
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         cci[i]    = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",CCIPeriod,CCIPrice,OverSold,OverBought,SmoothLength,SmoothPhase,4,y);
         trend[i]  = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",CCIPeriod,CCIPrice,OverSold,OverBought,SmoothLength,SmoothPhase,6,y);
         cciUpa[i] = EMPTY_VALUE;
         cciUpb[i] = EMPTY_VALUE;
         cciDna[i] = EMPTY_VALUE;
         cciDnb[i] = EMPTY_VALUE;
         manageArrow(i);

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

         datetime time = iTime(NULL,timeFrame,y);
            for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k < n; k++)
               cci[i+k] = cci[i] + (cci[i+n]-cci[i])*k/n;
   }
   
   for (i=limit;i>=0;i--)
   {
      if (trend[i] ==  1) cciUpa[i] = cci[i];
      if (trend[i] == -1) cciDna[i] = cci[i];
      if (trend[i] ==  2) cciUpb[i] = cci[i];
      if (trend[i] == -2) cciDnb[i] = cci[i];     
   }

   //
   //
   //
   //
   //
      if (alertsOn)
      {
         if (alertsOnCurrent)
            whichBar = 0;
         else     whichBar = 1; 
         whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
         
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (alertsOnZoneEnter && trend[whichBar]   == 1)                         doAlert(whichBar,DoubleToStr(OverBought,2)+" crossed up");
            if (alertsOnZoneEnter && trend[whichBar]   ==-1)                         doAlert(whichBar,DoubleToStr(OverSold  ,2)+" crossed down");
            if (alertsOnZoneExit  && trend[whichBar+1] == -1 && trend[whichBar]!=-1) doAlert(whichBar,DoubleToStr(OverBought,2)+" crossed down");
            if (alertsOnZoneExit  && trend[whichBar+1] ==1 && trend[whichBar]!= 1)   doAlert(whichBar,DoubleToStr(OverSold  ,2)+" crossed up");
         }         
      }
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

       message =  StringConcatenate(Symbol(),"  ",PeriodString()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," CCI level ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"CCI-NRP "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

void manageArrow(int i)
{
   if (ShowArrows)
   {
      deleteArrow(Time[i]);
      if (trend[i]!=trend[i+1])
      {
         if (ShowArrowsZoneEnter && trend[i]   == 1) 
            drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
            
         if (ShowArrowsZoneEnter && trend[i]   ==-1) 
            drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize,true);
            
         if (ShowArrowsZoneExit  && trend[i+1] ==-1 && (trend[i] !=-1)) 
            drawArrow(i,arrowsDnColor,arrowsUpCode,arrowsUpSize,false);
            
         if (ShowArrowsZoneExit  && trend[i+1] == 1 && (trend[i] != 1))
            drawArrow(i,arrowsUpColor,arrowsDnCode,arrowsDnSize,true);
            
      }
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,int theSize,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      //
      //SetIndexArrow
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theSize ); 
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
void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
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

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[0][k+s]=price; for(; k<10; k++) wrk[0][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
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

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
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

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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
   int Char;
   for (int length=StringLen(str)-1; length>=0; length--)
   {
        Char = StringGetChar(s, length);
         if((Char > 96 && Char < 123) || (Char > 223 && Char < 256))
                     s = StringSetChar(s, length, Char - 32);
         else if(Char > -33 && Char < 0)
                     s = StringSetChar(s, length, Char + 224);
   }
   return(s);
}

string PeriodString()
{
    switch (_Period) 
     {
        case PERIOD_M1:  return("M1");
        case PERIOD_M5:  return("M5");
        case PERIOD_M15: return("M15");
        case PERIOD_M30: return("M30");
        case PERIOD_H1:  return("H1");
        case PERIOD_H4:  return("H4");
        case PERIOD_D1:  return("D1");
        case PERIOD_W1:  return("W1");
        case PERIOD_MN1: return("MN1");
     }    
   return("M" + string(_Period));
}
//-------------------------------------------------------------------+