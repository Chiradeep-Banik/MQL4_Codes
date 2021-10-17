//+------------------------------------------------------------------+
//|                                                    SL_to_Bar.mq4 |
//|                               Copyright © 2009, Vladimir Hlystov |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
 
#property indicator_chart_window
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Red
 
//+------------------------------------------------------------------+
extern int   BAR            = 200;//searching for in last BAR bar
extern int   minSL          = 25;//it is exposed when 2 bars are not found
extern bool  show_bar       = true;//show bars on which search for SL
extern bool  show_info      = true;//show warrant on which is not installed by SL
extern color color_BAR      = DarkSlateGray;//colour bar on which search for SL
extern color color_Òåê_BAR  = Gray;//colour of the current bar
extern color color_SL       = Gray;//colour of the marks
//+------------------------------------------------------------------+
int per,Ask_Bid,TstartSell,TstartBay;
color colmet;
double SLSell_old,SLBay_old,SLSell[],SLBay[];
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
//---- indicator buffers mapping
   SetIndexBuffer(0,SLSell);
   SetIndexBuffer(1,SLBay);
//---- name for DataWindow and indicator subwindow label
   SetIndexLabel(0,"SL Sell");
   SetIndexLabel(1,"SL Bay");
//---- initialization done
      per=Period();
      Ask_Bid = MarketInfo(Symbol(),MODE_STOPLEVEL);
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   del("SL");
/*   ObjectDelete("SL-UP-bar ");
   ObjectDelete("SL-LO-bar ");
   ObjectDelete("SL-0-bar");
   ObjectDelete("SL for Sell ");
   ObjectDelete("SL for Bay ");*/
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   double SL_Bay =Stop_Loss( 1,Time[0]);
   double SL_Sell=Stop_Loss(-1,Time[0]);
   string info;
   //-----------------------------------------------------------------
   int counted_bars = IndicatorCounted();      
   if(counted_bars > 0) counted_bars--;
   int limit = Bars-counted_bars;
   double SL;
   for(int i=0; i<limit; i++) 
   {
      SL = Stop_Loss( 1,Time[i]);
      if (SL!=0) SLSell[i] = SL;
      SL = Stop_Loss(-1,Time[i]);
      if (SL!=0) SLBay[i] = SL;
   }
   //-----------------------------------------------------------------
   Drawfoots(SL_Sell,SL_Bay);
   if (show_info)
   {
      for (i=0; i<OrdersTotal(); i++)
      {
         if((OrderSelect(i, SELECT_BY_POS)==true) && (OrderSymbol()==Symbol()))
         { 
            if (OrderType()<2)  //Bay or Sell
            {
               if (OrderStopLoss()==0)
               {
                  info=info+"Îðäåð "+OrderTicket()+" áåç SL\n";
               }
            }
         }
      }
      Comment(info);
   }
   return(0);
  }
