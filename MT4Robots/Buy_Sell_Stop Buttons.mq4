//+------------------------------------------------------------------+
//|                            BUY SELL STOP BUTTONS v1              |
//|             http://algorithmic-trading-ea-mt4.000webhostapp.com/ |
//|                                                    AHARON TZADIK |
//+------------------------------------------------------------------+
#property copyright   "AHARON TZADIK"
#property link        "http://algorithmic-trading-ea-mt4.000webhostapp.com/"
#property version   "1.00"
#property strict

extern bool           USEMOVETOBREAKEVEN=true;//Enable "no loss"
extern double         WHENTOMOVETOBE=10;      //When to move break even
extern double         PIPSTOMOVESL=5;         //How much pips to move sl
extern double         Lots=0.01;              //Lots size 
input  double         MaximumRisk   =0.02;
input  double         DecreaseFactor=3;
extern double         TrailingStop=40;        //TrailingStop 
extern double         Stop_Loss=20;           //Stop Loss 
input  double         TakeProfit=50;          //TakeProfit 
input  int            MagicNumber=1111;
double buyprice;
bool result;
double priceopen,stoploss,takeprofit;
int           ticket,err,T;
double        pips;
//+-----------------
int total=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()

//-----------------------------------------------------------------------------------------------------------  
  {
   b1();
   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize==0.00001 || Point==0.01)
      pips=ticksize*10;
   else pips=ticksize;

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("BUY");
   ObjectDelete("SELL");
   ObjectDelete("CLOSE");
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   stop();
   if(USEMOVETOBREAKEVEN) MOVETOBREAKEVEN();
   Trail1();
//------------------------------------------------------------------------------  
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK && sparam=="BUY"){BUY();}
   if(id==CHARTEVENT_OBJECT_CLICK && sparam=="SELL"){SELL();}
   if(id==CHARTEVENT_OBJECT_CLICK && sparam=="CLOSE"){exitbuys();exitsells();}
//---

  }
//+------------------------------------------------------------------+  
//---  (BUY) possibility
//+------------------------------------------------------------------+ 
//| BUY                      BUY                 BUY                 |
//+------------------------------------------------------------------+  
//------------------------------------------------------------------------------------
void BUY()
  {
   ticket=OrderSend(Symbol(),OP_BUY,LotsOptimized(),ND(Ask),3,NDTP(Bid-Stop_Loss*pips),NDTP(Bid+TakeProfit*pips),"renko",MagicNumber,0,PaleGreen);
   if(ticket>0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
         Print("BUY order opened : ",OrderOpenPrice());
     }
   else
      Print("Error opening BUY order : ",GetLastError());
// return;
  }
//+------------------------------------------------------------------+  
//--- (SELL) possibility
//+------------------------------------------------------------------+
//| SELL             SELL                       SELL                 |
//+------------------------------------------------------------------+                  
//------------------------------------------------------------------------------------
void SELL()
  {
   ticket=OrderSend(Symbol(),OP_SELL,LotsOptimized(),ND(Bid),3,NDTP(Ask+Stop_Loss*pips),NDTP(Ask-TakeProfit*pips),"Short 1",MagicNumber,0,Red);
   if(ticket>0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
         Print("SELL order opened : ",OrderOpenPrice());
     }
   else
      Print("Error opening SELL order : ",GetLastError());
//return;
  }
//--- exit from the "no opened orders" block

