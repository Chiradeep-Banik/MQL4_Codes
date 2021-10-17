//+------------------------------------------------------------------+
//| DL_TRIX.mq4 |
//| Douglas Lozada |
//| http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright ""
#property link ""
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int Periodo = 12;
extern int Signal = 9 ;
//extern int Desplazar = 1;
//---- buffers
double TRIX_Buffer[];
double Signal_Buffer[];
double EMA1_buffer[];
double EMA2_buffer[];
double EMA3_buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- 3 additional buffers are used for counting.
IndicatorBuffers(5);
SetIndexBuffer(2,EMA1_buffer);
SetIndexBuffer(3,EMA2_buffer);
SetIndexBuffer(4,EMA3_buffer);

//---- indicators - drawing settings
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,TRIX_Buffer);
SetIndexStyle(1,DRAW_LINE);
SetIndexDrawBegin(1,Signal);
SetIndexBuffer(1,Signal_Buffer);


//---- name for DataWindow and indicator subwindow label
IndicatorShortName("TRIX("+Periodo+","+Signal+")");
SetIndexLabel(0,"Trix");
SetIndexLabel(1,"Signal");

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//---- 

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
int i,limit;
int counted_bars=IndicatorCounted();

//---- check for possible errors
if(counted_bars<0) return(-1);

if(Bars<=Periodo) return(0);
//---- initial zero
if(counted_bars<1)
{
for(i=1;i<=Periodo;i++) TRIX_Buffer[Bars-i]=0.0;
for(i=1;i<=Periodo;i++) Signal_Buffer[Bars-i]=0.0;
for(i=1;i<=Periodo;i++) EMA1_buffer[Bars-i]=0.0;
for(i=1;i<=Periodo;i++) EMA2_buffer[Bars-i]=0.0;
for(i=1;i<=Periodo;i++) EMA3_buffer[Bars-i]=0.0;
}

//---- last counted bar will be recounted
if(counted_bars>0) counted_bars--;
limit=Bars-counted_bars;

//---- Calculo el EMA1
for(i=0; i<limit; i++)
EMA1_buffer[i]=iMA(NULL,0,Periodo,0,MODE_EMA,PRICE_CLOSE,i);
for(i=0; i<limit; i++)
EMA2_buffer[i]=iMAOnArray(EMA1_buffer,Bars,Periodo,0,MODE_EMA,i);
for(i=0; i<limit; i++)
EMA3_buffer[i]=iMAOnArray(EMA2_buffer,Bars,Periodo,0,MODE_EMA,i);

// for(i=0; i<limit; i++) 
// TRIX_Buffer[i] = EMA3_buffer[i];
for(i=0; i<limit-1; i++)
TRIX_Buffer[i] = (EMA3_buffer[i] - EMA3_buffer[i+1]) / EMA3_buffer[i+1] *100;

//---- signal line counted in the 2-nd buffer
for(i=0; i<limit-1; i++)
Signal_Buffer[i]=iMAOnArray(TRIX_Buffer,Bars,Signal,0,MODE_SMA,i);

//---- done
return(0);
}
//+------------------------------------------------------------------+ 