//+------------------------------------------------------------------+
//|                                                    moving MinMax |
//|                                                                  |
//| original mq5 version made by investeo                            |
//| coversion to mq4 by mladen
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  DeepSkyBlue
#property indicator_color2  PaleVioletRed
#property indicator_color3  Yellow
#property indicator_color4  DeepSkyBlue
#property indicator_color5  PaleVioletRed
#property indicator_color6  DeepSkyBlue
#property indicator_color7  PaleVioletRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  2
#property indicator_width7  2

//
//
//
//
//

extern int Smoothing = 5;
extern int Window    = 300;
extern int Price     = PRICE_CLOSE;

//
//
//
//
//

double mmUp[];
double mmDn[];
double mmUph[];
double mmDnh[];
double mmUpa[];
double mmDna[];
double mmYeh[];
double prices[];

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
   IndicatorBuffers(8);
      SetIndexBuffer(0,mmUph); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,mmDnh); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,mmYeh); SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(3,mmUpa); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,233);
      SetIndexBuffer(4,mmDna); SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,234);
      SetIndexBuffer(5,mmUp);
      SetIndexBuffer(6,mmDn);
      SetIndexBuffer(7,prices);
   IndicatorShortName("Moving MinMax ("+Smoothing+","+Window+")");
   return(0);
}
int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double S[];
double work[][10];
#define sQiip1 0
#define sQiim1 1
#define sPiip1 2
#define sPiim1 3
#define dQiip1 4
#define dQiim1 5
#define dPiip1 6
#define dPiim1 7
#define sui    8
#define dui    9

//
//
//
//
//

int start()
{
   int scount = Window+2*Smoothing;
   int i,k,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(work,0) != Window) ArrayResize(work,Window);
         if (ArrayRange(S,0)    != scount) ArrayResize(S   ,scount);

   //
   //
   //
   //
   //
   
   for(i=limit; i>=0; i--) prices[i] = iMA(NULL,0,1,0,MODE_SMA,Price,i);

      ArrayCopy(S,prices,0,0,scount);
      for (i=0; i<Window; i++)
      {
         work[i][sQiip1]=0;
         work[i][sQiim1]=0;
         work[i][dQiip1]=0;
         work[i][dQiim1]=0;
         for(k=0; k<Smoothing; k++)
         {
            work[i][sQiip1] += MathExp( 2*(S[Smoothing-1+i+k]-S[i])/(S[Smoothing-1+i+k]+S[i]));
            work[i][sQiim1] += MathExp( 2*(S[Smoothing-1+i-k]-S[i])/(S[Smoothing-1+i-k]+S[i]));
            work[i][dQiip1] += MathExp(-2*(S[Smoothing-1+i+k]-S[i])/(S[Smoothing-1+i+k]+S[i]));
            work[i][dQiim1] += MathExp(-2*(S[Smoothing-1+i-k]-S[i])/(S[Smoothing-1+i-k]+S[i]));
         }
      }
      for(i=0; i<Window; i++)
      {
         work[i][sPiip1] = work[i][sQiip1] / (work[i][sQiip1] + work[i][sQiim1]);
         work[i][sPiim1] = work[i][sQiim1] / (work[i][sQiip1] + work[i][sQiim1]);
         work[i][dPiip1] = work[i][dQiip1] / (work[i][dQiip1] + work[i][dQiim1]);
         work[i][dPiim1] = work[i][dQiim1] / (work[i][dQiip1] + work[i][dQiim1]);
      }

   //
   //
   //
   //
   //
         
      work[0][sui] = 1;
      work[0][dui] = 1;
      for(i=1; i<Window; i++)
      {
         work[i][sui] = (work[i][sPiim1]/work[i][sPiip1])*work[i-1][sui];
         work[i][dui] = (work[i][dPiim1]/work[i][dPiip1])*work[i-1][dui];
      }

      double uSum = 0;
      double dSum = 0;
            for(i=0; i<Window; i++) { uSum+=work[i][sui]; dSum+=work[i][dui]; }
            for(i=0; i<Window; i++) { mmDn[i] = work[i][sui] / uSum; mmUp[i] = work[i][dui] / dSum; }
      double middle = (mmDn[0]+mmUp[0])/2.0;
            for(i=0; i<Window; i++) { mmDn[i] -= middle; mmUp[i] -= middle; }
   
   //
   //
   //
   //
   //

      int upind=0; double upval=mmUp[0];
      int dnind=0; double dnval=mmDn[0];
          mmUph[0] = EMPTY_VALUE;
          mmDnh[0] = EMPTY_VALUE;
          mmUpa[0] = EMPTY_VALUE;
          mmDna[0] = EMPTY_VALUE;
          mmYeh[0] = EMPTY_VALUE;
         
      //
      //
      //
      //
      //

      for(i=1; i<Window; i++)
      {
         if(mmDn[i]>dnval) { dnval=mmDn[i]; dnind=i; }
         if(mmUp[i]>upval) { upval=mmUp[i]; upind=i; }
                  mmUph[i] = EMPTY_VALUE;
                  mmDnh[i] = EMPTY_VALUE;
                  mmUpa[i] = EMPTY_VALUE;
                  mmDna[i] = EMPTY_VALUE;
                  mmYeh[i] = EMPTY_VALUE;
      }
      if(upind<dnind)
         {
            for(i=0; i<upind;  i++) mmDnh[i]=MathMax(mmUp[i],mmDn[i]);
            for(   ; i<dnind;  i++) mmUph[i]=MathMax(mmUp[i],mmDn[i]);
            for(   ; i<Window; i++) mmDnh[i]=MathMax(mmUp[i],mmDn[i]);
         }
      else
         {
            for(i=0; i<dnind;  i++) mmUph[i]=MathMax(mmUp[i],mmDn[i]);
            for(   ; i<upind;  i++) mmDnh[i]=MathMax(mmUp[i],mmDn[i]);
            for(   ; i<Window; i++) mmUph[i]=MathMax(mmUp[i],mmDn[i]);
      }               
      mmYeh[upind] = MathMax(mmUp[upind],mmDn[upind]);
      mmYeh[dnind] = MathMax(mmUp[dnind],mmDn[dnind]);
      mmUpa[dnind] = 0-dnval/3.0;
      mmDna[upind] = 0-dnval/3.0;
   
   //
   //
   //
   //
   //
   
   for (i=0; i<7; i++) SetIndexDrawBegin(i,Bars-Window);
   return(0);
}