#include <stdlib.mqh>
//+------------------------------------------------------------------+
//|                                                    TTM Stoch.mq4 |
//|                                                                  |
//|                                        Converted by Mql2Mq4 v0.7 |
//|                                            http://yousky.free.fr |
//|                                    Copyright © 2006, Yousky Soft |
//+------------------------------------------------------------------+

#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0.00
#property indicator_maximum 100.00
#property indicator_color1 Blue
#property indicator_buffers 2
#property indicator_color2 Magenta

//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| External variables                                               |
//+------------------------------------------------------------------+
extern double Slw = 5;
extern double Pds = 5;
extern double Slwsignal = 3;

//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+

int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];

void SetLoopCount(int loops)
{
}

void SetIndexValue(int shift, double value)
{
  ExtHistoBuffer[shift] = value;
}

void SetIndexValue2(int shift, double value)
{
  ExtHistoBuffer2[shift] = value;
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
for(shift =2000;shift >=0 ;shift --)
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
for(shift =2000-Pds;shift >=0 ;shift --){ 
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


loopbegin3 = loopbegin3+1; 
for(shift =2000;shift >=0 ;shift --){ 
prev2=GetIndexValue2(shift+1);
prev3=GetIndexValue(shift);
mavalue3= smconst1 * (prev3-prev2) +prev2;

SetIndexValue2(shift,mavalue3);
loopbegin3 = loopbegin3-1;
} 

}