//+------------------------------------------------------------------+
//|              Martingale Bone Crusher v1                          |
//|                   AHARON TZADIK                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "AHARON TZADIK"
#property link        "http://algorithmic-trading-ea-mt4.000webhostapp.com/"
#property version   "1.06"
#property strict


enum     optoin{Martingale1,Martingale2};
input          optoin Strategy=Martingale2; // Choose between two strategies
extern double     Multiply=2.0;             // Multiply for Martingale
extern double     Lotsize=0.01;              // Lot size
extern double     TrailingStop=30;          // TrailingStop pips distance
extern int        Stop_Loss=100;            // Stop Loss pips distance
extern int        Take_Profit=50;           // Take Profit pips distance
extern int        MA_PERIOD=1;             // Moving Average Period
extern int        MA_PERIOD1=50;             // Moving Average Period
extern int        MagicNumber=562148;       // Magic Number
extern string     Timeset="Timeset";
extern int        Start=0;                  // Start hour
extern int        End=24;                   // End hour
extern int        Maximum_loss=3;           // Maximum allowed loss
extern int        WaitTime=180;             // Wait time for loss in minutes
int count_0=0;
datetime  TimeSent;
double pips;
int cnt,freeze_level;
//--- price levels for orders and positions
double priceopen,stoploss,takeprofit;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize==0.00001 || ticksize==0.001)
      pips=ticksize*10;
   else pips=ticksize;
   return(INIT_SUCCEEDED);
   freeze_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   if(freeze_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_FREEZE_LEVEL=%d: order or position modification is not allowed,"+
                  " if there are %d points to the activation price",freeze_level,freeze_level);
     }

  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Check for New Bar (Compatible with both MQL4 and MQL5)
   static datetime dtBarCurrent=WRONG_VALUE;
   datetime dtBarPrevious=dtBarCurrent;
   dtBarCurrent=(datetime) SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   bool NewBarFlag=(dtBarCurrent!=dtBarPrevious);
   if(NewBarFlag)
     {
      //--- check for history and trading
      if(Bars<100)
        {
         Print("bars less than 100");
         return;
        }
      if(IsTradeAllowed()==false)
        {
         Print("Trade IS NOT Allowed");
         return;
        }
      //----
/*if(GetLastError()==134) return;
   if(Start>End)
      if(Hour() >= End && Hour() < Start) return;
   if(Start<End)
      if(Hour() < Start || Hour() >= End) return;*/
      switch(Strategy)

         //+------------------------------------------------------------------+
         //|                          Martingale 1                            |
         //+------------------------------------------------------------------+  
         ///////////////////////////////////////////////////////Martingale :////////////////////////////////////////////////
        {
         case    Martingale1 :
           {

            //--- check for history and trading
            if(Bars<100)
              {
               Print("bars less than 100");
               return;
              }
            if(IsTradeAllowed()==false)
              {
               Print("Trade IS NOT Allowed");
               return;
              }

            //----
            if(Start>End)
               if(Hour() >= End && Hour() < Start) return;
            if(Start<End)
               if(Hour() < Start || Hour() >= End) return;
            //----
            if(GetLastError()==134) return;
            double   LastLots=0;
            int OrderType_last_loss=-1,OrderType_last_win=-1;
            datetime  last_OrderCloseTime_win=-1,last_OrderCloseTime_loss=-1;

            for(int i=0; i<OrdersHistoryTotal(); i++)
              {
               LastLots=0;
               if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true && 
                  OrderMagicNumber()==MagicNumber)
               if(LastLots<OrderLots()) {LastLots=NormalizeDouble(OrderLots(),Digits);}
                 {
                  if(OrderProfit()>0)// last order win 
                    {
                     OrderType_last_win=OrderType();
                     last_OrderCloseTime_win=OrderCloseTime();
                    }
                  if(OrderProfit()<0)// last order loss
                    {
                     OrderType_last_loss=OrderType();
                     last_OrderCloseTime_loss=OrderCloseTime();
                     count_0++;
                    }
                 }
              }
            //-----------------------------------------------------------
            if(count_0>Maximum_loss)
               Sleep(6000*WaitTime);
            if(last_OrderCloseTime_win<last_OrderCloseTime_loss)// last order win or loss ? 
               //if(Multiply<1)Multiply=1;
              {

/** if(AccountFreeMargin()<(1000*LastLots*Multiply))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               return;
              }*/

               if(trade()==2) {Open_Order(OP_SELL,LastLots);Trail1();}
               if(trade()==1) {Open_Order(OP_BUY ,LastLots);Trail1();}
               //  break;

              }

            //--- no opened orders identified
            // if(OrdersTotal()==0)
            if(OrdersTotal()==0)
               //  if(OrdersTotal()==0)
              {
               if(Volume[0]>1) return;
               if(AccountFreeMargin()<(1000*Lotsize))//check for money ?
                 {
                  Print("We have no money. Free Margin = ",AccountFreeMargin());
                  return;
                 }
               // Buy order                                                             
               if(trade()==1)//if(Ask>iOpen(NULL,PERIOD_MN1,0))
                 {Open_Order1(OP_BUY,Lotsize);Trail1();}
               // Sell Order                                                             
               if(trade()==2) //if(Bid<iOpen(NULL,PERIOD_MN1,0))
                 {Open_Order1(OP_SELL,Lotsize);Trail1();}
              }
            //break;
           }
         break;

         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+     
         //////////////////////////////////////////////////////Trailing_stop://////////////////////////////////////////////////////////////////////
         case      Martingale2:
           {

            //--- check for history and trading
            if(Bars<100)
              {
               Print("bars less than 100");
               return;
              }
            if(IsTradeAllowed()==false)
              {
               Print("Trade IS NOT Allowed");
               return;
              }

            //----
            if(Start>End)
               if(Hour() >= End && Hour() < Start) return;
            if(Start<End)
               if(Hour() < Start || Hour() >= End) return;
            //----
            if(GetLastError()==134) return;
            double   LastLots=0;
            int OrderType_last_loss=-1,OrderType_last_win=-1;
            datetime  last_OrderCloseTime_win=-1,last_OrderCloseTime_loss=-1;

            for(int i=0; i<OrdersHistoryTotal(); i++)
              {
               LastLots=0;
               if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true && 
                  OrderMagicNumber()==MagicNumber)
               if(LastLots<OrderLots()) {LastLots=NormalizeDouble(OrderLots(),Digits);}
                 {
                  if(OrderProfit()>0)// last order win 
                    {
                     OrderType_last_win=OrderType();
                     last_OrderCloseTime_win=OrderCloseTime();
                    }
                  if(OrderProfit()<0)// last order loss
                    {
                     OrderType_last_loss=OrderType();
                     last_OrderCloseTime_loss=OrderCloseTime();
                     count_0++;
                    }
                 }
              }
            //-----------------------------------------------------------
            if(count_0>Maximum_loss)
               Sleep(6000*WaitTime);
            if(last_OrderCloseTime_win<last_OrderCloseTime_loss)// last order win or loss ? 
               //if(Multiply<1)Multiply=1;
              {
               //if(Volume[0]>1) return;
/** if(AccountFreeMargin()<(1000*LastLots*Multiply))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               return;
              }*/

               if(OrderType_last_loss ==0) {Open_Order(OP_SELL,LastLots);Trail1();}
               if(OrderType_last_loss ==1) {Open_Order(OP_BUY ,LastLots);Trail1();}
               //  break;

              }

            //--- no opened orders identified
            // if(OrdersTotal()==0)
            if(OrdersTotal()==0)
               // if(OrdersTotal()==0)
              {
               // if(Volume[0]>1) return;
               if(AccountFreeMargin()<(1000*Lotsize))//check for money ?
                 {
                  Print("We have no money. Free Margin = ",AccountFreeMargin());
                  return;
                 }
               // Buy order                                                             
               if(trade()==1)//if(Ask>iOpen(NULL,PERIOD_MN1,0))
                 {Open_Order1(OP_BUY,Lotsize);Trail1();}
               // Sell Order                                                             
               if(trade()==2) //if(Bid<iOpen(NULL,PERIOD_MN1,0))
                 {Open_Order1(OP_SELL,Lotsize);Trail1();}
              }
            //break;
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                           Open_Order                             |
//+------------------------------------------------------------------+ 

//============================ Open_Order=======================================
int Open_Order(int tip,double llots)//martingale
  {

   int ticket=-1;
//if(OrdersTotal()==0)
   if(openorderthispair(Symbol())==0)
     {
      if(tip==0)
        {
         while(ticket==-1)
           {

            if(((AccountStopoutMode()==1) && 
               (AccountFreeMarginCheck(Symbol(),OP_BUY,LotsOptimized1Mx(llots))>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) && 
               ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,LotsOptimized1Mx(llots)))*100)>AccountStopoutLevel())))
               if(AccountFreeMarginCheck(Symbol(),OP_BUY,LotsOptimized1Mx(llots)))
                  if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx(llots*Multiply),OP_BUY))
                     if(ticket>0)
                       {
                        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                           Print("BUY order opened : ",OrderOpenPrice());
                        Alert("we just got a buy signal on the ",_Period,"M",_Symbol);
                        SendNotification("we just got a buy signal on the1 "+(string)_Period+"M"+_Symbol);
                        SendMail("Order sent successfully","we just got a buy signal on the1 "+(string)_Period+"M"+_Symbol);
                       }
            if(AccountFreeMargin()<(10000*llots))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               break;
              }
            ticket=OrderSend(Symbol(),OP_BUY,LotsOptimizedMx(llots*Multiply),ND(Ask),3,NDTP(Bid-Stop_Loss*pips),NDTP(Bid+Take_Profit*pips),"Long 1",MagicNumber,0,PaleGreen);
            if(ticket>-1) break;

           }
        }

      if(tip==1)
        {
         ticket=-1;
         while(ticket==-1)
           {

            if(((AccountStopoutMode()==1) && 
               (AccountFreeMarginCheck(Symbol(),OP_SELL,LotsOptimized1Mx(llots))>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) && 
               ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_SELL,LotsOptimized1Mx(llots)))*100)>AccountStopoutLevel())))
               if(AccountFreeMarginCheck(Symbol(),OP_SELL,LotsOptimized1Mx(llots)))
                  if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx(llots),OP_SELL))
                     if(ticket>0)
                       {
                        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                           Print("SELL order opened : ",OrderOpenPrice());
                        Alert("we just got a sell signal on the ",_Period,"M",_Symbol);
                        SendMail("Order sent successfully","we just got a sell signal on the "+(string)_Period+"M"+_Symbol);
                       }
            if(AccountFreeMargin()<(10000*llots))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               break;
              }
            ticket=OrderSend(Symbol(),OP_SELL,LotsOptimizedMx(llots*Multiply),ND(Bid),3,NDTP(Ask+Stop_Loss*pips),NDTP(Ask-Take_Profit*pips),"Short 1",MagicNumber,0,Red);
            if(ticket>-1) break;

           }
        }
     }
