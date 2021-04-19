#property copyright "Banik"
#include <func.mqh>

input double maxloss = -1000;

void OnTick()
{
   double loss = 0 ;
   int t = OrdersTotal();
   for (int i = t-1 ; i > -1 ; i--)
   {
      bool s = OrderSelect(i , SELECT_BY_POS , MODE_TRADES);
      loss = loss + OrderProfit() + OrderCommission();   
   }
   
   if (loss < maxloss)
   {
      Alert ("Exceded ..... Closed All positions");
      Close_All_Positions();
   }
    
}

