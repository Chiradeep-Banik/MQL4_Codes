//+------------------------------------------------------------------+
//|                                                       KG_SDL.mq4 |
//|                                                            d4y47 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window 
#property indicator_buffers 5 

extern string  periode  =  "1D"; 
extern int      method  =  3;                         // MODE_SMA 
extern int       price  =  0;                          // PRICE_CLOSE 
extern int       renko  =  10;

extern bool   ShowLine  =  true;
extern int        Size  =  2;
extern ENUM_LINE_STYLE Style  =  STYLE_SOLID;

extern bool ShowArrows  =  true;
extern color   ColorUP  =  Lavender,    //FireBrick,       //Red,
               ColorDN  =  Magenta;     //DarkGreen;       //Lime
               
extern int   ArrowsGap  =  10,
             arrowsUP   = 233, 
             arrowsDN   = 234,
             arrowsSize = 1;

//---- buffers 
double Uptrend[];
double Dntrend[];
double ExtMapBuffer[]; 
int period; 
color warna1, warna2;
double ArrUp[],ArrDn[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init() 
{
   if (periode=="1D"){period=MathCeil(getdailyavg()/renko); warna1=LightBlue; warna2=Tomato;}
   else if (periode=="1W"){period=MathCeil(getweeklyavg()/renko); warna1=Red; warna2=Yellow;}
   else if (periode=="1MH"){period=MathCeil(getmonthlyavg()/renko); warna1=Magenta; warna2=Aqua;}
	else{
		Alert("Periode Salah");
		return(0);
	}

    IndicatorBuffers(5);  
    
    SetIndexBuffer(0, Uptrend); 
    ///ArraySetAsSeries(Uptrend, true); 
    SetIndexBuffer(1, Dntrend); 
    ///ArraySetAsSeries(Dntrend, true); 
    SetIndexBuffer(2, ExtMapBuffer);    SetIndexStyle(2,DRAW_NONE);
    ArraySetAsSeries(ExtMapBuffer, true); 
       
    int LNT = DRAW_NONE;    if (ShowLine == true) LNT = DRAW_LINE;   
    SetIndexStyle(0,LNT,Style,Size,warna1);
    SetIndexStyle(1,LNT,Style,Size,warna2);
    
    SetIndexBuffer(3, ArrUp); 
    SetIndexBuffer(4, ArrDn); 
    
    int ART = DRAW_NONE;    if (ShowArrows == true) ART = DRAW_ARROW;    
    SetIndexStyle(3,ART,STYLE_SOLID,arrowsSize,ColorUP); SetIndexArrow(3,arrowsUP);
    SetIndexStyle(4,ART,STYLE_SOLID,arrowsSize,ColorDN); SetIndexArrow(4,arrowsDN);
    
    SetIndexLabel(3,"DOWN");
    SetIndexLabel(4,"UP");
 
    
    IndicatorShortName("Slope Direction Line("+period+")"); 
    //getPeriod();
    return(0); 
} 
 
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit() 
{ 
    return(0); 
} 
 
//+------------------------------------------------------------------+ 
//| ?????????? ???????                                               | 
//+------------------------------------------------------------------+ 
double WMA(int x, int p) 
{ 
    return(iMA(NULL, 0, p, 0, method, price, x));    
} 
 
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start() 
{ 
    int counted_bars = IndicatorCounted(); 
    
    if(counted_bars < 0) 
        return(-1); 
                  
    int x = 0; 
    int p = MathSqrt(period);              
    int e = Bars - counted_bars + period + 1; 
    
    double vect[], trend[]; 
    
    if(e > Bars)    e = Bars;    
 
    ArrayResize(vect, e); 
    ArraySetAsSeries(vect, true);
    ArrayResize(trend, e); 
    ArraySetAsSeries(trend, true); 
    
    for(x = 0; x < e; x++) 
    { 
      vect[x] = 2*WMA(x, period/2) - WMA(x, period);        
    } 
 
    for(x = 0; x < e-period; x++)
     
        ExtMapBuffer[x] = iMAOnArray(vect, 0, p, 0, method, x);        
    
    for(x = e-period; x >= 0; x--) 
  {     
        trend[x] = trend[x+1];    
        if (ExtMapBuffer[x]> ExtMapBuffer[x+1]) trend[x] =1;  
        if (ExtMapBuffer[x]< ExtMapBuffer[x+1]) trend[x] =-1; 
        
          if (Digits == 3 || Digits == 5) int Gap = ArrowsGap*10;
                
            if  (trend[x+1] < 0 && trend[x] > 0)   ArrUp[x+1] = ExtMapBuffer[x+1] - Gap*Point;   else ArrUp[x+1] = EMPTY_VALUE; 
            if  (trend[x+1] > 0 && trend[x] < 0)   ArrDn[x+1] = ExtMapBuffer[x+1] + Gap*Point;   else ArrDn[x+1] = EMPTY_VALUE; 


    if (trend[x]>0)
    { 
     Uptrend[x] = ExtMapBuffer[x]; 
     if (trend[x+1]<0) Uptrend[x+1]=ExtMapBuffer[x+1];
     Dntrend[x] = EMPTY_VALUE;
    }
    
    else if (trend[x]<0)
    { 
     Dntrend[x] = ExtMapBuffer[x]; 
     if (trend[x+1]>0) Dntrend[x+1]=ExtMapBuffer[x+1];
     Uptrend[x] = EMPTY_VALUE;
    }    
   

  }
    
    return(0); 
} 
//+------------------------------------------------------------------+

void getPeriod()
{
   switch(Period()) 
      {
         case 1: 
            period=1440;
            break;
         case 5: 
            period=288;
            break;
         case 15: 
            period=96;
            break;
         case 30: 
            period=48;
            break;
         case 60: 
            period=24;
            break;
         case 240: 
            period=6;
            break;
         case 1440: 
            period=0;
            break;
         case 10080: 
            period=0;
            break;
         case 43200:
            period=0;
            break;
         
      }
 }

double getdailyavg()
{
   double RAvgd;
   double dR1,dR2,dR3,dR4,dR5,dR6,dR7,dR8,dR9,dR10,dR11,dR12,dR13,dR14,dR15,dR16,dR17,dR18,dR19,dR20;

   dR1  = (iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1))/Point;
   dR2  = (iHigh(NULL,PERIOD_D1,2)-iLow(NULL,PERIOD_D1,2))/Point;
   dR3  = (iHigh(NULL,PERIOD_D1,3)-iLow(NULL,PERIOD_D1,3))/Point;
   dR4  = (iHigh(NULL,PERIOD_D1,4)-iLow(NULL,PERIOD_D1,4))/Point;
   dR5  = (iHigh(NULL,PERIOD_D1,5)-iLow(NULL,PERIOD_D1,5))/Point;        
   dR6  = (iHigh(NULL,PERIOD_D1,6)-iLow(NULL,PERIOD_D1,6))/Point;
   dR7  = (iHigh(NULL,PERIOD_D1,7)-iLow(NULL,PERIOD_D1,7))/Point;
   dR8  = (iHigh(NULL,PERIOD_D1,8)-iLow(NULL,PERIOD_D1,8))/Point;
   dR9  = (iHigh(NULL,PERIOD_D1,9)-iLow(NULL,PERIOD_D1,9))/Point;
   dR10 = (iHigh(NULL,PERIOD_D1,10)-iLow(NULL,PERIOD_D1,10))/Point;        
   dR11 = (iHigh(NULL,PERIOD_D1,11)-iLow(NULL,PERIOD_D1,11))/Point;
   dR12 = (iHigh(NULL,PERIOD_D1,12)-iLow(NULL,PERIOD_D1,12))/Point;
   dR13 = (iHigh(NULL,PERIOD_D1,13)-iLow(NULL,PERIOD_D1,13))/Point;
   dR14 = (iHigh(NULL,PERIOD_D1,14)-iLow(NULL,PERIOD_D1,14))/Point;
   dR15 = (iHigh(NULL,PERIOD_D1,15)-iLow(NULL,PERIOD_D1,15))/Point;        
   dR16 = (iHigh(NULL,PERIOD_D1,16)-iLow(NULL,PERIOD_D1,16))/Point;
   dR17 = (iHigh(NULL,PERIOD_D1,17)-iLow(NULL,PERIOD_D1,17))/Point;
   dR18 = (iHigh(NULL,PERIOD_D1,18)-iLow(NULL,PERIOD_D1,18))/Point;
   dR19 = (iHigh(NULL,PERIOD_D1,19)-iLow(NULL,PERIOD_D1,19))/Point;
   dR20 = (iHigh(NULL,PERIOD_D1,20)-iLow(NULL,PERIOD_D1,20))/Point;     
   RAvgd=(dR1+dR2+dR3+dR4+dR5+dR6+dR7+dR8+dR9+dR10+dR11+dR12+dR13+dR14+dR15+dR16+dR17+dR18+dR19+dR20)/20;
   return(RAvgd);
}

