//--  Original Author : yangshu --//
//--  copyright YangShu 2011    --//
//--  Email:yangshu@yangshu.net --//
//--  Web: http://yangshu.net   --//
#property copyright "" 
#property link      "http://yangshu.net" 

#property indicator_chart_window 
#property indicator_buffers 3 
#property indicator_color1 Teal
#property indicator_style1 2
#property indicator_color2 DodgerBlue
#property indicator_color3 Red  
//---- input parameters 
extern int period=34; 
extern int TimeWindow=34;
extern int Sensitive=8;
int        method=3;                         // MODE_SMA 
int        price=0;                          // PRICE_CLOSE 
double ExtMapBuffer[]; 
double buf1[];
double buf2[];

int init() 
{ 
    IndicatorBuffers(3);  
    SetIndexBuffer(0,ExtMapBuffer); 
    ArraySetAsSeries(ExtMapBuffer, true); 
    SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
    IndicatorShortName("YangTraderMain"); 
   
   int  draw;
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,233);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,234);
   SetIndexEmptyValue(1,0.0);
   SetIndexDrawBegin(1,draw);
   SetIndexDrawBegin(2,draw);
   SetIndexBuffer(1,buf1);
   SetIndexBuffer(2,buf2);
  
  return(0); 
} 

double WMA(int x, int p) 
{ 
    return(iMA(NULL, 0, p, 0, method, price, x));    
} 

int start() 
{ 
    int counted_bars = IndicatorCounted(); 
    if(counted_bars < 0) return(-1); 
    int x = 0; 
    int p = MathSqrt(period);              
    int e = Bars - counted_bars + period + 1; 
    double vect[]; 
    if(e > Bars) e = Bars;    
    ArrayResize(vect, e); 
    ArraySetAsSeries(vect, true);
    for(x = 0; x < e; x++) 
        vect[x] = 2*WMA(x, period/2) - WMA(x, period);        
    for(x = 0; x < e-period; x++)
        ExtMapBuffer[x] = iMAOnArray(vect, 0, p, 0, method, x);        

   //Begin draw Buy or Sell arrow
   int vv=Bars-IndicatorCounted();
   for(int i=0; i<vv; i++)
   {
    double sg1 = iCustom(NULL,0,"YangTrader",TimeWindow,Sensitive,0,i);
    double sg2 = iCustom(NULL,0,"YangTrader",TimeWindow,Sensitive,0,i+1);
     if (sg1>15 && sg2<15)
      buf1[i] = Low[i+1]-15*Point;
     
     if (sg1<80 && sg2>=80)
      buf2[i] = High[i+1]+15*Point;
   }  

  return(0); 
} 