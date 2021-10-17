//+--------------------------------------------------------Bismillahir Rahmanir Rahim----------------------------------------------------+
//+--------------------------------------------------------------------------------------------------------------------------------------+
string indicator_name="Symbol Movement: ";
#property copyright   "Copyright 2017, Tanvir Ahmed"
#property link        "https://www.facebook.com/bd.tanvirahmed"
#property description "----------------------------------------------------------------------------"
#property description "This Custom Indicator is coded by Tanvir Ahmed"
#property description "Email: tanvirmfx@yahoo.com"
#property description "----------------------------------------------------------------------------"
#property version     "1.10"
#property strict
#property indicator_chart_window
#property indicator_buffers 1

enum ENUM_MARKET_PRICE {PRICE_NONE /*None*/,PRICE_BID /*Bid Price*/,PRICE_ASK /*Ask Price*/};
enum CLICK_ACTION {CHART_NEW /*Open New Chart*/,CHART_CHANGE /*Change Current Chart*/};
//---
input int candle_number             = 0;                 // Candle Number
input ENUM_TIMEFRAMES timeframe     = PERIOD_D1;         // Timeframe
input color button_bullish_color    = clrMediumSeaGreen; // Button Bullish Color
input color button_bearish_color    = clrLightCyan;      // Button Bearish Color
input color button_text_color       = clrNavy;           // Button Text Color
input ENUM_MARKET_PRICE market_price=PRICE_BID;          // Show Market Price
input CLICK_ACTION button_action    = CHART_CHANGE;      // On Button Click
input int button_height             = 18;                // Button Height
//---
bool symbol_button_show             = true;              // Symbol Button Show
ENUM_BASE_CORNER symbol_corner      = CORNER_LEFT_UPPER; // Button Chart Corner For Anchoring
string button_font_name             = "Lucida Console";  // Button Font Name
input int button_font_size          = 09;                // Button Font Size
color button_border_color           = clrNONE;           // Button Border Color
bool button_back                    = false;             // Button In Background
bool button_state                   = false;             // button State (Ppressed / Released)
bool button_selection               = false;             // Button Highlight To Move
bool button_selected                = false;             // Button Selected
bool button_hidden                  = true;              // Button Hidden in Object List
long button_zorder                  = 0;                 // Button Priority For Mouse Click
int button_first_y_distance         = 20;                // Button First Y Distance

int button_width;
string symbol_suffix;
string symbol_list[29]={"EURUSD","GBPUSD","USDCHF","USDJPY","USDCAD","AUDUSD","NZDUSD","EURGBP","EURCHF","EURJPY","EURCAD","EURAUD","EURNZD","GBPCHF","GBPJPY","GBPCAD","GBPAUD","GBPNZD","CHFJPY","CADCHF","CADJPY","AUDCHF","AUDJPY","AUDCAD","AUDNZD","NZDCHF","NZDJPY","NZDCAD","GTOTAL"};
//+--------------------------------------------------------------------------------------------------------------------------------------+
//| custom indicator initialization function                                                                                             |
//+--------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
   Print(indicator_name+Symbol()+" -- Bismillahir Rahmanir Raheem!");
   ChartSetInteger(CHART_MODE,CHART_FOREGROUND,false);
   symbol_suffix=StringSubstr(Symbol(),6,0);
   int symbol_suffix_length=StringLen(symbol_suffix);
//--- button width value set:
   if(button_height<=12)
     {
      button_width=190;
     }
   else
     {
      button_width=260;
     }
   if(market_price==PRICE_BID || market_price==PRICE_ASK)
     {
      button_width=button_width;
     }
   else
     {
      button_width=button_width-60;
     }
//--- symbol name set and enabling function: 
   for(int i=0; i<=27; i++)
     {
      string symbol_name=(symbol_list[i]+symbol_suffix);
      if(bool(SymbolInfoInteger(symbol_name,SYMBOL_SELECT))==false)
        {
         SymbolSelect(symbol_name,true);
        }
     }
   return(INIT_SUCCEEDED);
  }