double getweeklyavg()
{
   double RAvgw;
   double wR1,wR2,wR3,wR4,wR5,wR6,wR7,wR8,wR9,wR10,wR11,wR12,wR13,wR14,wR15,wR16;

   wR1  = (iHigh(NULL,PERIOD_W1,1)-iLow(NULL,PERIOD_W1,1))/Point;
   wR2  = (iHigh(NULL,PERIOD_W1,2)-iLow(NULL,PERIOD_W1,2))/Point;
   wR3  = (iHigh(NULL,PERIOD_W1,3)-iLow(NULL,PERIOD_W1,3))/Point;
   wR4  = (iHigh(NULL,PERIOD_W1,4)-iLow(NULL,PERIOD_W1,4))/Point;
   wR5  = (iHigh(NULL,PERIOD_W1,5)-iLow(NULL,PERIOD_W1,5))/Point;         
   wR6  = (iHigh(NULL,PERIOD_W1,6)-iLow(NULL,PERIOD_W1,6))/Point;
   wR7  = (iHigh(NULL,PERIOD_W1,7)-iLow(NULL,PERIOD_W1,7))/Point;
   wR8  = (iHigh(NULL,PERIOD_W1,8)-iLow(NULL,PERIOD_W1,8))/Point;
   wR9  = (iHigh(NULL,PERIOD_W1,9)-iLow(NULL,PERIOD_W1,9))/Point;
   wR10 = (iHigh(NULL,PERIOD_W1,10)-iLow(NULL,PERIOD_W1,10))/Point;         
   wR11 = (iHigh(NULL,PERIOD_W1,11)-iLow(NULL,PERIOD_W1,11))/Point;
   wR12 = (iHigh(NULL,PERIOD_W1,12)-iLow(NULL,PERIOD_W1,12))/Point;
   wR13 = (iHigh(NULL,PERIOD_W1,13)-iLow(NULL,PERIOD_W1,13))/Point;
   wR14 = (iHigh(NULL,PERIOD_W1,14)-iLow(NULL,PERIOD_W1,14))/Point;
   wR15 = (iHigh(NULL,PERIOD_W1,15)-iLow(NULL,PERIOD_W1,15))/Point;         
   wR16 = (iHigh(NULL,PERIOD_W1,16)-iLow(NULL,PERIOD_W1,16))/Point;

   RAvgw=(wR1+wR2+wR3+wR4+wR5+wR6+wR7+wR8+wR9+wR10+wR11+wR12+wR13+wR14+wR15+wR16)/16;
   return(RAvgw);
}

