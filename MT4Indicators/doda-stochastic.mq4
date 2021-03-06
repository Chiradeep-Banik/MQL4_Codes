#include <stdlib.mqh>

//+------------------------------------------------------------------+
//|                                              Doda-Stochastic.mq4 |
//|                             Copyright ? 2010, Gopal Krishan Doda |
//|                                        http://www.DodaCharts.com |
//|                                     http://www.InvestmentKit.com |
//|This is version 1.0 of Doda-Stochastic indicator                  |
//|Last Modified on 08-Mar-2011                                      |
//| I'm not the original coder. Just modified for screen alert.      |
//+------------------------------------------------------------------+


// This was converted using YouSky's MT3 to MT4 translator.  I cannot take credit for the code.//

#property indicator_separate_window
#property indicator_minimum 0.00
#property indicator_maximum 100.00
#property indicator_color1 Lime
#property indicator_buffers 2
#property indicator_color2 Red
#property indicator_level1 20
#property indicator_level2 80

//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| External variables                                               |
//+------------------------------------------------------------------+
extern double Slw = 8;
extern double Pds = 13;
extern double Slwsignal = 9;
extern int    Barcount = 2000;

//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+

int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];
bool BuyAlert=false, SellAlert=false;

void SetLoopCount(int loops)
{
}

void SetIndexValue(int shift, double value)
{
  ExtHistoBuffer[shift] = value;
//  Print ("ExtHistoBuffer :" ,value);    // green
}

void SetIndexValue2(int shift, double value)
{
  ExtHistoBuffer2[shift] = value;
//  Print ("ExtHistoBuffer2 :" ,value);    // green
}

double GetIndexValue(int shift)
{
  return(ExtHistoBuffer[shift]);
}

double GetIndexValue2(int shift)
{
  return(ExtHistoBuffer2[shift]);
}

//+------------------------------------------------------------------+
//| End                                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+

int init()
{
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0, ExtHistoBuffer);

   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(1, ExtHistoBuffer2);

   
    
   return(0);
}
int start()
{
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
double AA = 0;
double bb = 0;
double aa1 = 0;
double cnt1 = 0;
int shift = 0;
double cnt = 0;
double loopbegin = 0;
double loopbegin2 = 0;
double loopbegin3 = 0;
bool first = True;
double prevbars = 0;
double sum = 0;
double smconst = 0;
double smconst1 = 0;
double prev = 0;
double prev1 = 0;
double prev2 = 0;
double prev3 = 0;
double weight = 0;
double linear = 0;
double MAValue = 0;
double MAValue2 = 0;
double mavalue3 = 0;
string MAstring = "";
double MyHigh = 0;
double MyLow = 0;
int counter = 0;
double Price = 0;
double Price1 = 0;
double tmpDevAA = 0;

SetLoopCount(0);
smconst = 2 / (1+Slw);
smconst1 = 2 / (1+Slwsignal);
	      
loopbegin = loopbegin+1; 
for(shift =Barcount;shift >=0 ;shift --)
{ 
    prev = GetIndexValue2(shift+1);
    
    // Yousky 15/05/2006 - Change to avoid Zero divide exception.
    AA = 0;
    tmpDevAA = (High[Highest(NULL, 0, MODE_HIGH,shift+Pds,Pds)] - Low[Lowest(NULL, 0, MODE_LOW,shift+Pds,Pds)]);
    
    if (tmpDevAA != 0)
      AA = 100* ((Close[shift] - Low[Lowest(NULL, 0, MODE_LOW,shift+Pds,Pds)]) / tmpDevAA);
    // ---
      
    MAValue2 = smconst * (AA-prev) + prev;
    
    SetIndexValue2(shift,MAValue2);
    
   	
	loopbegin = loopbegin-1; 
	

} 




loopbegin2 = loopbegin2+1; 
for(shift =Barcount-Pds;shift >=0 ;shift --){ 
MyHigh = -999999;
MyLow = 99999999;
for(counter =shift;counter <=Pds + shift ;counter ++){ 
Price= GetIndexValue2(counter);
if( Price > MyHigh ) 
MyHigh = Price;
if( Pds <= 0 ) 
MyHigh = Price;
if( Price < MyLow ) 
MyLow = Price;
if( Pds <= 0 ) 
MyLow = Price;
} 

prev1 = GetIndexValue(shift+1);
aa1=GetIndexValue2(shift);

// Yousky 15/05/2006 - Change to avoid Zero divide exception.
bb= 0;
if ((MyHigh-MyLow) != 0)
  bb=100*(aa1-MyLow)/(MyHigh-MyLow);
// ---



  
MAValue = smconst * (bb-prev1) + prev1;
	
SetIndexValue(shift,MAValue);

loopbegin2 = loopbegin2-1; 
} 

//Print (MAValue);  // green

loopbegin3 = loopbegin3+1; 
for(shift =Barcount;shift >=0 ;shift --){ 
prev2=GetIndexValue2(shift+1);
prev3=GetIndexValue(shift);
mavalue3= smconst1 * (prev3-prev2) +prev2;


SetIndexValue2(shift,mavalue3);
loopbegin3 = loopbegin3-1;





} 

 
   if(ExtHistoBuffer[0] > ExtHistoBuffer2[0] && ExtHistoBuffer[0]<20.1 && ExtHistoBuffer2[0] < 20.1 && BuyAlert==False)
   {

      Alert ("Doda-Stochastic says Buy  ",Symbol()," at ",Close[0]); 
      BuyAlert = True;
      SellAlert = False;
  }
   
   if(ExtHistoBuffer2[0] > ExtHistoBuffer[0] && ExtHistoBuffer[0]>80.1 && ExtHistoBuffer2[0] > 80.1 && SellAlert==False)
   {
   // sell signal
      Alert ("Doda-Stochastic says Sell  ",Symbol()," at ",Close[0]); 
      BuyAlert = false;
      SellAlert = True;  
      
   }
 


}