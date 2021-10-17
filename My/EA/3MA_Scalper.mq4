#include  <func.mqh>
#property copyright "Banik"
#property strict
#property show_inputs

input double lot = 1;

int magic_num = 13113;

int OnInit(){
   Alert("EA Started...");
   return(INIT_SUCCEEDED);
}



void OnDeinit(const int reason){
   Alert("EA Stopped");
}


void OnTick(){
   
   double h1_fast_ma = iMA(NULL , PERIOD_H1 , 8 , 0 , MODE_EMA , PRICE_CLOSE ,0);
   double h1_slow_ma = iMA(NULL , PERIOD_H1 , 21 , 0 , MODE_EMA , PRICE_CLOSE ,0);
   
   int h1_trend = H1_check_trend(h1_fast_ma , h1_slow_ma);
   
   double m5_21_ma = iMA(NULL , PERIOD_M5 , 21, 0 , MODE_EMA , PRICE_CLOSE , 0);
   double m5_13_ma = iMA(NULL , PERIOD_M5 , 13, 0 , MODE_EMA , PRICE_CLOSE , 0);
   double m5_8_ma = iMA(NULL , PERIOD_M5 , 8, 0 , MODE_EMA , PRICE_CLOSE , 0);
   
   int m5_signal = m5_signal_check(m5_8_ma , m5_13_ma , m5_21_ma);
   
   if(h1_trend == 1 && m5_signal == 1 && OrdersTotal() == 0){
      if (Close[1] > m5_8_ma && Ask > m5_21_ma && Ask < m5_8_ma){
         double entry_price = High[iHighest(NULL , PERIOD_M5 , MODE_HIGH , 5 ,0)];
         double stoploss = Low[iLowest(NULL , PERIOD_M5, MODE_LOW , 3,0)];
         double r_pips = entry_price - stoploss;
         double takeprofit_1 = entry_price + r_pips;
         double takeprofit_2 = entry_price + 2*r_pips;         
         
         if (m5_separation(m5_8_ma , m5_13_ma , m5_21_ma) == true){
            int ticket_buy1 = OrderSend(NULL ,OP_BUYSTOP , lot,entry_price ,0, stoploss , takeprofit_1 ,"Buy_stop" , magic_num , 0 , clrBlue);
            int ticket_buy2 = OrderSend(NULL ,OP_BUYSTOP, lot ,entry_price ,0, stoploss , takeprofit_2 ,"Buy_stop" , magic_num ,0 , clrBlue);
         }     
      }
   }
   
   if (h1_trend == -1 && m5_signal == -1 && OrdersTotal() == 0){
      if (Close[1] < m5_8_ma && Bid < m5_21_ma && Bid > m5_8_ma){
         double entry_price = Low[iLowest(NULL , PERIOD_M5 , MODE_LOW , 5 ,0)];
         double stoploss = High[iHighest(NULL , PERIOD_M5, MODE_HIGH , 3,0)];
         double r_pips = stoploss - entry_price;
         double takeprofit_1 = entry_price - r_pips;
         double takeprofit_2 = entry_price - 2*r_pips;
         
         if (m5_separation(m5_8_ma , m5_13_ma , m5_21_ma) == true){
            int ticket_sell1 = OrderSend(NULL ,OP_SELLSTOP , lot ,entry_price ,2, stoploss , takeprofit_1 ,"Sell_stop" , magic_num , 0 , clrRosyBrown);
            int ticket_sell2 = OrderSend(NULL ,OP_SELLSTOP , lot,entry_price ,2, stoploss , takeprofit_2 ,"Sell_stop" , magic_num , 0 , clrRosyBrown);
         }
      }
   }
   
   move_to_breakeven();
   deleting_orders();
   
   Comment (DoubleToString(h1_fast_ma , _Digits) + "\n" 
            + DoubleToString(h1_slow_ma, _Digits) + "\n" 
            + "H1 Trend :" +DoubleToString(h1_trend ,0) + "\n"
            + DoubleToString(m5_21_ma, _Digits) + "\n"
            + DoubleToString(m5_13_ma, _Digits) + "\n"
            + DoubleToString(m5_8_ma, _Digits) + "\n"
            + "M5 Signal :" + DoubleToString(m5_signal , 0));
           
}


int H1_check_trend(double fast_ma , double slow_ma){
   
   if (fast_ma > slow_ma  && Ask> fast_ma)
      return 1;
   else
      if (fast_ma < slow_ma  && Bid < fast_ma)
         return -1;
      else
         return 0;
   
}

int m5_signal_check(double ma_8 , double ma_13 , double ma_21){
  
  if (ma_8 > ma_13 && ma_13 > ma_21)
      return 1;
  else
      if (ma_8 < ma_13 && ma_13 < ma_21)
         return -1;
      else
         return 0;  
   
}

void move_to_breakeven(){

   for (int i = OrdersTotal() ; i > -1 ; i--){
      
      bool os = OrderSelect( i , SELECT_BY_POS , MODE_TRADES);
      double dis = MathAbs(OrderOpenPrice()- OrderStopLoss());
      double tp = 0.00000 ;
      if (OrderType() == OP_BUY )
         tp = OrderOpenPrice() + dis;
      if (OrderType() == OP_SELL)
         tp = OrderOpenPrice() - dis;
      if (Ask == tp )
         bool om = OrderModify(OrderTicket() , OrderOpenPrice() , OrderOpenPrice() , OrderTakeProfit() , 0 , clrNONE);
   }
}

bool m5_separation(double ma_8,double ma_13 , double ma_21){

   double m8 = NormalizeDouble(ma_8 , _Digits);
   double m13 = NormalizeDouble(ma_13 , _Digits);
   double m21 = NormalizeDouble(ma_21 , _Digits);
   
   double m8_13 = MathAbs(m8-m13);
   double m13_21 = MathAbs (m13-m21);
   
   if (m8_13 > 0.00020 && m13_21 > 0.00020)
      return true;
   else
      return false;
}

void deleting_orders(){
   for (int j = OrdersTotal() ; j > -1 ; j--){
      bool os1 = OrderSelect(j , SELECT_BY_POS , MODE_TRADES);
      datetime t_expiry = OrderOpenTime() + 60;
      if (TimeCurrent() == t_expiry)
         bool od = OrderDelete(OrderTicket() ,clrNONE);
   }
   
}