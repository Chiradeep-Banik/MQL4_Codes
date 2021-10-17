//+------------------------------------------------------------------+
//|                                                      MAAngle.mq4 |
//|                                               original    jpkfox |
//|                                               edited by dariuske |
//| You can use this indicator to measure when the MA angle is       |
//| "near zero". AngleTreshold determines when the angle for the     |
//| EMA is "about zero": This is when the value is between           |
//| [-AngleTreshold, AngleTreshold] (or when the histogram is red).  |
//|   MAMode : 0 = SMA, 1 = EMA, 2 = Smoothed, 3 = Weighted          |
//|   MAPeriod: MA period                                            |
//|   AngleTreshold: The angle value is "about zero" when it is      |
//|     between the values [-AngleTreshold, AngleTreshold].          |      
//|   StartMAShift: The starting point to calculate the              |   
//|     angle. This is a shift value to the left from the            |
//|     observation point. Should be StartEMAShift > EndEMAShift.    | 
//|   StartMAShift: The ending point to calculate the                |
//|     angle. This is a shift value to the left from the            | 
//|     observation point. Should be StartEMAShift > EndEMAShift.    |
//|                                                                  |
//|   Modified by MrPip                                              |
//|       Red for down                                               |
//|       Yellow for near zero                                       |
//|       Green for up                                               |
//|  10/15/05  MrPip                                                 |
//|            Corrected problem with USDJPY and optimized code      |
//|  10/23/05  Added other JPY crosses                               |
//|                                                                  |
//|                                                                  |  
//|                                                                  |  
//|  12/01/07  Dariuske: Changed code for SMA50 (PhilNelSystem)      |
//|  18/01/07  Dariuske: Changed code for multiple mode MA's         |
//+------------------------------------------------------------------+

#property  copyright "jpkfox"
#property  link      "http://www.strategybuilderfx.com/forums/showthread.php?t=15274&page=1&pp=8"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  LimeGreen
#property  indicator_color2  FireBrick 
#property  indicator_color3 Yellow
//---- indicator parameters
extern int MAMode = 0;
extern int MAPeriod=50;
extern int Price=4;
extern double AngleTreshold=0.25;
extern int StartMAShift=2;
extern int EndMAShift=0;


//---- indicator buffers
double UpBuffer[];
double DownBuffer[];
double ZeroBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,4);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,4);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,4);

   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,UpBuffer) &&
      !SetIndexBuffer(1,DownBuffer) &&
      !SetIndexBuffer(2,ZeroBuffer))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   //IndicatorShortName("MAAngle("+MAPeriod+","+AngleTreshold+","+StartMAShift+","+EndMAShift+")");
   IndicatorShortName("MAAngle");
//---- initialization done
   return(0);
}
//+------------------------------------------------------------------+
//| The angle for EMA                                                |
//+------------------------------------------------------------------+
int start()
{
   double fEndMA, fStartMA;
   double fAngle, mFactor, dFactor;
   int nLimit, i;
   int nCountedBars;
   double angle;
   int ShiftDif;
   string Sym;
   
   if (MAMode >= 4) MAMode = 0;
 
   if(EndMAShift >= StartMAShift)
   {
      Print("Error: EndMAShift >= StartMAShift");
      StartMAShift = 6;
      EndMAShift = 0;      
   }  
         
   nCountedBars = IndicatorCounted();
//---- check for possible errors
   if(nCountedBars<0) 
      return(-1);
//---- last counted bar will be recounted
   if(nCountedBars>0) 
      nCountedBars--;
   nLimit = Bars-nCountedBars;
   dFactor = 2*3.14159/180.0;
   mFactor = 10000.0;
   Sym = StringSubstr(Symbol(),3,3);
   if (Sym == "JPY") mFactor = 100.0;
   ShiftDif = StartMAShift-EndMAShift;
   mFactor /= ShiftDif; 
//---- main loop
   for(i=0; i<nLimit; i++)
   {
      fEndMA=iMA(NULL,0,MAPeriod,0,MAMode,Price,i+EndMAShift);
      fStartMA=iMA(NULL,0,MAPeriod,0,MAMode,Price,i+StartMAShift);
      // 10000.0 : Multiply by 10000 so that the fAngle is not too small
      // for the indicator Window.
      fAngle = mFactor * (fEndMA - fStartMA)/2.0;
      //fAngle = MathArctan(fAngle)/dFactor;

      DownBuffer[i] = 0.0;
      UpBuffer[i] = 0.0;
      ZeroBuffer[i] = 0.0;
      
      if(fAngle > AngleTreshold)
         UpBuffer[i] = fAngle;
      else if (fAngle < -AngleTreshold)
         DownBuffer[i] = fAngle;
      else ZeroBuffer[i] = fAngle;
   }

   return(0);
  }
//+------------------------------------------------------------------+

