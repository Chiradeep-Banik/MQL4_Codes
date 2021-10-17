#property copyright "Banik"

void Close_All_Positions()
{
    int totalorders = OrdersTotal();
    for (int i = totalorders-1; i >= 0 ; i--)
    {
      bool o = OrderSelect(i , SELECT_BY_POS , MODE_TRADES);
      int type = OrderType();
      bool cl;
      if (type == OP_BUY)
      {
         cl = OrderClose(OrderTicket(),OrderLots(),Bid , 5 , clrNONE);
      }
      else
         if(type == OP_SELL)
         {
            cl = OrderClose(OrderTicket(),OrderLots(),Ask , 5 , clrNONE);
         }
         else
         {
            Alert ("Your code Sucks");
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