//+------------------------------------------------------------------+
//|   stop                                                           |
//+------------------------------------------------------------------+   
//-----------------------------------------------------------------------------+ 
void stop()
  {
   int cnt;
//+------------------------------------------------------------------+
   double middleBB=iBands(Symbol(),0,20, 2,0,0,MODE_MAIN,1);//middle
   double lowerBB=iBands(Symbol(),0,20, 2,0,0,MODE_LOWER,1);//lower
   double upperBB=iBands(Symbol(),0,20, 2,0,0,MODE_UPPER,1);//upper
//+------------------------------------------------------------------+                                        
   double  MacdMAIN=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
//+------------------------------------------------------------------+       
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
            //--- should it be closed?

            if(((Bid<OrderOpenPrice()-iATR(NULL,0,14,0))
               || ((MacdMAIN>0 && MacdMAIN<MacdSIGNAL) || (MacdMAIN<0 && (MathAbs(MacdMAIN)>MathAbs(MacdSIGNAL))))
               || Close[1]==upperBB))
               exitbuys();
            //--- check for trailing stop
           }
         else // go to short position
           {
            //--- should it be closed?

            if(((Ask>OrderOpenPrice()+iATR(NULL,0,14,0))
               || ((MacdMAIN>0 && MacdMAIN>MacdSIGNAL) || (MacdMAIN<0 && (MathAbs(MacdMAIN)<MathAbs(MacdSIGNAL)))))
               || Close[1]==lowerBB)
               exitsells();
            //--- check for trailing stop
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Trailing stop loss                                               |
//+------------------------------------------------------------------+ 
// --------------- ----------------------------------------------------------- ------------------------                    
void Trail1()
  {
   total=OrdersTotal();
//--- it is important to enter the market correctly, but it is more important to exit it correctly...   
   for(int cnt=0;cnt<total;cnt++)
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
                     takeprofit=OrderTakeProfit()+pips*TrailingStop;
                     double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
                     if(stoploss<StopLevel*pips) stoploss=StopLevel*pips;
                     string symbol=OrderSymbol();
                     double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
                     if(MathAbs(OrderStopLoss()-stoploss)>point)
                        if((pips*TrailingStop)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*pips)

                           //--- modify order and exit
                           if(CheckStopLoss_Takeprofit(OP_BUY,stoploss,takeprofit))
                              if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit))
                                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0,Green))
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
                     takeprofit=OrderTakeProfit()-pips*TrailingStop;
                     double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
                     if(stoploss<StopLevel*pips) stoploss=StopLevel*pips;
                     if(takeprofit<StopLevel*pips) takeprofit=StopLevel*pips;
                     string symbol=OrderSymbol();
                     double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
                     if(MathAbs(OrderStopLoss()-stoploss)>point)
                        if((pips*TrailingStop)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*pips)

                           //--- modify order and exit
                           if(CheckStopLoss_Takeprofit(OP_SELL,stoploss,takeprofit))
                              if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit))
                                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0,Red))
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
//|                          MOVE TO BREAK EVEN                               |
//+---------------------------------------------------------------------------+
void MOVETOBREAKEVEN()

  {
   for(int b=OrdersTotal()-1;b>=0;b--)
     {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()!=MagicNumber)continue;
      if(OrderSymbol()==Symbol())
         if(OrderType()==OP_BUY)
            if(Bid-OrderOpenPrice()>WHENTOMOVETOBE*pips)
               if(OrderOpenPrice()>OrderStopLoss())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(PIPSTOMOVESL*pips),OrderTakeProfit(),0,CLR_NONE))
                     Print("eror");
     }

   for(int s=OrdersTotal()-1;s>=0;s--)
     {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()!=MagicNumber)continue;
      if(OrderSymbol()==Symbol())
         if(OrderType()==OP_SELL)
            if(OrderOpenPrice()-Ask>WHENTOMOVETOBE*pips)
               if(OrderOpenPrice()<OrderStopLoss())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(PIPSTOMOVESL*pips),OrderTakeProfit(),0,CLR_NONE))
                     Print("eror");
     }
  }
//--------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
//|                    exit                                          |
//+------------------------------------------------------------------+
void exit()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {

         //if(OrderType()==OP_SELL)
           {
            if((Ask==OrderTakeProfit()) || Bid==OrderStopLoss())//If one order closed than close all
               if(OrderType()==OP_SELL)
                 {
                  result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);//actual order closing
                  if(result!=true)//if it did not close
                    {
                     err=GetLastError(); Print("LastError = ",err);//get the reason why it didn't close
                    }
                 }
            else if(OrderType()==OP_BUY)
              {
               result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);//actual order closing
               if(result!=true)//if it did not close
                 {
                  err=GetLastError(); Print("LastError = ",err);//get the reason why it didn't close
                 }
              }
           }

        }
     }
  }
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
int openorderthispair(string pair)
  {
   total=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))Print("eror");//בודקים אם ישנה עסקה פתוחה בצמד הנוכחי
      if(OrderSymbol()==pair) total++;
     }
   return(total);
  }
//-----------------------------------------------------------------------------------------------------------   

//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
//-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ",oper," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume/*,string &description*/)

  {
   double lot=volume;
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>max_volume)

      Print("Volume is greater than the maximal allowed ,we use",max_volume);
//  return(false);

//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minlot)

      Print("Volume is less than the minimal allowed ,we use",minlot);
//  return(false);

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lot/volume_step);
   if(MathAbs(ratio*volume_step-lot)>0.0000001)
     {
      Print("Volume is not a multiple of the minimal step ,we use, the closest correct volume is %.2f",
            volume_step,ratio*volume_step);
      //   return(false);
     }
//  description="Correct volume value";
   return(true);
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
int b1()
  {
   int chart_ID=0;
   string name="BUY";
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,150);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,50);
//--- set button size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,100);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,100);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,0);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,"BUY");
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,12);
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrBlue);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,clrGray);
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,clrBlack);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,false);
//--- set button state 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,false);
//--- enable (true) or disable (false) the mode of moving the button by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
//--- hide ( true)or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,false);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution 

//+------------------------------------------------------------------+
//| SELL                                                             |
//+------------------------------------------------------------------+ 
   string name1="SELL";
   if(!ObjectCreate(0,name1,OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name1,OBJPROP_XDISTANCE,250);
   ObjectSetInteger(chart_ID,name1,OBJPROP_YDISTANCE,50);
//--- set button size 
   ObjectSetInteger(chart_ID,name1,OBJPROP_XSIZE,100);
   ObjectSetInteger(chart_ID,name1,OBJPROP_YSIZE,100);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name1,OBJPROP_CORNER,0);
