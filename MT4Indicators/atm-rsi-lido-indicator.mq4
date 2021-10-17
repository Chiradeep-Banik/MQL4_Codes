//+------------------------------------------------------------------+
//|                                                     RSI_LiDo.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//| original "RSI_dot" concept by Accrete, and nicely tweaked by     |
//| telsa of ForexFactory fame !! Many thanks telsa...Accrete        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100

#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Aqua
#property indicator_level1 75 
#property indicator_level2 65
#property indicator_level3 35
#property indicator_level4 25



//---- input parameters
extern int RSIPeriod=12;

//---- buffers
double dRsiLine[];
double dRsiDots[];

int init() {

    IndicatorShortName("ATM RSI LiDo (" + RSIPeriod + ")");
    
    SetIndexBuffer(0,dRsiLine);
    SetIndexStyle (0,DRAW_LINE);
    SetIndexLabel (0,"RSI");
    
    SetIndexBuffer(1,dRsiDots);
    SetIndexStyle (1,DRAW_ARROW);
    SetIndexArrow (1,159);
    SetIndexLabel (1,"RSI");

    return(0);
}

int start() {

    // Determine how far back to iterate
    int iBarsToCalc = Bars - IndicatorCounted();
    if (iBarsToCalc < Bars) iBarsToCalc++;

    for (int i=iBarsToCalc-1;i>=0;i--) {
        dRsiLine[i] = iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i);
        dRsiDots[i] = dRsiLine[i];
    }
}
//__________________

 //Will Code For Pips