//+------------------------------------------------------------------+
//æææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææææ
//////////////////////////////////////////////////////////////////////
//    Stop_Loss                                                     // 
//    Returns importance SL for operation of the buying or sale     //
//                         "Copyright © 2009, Vladimir Hlystov"     //
//                                          "cmillion@narod.ru"     //
//    direction = 1 Bay           -1 Sell                           //
//                                                                  //
//////////////////////////////////////////////////////////////////////
double Stop_Loss(int direction, int TimeBar) //TimeBar - âðåìÿ íà÷àëà òåê áàðà
{
   if (direction == 0) return (0);
   int i;
   int timeframe,toBar,tf; 
   double SL_toBar,
          max_toBar,
          min_toBar;
   timeframe=next_period(per+1);
   int tekBar = iBarShift(NULL,timeframe,TimeBar,false); //Ïîèñê áàðà ïî âðåìåíè. Ôóíêöèÿ âîçâðàùàåò ñìåùåíèå áàðà, êîòîðîìó ïðèíàäëåæèò óêàçàííîå âðåìÿ.   
   Comment(tekBar);
   double max_0Bar = iHigh( NULL, timeframe, tekBar);
   double min_0Bar = iLow ( NULL, timeframe, tekBar);
   if ( direction ==1 ) //Bay
   {
      SL_toBar=0;
      for (toBar=1+tekBar; toBar<BAR+tekBar; toBar++)
      {
         max_toBar = iHigh( NULL, timeframe, toBar);
         min_toBar = iLow ( NULL, timeframe, toBar);
         if ( max_0Bar > max_toBar && min_0Bar > min_toBar)
         {
            SL_toBar = min_toBar-Point*Ask_Bid;
            if (show_bar==true){
               ObjectDelete("SL-UP-bar ");
               ObjectCreate("SL-UP-bar ", OBJ_RECTANGLE, 0, 0,0, 0,0);
               ObjectSet   ("SL-UP-bar ", OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet   ("SL-UP-bar ", OBJPROP_COLOR, color_BAR);
               ObjectSet   ("SL-UP-bar ", OBJPROP_BACK, true);
               ObjectSet   ("SL-UP-bar ", OBJPROP_TIME1 , iTime( NULL, timeframe, toBar-1));
               ObjectSet   ("SL-UP-bar ", OBJPROP_PRICE1, SL_toBar);
               ObjectSet   ("SL-UP-bar ", OBJPROP_TIME2 , iTime( NULL, timeframe, toBar));
               ObjectSet   ("SL-UP-bar ", OBJPROP_PRICE2, max_toBar);}
            break;
         }
      }
/*      if (SL_toBar==0)//No SL
      {  tf=timeframe;
         for (i=1; i<5; i++)
         {
            tf=next_period(tf+1);
            if ((iLow(NULL,tf,0)-Point*Ask_Bid) < (Bid-Point*minSL))
            {
               SL_toBar=iLow(NULL,tf,0)-Point*Ask_Bid;
               if (show_bar==true){
                  ObjectDelete("SL-UP-bar ");
                  ObjectCreate("SL-UP-bar ", OBJ_RECTANGLE, 0, 0,0, 0,0);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_COLOR, Red);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_BACK, false);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_TIME1 , iTime( NULL, tf, 0));
                  ObjectSet   ("SL-UP-bar ", OBJPROP_PRICE1, SL_toBar);
                  ObjectSet   ("SL-UP-bar ", OBJPROP_TIME2 , CurTime());
                  ObjectSet   ("SL-UP-bar ", OBJPROP_PRICE2, iHigh( NULL, tf, 0));}
               break;
            }
         }
      }*/
   }
   if ( direction ==-1 ) //Sell
   {
      SL_toBar=0;
      for (toBar=1+tekBar; toBar<BAR+tekBar; toBar++) 
      {
         max_toBar = iHigh( NULL, timeframe, toBar);
         min_toBar = iLow ( NULL, timeframe, toBar);
         if ( max_0Bar < max_toBar && min_0Bar < min_toBar)
         {
            SL_toBar = max_toBar+Point*Ask_Bid;
            if (show_bar==true){
               ObjectDelete("SL-LO-bar ");
               ObjectCreate("SL-LO-bar ", OBJ_RECTANGLE, 0, 0,0, 0,0);
               ObjectSet   ("SL-LO-bar ", OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet   ("SL-LO-bar ", OBJPROP_COLOR, color_BAR);
               ObjectSet   ("SL-LO-bar ", OBJPROP_BACK, true);
               ObjectSet   ("SL-LO-bar ", OBJPROP_TIME1 , iTime( NULL, timeframe, toBar-1));
               ObjectSet   ("SL-LO-bar ", OBJPROP_PRICE1, min_toBar);
               ObjectSet   ("SL-LO-bar ", OBJPROP_TIME2 , iTime( NULL, timeframe, toBar));
               ObjectSet   ("SL-LO-bar ", OBJPROP_PRICE2, SL_toBar);}
            break;
         }
      }
/*      if (SL_toBar==0)//No SL
      {  tf=timeframe;
         for (i=1; i<5; i++)
         {
            tf=next_period(tf+1);
            if ((iHigh(NULL,tf,0)+Point*Ask_Bid) > (Ask+Point*minSL))
            {
               SL_toBar=iHigh(NULL,tf,0)+Point*Ask_Bid;
               if (show_bar==true){
                  ObjectDelete("SL-LO-bar ");
                  ObjectCreate("SL-LO-bar ", OBJ_RECTANGLE, 0, 0,0, 0,0);
                  ObjectSet   ("SL-LO-bar ", OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet   ("SL-LO-bar ", OBJPROP_COLOR, Red);
                  ObjectSet   ("SL-LO-bar ", OBJPROP_BACK, false);
                  ObjectSet   ("SL-LO-bar ", OBJPROP_TIME1 , iTime( NULL, tf, 0));
                  ObjectSet   ("SL-LO-bar ", OBJPROP_PRICE1, iLow ( NULL, tf, 0));
                  ObjectSet   ("SL-LO-bar ", OBJPROP_TIME2 , CurTime());
                  ObjectSet   ("SL-LO-bar ", OBJPROP_PRICE2, SL_toBar);}
               break;
            }
         }
      }*/
   }
   if (show_bar==true){
      ObjectDelete("SL-0-bar");
      ObjectCreate("SL-0-bar", OBJ_RECTANGLE, 0, 0,0, 0,0);
      ObjectSet   ("SL-0-bar", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet   ("SL-0-bar", OBJPROP_COLOR, color_Òåê_BAR);
      ObjectSet   ("SL-0-bar", OBJPROP_BACK, true);
      ObjectSet   ("SL-0-bar", OBJPROP_TIME1 , iTime( NULL, timeframe, 0));
      ObjectSet   ("SL-0-bar", OBJPROP_PRICE1, min_0Bar);
      ObjectSet   ("SL-0-bar", OBJPROP_TIME2 , iTime( NULL, timeframe, 0)+timeframe*60);
      ObjectSet   ("SL-0-bar", OBJPROP_PRICE2, max_0Bar);}
   return (NormalizeDouble(SL_toBar,Digits));   
}
//+------------------------------------------------------------------+
int next_period(int per)
{
   if (per > 10080)  return(43200); 
   if (per > 1440)   return(10080); 
   if (per > 240)    return(1440); 
   if (per > 60)     return(240); 
   if (per > 30)     return(240);
   if (per > 15)     return(60); 
   if (per > 5)      return(30); 
   if (per > 1)      return(5);   
}
//+------------------------------------------------------------------+
double Drawfoots(double top, double bottom)
{  
   int indention=Time[0]+per*3*60;
   if (show_bar==true)
   {
      colmet=color_SL;
      if (top==0) {top=Ask;colmet=Red;}
      ObjectDelete("SL for Sell ");
      ObjectCreate("SL for Sell ", OBJ_ARROW,0,indention,top,0,0,0,0);
      ObjectSet   ("SL for Sell ", OBJPROP_ARROWCODE,6);
      ObjectSet   ("SL for Sell ", OBJPROP_COLOR,colmet );
      ObjectSet   ("SL for Sell ", OBJPROP_BACK, true);
      colmet=color_SL;
      if (bottom ==0) {bottom =Bid;colmet=Red;}
      ObjectDelete("SL for Bay ");
      ObjectCreate("SL for Bay ", OBJ_ARROW,0,indention,bottom,0,0,0,0);
      ObjectSet   ("SL for Bay ", OBJPROP_ARROWCODE,6);
      ObjectSet   ("SL for Bay ", OBJPROP_COLOR,colmet );
      ObjectSet   ("SL for Bay ", OBJPROP_BACK, true);
   }
}
//+------------------------------------------------------------------+
int del(string Ob)
{
   for(int n=ObjectsTotal()-1; n>=0; n--) 
   {
      string Obj_Name=ObjectName(n);
      if (StringFind(Obj_Name,Ob,0) != -1) ObjectDelete(Obj_Name);
   }
   return;
}
//+------------------------------------------------------------------+