//--- set the text 
   ObjectSetString(chart_ID,name1,OBJPROP_TEXT,"SELL");
//--- set text font 
   ObjectSetString(chart_ID,name1,OBJPROP_FONT,"Arial");
//--- set font size 
   ObjectSetInteger(chart_ID,name1,OBJPROP_FONTSIZE,12);
//--- set text color 
   ObjectSetInteger(chart_ID,name1,OBJPROP_COLOR,clrRed);
//--- set background color 
   ObjectSetInteger(chart_ID,name1,OBJPROP_BGCOLOR,clrGray);
//--- set border color 
   ObjectSetInteger(chart_ID,name1,OBJPROP_BORDER_COLOR,clrBlack);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name1,OBJPROP_BACK,false);
//--- set button state 
   ObjectSetInteger(chart_ID,name1,OBJPROP_STATE,false);
//--- enable (true) or disable (false) the mode of moving the button by mouse 
   ObjectSetInteger(chart_ID,name1,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name1,OBJPROP_SELECTED,false);
//--- hide ( true)or display (false) graphical object name1 in the object list 
   ObjectSetInteger(chart_ID,name1,OBJPROP_HIDDEN,false);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name1,OBJPROP_ZORDER,0);
//--- successful execution 

//+------------------------------------------------------------------+
//| CLOSE                                                             |
//+------------------------------------------------------------------+ 
   string name2="CLOSE";
   if(!ObjectCreate(0,name2,OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name2,OBJPROP_XDISTANCE,350);
   ObjectSetInteger(chart_ID,name2,OBJPROP_YDISTANCE,50);
//--- set button size 
   ObjectSetInteger(chart_ID,name2,OBJPROP_XSIZE,100);
   ObjectSetInteger(chart_ID,name2,OBJPROP_YSIZE,100);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name2,OBJPROP_CORNER,0);
//--- set the text 
   ObjectSetString(chart_ID,name2,OBJPROP_TEXT,"CLOSE");
//--- set text font 
   ObjectSetString(chart_ID,name2,OBJPROP_FONT,"Arial");
//--- set font size 
   ObjectSetInteger(chart_ID,name2,OBJPROP_FONTSIZE,12);
//--- set text color 
   ObjectSetInteger(chart_ID,name2,OBJPROP_COLOR,clrRed);
//--- set background color 
   ObjectSetInteger(chart_ID,name2,OBJPROP_BGCOLOR,clrGray);
//--- set border color 
   ObjectSetInteger(chart_ID,name2,OBJPROP_BORDER_COLOR,clrBlack);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name2,OBJPROP_BACK,false);
//--- set button state 
   ObjectSetInteger(chart_ID,name2,OBJPROP_STATE,false);
//--- enable (true) or disable (false) the mode of moving the button by mouse 
   ObjectSetInteger(chart_ID,name2,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name2,OBJPROP_SELECTED,false);
//--- hide ( true)or display (false) graphical object name1 in the object list 
   ObjectSetInteger(chart_ID,name2,OBJPROP_HIDDEN,false);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name2,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);


  }
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized1Mx1(double llots)
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
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
   if(MaximumRisk>0)
     {
      lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
     }
//--- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
           {
            Print("Error in history!");
            break;
           }
         if(OrderSymbol()!=Symbol() /*|| OrderType()>OP_SELL*/)
            continue;
         //---
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minlot)
     { lot=minlot; }
// Print("Volume is less than the minimal allowed ,we use",minlot);}
// lot=minlot;

//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>maxlot)
     { lot=maxlot;  }
//  Print("Volume is greater than the maximal allowed,we use",maxlot);}
// lot=maxlot;

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lot/volume_step);
   if(MathAbs(ratio*volume_step-lot)>0.0000001)
     {  lot=ratio*volume_step;}
   return(lot);
/* else  Print("StopOut level  Not enough money for ",OP_SELL," ",lot," ",Symbol());
   return(0);*/
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double ND(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+ 
////////////////////////////////////////////////////////////////////////////////////
int getOpenOrders()
  {

   int Orders=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        {
         continue;
        }
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
        {
         continue;
        }
      Orders++;
     }
   return(Orders);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Checking the new values of levels before order modification      |
//+------------------------------------------------------------------+
bool OrderModifyCheck(int Ticket,double price,double sl,double tp)
  {
//--- select order by ticket
   if(OrderSelect(Ticket,SELECT_BY_TICKET))
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
                     Ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
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

//+------------------------------------------------------------------+
//|                                      exitbuys()                  |
//+------------------------------------------------------------------+
void exitbuys()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
            if(result!=true)//if it did not close
              {
               err=GetLastError(); Print("LastError = ",err);//get the reason why it didn't close
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+  
//+------------------------------------------------------------------+
//|                    exitsells()                                   |
//+------------------------------------------------------------------+
void exitsells()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {

         if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
            if(result!=true)//if it did not close
              {
               err=GetLastError(); Print("LastError = ",err);//get the reason why it didn't close
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
