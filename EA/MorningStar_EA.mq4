#include <func.mqh>

#property copyright "Banik"
#property strict

int OnInit(){

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
}

void OnTick(){

   candle c1,c2,c3;
   c1.pos = 1;
   c2.pos = 2;
   c3.pos = 3;
   
   //double vol= optimal_lot_size(c1.open() , 100);
   double vol=1;
   if (c1.bull_bear() == 1)
         if (c3.bull_bear() == -1)
            if (4*c2.distance() < c1.distance())
               if (4*c2.distance() < c3.distance())
                  if(c2.distance() != 0 )
                     if (c1.distance()*2 > c3.distance())
                        if (c3.distance()*2 > c1.distance())
                           if (margin_check(0 ,vol,_Symbol) == true)
                              if (OrdersTotal() == 0)
                                 int ticket = OrderSend(_Symbol , OP_BUY ,vol,Ask , 2,c1.open() ,Ask+c1.distance()*2 ,NULL ,0, 0,clrGreen);
                                 
   if (c1.bull_bear() == -1)
         if (c3.bull_bear() == 1)
            if (4*c2.distance() < c1.distance())
               if (4*c2.distance() < c3.distance())
                  if(c2.distance() != 0 )
                     if (c1.distance()*2 > c3.distance())
                        if (c3.distance()*2 > c1.distance())
                           if (margin_check(1 ,vol,_Symbol) == true)
                              if (OrdersTotal() == 0)                                    
                                 int ticket = OrderSend(_Symbol , OP_SELL ,vol,Bid , 2,c1.open() ,Bid - c1.distance()*2 ,NULL ,0, 0,clrRed);


   move_to_breakeven();
}

bool margin_check(int  type , double vol , string Sym){
   double free_margin = AccountFreeMarginCheck(Sym , type , vol);          //0 - BUY , 1- SELL
   if (free_margin <= 0 )
      return false;
   else
      return true;
}

class candle{
   public:
      int pos;           
      candle(){
      }
      ~candle(){
      }
      double high(){
         return iHigh(NULL , 0 ,pos);
      }
      double low(){
         return iLow(NULL ,0 , pos);
      }
      double close(){
         return iClose(NULL ,0 , pos);
      }
      double open(){
         return iOpen(NULL , 0 , pos);
      }
      int bull_bear(){
         if (open() > close())
            return -1;
         else
            if (open() < close())
               return 1;
            else
               return 0;
      }
      double distance(){
         double dis = MathAbs(open() - close());
         return dis;
      }
};