//-----------
   return(0);
  }
//+------------------------------------------------------------------+
//|                           Open_Order1                            |
//+------------------------------------------------------------------+
//============================ Open_Order1=======================================
int Open_Order1(int tip,double llots)
  {
   int ticket=-1;
   if(OrdersTotal()==0)
     {
      if(tip==0)
        {
         while(ticket==-1)
           {

            if(((AccountStopoutMode()==1) && 
               (AccountFreeMarginCheck(Symbol(),OP_BUY,llots)>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) && 
               ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,llots))*100)>AccountStopoutLevel())))
               if(CheckMoneyForTrade(Symbol(),LotsOptimized1x(),OP_BUY))
                  if(ticket>0)
                    {
                     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                        Print("BUY order opened : ",OrderOpenPrice());
                     Alert("we just got a buy signal on the ",_Period,"M",_Symbol);
                     SendNotification("we just got a buy signal on the1 "+(string)_Period+"M"+_Symbol);
                     SendMail("Order sent successfully","we just got a buy signal on the1 "+(string)_Period+"M"+_Symbol);
                    }
            if(AccountFreeMargin()<(10000*llots))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               break;
              }
            ticket=OrderSend(Symbol(),OP_BUY,LotsOptimizedMx(Lotsize),ND(Ask),3,NDTP(Bid-Stop_Loss*pips),NDTP(Bid+Take_Profit*pips),"Long 1",MagicNumber,0,PaleGreen);
            if(ticket>-1) break;

           }
        }

      if(tip==1)
        {
         ticket=-1;
         while(ticket==-1)
           {

            if(((AccountStopoutMode()==1) && 
               (AccountFreeMarginCheck(Symbol(),OP_SELL,llots)>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) && 
               ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_SELL,llots))*100)>AccountStopoutLevel())))
               if(CheckMoneyForTrade(Symbol(),LotsOptimized1x(),OP_SELL))
                  if(ticket>0)
                    {
                     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                        Print("SELL order opened : ",OrderOpenPrice());
                     Alert("we just got a sell signal on the ",_Period,"M",_Symbol);
                     SendMail("Order sent successfully","we just got a sell signal on the "+(string)_Period+"M"+_Symbol);
                    }
            if(AccountFreeMargin()<(10000*llots))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               break;
              }
            ticket=OrderSend(Symbol(),OP_SELL,LotsOptimizedMx(Lotsize),ND(Bid),3,NDTP(Ask+Stop_Loss*pips),NDTP(Ask-Take_Profit*pips),"Short 1",MagicNumber,0,Red);
            if(ticket>-1) break;

           }
        }
     }
