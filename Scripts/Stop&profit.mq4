//+------------------------------------------------------------------+
//|                                                  Stop&profit.mq4 |
//|                                                            Banik |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Banik"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

input double TP = 00000.000000;
input double SL=00000.0000000;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart(){

   int totalorders = OrdersTotal();
   for (int i = totalorders-1;i >= 0 ; i--)
   {
      bool o = OrderSelect(i, SELECT_BY_POS,MODE_TRADES);
      bool modified = OrderModify(OrderTicket() , OrderOpenPrice(), SL ,TP ,0,clrNONE);
   }
}

