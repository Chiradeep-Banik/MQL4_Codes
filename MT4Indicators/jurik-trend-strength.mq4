//+------------------------------------------------------------------+
//|                                              rsx on jurik smooth |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers   3
#property indicator_color1  Yellow
#property indicator_style1  STYLE_DASH
#property indicator_color2  LimeGreen
#property indicator_width2  2 
#property indicator_color3  Red
#property indicator_width3  2 

//
//
//
//
//

extern int    RsxLength    = 14;
extern int    Price        = 0;
extern int    SmoothLength = 5;
extern int    SmoothPhase  = 0;
extern double K            = 4.236; // Multiplier  

//
//
//
//
//

double rsx[];
double UpTrend[];
double DnTrend[];
double smin[];
double smax[];
double atrrsx[];
double Delta[];
double trend[];

double wrkBuffer[][13];

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
   SetIndexBuffer(0,rsx);     SetIndexStyle(0,DRAW_LINE); SetIndexLabel(0,"Jrsx");
   SetIndexBuffer(1,UpTrend); SetIndexStyle(1,DRAW_LINE); SetIndexLabel(1,"UpTrend");
   SetIndexBuffer(2,DnTrend); SetIndexStyle(2,DRAW_LINE); SetIndexLabel(2,"DnTrend"); 
   SetIndexBuffer(3,smin);
   SetIndexBuffer(4,smax);
   SetIndexBuffer(5,atrrsx);
   SetIndexBuffer(6,Delta);
   SetIndexBuffer(7,trend);
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   
   IndicatorShortName("jurik trend strength ("+RsxLength+","+SmoothLength+","+SmoothPhase+")");
   if (StringSubstr(Symbol(),3,3)=="JPY") {
   K=K/100;
   }
 
   return(0);
}

int deinit() { return(0); }

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
        limit=MathMin(Bars-counted_bars,Bars-1);
        if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);

   //
   //
   //
   //
   //
   
   double Kg = (3.0)/(2.0+RsxLength);
   double Hg = 1.0-Kg;
   for(i=limit, r=Bars-i-1; i>=0; i--, r++)
   {
      wrkBuffer[r][12] = iSmooth(iMA(NULL,0,1,0,MODE_SMA,Price,i),SmoothLength,SmoothPhase,i,0);

      if (i==(Bars-1)) { for (int c=0; c<12; c++) wrkBuffer[r][c] = 0; continue; }  

      //
      //
      //
      //
      //
      
      double roc = wrkBuffer[r][12]-wrkBuffer[r-1][12];
      double roa = MathAbs(roc);
      for (int k=0; k<3; k++)
      {
         int kk = k*2;
            wrkBuffer[r][kk+0] = Kg*roc                + Hg*wrkBuffer[r-1][kk+0];
            wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; roc = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
            wrkBuffer[r][kk+6] = Kg*roa                + Hg*wrkBuffer[r-1][kk+6];
            wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; roa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
      }
      if (roa != 0)
           rsx[i] = MathMax(MathMin((roc/roa+1.0)*50.0,100.00),0.00); 
      else rsx[i] = 50.0;
   
      if(rsx[i] > rsx[i+1]) {double hrsx = rsx[i]; double lrsx = rsx[i+1];}
      else 
      if(rsx[i] < rsx[i+1]) {hrsx = rsx[i+1]; lrsx = rsx[i];}
      else
      {hrsx = rsx[i]; lrsx = rsx[i];}
   
      atrrsx[i] = hrsx - lrsx;            
      Delta[i] = iSmooth(iMA(atrrsx[i],0,2*RsxLength-1,0,MODE_SMA,Price,i),SmoothLength,SmoothPhase,i,10);
     
      smin[i] = rsx[i] - K*Delta[i]; 
      smax[i] = rsx[i] + K*Delta[i];
      
      trend[i] = trend[i+1];
   
      if (rsx[i]>smax[i+1])  trend[i]= 1; 
	   if (rsx[i]<smin[i+1])  trend[i]=-1;

      if(trend[i]>0)
	   {
	   if (smin[i]<smin[i+1]) smin[i]=smin[i+1];
	   UpTrend[i]=smin[i];
	   DnTrend[i]=EMPTY_VALUE;
	   }
	   else
	   if(trend[i]<0)
	   {
	   if(smax[i]>smax[i+1]) smax[i]=smax[i+1];
	   DnTrend[i]=smax[i];
	   UpTrend[i]=EMPTY_VALUE;
	   }
	   }
//----
   return(0);
  }


double wrk[][20];

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
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

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