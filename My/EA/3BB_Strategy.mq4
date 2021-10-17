
#property copyright "Banik"
#property show_inputs

input int bbperiod = 50;
input int bbstd_div_entry = 2;
input int bbstd_div_profit = 1;
input int bbstd_div_loss = 6; 
input double maxloss = 100;

int magic_num = 1313;

int OnInit()
{
   Alert("EA started....");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Alert("EA stopped....");
   
}

void OnTick()
{
   double bb_buy_entry = iBands(NULL , 0 ,bbperiod , bbstd_div_entry ,0 , PRICE_CLOSE , MODE_LOWER, 0);
   double bb_sell_entry = iBands(NULL , 0 ,bbperiod , bbstd_div_entry ,0 , PRICE_CLOSE , MODE_UPPER, 0);
   
   double bb_buy_stop = iBands(NULL , 0 ,bbperiod , bbstd_div_loss ,0 , PRICE_CLOSE , MODE_LOWER, 0);
   double bb_sell_stop = iBands(NULL , 0 ,bbperiod , bbstd_div_loss ,0 , PRICE_CLOSE , MODE_UPPER, 0);
   
   double bb_buy_profit = iBands(NULL , 0 ,bbperiod , bbstd_div_profit ,0 , PRICE_CLOSE , MODE_LOWER, 0);
   double bb_sell_profit = iBands(NULL , 0 ,bbperiod , bbstd_div_profit ,0 , PRICE_CLOSE , MODE_UPPER, 0);
   
   int rsi = iRSI( NULL , 0 , 14 , PRICE_CLOSE , 0);
   
  
   
   if ( ordercheck(1313) == false )
   {
      if (Ask < bb_buy_entry && rsi < 30 && Open[0] > bb_buy_entry)
      {
         double volume_buy = optimal_lot_size(bb_buy_stop , maxloss);
         int ticket_buy = OrderSend(NULL , OP_BUY , volume_buy , Ask , 3 ,bb_buy_stop , bb_buy_profit ,NULL , magic_num , 0 ,clrGreen);
         if (ticket_buy < 0 )
         {Print ("Error Code : " + GetLastError());} 
      }
      else
         if (Bid > bb_sell_entry && rsi > 70 && Open[0] < bb_sell_entry)
         {
            double volume_sell = optimal_lot_size(bb_sell_stop , maxloss);
            int ticket_sell = OrderSend(NULL , OP_SELL , volume_sell , Bid , 3 ,bb_sell_stop , bb_sell_profit , NULL , magic_num ,0 , clrRed); 
            if (ticket_sell < 0 )
            {Print ("Error Code : " + GetLastError());}
         }
   }
   
   
}

double optimal_lot_size( double stoploss , double max_loss)
{
   double pip_Value = MarketInfo(NULL , MODE_TICKVALUE);
   double pip_size = MarketInfo(NULL , MODE_TICKSIZE);
   double price = NormalizeDouble((Ask +Bid)/2 , 5);
   double stop_loss_pips = MathAbs((price - stoploss));
   double max_loss_in_quoted_currency = max_loss/pip_Value;
   double lot_size = max_loss_in_quoted_currency / stop_loss_pips;
   double volume = NormalizeDouble((lot_size*pip_size) , 2 );
   
   return volume;                          
   
}

bool ordercheck(int magic_no)
{
   int t = OrdersTotal();
   bool m = false;
   for (int i = 0 ; i < t ; i++)
   {
      bool os = OrderSelect(i , SELECT_BY_POS , MODE_TRADES);
      if (OrderMagicNumber() == magic_no)
      {
         m =  true;
      }
   }
   return m;
}