//-----------
   return(0);
  }
//+------------------------------------------------------------------+
//| Trailing stop loss                                               |
//+------------------------------------------------------------------+ 
// --------------- ----------------------------------------------------------- ------------------------                    
void Trail1()
  {
   int total=OrdersTotal();
//--- it is important to enter the market correctly, but it is more important to exit it correctly...   
   for(cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {

            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>pips*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-pips*TrailingStop)
                    {

                     RefreshRates();
                     stoploss=Bid-(pips*TrailingStop);
                     double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
                     if(stoploss<StopLevel*pips) stoploss=StopLevel*pips;
                     string symbol=OrderSymbol();
                     double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
                     if(MathAbs(OrderStopLoss()-stoploss)>point)
                        if((pips*TrailingStop)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*pips)

                           //--- modify order and exit
                           if(CheckStopLoss_Takeprofit(OP_BUY,Bid-pips*TrailingStop,OrderTakeProfit()))
                              if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),Bid-pips*TrailingStop,OrderTakeProfit()))
                                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-pips*TrailingStop,OrderTakeProfit(),0,Green))
                                    Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
         else // go to short position
           {
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(pips*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+pips*TrailingStop)) || (OrderStopLoss()==0))
                    {

                     RefreshRates();
                     stoploss=Ask+(pips*TrailingStop);
                     double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
                     if(stoploss<StopLevel*pips) stoploss=StopLevel*pips;
                     string symbol=OrderSymbol();
                     double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
                     if(MathAbs(OrderStopLoss()-stoploss)>point)
                        if((pips*TrailingStop)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*pips)

                           //--- modify order and exit
                           if(CheckStopLoss_Takeprofit(OP_SELL,Ask+pips*TrailingStop,OrderTakeProfit()))
                              if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),Ask+pips*TrailingStop,OrderTakeProfit()))
                                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+pips*TrailingStop,OrderTakeProfit(),0,Red))
                                    Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
