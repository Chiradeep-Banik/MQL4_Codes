//+------------------------------------------------------------------+
//|                                                 News Alert 2.mq4 |
//|                                                     João Barbosa |
//|                                        obarbosa2001@yahoo.com.br |
//+------------------------------------------------------------------+
#property copyright "João Barbosa"
#property link      "obarbosa2001@yahoo.com.br"

#property indicator_chart_window

int NormalSpread, NormalStopLevel;
extern int Lag=2;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   NormalSpread=MarketInfo(Symbol(),MODE_SPREAD);
   NormalStopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   start();
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
   RefreshRates();
   int ActualSpread=(Ask-Bid)/Point;
   int ActualStopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if (ActualSpread+1>NormalSpread+Lag) { Alert("News or High Volatility !!! Spread has change.");
                                    Print("Actual Spread: ",ActualSpread," Pips, Normal Spread: ",NormalSpread," Pips"); }
   if (ActualStopLevel>NormalStopLevel) { Alert("News or High Volatility !!! Stop Level has change.");
                                          Print("Actual Stop Level: ",ActualStopLevel," Pips, Normal Stop Level: ",NormalStopLevel," Pips"); }

   return(0);
  }
//+------------------------------------------------------------------+