double getmonthlyavg()
{
   double RAvgm;
   double mR1,mR2,mR3,mR4,mR5,mR6,mR7,mR8,mR9,mR10,mR11,mR12;

   mR1  = (iHigh(NULL,PERIOD_MN1,1)-iLow(NULL,PERIOD_MN1,1))/Point;
   mR2  = (iHigh(NULL,PERIOD_MN1,2)-iLow(NULL,PERIOD_MN1,2))/Point;
   mR3  = (iHigh(NULL,PERIOD_MN1,3)-iLow(NULL,PERIOD_MN1,3))/Point;
   mR4  = (iHigh(NULL,PERIOD_MN1,4)-iLow(NULL,PERIOD_MN1,4))/Point;
   mR5  = (iHigh(NULL,PERIOD_MN1,5)-iLow(NULL,PERIOD_MN1,5))/Point;         
   mR6  = (iHigh(NULL,PERIOD_MN1,6)-iLow(NULL,PERIOD_MN1,6))/Point;
   mR7  = (iHigh(NULL,PERIOD_MN1,7)-iLow(NULL,PERIOD_MN1,7))/Point;
   mR8  = (iHigh(NULL,PERIOD_MN1,8)-iLow(NULL,PERIOD_MN1,8))/Point;
   mR9  = (iHigh(NULL,PERIOD_MN1,9)-iLow(NULL,PERIOD_MN1,9))/Point;
   mR10 = (iHigh(NULL,PERIOD_MN1,10)-iLow(NULL,PERIOD_MN1,10))/Point;         
   mR11 = (iHigh(NULL,PERIOD_MN1,11)-iLow(NULL,PERIOD_MN1,11))/Point;
   mR12 = (iHigh(NULL,PERIOD_MN1,12)-iLow(NULL,PERIOD_MN1,12))/Point;

   RAvgm=(mR1+mR2+mR3+mR4+mR5+mR6+mR7+mR8+mR9+mR10+mR11+mR12)/12;
   return(RAvgm);
}