//              IfOrderDoesNotExistBuy
//+---------------------------------------------------------------------------+
bool IfOrderDoesNotExistBuy()
  {
   bool exists=false;
   for(int i=OrdersTotal(); i>=0; i--)
     {

      if(OrderSelect(i,SELECT_BY_POS)==true && OrderSymbol()==Symbol())
        {
         exists = true; return(exists);
           }else{
         Print("OrderSelect() error - ",(GetLastError()));
        }
     }

   if(exists==false)
     {
      //BuyOrderType();
      // return(exists);
     }
   return(0);
  }
//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------   
int trade()
//trading conditions
  {
   if(iMA(Symbol(),0,MA_PERIOD,0,0,0,1)<iMA(Symbol(),0,MA_PERIOD1,0,0,0,1))//BUY
      return(1);
   else if(iMA(Symbol(),0,MA_PERIOD,0,0,0,1)>iMA(Symbol(),0,MA_PERIOD1,0,0,0,1))//SELL

   return(2);
   return(0);  
  }
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
int openorderthispair(string pair)//בוחרים עסקה בצמד המטבעות הנוכחי
  {
   int total=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))Print("eror");//בודקים אם ישנה עסקה פתוחה בצמד הנוכחי
      if(OrderSymbol()==pair) total++;//סופרים סך הכל עסקאות
     }
   return(total);
  }
//-----------------------------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
double ND(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimizedMx(double llots)
  {
   double lots=llots;
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lots<minlot)
     {
      lots=minlot;
      Print("Volume is less than the minimal allowed ,we use",minlot);
     }
//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lots>maxlot)
     {
      lots=maxlot;
      Print("Volume is greater than the maximal allowed,we use",maxlot);
     }
//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lots/volume_step);
   if(MathAbs(ratio*volume_step-lots)>0.0000001)
     {
      lots=ratio*volume_step;

      Print("Volume is not a multiple of the minimal step ,we use the closest correct volume ",ratio*volume_step);
     }

   return(lots);

  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized1Mx(double llots)
  {
   double lots=llots;
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lots<minlot)
     { lots=minlot; }
//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lots>maxlot)
     { lots=maxlot;  }
//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lots/volume_step);
   if(MathAbs(ratio*volume_step-lots)>0.0000001)
     {  lots=ratio*volume_step;}
   if(((AccountStopoutMode()==1) && 
      (AccountFreeMarginCheck(Symbol(),OP_BUY,lots)>AccountStopoutLevel()))
      || ((AccountStopoutMode()==0) && 
      ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,lots))*100)>AccountStopoutLevel())))
      return(lots);
