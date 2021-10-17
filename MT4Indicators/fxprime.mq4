//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 6


#property indicator_minimum -100
#property indicator_maximum 100

#property  indicator_color1  LimeGreen
#property  indicator_color2  Yellow
#property  indicator_color3  FireBrick
#property  indicator_color4  Lime
#property  indicator_color5  Red
#property  indicator_color6  CornflowerBlue

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 4

//---- indicator parameters
extern int       rsi_period=8;
extern int       rsi_price=PRICE_CLOSE;
extern bool      chk_rsi = false;

extern     bool      check_ema_angle = true;
extern     bool      enablealertbuy = false;
extern     bool      enablealertsell = false;
extern     bool      enablealertexit = false;
extern     bool      alertpair = false;
extern     bool      display_fxprime_short = true;
extern     bool      display_fxprime_long = true;
extern     bool      display_fxprime_exit = true;

extern     int       indicator_period = 0;
extern     int       previous_shift = 1;
extern     int       cci_period = 63;
extern     int       long_period = 64;
extern     int       short_rsi = 8;
extern     int       long_rsi = 14;
extern     int       filter_out_cci = 5;
extern     double    filter_out_long = 165;
extern     double    filter_out_short = -165;

extern     double    exit_cci_cross_long = 0;
extern     double    exit_cci_cross_short = 0;
extern     double    long_rsi_cross = 55;
extern     double    short_rsi_cross = 45;

extern     double    small_long_cci_cross = 30;
extern     double    small_short_cci_cross = -30;
extern     double    large_long_cci_cross = 25;
extern     double    large_short_cci_cross = -25;
extern     int       sto_K = 5;
extern     int       sto_D = 3;
extern     int       sto_S = 3;
extern     int       adx_period = 20;
extern     double    adx_level = 15;
extern     bool      chk_adx = false;
extern     int       cci_price = PRICE_TYPICAL;

// ---------- ema angle settings
extern     int       ea_EMAPeriod=34;
extern     double    ea_AngleTreshold=0.2;
extern     int       ea_StartEMAShift=6;
extern     int       ea_EndEMAShift=0;
extern     bool      display_ema_angle = false;

extern     string    alertbuymsg = "#fxprime BUY ";
extern     string    alertsellmsg = "#fxprime SELL ";
extern     string    alertexitmsg = "#fxprime EXIT";

extern int EMAPeriod=36;
extern double AngleTreshold=0.2;
extern int StartEMAShift=0;
extern int EndEMAShift=-1;

//---- indicator buffers
double UpBuffer[];
double DownBuffer[];
double ZeroBuffer[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];

#define pos                50
#define shortmul           -1
#define SPACE              " "
#define IND_LONG_SYMBOL    110
#define IND_SHORT_SYMBOL   110
#define IND_EXIT_SYMBOL    159
#define OP_NEUTRAL         -1
#define EMPTY_LEVEL        -200
#define SIG_LEVEL          0.2
#define EXT_LEVEL          -0.2

#define OP_EXIT            -100
#define PI                 3.14159
#define PIDEGREES          180.0


