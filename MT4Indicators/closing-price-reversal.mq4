#property copyright "Copyright © 2016, Crossluck"
#property version "1.00"
#property description "Closing Price Reversal"
//-----------------------------------------------------------------------------------------------------------------------------//
#property strict
//-----------------------------------------------------------------------------------------------------------------------------//
#property indicator_chart_window
#property indicator_buffers 2
//-----------------------------------------------------------------------------------------------------------------------------//
extern string S1="Настройки графики";
extern bool ClearAllObjects=true;//Удалить все объекты
extern ENUM_TIMEFRAMES timeframe=0;//мульти-фильтр
extern int CountedBars=10000;//Пересчёт баров
extern int SizeUPARROW=1;//Размер верхней стрелки
extern int SizeDOWNARROW=1;//Размер нижней стрелки
extern color ColorUPARROW=Green;//Цвет верхней стрелки
extern color ColorDOWNARROW=Red;//Цвет верхней стрелки
extern int CodeUPARROW=108;//Код верхней стрелки
extern int CodeDOWNARROW=108;//Код нижней стрелки
extern string S2="Настройки звука";
extern string SoundFile="alert.wav";//Звуковой файл
extern bool UseSound=true;//Использование звука
//-----------------------------------------------------------------------------------------------------------------------------//
string LF="\n";
//-----------------------------------------------------------------------------------------------------------------------------//
int ObjCount=0;
int current=0;
//-----------------------------------------------------------------------------------------------------------------------------//
double up[];
double down[];
//-----------------------------------------------------------------------------------------------------------------------------//
bool soundbuy=false;
bool soundsell=false;
bool buy=false,sell=false;
bool buy_2=false,sell_2=false;
//-----------------------------------------------------------------------------------------------------------------------------//
int init()
{
if(ClearAllObjects)ObjectsDeleteAll();
IndicatorShortName("CPR");
IndicatorDigits(5);
IndicatorBuffers(2);
SetIndexBuffer(0,up);
SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,SizeUPARROW,ColorUPARROW);
SetIndexArrow(0,CodeUPARROW);
SetIndexBuffer(1,down);
SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,SizeDOWNARROW,ColorDOWNARROW);
SetIndexArrow(1,CodeDOWNARROW);
return(0);
}
//-----------------------------------------------------------------------------------------------------------------------------//
int deinit()
{
if(ClearAllObjects)ObjectsDeleteAll();
return(0);
}
//-----------------------------------------------------------------------------------------------------------------------------//
int start()
{
Tick();
return(0);
}
//-----------------------------------------------------------------------------------------------------------------------------//
void Tick()
{
if(CountedBars>=Bars)CountedBars=Bars-3;
for(int i=CountedBars;i>=0;i--)
{
globalTrend(i);
current=i;
up();
down();
}
}
void globalTrend(int currents){
   if(!buy && iOpen(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+2)
      >(iClose(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+2))
      &&(iOpen(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+1)
      <(iClose(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+1))
      &&(iOpen(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+1))
      <(iClose(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+2))
      &&(iClose(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+1)
      >(iLow(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+2))))){
      buy=true;sell=false;
   }
   if(!sell && iOpen(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+2)
      <(iClose(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+2))
      &&(iOpen(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+1)
      >(iClose(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+1))
      &&(iOpen(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+1))
      >(iClose(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+2))
      &&(iClose(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+1)
      <(iHigh(_Symbol,timeframe,iBarShift(_Symbol,timeframe,Time[currents])+2))))){
      buy=false;sell=true;
   }      
}
//-----------------------------------------------------------------------------------------------------------------------------//
void up()
{
if(buy_2==false)
if(buy&&Open[current+2]>(Close[current+2])
&&
Open[current+3]>(Close[current+3])
&&
Open[current+1]<(Close[current+2])
&&
Open[current+1]<(Close[current+1])
&&
Close[current+1]>(Low[current+2]))
{
arrow_up();
}
}
void arrow_up()
{
up[current]=Low[current]-50*Point();
buy_2=true;
sell_2=false;
}
//-----------------------------------------------------------------------------------------------------------------------------//
void down()
{
if(sell_2==false)
if(sell&&Open[current+2]<(Close[current+2])
&&
Open[current+3]<(Close[current+3])
&&
Open[current+1]>(Close[current+2])
&&
Open[current+1]>(Close[current+1])
&&
Close[current+1]<(High[current+2]))
{
arrow_down();
}
}
void arrow_down()
{
down[current]=High[current]+50*Point();
buy_2=false;
sell_2=true;
//-----------------------------------------------------------------------------------------------------------------------------//
if(up[0]!=EMPTY_VALUE&&up[0]!=0&&soundbuy)
{
soundbuy=false;
if(UseSound)PlaySound(SoundFile);
Alert("(CPR)" " Поступил сигнал на покупку по символу " + Symbol() + ", на тайм-фрейме " + (string)Period() + " мин.," + " по цене " + (string)Bid); 
}
if(!soundbuy&&(up[0]==EMPTY_VALUE||up[0]==0))soundbuy=true;
//-----------------------------------------------------------------------------------------------------------------------------//
if(down[0]!=EMPTY_VALUE&&down[0]!=0&&soundsell)
{
soundsell=false;
if(UseSound)PlaySound(SoundFile);
Alert("(CPR)" " Поступил сигнал на продажу по символу " + Symbol()+ ", на тайм-фрейе " + (string)Period() + " мин.," + " по цене " + (string)Bid);
}
if(!soundsell&&(down[0]==EMPTY_VALUE||down[0]==0))soundsell=true;
//-----------------------------------------------------------------------------------------------------------------------------//
}