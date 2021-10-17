#property copyright ""
#property version ""
#property description ""
//-----------------------------------------------------------------------------------------------------------------------------//
#property strict
//-----------------------------------------------------------------------------------------------------------------------------//
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrGreenYellow
#property indicator_width1 1
#property indicator_color2 clrIndianRed
#property indicator_width2 1
//-----------------------------------------------------------------------------------------------------------------------------//
extern string S1="Настройки ADX";
extern int period=14;//Период
extern ENUM_APPLIED_PRICE applied_price=1;//Применить к
extern int trend_strength=20;//Сила тренда
extern string S2="Настройки Moving Average";
extern int ma_period=14;//Период
extern int ma_shift=0;//Сдвиг
extern ENUM_MA_METHOD ma_method=2;//Метод МА
extern ENUM_APPLIED_PRICE ma_applied_price=1;//Применить к
extern string S3="Настройки графики";
extern bool ClearAllObjects=true;//Удалить все объекты
extern int CountedBars=1000;//Пересчёт баров
extern int ArrowsIndent=50;//Отступ стрелок
extern string S4="Настройки звука";
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
bool buy=false;
bool sell=false;
bool sBuy=false;
bool sSell=false;
//-----------------------------------------------------------------------------------------------------------------------------//
int init()
{
if(ClearAllObjects)ObjectsDeleteAll();
IndicatorShortName("A.D.M.I.");
IndicatorDigits(5);
IndicatorBuffers(2);
SetIndexBuffer(0,up);
SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID);
SetIndexArrow(0,225);
SetIndexBuffer(1,down);
SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID);
SetIndexArrow(1,226);
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
for(int i=CountedBars;i>=0;i--)
{
current=i;
up();
down();
}
}
//-----------------------------------------------------------------------------------------------------------------------------//
void up()
{
if(buy==false)
if(iADX(NULL,PERIOD_CURRENT,period,applied_price,MODE_PLUSDI,current)>iADX(NULL,PERIOD_CURRENT,period,applied_price,MODE_MINUSDI,current)
&&
(iADX(NULL,PERIOD_CURRENT,period,applied_price,MODE_MAIN,current)>=trend_strength)
&&
(Open[current]>iMA(NULL,PERIOD_CURRENT,ma_period,ma_shift,ma_method,ma_applied_price,current)
&&
(iMA(NULL,PERIOD_CURRENT,ma_period,ma_shift,ma_method,ma_applied_price,current)>(iMA(NULL,PERIOD_CURRENT,ma_period,ma_shift,ma_method,ma_applied_price,current+1)))))
{
arrows_up();
}
}
void arrows_up()
{
up[current]=Low[current]-ArrowsIndent*Point();
buy=true;
sell=false;
}
//-----------------------------------------------------------------------------------------------------------------------------//
void down()
{
if(sell==false)
if(iADX(NULL,PERIOD_CURRENT,period,applied_price,MODE_PLUSDI,current)<iADX(NULL,PERIOD_CURRENT,period,applied_price,MODE_MINUSDI,current)
&&
(iADX(NULL,PERIOD_CURRENT,period,applied_price,MODE_MAIN,current)>=trend_strength)
&&
(Open[current]<iMA(NULL,PERIOD_CURRENT,ma_period,ma_shift,ma_method,ma_applied_price,current)
&&
(iMA(NULL,PERIOD_CURRENT,ma_period,ma_shift,ma_method,ma_applied_price,current)<(iMA(NULL,PERIOD_CURRENT,ma_period,ma_shift,ma_method,ma_applied_price,current+1)))))

{
arrows_down();
}
}
void arrows_down()
{
down[current]=High[current]+ArrowsIndent*Point();
buy=false;
sell=true;
//-----------------------------------------------------------------------------------------------------------------------------//
if(up[0]!=EMPTY_VALUE&&up[0]!=0&&sBuy)
{
sBuy=false;
if(UseSound)PlaySound(SoundFile);
Alert("(A.D.M.I.)" " Поступил сигнал на покупку по символу " + Symbol() + ", на тайм-фрейме " + (string)Period() + " минут," + " по цене " + (string)Bid); 
}
if(!sBuy&&(up[0]==EMPTY_VALUE||up[0]==0))sBuy=true;
//-----------------------------------------------------------------------------------------------------------------------------//
if(down[0]!=EMPTY_VALUE&&down[0]!=0&&sSell)
{
sSell=false;
if(UseSound)PlaySound(SoundFile);
Alert("(A.D.M.I.)" " Поступил сигнал на продажу по символу " + Symbol()+ ", на тайм-фрейе " + (string)Period() + " минут," + " по цене " + (string)Bid);
}
if(!sSell&&(down[0]==EMPTY_VALUE||down[0]==0))sSell=true;
}
//-----------------------------------------------------------------------------------------------------------------------------//