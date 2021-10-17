//+------------------------------------------------------------------+
//|                                          Jays Candle Display.mq4 |
//|                                                        Oje Uadia |
//|                                         moneyinthesack@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Oje Uadia"
#property link      "moneyinthesack@yahoo.com"

#property indicator_separate_window
//---- input parameters
extern int candleshift=0;
extern color     swing_colour=MediumPurple;
extern color     body_colour=DarkOrchid;
string shortname= "Jays Candle Display";
int myspace;
string timetxt[6]={"M1","M5","M30","H1","H4","D1"}; //6
int times [6]={1,15,30,60,240,1440};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorShortName(shortname);
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
  myspace= WindowFind(shortname);
   int    counted_bars=IndicatorCounted();
static bool alreadydrawn = false;
if (alreadydrawn==false)
{
//-------------------------------------------------------------------------------------------------------
// create body and swing
//-------------------------------------------------------------------------------------------------------
ObjectCreate("bodytxt",OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("bodytxt",OBJPROP_XDISTANCE,10);
ObjectSet("bodytxt",OBJPROP_YDISTANCE,25);
ObjectSetText("bodytxt","Body",11,"Times New Roman",LightGoldenrod); //--done body--//

ObjectCreate("swingtxt",OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("swingtxt",OBJPROP_XDISTANCE,10);
ObjectSet("swingtxt",OBJPROP_YDISTANCE,45);
ObjectSetText("swingtxt","SwinG",11,"Times New Roman",LightGoldenrod); //--done swing--//

//----------------------------------------------------------------------------------------------------
// cycle for timeframe texts
//---------------------------------------------------------------------------------------------------

for (int x=0;x<6;x++)
{
ObjectCreate("timenames"+x,OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("timenames"+x,OBJPROP_XDISTANCE,(x*80)+100);
ObjectSet("timenames"+x,OBJPROP_YDISTANCE,14);
ObjectSetText("timenames"+x,timetxt[x],7,"Times New Roman",LightGoldenrod); 
}   //--done timeframes--//

//---------------------------------------------------------------------------------------------
// cycle for body pips
//---------------------------------------------------------------------------------------------

for (x=0;x<6;x++)
{
ObjectCreate("bodypips"+x,OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("bodypips"+x,OBJPROP_XDISTANCE,(x*80)+100);
ObjectSet("bodypips"+x,OBJPROP_YDISTANCE,25);
ObjectSetText("bodypips"+x,CharToStr(54),9,"Wingdings",LightGoldenrod); 
} //--done body pips--//

//---------------------------------------------------------------------------------------------------
// cycle for swing pips
//--------------------------------------------------------------------------------------------------
for (x=0;x<6;x++)
{
ObjectCreate("swingpips"+x,OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("swingpips"+x,OBJPROP_XDISTANCE,(x*80)+100);
ObjectSet("swingpips"+x,OBJPROP_YDISTANCE,45);
ObjectSetText("swingpips"+x,CharToStr(54),9,"Wingdings",LightGoldenrod); 
} //-- done swing pips--//


}//---- end of already drawn code


//--------------------------------------------------------------------------------------------------------
// main calculation section
//--------------------------------------------------------------------------------------------------------

for (x=0;x<6;x++)
{
double open = iOpen(Symbol(),times[x],candleshift);
double close = iClose(Symbol(),times[x],candleshift);
double top = iHigh(Symbol(),times[x],candleshift);
double bottom= iLow(Symbol(),times[x],candleshift);
double swingvalue = top - bottom;
double bodyvalue = open - close;
if (bodyvalue>0)
{
ObjectSetText("bodypips"+x,DoubleToStr(bodyvalue,Digits),9,"Times New Roman",Red);
}
else
if (bodyvalue<0)
{
ObjectSetText("bodypips"+x,DoubleToStr(MathAbs(bodyvalue),Digits),9,"Times New Roman",LimeGreen);
}


ObjectSetText("swingpips"+x,DoubleToStr(swingvalue,Digits),9,"Times New Roman",MediumPurple);

}//-- done main calculation--//
   return(0);
  }
//+------------------------------------------------------------------+