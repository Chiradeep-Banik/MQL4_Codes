#include  <func.mqh>

#property copyright "Banik"
#property strict
#property show_inputs

input int profit_ticks = 8;
input double lot_size = 0.5;

int magic_num = 1313113;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("Started...");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Alert("Stopped....");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      //datetime new_candle_time = TimeCurrent();
      double op = Open[1];
      double prev_op = Open[2];
   
      double cl = Close[1];
      double prev_cl = Close[2]; 
   
      double hi = High[1];
      double lo = Low [1];
   
      double dif = MathAbs(op - cl);
      double prev_dif = MathAbs(prev_cl - prev_op);
   
   
   
   if (dif > 3*prev_dif && op > cl && Low [2] > Low[1] && isnewcandle() == true )
        {
            //double vol = optimal_lot_size(hi , risked_capital);
            if (OrdersTotal() < 1)
            {
               /*
               int ticket_sell = OrderSend( NULL , OP_SELL , 0.3 , Bid , 2 , hi , Bid - profit_ticks*0.00001 , "sell" , magic_num , 0 , clrRed);
               if (ticket_sell < 0)
               {
                  Print ("Error :" + GetLastError() );
               }
               */
               int ticket_buy = OrderSend( NULL , OP_BUY , lot_size , Ask , 2 , Bid - profit_ticks*0.00001 , hi , "buy" , magic_num , 0 , clrGreen);
               if (ticket_buy < 0)
               {
                  Print ("Error :" + GetLastError() );
               }
            
            } 
        }
        
   if (dif > 3*prev_dif && cl > op && High[1] > High[2] && isnewcandle() == true )
        {
            //double vol = optimal_lot_size(lo , risked_capital);
            if (OrdersTotal() < 1)
            {
               /*
               int ticket_buy = OrderSend( NULL , OP_BUY , 0.3 , Ask , 2 , lo , Ask + profit_ticks*0.00001 , "buy" , magic_num , 0 , clrGreen);
               if (ticket_buy < 0)
               {
                  Print ("Error :" + GetLastError() );
               }
               */
               int ticket_sell = OrderSend( NULL , OP_SELL , lot_size , Bid , 2 , Ask + profit_ticks*0.00001 , lo , "sell" , magic_num , 0 , clrRed);
               if (ticket_sell < 0)
               {
                  Print ("Error :" + GetLastError() );
               }
           
            } 
        } 
   
  }
//+------------------------------------------------------------------+

