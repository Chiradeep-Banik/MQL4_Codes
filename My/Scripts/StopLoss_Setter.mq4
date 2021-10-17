#property copyright "Banik"
#property strict
#property show_inputs

extern double risk = 500;
extern double Takeprofit=0.00000; 

void OnStart(){
   int total_orders = OrdersTotal();
   double tick_value = MarketInfo(NULL,MODE_TICKVALUE);
   double tick_size = MarketInfo(NULL,MODE_TICKSIZE);
   double sum_of_prices = 0;
   double lot = 0;
   int order_type =0;
   double stoploss = 0;
   for (int i = OrdersTotal() ; i > -1 ; i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         sum_of_prices=sum_of_prices+OrderOpenPrice();
         lot = OrderLots();
         order_type = OrderType();
      }
   }
   double avg_price = NormalizeDouble((sum_of_prices/total_orders),_Digits);
   
   double total_order_size = avg_price*100000;
   
   double distance_to_move = NormalizeDouble((risk*lot)/OrdersTotal(),0);
   
   if (order_type == OP_BUY)
      stoploss = (total_order_size-distance_to_move)*0.00001;
   else
      stoploss = (total_order_size+distance_to_move)*0.00001;
   
   for(int j = OrdersTotal();j > -1;j--){
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)){
         bool mod = OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,Takeprofit,0,clrNONE);
      }
   }
}
