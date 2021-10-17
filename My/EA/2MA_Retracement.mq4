#include  <func.mqh>

#property copyright "Banik"
#property strict


/*
Strategy--
# BUY 
- Only when 20 sma is above the 50 sma
- when price retrace back to the 20 sma line 
- we buy at that price with a stoploss just below the 50 sma

# SELl 
- Only when 20 sma is below the 50 sma
- when price retrace back to the 20 sma line 
- we sell at that price with a stoploss just above the 50 sma

*/

input int slow_ma_period = 50;
input int fast_ma_period = 20;
input double risk_reward = 3;
input double max_risk = 100;

int magic_num = 12345;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("EA Started");
//---
   return(INIT_SUCCEEDED);
  }
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Alert ("EA Stopped");
  }
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
      double slow_ma = iMA(NULL , 0 , slow_ma_period , 0 , MODE_SMA , PRICE_CLOSE , 0);
      double fast_ma = iMA(NULL , 0 , fast_ma_period , 0 , MODE_SMA , PRICE_CLOSE , 0);
      
      if (OrdersTotal() < 5)
      
         if (fast_ma > slow_ma)
         {
            if (Close[1] > fast_ma && Ask == fast_ma )
            {
               double stop_distance = fast_ma - slow_ma;
               double stoploss = Ask - stop_distance - 0.0002;
               double takeprofit = Ask + stop_distance*risk_reward;
               
               
               
               int ticket_buy = OrderSend(NULL , OP_BUY  ,optimal_lot_size(stoploss,max_risk) , Ask , 2 , stoploss , takeprofit , "BUY" , magic_num , 0 , clrGreen);
               
            }
            //buy
         }
         if (slow_ma > fast_ma)
         {
            if (Close[1] < fast_ma && Bid == fast_ma)
            {
               double stop_distance = slow_ma - fast_ma;
               double stoploss = Bid + stop_distance + 0.0002;
               double takeprofit = Bid -  stop_distance*risk_reward;
               
               
               
               int ticket_sell = OrderSend(NULL , OP_SELL  ,optimal_lot_size(stoploss,max_risk) , Bid , 2 , stoploss , takeprofit , "SELL" , magic_num , 0 , clrRed);
            }
            //sell
         }
  }
//+------------------------------------------------------------------+