/* else  Print("StopOut level  Not enough money for ",OP_SELL," ",lot," ",Symbol());*/
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized1x()
  {
   double lots=Lotsize;
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lots<minlot)
     { lots=minlot; }
//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lots>maxlot)
     { lots=maxlot;  }
//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lots/volume_step);
   if(MathAbs(ratio*volume_step-lots)>0.0000001)
     {  lots=ratio*volume_step;}
   return(lots);
  }
//+------------------------------------------------------------------+
double NDTP(double val)
  {
   RefreshRates();
   double SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(val<StopLevel*pips+SPREAD*pips) val=StopLevel*pips+SPREAD*pips;
// double STOPLEVEL = MarketInfo(Symbol(),MODE_STOPLEVEL);
//int Stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);

//if (Stops_level*pips<val-Bid)
//val=Ask+Stops_level*pips;
   return(NormalizeDouble(val, Digits));
// return(val);
  }
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
//-- if there is not enough money
// else if(free_margin<0)
   if((((AccountStopoutMode()==1) && 
      (AccountFreeMarginCheck(symb,type,lots)<AccountStopoutLevel()))
      || ((AccountStopoutMode()==0) && 
      ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_SELL,lots))*100)<AccountStopoutLevel()))))
     {
      Print("StopOut level  Not enough money for ",OP_SELL," ",lots," ",Symbol());
      return(false);
     }
   else if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ",oper," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking the new values of levels before order modification      |
//+------------------------------------------------------------------+
bool OrderModifyCheck(int ticket,double price,double sl,double tp)
  {
//--- select order by ticket
   if(OrderSelect(ticket,SELECT_BY_TICKET))
     {
      //--- point size and name of the symbol, for which a pending order was placed
      string symbol=OrderSymbol();
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      //--- check if there are changes in the Open price
      bool PriceOpenChanged=true;
      int type=OrderType();
      if(!(type==OP_BUY || type==OP_SELL))
        {
         PriceOpenChanged=(MathAbs(OrderOpenPrice()-price)>point);
        }
      //--- check if there are changes in the StopLoss level
      bool StopLossChanged=(MathAbs(OrderStopLoss()-sl)>point);
      //--- check if there are changes in the Takeprofit level
      bool TakeProfitChanged=(MathAbs(OrderTakeProfit()-tp)>point);
      //--- if there are any changes in levels
      if(PriceOpenChanged || StopLossChanged || TakeProfitChanged)
         return(true);  // order can be modified      
      //--- there are no changes in the Open, StopLoss and Takeprofit levels
      else
      //--- notify about the error
         PrintFormat("Order #%d already has levels of Open=%.5f SL=%.5f TP=%.5f",
                     ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
     }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying 
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type,double SL,double TP)
  {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must"+
                  " not be nearer than %d points from the closing price",stops_level,stops_level);
     }
//---
   bool SL_check=false,TP_check=false;
//--- check only two order types
   switch(type)
     {
      //--- Buy operation
      case  ORDER_TYPE_BUY:
        {
         //--- check the StopLoss
         SL_check=(Bid-SL>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
                        " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SL,Bid-stops_level*_Point,Bid,stops_level);
         //--- check the TakeProfit
         TP_check=(TP-Bid>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f"+
                        " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TP,Bid+stops_level*_Point,Bid,stops_level);
         //--- return the result of checking
         return(SL_check&&TP_check);
        }
      //--- Sell operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
         SL_check=(SL-Ask>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
                        " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SL,Ask+stops_level*_Point,Ask,stops_level);
         //--- check the TakeProfit
         TP_check=(Ask-TP>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f "+
                        " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TP,Ask-stops_level*_Point,Ask,stops_level);
         //--- return the result of checking
         return(TP_check&&SL_check);
        }
      break;
     }
//--- a slightly different function is required for pending orders
   return false;
  }
//+------------------------------------------------------------------+   