datetime buytime;
datetime selltime;
datetime exittime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   int emaa_draw = DRAW_HISTOGRAM;
   if (!display_ema_angle) emaa_draw = DRAW_NONE;
   IndicatorBuffers(6);
   SetIndexStyle(0,emaa_draw,STYLE_SOLID,2);
   SetIndexStyle(1,emaa_draw,STYLE_SOLID,2);
   SetIndexStyle(2,emaa_draw,STYLE_SOLID,2);

   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DownBuffer);
   SetIndexBuffer(2,ZeroBuffer);
   
   int draw_fxprime;
   
   draw_fxprime = DRAW_ARROW;
   if (!display_fxprime_long) draw_fxprime = DRAW_NONE;
   SetIndexStyle(3,draw_fxprime);
   SetIndexArrow(3,IND_LONG_SYMBOL);
   SetIndexBuffer(3,ExtMapBuffer5);
   SetIndexEmptyValue(3,EMPTY_LEVEL);

   draw_fxprime = DRAW_ARROW;
   if (!display_fxprime_short) draw_fxprime = DRAW_NONE; 
   SetIndexStyle(4,draw_fxprime);
   SetIndexArrow(4,IND_SHORT_SYMBOL);
   SetIndexBuffer(4,ExtMapBuffer6);
   SetIndexEmptyValue(4,EMPTY_LEVEL);

   draw_fxprime = DRAW_ARROW;
   if (!display_fxprime_exit) draw_fxprime = DRAW_NONE;
   SetIndexStyle(5,draw_fxprime);
   SetIndexArrow(5,IND_EXIT_SYMBOL);
   SetIndexBuffer(5,ExtMapBuffer7);
   SetIndexEmptyValue(5,EMPTY_LEVEL);
   
   ShowCopyright();

   return(0);
}
//+------------------------------------------------------------------+
//| The angle for EMA                                                |
//+------------------------------------------------------------------+
int start()
{
   double fEndMA, fStartMA;
   double fAngle, mFactor, dFactor;
   int nLimit, i;
   int nCountedBars;
   double angle;
   int ShiftDif;
 
   if(EndEMAShift >= StartEMAShift)
   {
      Print("Error: EndEMAShift >= StartEMAShift");
      StartEMAShift = 6;
      EndEMAShift = 0;      
   }  
         
   nCountedBars = IndicatorCounted();
//---- check for possible errors
   if(nCountedBars<0) 
      return(-1);
//---- last counted bar will be recounted
   if(nCountedBars>0) 
      nCountedBars--;
   nLimit = Bars-nCountedBars;
   dFactor = 3.14159/180.0;
   mFactor = 10000.0;
   
   if (Symbol() == "USDJPY") mFactor = 100.0;
   ShiftDif = StartEMAShift-EndEMAShift;
   mFactor /= ShiftDif; 
//---- main loop
   
   for(i=0; i<nLimit; i++)
   {
      ExtMapBuffer5[i] = EMPTY_LEVEL;
      ExtMapBuffer6[i] = EMPTY_LEVEL;
      ExtMapBuffer7[i] = EMPTY_LEVEL;
   
      bool ea_green = false;
      bool ea_red = false;
      bool ea_yellow = false;
      
      double rsi = iRSI(NULL, 0, rsi_period, rsi_price, i);
      double cci_fo = iCCI(Symbol(), indicator_period, filter_out_cci, cci_price, i);
      
      double cci = iCCI(Symbol(), indicator_period, cci_period, cci_price, i);
      double cci_p = iCCI(Symbol(), indicator_period, cci_period, cci_price, i+previous_shift);
      double cci_l = iCCI(Symbol(), indicator_period, long_period, cci_price, i);
      double cci_lp = iCCI(Symbol(), indicator_period, long_period, cci_price, i+previous_shift);
      
      double lrsi = iRSI(Symbol(), indicator_period, long_rsi, PRICE_CLOSE, i);
      
      double adxpdi = iADX(Symbol(), indicator_period, adx_period, PRICE_CLOSE, MODE_PLUSDI, i);
      double adxmdi = iADX(Symbol(), indicator_period, adx_period, PRICE_CLOSE, MODE_MINUSDI, i);
      double adxmain = iADX(Symbol(), indicator_period, adx_period, PRICE_CLOSE, MODE_MAIN, i);

      int adx_op = OP_NEUTRAL;
      if (adxpdi >= adxmdi && adxmain > adx_level) adx_op = OP_BUY;
      if (adxpdi < adxmdi && adxmain > adx_level) adx_op = OP_SELL;


      fEndMA=iMA(NULL,0, EMAPeriod,0,MODE_EMA,PRICE_MEDIAN,i+EndEMAShift);
      fStartMA=iMA(NULL,0,EMAPeriod,0,MODE_EMA,PRICE_MEDIAN,i+StartEMAShift);
      // 10000.0 : Multiply by 10000 so that the fAngle is not too small
      // for the indicator Window.
      fAngle = mFactor * (fEndMA - fStartMA);
//      fAngle = MathArctan(fAngle)/dFactor;

      DownBuffer[i] = 0.0;
      UpBuffer[i] = 0.0;
      ZeroBuffer[i] = 0.0;
      
      if(fAngle > AngleTreshold)
      {
         ea_green = true;
         UpBuffer[i] = fAngle;
      }
      else if (fAngle < -AngleTreshold)
      {
         ea_yellow = true;
         DownBuffer[i] = fAngle;
      }
      else 
      {
         ea_red = true;
         ZeroBuffer[i] = fAngle;
      }
      
      
      if (cci > small_long_cci_cross && cci_l > large_long_cci_cross && (rsi > long_rsi_cross || !chk_rsi) && (adx_op == OP_BUY || !chk_adx) && ea_green)
      {
         ExtMapBuffer5[i] = SIG_LEVEL;
         if (i == 1 && ExtMapBuffer5[i+1] != SIG_LEVEL && enablealertbuy && buytime < iTime(NULL, 0, 2))
         {
            buytime = iTime(NULL, 0, 2);
            AlertSignal(alertpair, OP_BUY, alertbuymsg, alertsellmsg, alertexitmsg);
         }
      }
      // if (cci > long_cci_cross && rsi > long_rsi_cross && adxpdi > adxmdi && adxmdi < adxmain) 
         
      // cci_l < short_cci_cross && 
      // (cci < short_cci_cross && rsi < short_rsi_cross && adxpdi < adxmdi && adxmdi > adxpdi) 
      // (cci < short_cci_cross && cci_l < short_cci_cross && rsi > short_rsi_cross)
      if (cci < small_short_cci_cross && cci_l < large_short_cci_cross && (rsi < short_rsi_cross || !chk_rsi) && (adx_op == OP_SELL || !chk_adx) && ea_yellow)
      {
         ExtMapBuffer6[i] = SIG_LEVEL;
         if (i == 1 && ExtMapBuffer6[i+1] != SIG_LEVEL && enablealertsell && selltime < iTime(NULL, 0, 2))
         {
            selltime = iTime(NULL, 0, 2);
            AlertSignal(alertpair, OP_SELL, alertbuymsg, alertsellmsg, alertexitmsg);
         }
      }
      if ((cci >= exit_cci_cross_short && cci_p < exit_cci_cross_short) || (cci <= exit_cci_cross_long && cci_p > exit_cci_cross_long))
      // if (cci_fo > filter_out_long || cci_fo < filter_out_short)
      {
         ExtMapBuffer7[i] = EXT_LEVEL;
         if (i == 1 && ExtMapBuffer7[i+1] != SIG_LEVEL && enablealertexit && exittime < iTime(NULL, 0, 2))
         {
            exittime = iTime(NULL, 0, 2);
            AlertSignal(alertpair, OP_EXIT, alertbuymsg, alertsellmsg, alertexitmsg);
         }
      }
    
   }
   return(0);
  }
//+------------------------------------------------------------------+


void ShowCopyright()
{
   Print("");
   Print("");
}

void AlertSignal(bool alertpair, int op, string buy, string sell, string exit)
{
   string msg = "";
   
   if (alertpair) msg = StringConcatenate(msg, Symbol(), ", ");
   
   if (op == OP_BUY) msg = StringConcatenate(msg, buy);
   else if (op == OP_SELL) msg = StringConcatenate(msg, sell);
   else if (op == OP_EXIT) msg = StringConcatenate(msg, exit);
   
   Alert(msg);
}