//+--------------------------------------------------------------------------------------------------------------------------------------+
//| custom indicator deinitialization function                                                                                           |
//+--------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- objects delete function:
   for(int i=0; i<=28; i++)
     {
      string symbol_name=(symbol_list[i]+symbol_suffix);
      ObjectDelete(symbol_name);
     }
   Print(indicator_name+Symbol()+" -- Alhamdulillahi Rabbil Al-Ameen!");
  }
//+--------------------------------------------------------------------------------------------------------------------------------------+
//| custom indicator ontick function                                                                                                     |
//+--------------------------------------------------------------------------------------------------------------------------------------+
int OnCalculate(const int      rates_total,
                const int      prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
   ChartSetInteger(CHART_MODE,CHART_FOREGROUND,false);
   int button_gap=0;
   double total_body_range=0;
   double total_candle_range=0;
//--- start checking 28 symbols bid/ ask price, open-close range and high-low range:
   for(int i=0; i<=28; i++)
     {
      button_gap=i;
      string symbol_name=(symbol_list[i]+symbol_suffix);
      //--- symbol pips count function:
      int digits=int(MarketInfo(symbol_name,MODE_DIGITS));
      string symbol_price=NULL;
      if(market_price==PRICE_BID)
        {
         symbol_price=DoubleToStr(MarketInfo(symbol_name,MODE_BID),digits);
        }
      else if(market_price==PRICE_ASK)
        {
         symbol_price=DoubleToStr(MarketInfo(symbol_name,MODE_ASK),digits);
        }
      else
        {
         symbol_price=NULL;
        }
      if(symbol_price=="0")
        {
         symbol_price=".00000";
        }
      else
        {
         symbol_price=symbol_price;
        }
      if((digits<=3 && StrToDouble(symbol_price)<100.000))
        {
         symbol_price="0"+symbol_price;
        }
      else
        {
         symbol_price=symbol_price;
        }
      string start_bracket=NULL;
      string end_bracket=NULL;
      if(market_price==PRICE_BID || market_price==PRICE_ASK)
        {
         symbol_price=" "+symbol_price;
         if(symbol_name=="GTOTAL"+symbol_suffix)
           {
            symbol_price=" "+"_______";
           }
         else
           {
            symbol_price=symbol_price;
           }
         start_bracket=" [";
         end_bracket="]";
        }
      else
        {
         symbol_price=NULL;
         start_bracket=" ";
         end_bracket=NULL;
        }
      double point= 0;
      double pips = 0;
      if(digits<=3)
        {
         point= 0.01;
         pips = 100.00;
        }
      else
        {
         point=0.0001;
         pips =10000.00;
        }
      double symbol_body_range=NormalizeDouble(((iClose(symbol_name,timeframe,candle_number)-iOpen(symbol_name,timeframe,candle_number))*pips),2);
      double symbol_candle_range=NormalizeDouble(((iHigh(symbol_name,timeframe,candle_number)-iLow(symbol_name,timeframe,candle_number))*pips),2);
      total_body_range+=NormalizeDouble(((iClose(symbol_name,timeframe,candle_number)-iOpen(symbol_name,timeframe,candle_number))*pips),2);
      total_candle_range+=NormalizeDouble(((iHigh(symbol_name,timeframe,candle_number)-iLow(symbol_name,timeframe,candle_number))*pips),2);
      if(symbol_name=="GTOTAL"+symbol_suffix)
        {
         button_gap=(button_gap+1);
         symbol_body_range=total_body_range;
         symbol_candle_range=total_candle_range;
        }
      else
        {
         button_gap=button_gap;
         symbol_body_range=symbol_body_range;
         symbol_candle_range=symbol_candle_range;
        }
      double symbol_body_ranges=0;
      if(symbol_body_range<0)
        {
         symbol_body_ranges=(symbol_body_range*(-1));
        }
      else
        {
         symbol_body_ranges=symbol_body_range;
        }
      string symbol_bd_range = NULL;
      if(symbol_body_ranges <= 9.99)
        {
         symbol_bd_range="000"+DoubleToStr(symbol_body_ranges,2);
        }
      else if(symbol_body_ranges>9.99 && symbol_body_ranges<=99.99)
        {
         symbol_bd_range="00"+DoubleToStr(symbol_body_ranges,2);
        }
      else if(symbol_body_ranges>99.99 && symbol_body_ranges<=999.99)
        {
         symbol_bd_range="0"+DoubleToStr(symbol_body_ranges,2);
        }
      else
        {
         symbol_bd_range=DoubleToStr(symbol_body_ranges,2);
        }
      double symbol_candle_ranges=0;
      if(symbol_candle_range<0)
        {
         symbol_candle_ranges=(symbol_candle_range*(-1));
        }
      else
        {
         symbol_candle_ranges=symbol_candle_range;
        }
      string symbol_cndle_range=NULL;
      if(symbol_candle_ranges<=9.99)
        {
         symbol_cndle_range="000"+DoubleToStr(symbol_candle_ranges,2);
        }
      else if(symbol_candle_ranges>9.99 && symbol_candle_ranges<=99.99)
        {
         symbol_cndle_range="00"+DoubleToStr(symbol_candle_ranges,2);
        }
      else if(symbol_candle_ranges>99.99 && symbol_candle_ranges<=999.99)
        {
         symbol_cndle_range="0"+DoubleToStr(symbol_candle_ranges,2);
        }
      else
        {
         symbol_cndle_range=DoubleToStr(symbol_candle_ranges,2);
        }
      string symbol_text=StringSubstr(symbol_name,0,6)+symbol_price+start_bracket+symbol_bd_range+" : "+symbol_cndle_range+end_bracket;
      //--- symbol button show with information:
      int symbol_x_distance = 5;
      int symbol_y_distance = (button_first_y_distance+(button_height*button_gap));
      color button_color=clrNONE;
      if(symbol_body_range>=0)
        {
         button_color=button_bullish_color;
        }
      else
        {
         button_color=button_bearish_color;
        }
      //--- set button on chart:
      ObjectCreate(0,symbol_name,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,symbol_name,OBJPROP_XDISTANCE,symbol_x_distance);
      ObjectSetInteger(0,symbol_name,OBJPROP_YDISTANCE,symbol_y_distance);
      ObjectSetInteger(0,symbol_name,OBJPROP_XSIZE,button_width);
      ObjectSetInteger(0,symbol_name,OBJPROP_YSIZE,button_height);
      ObjectSetInteger(0,symbol_name,OBJPROP_CORNER,symbol_corner);
      ObjectSetString(0,symbol_name,OBJPROP_TEXT,symbol_text);
      ObjectSetString(0,symbol_name,OBJPROP_FONT,button_font_name);
      ObjectSetInteger(0,symbol_name,OBJPROP_FONTSIZE,button_font_size);
      ObjectSetInteger(0,symbol_name,OBJPROP_COLOR,button_text_color);
      ObjectSetInteger(0,symbol_name,OBJPROP_BORDER_COLOR,button_border_color);
      ObjectSetInteger(0,symbol_name,OBJPROP_BACK,button_back);
      ObjectSetInteger(0,symbol_name,OBJPROP_SELECTABLE,button_selection);
      ObjectSetInteger(0,symbol_name,OBJPROP_SELECTED,button_selected);
      ObjectSetInteger(0,symbol_name,OBJPROP_HIDDEN,button_hidden);
      ObjectSetInteger(0,symbol_name,OBJPROP_BGCOLOR,button_color);
      ObjectSetInteger(0,symbol_name,OBJPROP_ZORDER,button_zorder);
      ObjectSetInteger(0,symbol_name,OBJPROP_STATE,button_state);
     }
   return(rates_total);
  } //--- on calculate function completed;
//+--------------------------------------------------------------------------------------------------------------------------------------+
//| chart handling event                                                                                                                 |
//+--------------------------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int    id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//--- set button preesed for opening the symbol chart:
   for(int i=0; i<=27; i++)
     {
      string symbol_name=(symbol_list[i]+symbol_suffix);
      if(sparam==symbol_name)
        {
         if(button_action==CHART_NEW)
           {
            ChartOpen(symbol_name,PERIOD_CURRENT);
           }
         else if(button_action==CHART_CHANGE)
           {
            ChartSetSymbolPeriod(0,symbol_name,PERIOD_CURRENT);
           }
        }
     }
  }
//+------------------------------------------------(= indicator coding finished =)-------------------------------------------------------+
//+-----------------------------------------------(ALhamdulillahi Rabbil Al-Ameen)-------------------------------------------------------+
