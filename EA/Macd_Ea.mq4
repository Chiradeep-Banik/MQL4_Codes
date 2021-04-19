#include  <func.mqh>

#property copyright "Banik"
#property strict
#property show_inputs

// Works best on H4 time frame

input int ema_fast = 12 ;
input int ema_slow = 26 ;
input int signal_period = 9;
input double vol = 1;
input double risk_in_pips = 10;
input double risk_reward = 3.5; // Risk times the reward

int magic_num = 1234;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("EA started..");
//---
   return(INIT_SUCCEEDED);
  }
  
  

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Alert("EA Stopped....");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
if (isnewcandle() == true && OrdersTotal() == 0)
{
   
   double macd_main = iMACD(NULL , 0 ,ema_fast , ema_slow , signal_period , PRICE_CLOSE , MODE_MAIN , 0);
   double macd_signal = iMACD(NULL , 0 ,ema_fast , ema_slow , signal_period , PRICE_CLOSE , MODE_SIGNAL , 0);
   double prev_macd_main = iMACD(NULL , 0 ,ema_fast , ema_slow , signal_period , PRICE_CLOSE , MODE_MAIN , 1);
   double prev_macd_signal = iMACD(NULL , 0 ,ema_fast , ema_slow , signal_period , PRICE_CLOSE , MODE_SIGNAL , 1);
   
   double ema_signal = iMA(NULL , 0 , 200 , 0 , MODE_EMA , PRICE_CLOSE , 0); 
   
   
   if (prev_macd_main < prev_macd_signal && macd_main > macd_signal && macd_main > 0 && macd_signal > 0 && Ask > ema_signal)
   {
      //buy
      int ticket_buy = OrderSend(NULL , OP_BUY , vol ,Ask ,3 , Ask - (risk_in_pips*0.0001) , Ask + (risk_in_pips*risk_reward*0.0001),"Buy" , magic_num , 0 , clrGreen);
      
   }
   if (prev_macd_main > prev_macd_signal && macd_main < macd_signal && macd_main < 0 && macd_signal < 0 && Bid < ema_signal)
   {
      //sell
      
      int ticket_sell = OrderSend(NULL , OP_SELL , vol ,Bid ,3 , Bid + (risk_in_pips*0.0001) , Bid - (risk_in_pips*risk_reward*0.0001),"Buy" , magic_num , 0 , clrGreen);
      
   }
}

     
  }
//+------------------------------------------------------------------+
