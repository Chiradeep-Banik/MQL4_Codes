#property  show_inputs

input int R;

void OnTick()
{
 int t = OrdersTotal();
 for (int j = t - 1; j >= 0 ; j--)
 {
   bool s = OrderSelect(j , SELECT_BY_POS , MODE_TRADES);
   trailing_stoploss();
 } 
   
}
//+------------------------------------------------------------------+
void trailing_stoploss()
{
   if (OrderProfit() >= R)
   {
      bool m = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(), OrderTakeProfit(), 0, clrRed);
   }
}