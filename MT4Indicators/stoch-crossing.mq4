//+------------------------------------------------------------------+
//|            Stoch Crossing.mq4 modified from EMA-Crossover_Signal |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Allows you to enter two ema periods and it will then show you at |
//| Which point they crossed over. It is more usful on the shorter   |
//| periods that get obscured by the bars / candlesticks and when    |
//| the zoom level is out. Also allows you then to remove the emas   |
//| from the chart. (emas are initially set at 5 and 6)              |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//----
#property indicator_chart_window
#property indicator_buffers 2
//----
#property indicator_color1 DarkGreen
#property indicator_width1 3
#property indicator_color2 Red
#property indicator_width2 3
//----
extern string note1="Stochastic settings";
extern string note2="default = Stoch(30,10,10)";
extern int       KPeriod1   =30;
extern int       DPeriod1   =10;
extern int       Slowing1   =10;
extern string note3="0=sma, 1=ema, 2=smma, 3=lwma";
extern int       MAMethod1 =0;
extern string note4="0=high/low, 1=close/close";
extern int       PriceField1= 1;
//----
extern string note5="--------------------------------------------";
extern string note6="Arrow Type";
extern string note7="0=Thick, 1=Thin, 2=Hollow, 3=Round";
extern string note8="4=Fractal, 5=Diagonal Thin";
extern string note9="6=Diagonal Thick, 7=Diagonal Hollow";
extern string note10="8=Thumb, 9=Finger";
extern int ArrowType=3;
extern string note11="--------------------------------------------";
extern string note12="turn on Alert = true; turn off = false";
extern bool AlertOn=true;
extern string note13="--------------------------------------------";
extern string note14="send Email Alert = true; turn off = false";
extern bool SendAnEmail=false;
extern string note15="---------------------------------- Try";
extern string note16="GBPJPY M15 chart Stoch(30,10,10)";
//----
double CrossUp[];
double CrossDown[];
//----
string AlertPrefix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  string GetTimeFrameStr() 
  {
   switch(Period())
     {
      case 1 : string TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr=Period();
     }
   return(TimeFrameStr);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
     if (ArrowType==0) 
     {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 233);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 234);
     }
     else if (ArrowType==1) 
     {
         SetIndexStyle(0,DRAW_ARROW);
         SetIndexArrow(0, 225);
         SetIndexStyle(1,DRAW_ARROW);
         SetIndexArrow(1, 226);
        }
        else if (ArrowType==2) 
        {
            SetIndexStyle(0,DRAW_ARROW);
            SetIndexArrow(0, 241);
            SetIndexStyle(1,DRAW_ARROW);
            SetIndexArrow(1, 242);
           }
           else if (ArrowType==3) 
           {
               SetIndexStyle(0,DRAW_ARROW);
               SetIndexArrow(0, 221);
               SetIndexStyle(1,DRAW_ARROW);
               SetIndexArrow(1, 222);
              }
              else if (ArrowType==4) 
              {
                  SetIndexStyle(0,DRAW_ARROW);
                  SetIndexArrow(0, 217);
                  SetIndexStyle(1,DRAW_ARROW);
                  SetIndexArrow(1, 218);
                 }
                 else if (ArrowType==5) 
                 {
                     SetIndexStyle(0,DRAW_ARROW);
                     SetIndexArrow(0, 228);
                     SetIndexStyle(1,DRAW_ARROW);
                     SetIndexArrow(1, 230);
                    }
                    else if (ArrowType==6) 
                    {
                        SetIndexStyle(0,DRAW_ARROW);
                        SetIndexArrow(0, 236);
                        SetIndexStyle(1,DRAW_ARROW);
                        SetIndexArrow(1, 238);
                       }
                       else if (ArrowType==7) 
                       {
                           SetIndexStyle(0,DRAW_ARROW);
                           SetIndexArrow(0, 246);
                           SetIndexStyle(1,DRAW_ARROW);
                           SetIndexArrow(1, 248);
                          }
                          else if (ArrowType==8) 
                          {
                              SetIndexStyle(0,DRAW_ARROW);
                              SetIndexArrow(0, 67);
                              SetIndexStyle(1,DRAW_ARROW);
                              SetIndexArrow(1, 68);
                             }
                             else if (ArrowType==9) 
                             {
                                 SetIndexStyle(0,DRAW_ARROW);
                                 SetIndexArrow(0, 71);
                                 SetIndexStyle(1,DRAW_ARROW);
                                 SetIndexArrow(1, 72);
                                }
   SetIndexBuffer(0, CrossUp);
   SetIndexBuffer(1, CrossDown);
   AlertPrefix=Symbol()+" ("+GetTimeFrameStr()+"):  ";
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime lastbar;
   datetime curbar=Time[0];
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      return(true);
     }
   else
     {
      return(false);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  int start() 
  {
   int limit, i, counter;
   double stochastic1now, stochastic2now, stochastic1previous, stochastic2previous, stochastic1after, stochastic2after;
   double Range, AvgRange;
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+MathMax(9,MathMax(KPeriod1,DPeriod1));
   
     for(i=0; i<=limit; i++) 
     {
      counter=i;
      Range=0;
      AvgRange=0;
      for(counter=i ;counter<=i+9;counter++)
        {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
        }
      Range=AvgRange/10;
      stochastic1now=iStochastic(NULL,0,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,0,i);
      stochastic1previous=iStochastic(NULL,0,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,0,i+1);
      stochastic1after=iStochastic(NULL,0,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,0,i-1);
      stochastic2now=iStochastic(NULL,0,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,1,i);
      stochastic2previous=iStochastic(NULL,0,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,1,i+1);
      stochastic2after=iStochastic(NULL,0,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,1,i-1);
//----
        if ((stochastic1now > stochastic2now) && (stochastic1previous < stochastic2previous) && (stochastic1after > stochastic2after)) 
        {
         CrossUp[i]=Low[i] - Range*1.5;
           if (AlertOn && NewBar()) 
           {
            Alert(AlertPrefix+"Stoch ("+KPeriod1+","+DPeriod1+","+Slowing1+") %K crosses UP %D\nBUY signal @ Ask = ",Ask,"; Bid = ",Bid,"\nDate & Time = ",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()));
           }
           if (SendAnEmail && NewBar()) 
           {
            SendMail(AlertPrefix,"Stoch ("+KPeriod1+","+DPeriod1+","+Slowing1+") %K crosses UP %D\nBUY signal @ Ask = "+DoubleToStr(Ask,4)+", Bid = "+DoubleToStr(Bid,4)+", Date & Time = "+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime()));
           }
        }
        if ((stochastic1now < stochastic2now) && (stochastic1previous > stochastic2previous) && (stochastic1after < stochastic2after)) 
        {
         CrossDown[i]=High[i] + Range*1.5;
           if (AlertOn && NewBar())
           {
            Alert(AlertPrefix+"Stoch ("+KPeriod1+","+DPeriod1+","+Slowing1+") %K crosses DOWN %D\nSELL signal @ Ask = ",Ask,"; Bid = ",Bid,"\nDate & Time = ",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()));
           }
           if (SendAnEmail && NewBar()) 
           {
            SendMail(AlertPrefix,"Stoch ("+KPeriod1+","+DPeriod1+","+Slowing1+") %K crosses DOWN %D\nSELL signal @ Ask = "+DoubleToStr(Ask,4)+", Bid = "+DoubleToStr(Bid,4)+", Date & Time = "+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime()));
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+