#include <func.mqh>
#property copyright "Banik"
#property strict
#property show_inputs

double tick_size ;
input int risk_ticks = 200;
input double reward_ratio = 2;
input double risk_percent = 1;

double risk_amount = risk_percent*AccountEquity()/100;

int OnInit(){
   if (_Digits == 5)
      tick_size = 0.00001;
   else
      tick_size = 0.00010;
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
}

void OnTick(){
   
   
   double ema = NormalizeDouble(iMA(NULL ,0 , 200 ,0 ,MODE_EMA , PRICE_CLOSE,0),5);
   /*sell*/
   {
      bool found = 0;
      double  high_close = Close[iHighest(NULL ,0 ,MODE_CLOSE , 5, 0)];
      double  high_open= Open[iHighest(NULL ,0 ,MODE_OPEN ,5 , 0)];
      double high_barrier = MathMax(high_close,high_open);
      double stop = Bid + risk_ticks*tick_size;
      double tp = Bid - risk_ticks*tick_size*reward_ratio;
      
      
      if (iHigh(NULL ,0 ,0) > high_barrier)
         if (iHigh(NULL ,0 ,1) > high_barrier)
            if (iHigh(NULL ,0 ,2) > high_barrier)
               if (iHigh(NULL ,0 ,3) > high_barrier)
                  if (iHigh(NULL ,0 ,4) > high_barrier)
                     if (iHigh(NULL ,0 ,5) > high_barrier)
                        found = 1;
                                         
                  
      double lot = optimal_lot_size(Bid ,stop , risk_amount);
      if (found == true && isnewcandle() == true)
         if (OrdersTotal() == 0)
            if (Bid < ema)
               int ticket_sell = OrderSend(NULL ,OP_SELL , lot , Bid , 3, stop ,tp ,NULL ,0 ,0,clrNONE);          
   }
   
   /*Buy*/
   {
      bool found = 0;
      double  low_close = Close[iLowest(NULL ,0 ,MODE_CLOSE , 5, 0)];
      double  low_open= Open[iLowest(NULL ,0 ,MODE_OPEN ,5 , 0)];
      double low_barrier = MathMin(low_close,low_open);
      double stop = Ask - risk_ticks*tick_size;
      double tp = Ask + risk_ticks*tick_size*reward_ratio;
      
      
      if (iLow(NULL ,0 ,0) < low_barrier)
         if (iLow(NULL ,0 ,1) < low_barrier)
            if (iLow(NULL ,0 ,2) < low_barrier)
               if (iLow(NULL ,0 ,3) < low_barrier)
                  if (iLow(NULL ,0 ,4) < low_barrier)
                     if (iLow(NULL ,0 ,5) < low_barrier)
                        found = 1;
      
      double lot = optimal_lot_size(Ask ,stop , risk_amount);
      if (found == true && isnewcandle() == true)
         if (OrdersTotal() == 0 )
            if (Ask > ema)        
               int ticket_buy = OrderSend(NULL ,OP_BUY , lot , Ask , 3, stop ,tp ,NULL ,0 ,0,clrNONE);             
   }
   
   move_to_breakeven();
}

void move_to_breakeven(){
   for (int i = 0 ; i  <OrdersTotal() ; i++ ){
      bool os = OrderSelect(i , SELECT_BY_POS , MODE_TRADES);
      if (OrderType() == OP_BUY){
         double distance = OrderOpenPrice() - OrderStopLoss();
         double l1 = OrderOpenPrice()+distance;
         double l2 = OrderOpenPrice() + 2*distance;
         if (Bid >= l1)
            bool modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
         if (Bid >= l2)
            bool modify = OrderModify(OrderTicket(),OrderOpenPrice(),l1,OrderTakeProfit(),0,clrNONE);
      }
      if (OrderType() == OP_SELL){
         double distance = OrderStopLoss() -OrderOpenPrice();
         double l1 = OrderOpenPrice()-distance;
         double l2 = OrderOpenPrice()-2*distance;
         if (Ask <= l1)
            bool modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
         if (Ask <= l2)
            bool modify = OrderModify(OrderTicket(),OrderOpenPrice(),l1,OrderTakeProfit(),0,clrNONE);
      }
      
   }
}

double optimal_lot_size(double pricee , double stoploss , double max_loss )
{
   double pip_Value = MarketInfo(NULL , MODE_TICKVALUE);
   double pip_size = MarketInfo(NULL , MODE_TICKSIZE);
   double price = pricee;
   double stop_loss_pips = MathAbs((price - stoploss));
   double max_loss_in_quoted_currency = max_loss/pip_Value;
   double lot_size = max_loss_in_quoted_currency / stop_loss_pips;
   double volume = NormalizeDouble((lot_size*pip_size) , 2 );
   
   return volume;                          
   
}