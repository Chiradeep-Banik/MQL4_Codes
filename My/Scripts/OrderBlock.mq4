#property copyright "Banik"
#property version   "1.00"
#property strict
#property show_inputs

input int tick_difference = 2;
input int No_Of_Trdaes = 10;
input double vol = 0.5;

enum trade_type {buy,sell};
input trade_type trade = buy;

void OnStart(){
   double tick_difference_in_points = 0.00001*tick_difference;
   if( trade == buy ){
      //BUY
      double price = Ask;
      int ticket = OrderSend(NULL,OP_BUY,vol,price,2,0,0,NULL,0,0,clrNONE);
      for(int i=0;i < No_Of_Trdaes-1;i++){
         price = price-tick_difference_in_points;
         ticket = OrderSend(NULL,OP_BUYLIMIT,vol,price,2,0,0,NULL,0,0,clrNONE);
      }
      
   }
   else{
      //SELL
      double price = Bid;
      int ticket = OrderSend(NULL,OP_SELL,vol,price,2,0,0,NULL,0,0,clrNONE);
      for(int i=0;i < No_Of_Trdaes-2;i++){
         price = price+tick_difference_in_points;
         ticket = OrderSend(NULL,OP_SELLLIMIT,vol,price,2,0,0,NULL,0,0,clrNONE);
      }
   }
      
}
