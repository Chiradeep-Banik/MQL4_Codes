#property copyright "Banik"
#property version   "2.00"
#property strict
#property show_inputs

double ticks; 
input int recovery_zone = 200 ; //in ticks
input double vol = 0.02;
input bool Agressive_Style = false;
input double risk_reward = 3;
input bool Trail_stop = false;

double zone_length = 0;
double entry_buy =0;
double entry_sell=0;
double stop_buy=0;
double tp_buy=0;
double stop_sell =0;
double tp_sell=0;

int OnInit(){
   if (_Digits == 5)
      ticks = 0.00001;   
   else
      ticks = 0.0001;
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}
void OnTick(){
   
   zone_length = recovery_zone*ticks;
   if (OrdersTotal() == 0){
      entry_buy = Ask;
      entry_sell = Ask - zone_length;
      stop_buy = entry_sell - zone_length;
      tp_buy = entry_buy+risk_reward*zone_length;
      stop_sell = entry_buy + zone_length;
      tp_sell = entry_sell-risk_reward*zone_length;
   }   
   double price_buy = entry_buy;
   double price_sell = entry_sell;
   
   if(OrdersTotal() == 0 && price_buy == Ask)
      int b1 = OrderSend(NULL ,OP_BUY , vol , Ask ,0,stop_buy , tp_buy , NULL , 0 ,0,clrGreen);  
   if (OrdersTotal() == 1 && price_sell > Bid)
      int s1 = OrderSend(NULL ,OP_SELL , vol*2 , Bid ,0,stop_sell , tp_sell , NULL , 0 ,0,clrRed);
   if (OrdersTotal() == 2 && price_buy < Ask)
      int b2 = OrderSend(NULL ,OP_BUY , vol*4 , Ask ,0,stop_buy , tp_buy , NULL , 0 ,0,clrGreen); 
   if (OrdersTotal() == 3 && price_sell > Bid )
      int s2 = OrderSend(NULL ,OP_SELL , vol*8 , Bid,0,stop_sell , tp_sell , NULL , 0 ,0,clrRed);
   if (Agressive_Style == 1){
      if (OrdersTotal() == 4 && price_buy < Ask )
         int b3 = OrderSend(NULL ,OP_BUY , vol*16 , Ask ,0,stop_buy , tp_buy, NULL , 0 ,0,clrGreen);  
      if (OrdersTotal() == 5 && price_sell > Bid )
         int s3 = OrderSend(NULL ,OP_SELL , vol*32 , Bid ,0,stop_sell , tp_sell , NULL , 0 ,0,clrRed);
   }
   if (Trail_stop == 1)
      trail_stop();
}


void trail_stop(){
   for (int i = OrdersTotal() ; i >-1 ; i--){
      bool os = OrderSelect(i , SELECT_BY_POS ,MODE_TRADES);
      if (OrderType() == OP_BUY){
         if (Bid == entry_buy+1*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice() , OrderTakeProfit() , clrNONE);
         if (Bid == entry_buy+2*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice()+zone_length , OrderTakeProfit() , clrNONE);
         if (Bid == entry_buy+3*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice()+2*zone_length , OrderTakeProfit() , clrNONE);
         if (Bid == entry_buy+4*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice()+3*zone_length , OrderTakeProfit() , clrNONE);
         if (Bid == entry_buy+5*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice()+4*zone_length , OrderTakeProfit() , clrNONE);       
      }
      else
         if (OrderType() == OP_SELL){
         if (Ask == entry_sell-1*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice() , OrderTakeProfit() , clrNONE);
         if (Ask == entry_sell-2*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice()-zone_length , OrderTakeProfit() , clrNONE);
         if (Ask == entry_sell-3*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice()-2*zone_length , OrderTakeProfit() , clrNONE);
         if (Ask == entry_sell-4*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice()-3*zone_length , OrderTakeProfit() , clrNONE);
         if (Ask == entry_sell-5*zone_length)
            bool om = OrderModify(OrderTicket() , OrderOpenPrice(),OrderOpenPrice()-4*zone_length , OrderTakeProfit() , clrNONE); 
         
         }
   }
}
