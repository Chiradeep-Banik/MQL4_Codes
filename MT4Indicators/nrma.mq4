//+------------------------------------------------------------------+
//|                                                         NRMA.mq4 |
//|                                                             Rosh |
//|                                  http://konkop.narod.ru/nrma.htm |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Gold

//---- input parameters
extern double    K=1;
extern int       Smooth=3;
extern double       Fast=2;
extern double       Sharp=2;
//---- buffers
double ExtMapBuffer1[];

double HPrice[];
double LPrice[];
double NRTR[];
double Trend[];
double Oscil[];
double NRatio[];
//-----

double F;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(7);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,3);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"NRMA");

   SetIndexBuffer(1,NRTR);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,108);
   SetIndexLabel(1,"NRTR");
   
   SetIndexBuffer(2,LPrice);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,158);
   SetIndexLabel(2,"LPrice");

   SetIndexBuffer(3,HPrice);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,158);
   SetIndexLabel(3,"HPrice");

   SetIndexBuffer(4,Trend);
   SetIndexBuffer(5,Oscil);
   SetIndexBuffer(6,NRatio);

   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);   
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
   //SetIndexEmptyValue(0,0.0);
   F=2/(1.0+Fast);    //было  F=1/(2.0+Fast);
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
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int i;
//----
   int limit,limit2;
   if (counted_bars==0) limit=Bars;
   if (counted_bars>0) limit=Bars-counted_bars;
   limit--;

   if (counted_bars==0) //
      {
      if (Close[limit]>Open[limit]) 
         {
         Trend[limit]=1.0; 
         LPrice[limit]=NormalizeDouble(Close[limit]*(1.0-K*0.01),Digits);
         HPrice[limit]=0.0;
         NRTR[limit]=LPrice[limit];
         }
      else 
         {
         Trend[limit]=-1.0;
         HPrice[limit]=NormalizeDouble(Close[limit]*(1.0+K*0.01),Digits);
         LPrice[limit]=0.0;
         NRTR[limit]=HPrice[limit];
         }
      for(i=limit;i>limit-100;i--) ExtMapBuffer1[i]=Close[i];   
      limit--;   
      }   
   for (i=limit;i>=0;i--)
      {
      if (Trend[i+1]>0)
         {
         if (Close[i]<NRTR[i+1])
            {
            Trend[i]=-1.0;
            HPrice[i]=NormalizeDouble(Close[i]*(1.0+K*0.01),Digits);
            LPrice[i]=0.0;
            NRTR[i]=HPrice[i];
            }
         else
            {
            Trend[i]=1.0;
            LPrice[i]=NormalizeDouble(Close[i]*(1.0-K*0.01),Digits);
            HPrice[i]=0.0;
            if (LPrice[i]>NRTR[i+1]) NRTR[i]=LPrice[i]; else NRTR[i]=NRTR[i+1];            
            }   
         }
      else
         {
         if (Close[i]>NRTR[i+1])
            {
            Trend[i]=1.0;
            LPrice[i]=NormalizeDouble(Close[i]*(1.0-K*0.01),Digits);
            HPrice[i]=0.0;
            NRTR[i]=LPrice[i];
            }
         else
            {
            Trend[i]=-1.0;
            HPrice[i]=NormalizeDouble(Close[i]*(1.0+K*0.01),Digits);
            LPrice[i]=0.0;
            if (HPrice[i]<NRTR[i+1]) NRTR[i]=HPrice[i];  else NRTR[i]=NRTR[i+1];            
            }   
         }    
      //if (Trend[i]!=Trend[i+1])Print("Trend[",i,"]=",Trend[i]);
      }   

   for (i=limit;i>=0;i--)
      {
      Oscil[i]=(100.0*MathAbs(Close[i]-NRTR[i])/Close[i])/K;
      }

   for (i=limit;i>=0;i--)
      {
      NRatio[i]=MathPow(iMAOnArray(Oscil,0,Smooth,0,MODE_SMA,i),Sharp);
      }
      
   for (i=limit;i>=0;i--)
      {
      ExtMapBuffer1[i]=ExtMapBuffer1[i+1]+NRatio[i]*F*(Close[i]-ExtMapBuffer1[i+1]);
      }
      
//----
   return(0);
  }
//+------------------------------------------------------------------+