//2009.12.21
//+------------------------------------------------------------------+
//| Oscillator squeaker! ;stochastic based.
//+------------------------------------------------------------------+
#property copyright ""
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Lavender
#property indicator_color4 Linen
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_level1 0.0
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelcolor Black
#property indicator_maximum 1
#property indicator_minimum -1
//---- buffers
double BufS[];
double BufL[];
double BufQ[];
double Bufq[];
//---- parameters
extern int Kperiod=50;
extern int Dperiod=3;
extern int Slowing=3;
extern int Method=0;//0:SMA,1:EMA,2:SMMA,3:LWMA
extern int Price_field=1;//0:Low-High,1:Close-Close
extern int Mode=0;//0:main,1:signal
//+------------------------------------------------------------------+
//| init
//+------------------------------------------------------------------+
int init()
{
	switch(Method)
	{
		case 0:string method="SMA";break;
		case 1:method="EMA";break;
		case 2:method="SMMA";break;
		case 3:method="LWMA";break;
	}
	switch(Price_field)
	{
		case 0:string pf="(Lo/Hi)";break;
		case 1:pf="(Close)";break;
	}
	switch(Mode)
	{
		case 0:string mode="MODE_MAIN";break;
		case 1:mode="MODE_SIGNAL";break;
	}
	IndicatorShortName("squeak!_Stochastic("+Kperiod+","+Dperiod+","+Slowing+")"+method+pf+mode);
	//IndicatorBuffers(3);
	SetIndexBuffer(0,BufS);SetIndexLabel(0,"sq?Bear");SetIndexStyle(0,DRAW_HISTOGRAM);
	SetIndexBuffer(1,BufL);SetIndexLabel(1,"sq?Bull");SetIndexStyle(1,DRAW_HISTOGRAM);
	SetIndexBuffer(2,BufQ);SetIndexLabel(2,NULL);SetIndexStyle(2,DRAW_HISTOGRAM);
	SetIndexBuffer(3,Bufq);SetIndexLabel(3,NULL);SetIndexStyle(3,DRAW_HISTOGRAM);
	return(0);
}
//+------------------------------------------------------------------+
//| start
//+------------------------------------------------------------------+
int start()
{
	static double Buf=0.0;
	int cntbar=IndicatorCounted();
	if(Volume[0]==1)cntbar=0;
	int limit=Bars-cntbar;
	if(cntbar==0){limit-=Kperiod+Dperiod+Slowing+1;BufL[limit+1]=0;BufS[limit+1]=0;}
	for(int i=limit;i>=0;i--)
	{
		BufL[i]=EMPTY_VALUE;BufS[i]=EMPTY_VALUE;BufQ[i]=EMPTY_VALUE;Bufq[i]=EMPTY_VALUE;
		double bs0=iStochastic(NULL,0,Kperiod,Dperiod,Slowing,Method,Price_field,Mode,i);
		double bs1=iStochastic(NULL,0,Kperiod,Dperiod,Slowing,Method,Price_field,Mode,i+1);
		double c0=Close[i],c1=Close[i+1];
		double k=(c0-c1)/Point,kk=(bs0-bs1),kkk=k*kk,kkkk;
		if(kkk>0){if(k<0)kkk*=-1;if(MathAbs(kkk)>100)kkk/=100;kkkk=kkk/100.0+1/kkk;}else{kkk=0;}
		if(kkk>0)
		{
			if(Buf<=0)
			{
				if(kkk>-Buf){BufL[i]=kkkk;Buf=kkk;}
			}
			else
			{BufL[i]=kkkk;Buf=kkk;}
		}
		else if(kkk<0)
		{
			if(Buf>=0)
			{
				if(kkk<-Buf){BufS[i]=kkkk;Buf=kkk;}
			}
			else
			{BufS[i]=kkkk;Buf=kkk;}
		}
		else
		{BufL[i]=BufL[i+1];BufS[i]=BufS[i+1];}
		//*
		if(BufL[i]==EMPTY_VALUE&&BufS[i]==EMPTY_VALUE)
		{
			kkk=Buf/100+1/Buf;
			if(kkk>0)BufQ[i]=kkk;else Bufq[i]=kkk;
		}
	}
   return(0);
}
//+------------------------------------------------------------------+