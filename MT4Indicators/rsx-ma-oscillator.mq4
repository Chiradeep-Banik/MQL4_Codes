//+------------------------------------------------------------------+
//|                                                       RSX_MA.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Red

#property indicator_level1 0
#property indicator_levelcolor SteelBlue
//---- input parameters
extern int       Lengh=14;
extern int   CountBars=300;
extern int MaType = MODE_SMA;
extern int MaPeriod = 8;
//---- buffers
double rsx[];
double ExtMapBuffer1[];

int    shift,r,w,k,counted_bars,T0,T1,Tnew;
//----
double v4,v8,v10,v14,v18,v20,v0C,v1C,v8A,minuse;
double F28,F30,F38,F40,F48,F50,F58,F60,F68,F70,F78,F80,JRSX;
double f0,f28,f30,f38,f40,f48,f50,f58,f60,f68,f70,f78,f80,Kg,Hg;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexBuffer(0,rsx);
   
  
   SetIndexStyle(1,DRAW_LINE,0,1);

   SetIndexBuffer(1,ExtMapBuffer1);
   SetIndexEmptyValue(1,0.0);

   
   IndicatorShortName("RSX_MA");
   SetIndexDrawBegin(0,Bars-CountBars);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//----  
   if (Lengh-1>=5) w=Lengh-1; else w=5; Kg=3/(Lengh+2.0); Hg=1.0-Kg;
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
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    k,i,pos1,pos2,pos3,pos4;
   double rsi1,rsi2,rsi3,vol1,vol2,vol3,vol4;
   
   counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   if (counted_bars>Lengh) shift=Bars-counted_bars-1;
   else shift=Bars-Lengh-1;
//----
   Tnew=Time[shift+1];
   //---- восстановление переменных -------
   if((Tnew!=T0)&&(shift<Bars-Lengh-1))
     {
      if (Tnew==T1)
        {
         f28=F28; f30=F30; f38=F38; f40=F40; f48=F48; f50=F50;
         f58=F58; f60=F60; f68=F68; f70=F70; f78=F78; f80=F80;
        } else return(-1);
     }
//----
   if (Lengh-1>=5)w=Lengh-1;else w=5; Kg=3/(Lengh+2.0); Hg=1.0-Kg;
   while(shift>=0)
     {
      //+-------------------+
      if (r==0){r=1; k=0;}
      else
        {
         //----
         if (r>=w) r=w+1; else r=r+1;
         v8=Close[shift]-Close[shift+1]; v8A=MathAbs(v8);
         //---- вычисление V14 ------
         f28=Hg  * f28 + Kg  *  v8;
         f30=Kg  * f28 + Hg  * f30;
         v0C=1.5 * f28 - 0.5 * f30;
         f38=Hg  * f38 + Kg  * v0C;
         f40=Kg  * f38 + Hg  * f40;
         v10=1.5 * f38 - 0.5 * f40;
         f48=Hg  * f48 + Kg  * v10;
         f50=Kg  * f48 + Hg  * f50;
         v14=1.5 * f48 - 0.5 * f50;
         //---- вычисление V20 ------
         f58=Hg  * f58 + Kg  * v8A;
         f60=Kg  * f58 + Hg  * f60;
         v18=1.5 * f58 - 0.5 * f60;
         f68=Hg  * f68 + Kg  * v18;
         f70=Kg  * f68 + Hg  * f70;
         v1C=1.5 * f68 - 0.5 * f70;
         f78=Hg  * f78 + Kg  * v1C;
         f80=Kg  * f78 + Hg  * f80;
         v20=1.5 * f78 - 0.5 * f80;
         //----
         if ((r<=w) && (v8!= 0)) k=1;
         if ((r==w) && (k==0)) r=0;
        }//-----
      if ((r>w)&&(v20>0.0000000001))
      {
        v4=(v14/v20+1.0)*50.0;
      /*if(v4>100.0)
      v4=100.0;
      if(v4<0.0)
      v4=0.0;*/
      }
      else 
      v4=50.0;
      rsx[shift]=(v4/50)-1;
      if (shift==1)
        {
         T1=Time[1];T0=Time[0];
         F28=f28; F30=f30; F38=f38; F40=f40; F48=f48; F50=f50;
         F58=f58; F60=f60; F68=f68; F70=f70; F78=f78; F80=f80;
        }
      
           
   shift--;
   ArraySetAsSeries(rsx,true);
   }
      
   for(int j=0; j<CountBars-MaPeriod; j++) 
   {
   ExtMapBuffer1[j] = iMAOnArray(rsx,Bars,MaPeriod,0,MaType,j);
   }
   return(0);
  }

