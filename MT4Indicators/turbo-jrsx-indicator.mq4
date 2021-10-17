//+---------------------------------------------------------+
//+---------------------------------------------------------+

#property copyright ""
#property link ""
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_level1 70
#property indicator_level2 30
#property indicator_level3 50
#property indicator_maximum 100
#property indicator_minimum 0

//---- input parameters
extern int Len=14; //---- buffers
extern double UpperLevel   =  70;
extern double LowerLevel   =  30;
extern string  p = "--Applied Price Types--";
extern string  p0 = " 0 = close";
extern string  p1 = " 1 = open";
extern string  p2 = " 2 = high";
extern string  p3 = " 3 = low";
extern string  p4 = " 4 = median(high+low)/2";
extern string  p5 = " 5 = typical(high+low+close)/3";
extern string  p6 = " 6 = weighted(high+low+close+close)/4";
extern int     PriceMode = 5;

double rsx[];
double jrhi[];
double jrlo[];

int init() {
   IndicatorShortName("3c_Turbo_JRSX");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,rsx);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,jrhi);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,jrlo);
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{

   double tempPrice;
   double f88, f90;
   double f0, v4, v8, vC, v10, v14, v18, v20;
   double f8, f10, f18, f20, f28, f30, f38, f48, v1C;
   double f50, f58, f60, f68, f70, f78, f80, f40;
   
   //int counted_bars = IndicatorCounted(),limit,shift;

   //if (counted_bars<0) return(-1);
   //if (counted_bars>0) counted_bars--;
   double limit=Bars-(Len)-1;
   
   //if(counted_bars>Len) limit=Bars-counted_bars-1;

   for (int shift=limit;shift>=0;shift--) {
      tempPrice = GetPrice(PriceMode, shift);  // Get the price based on mode entered
      if (f90 == 0.0) {
      
         f90 = 1.0;
         f0 = 0.0;
         if (Len-1 >= 5) f88 = Len-1.0; else f88 = 5.0;
 //      f8 = 100.0*(Close[shift]);
 // 
 //      Modified for median price
 //      Modified for any price based on PriceMode input
 //      default input is typical price
 //
 //        f8 = 100.0*((High[shift]+Low[shift]+Close[shift])/3);
         f8 = 100.0 * tempPrice;
         f18 = 3.0 / (Len + 2.0);
         f20 = 1.0 - f18;
         
      } else{
         if (f88 <= f90) f90 = f88 + 1; else f90 = f90 + 1;
         f10 = f8;
 //      f8 = 100*Close[shift];
 //         f8 = 100.0*((High[shift]+Low[shift]+Close[shift])/3);
         f8 = 100 * tempPrice;
         v8 = f8 - f10;
         f28 = f20 * f28 + f18 * v8;
         f30 = f18 * f28 + f20 * f30;
         vC = f28 * 1.5 - f30 * 0.5;
         f38 = f20 * f38 + f18 * vC;
         f40 = f18 * f38 + f20 * f40;
         v10 = f38 * 1.5 - f40 * 0.5;
         f48 = f20 * f48 + f18 * v10;
         f50 = f18 * f48 + f20 * f50;
         v14 = f48 * 1.5 - f50 * 0.5;
         f58 = f20 * f58 + f18 * MathAbs(v8);
         f60 = f18 * f58 + f20 * f60;
         v18 = f58 * 1.5 - f60 * 0.5;
         f68 = f20 * f68 + f18 * v18;

         f70 = f18 * f68 + f20 * f70;
         v1C = f68 * 1.5 - f70 * 0.5;
         f78 = f20 * f78 + f18 * v1C;
         f80 = f18 * f78 + f20 * f80;
         v20 = f78 * 1.5 - f80 * 0.5;

         if ((f88 >= f90) && (f8 != f10)) f0 = 1.0;
         if ((f88 == f90) && (f0 == 0.0)) f90 = 0.0;
      }

      if ((f88 < f90) && (v20 > 0.0000000001)) {

         v4 = (v14 / v20 + 1.0) * 50.0;
         if (v4 > 100.0) v4 = 100.0;
         if (v4 < 0.0) v4 = 0.0;

      } else {
         v4 = 50.0;
      }
      
      rsx[shift]=v4;
      jrhi[shift]=v4;
      jrlo[shift]=v4;

      if (v4 >= UpperLevel)
      {
          jrlo[shift] = EMPTY_VALUE;
      }
      else if (v4 <= LowerLevel) 
      {
          jrhi[shift] = EMPTY_VALUE;
      }
      else 
      {
         
         jrhi[shift]=EMPTY_VALUE;//EMPTY_VALUE;
         jrlo[shift]=EMPTY_VALUE;//EMPTY_VALUE;
      }
        


   }
   
   return(0);
   
}

// Applied Price enumerations
// 0=close, 1=open, 2=high, 3=low, 4=median((h+l/2)), 5=typical((h+l+c)/3), 6=weighted((h+l+c+c)/4)
double GetPrice(int pMode, int mShift)
{
   double price;
   
   switch(pMode)
   {
     case 0: price = Close[mShift];
             break;
     case 1: price = Open[mShift];
             break;
     case 2: price = High[mShift];
             break;
     case 3: price = Low[mShift];
             break;
     case 4: price = (High[mShift] + Low[mShift])/2.0;
             break;
     case 5: price = (High[mShift] + Low[mShift] + Close[mShift])/3.0;
             break;
     case 6: price = (High[mShift] + Low[mShift] + 2.0*Close[mShift])/4;
             break;
   }
   return (price);
}

