//+------------------------------------------------------------------+
//|                                               5 Day BreakOut.mq4 |
//|                                      Copyright © 2007, Bill Sica |
//|                                        http://www.tetsuyama.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Bill Sica"
#property link      ""

#property indicator_chart_window

//---- input parameters
extern int DAYS=5;

//---- Variables
double yesterday_close,Current_price;
double phigh,plow,plownew;
int i=1;

//---- Buffers
double daily_high[20] ;
double daily_low[20] ;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
   {
//---- indicators
//----
      return(0);
   }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
   {
//----
   
//----
      return(0);
   }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
   {
      int    counted_bars=IndicatorCounted();
//----
      Current_price= MarketInfo( Symbol(), MODE_BID);
//---- TODO: add your code here
      ArrayResize( daily_high, DAYS);
      ArrayResize( daily_low, DAYS);
      ArrayInitialize( daily_high, 0);
      ArrayInitialize( daily_low, 0);
      ArrayCopySeries( daily_low, MODE_LOW, Symbol(), PERIOD_D1);
      ArrayCopySeries( daily_high, MODE_HIGH, Symbol(), PERIOD_D1);
/* initialise */
      plow = daily_low[ 1];
      phigh = daily_high[1];
      for(i=1;i<DAYS; i++)
         {
            if(plow > daily_low[i])
               {
                  plow = daily_low[i] ;
               }
         }
      for(i=1;i<DAYS; i++)
         {
            if(phigh < daily_high[i])
               {
                  phigh = daily_high[ i];
               }
         }

      Comment("\n5dayH ",phigh,"\n5dayL ",plow);

      ObjectDelete( "5dayHigh" );
      ObjectDelete( "5dayLow" );

      ObjectCreate( "5dayHigh" , OBJ_HLINE,0, CurTime(),phigh) ;
      ObjectSet("5dayHigh ",OBJPROP_COLOR,SpringGreen);
      ObjectSet("5dayHigh ",OBJPROP_STYLE,STYLE_SOLID);

      ObjectCreate( "5dayLow" , OBJ_HLINE,0, CurTime(),plow) ;
      ObjectSet("5dayLow" ,OBJPROP_COLOR,Red) ;
      ObjectSet("5dayLow" ,OBJPROP_STYLE,STYLE_SOLID);

      ObjectsRedraw( );

      if (Bid <= plow)
         {
            // Alert(Symbol( ), " has hit a 5 day LOW. Bounce or Breakout?"," -",plow);
         }

      if (Bid >= phigh)
         {
            //Alert(Symbol( ), " has hit a 5 day HIGH. Bounce or Breakout?"," -",phigh);
         }
//----
      return(0);
   }
//+------------------------------------------------------------------+