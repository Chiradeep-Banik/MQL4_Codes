//+------------------------------------------------------------------+
//|                                                  var_mov_avg.mq4 |
//|                                 Copyright © 2016, Dmitri Migunov |
//|                                            sniper_dragon@mail.ru |
//|                                                                  |
//|          Thanks for previous version 2004, GOODMAN & Mstera è AF |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Dmitri Migunov"
#property link      "sniper_dragon@mail.ru"
#property version   "1.00"
      
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  clrSienna
#property indicator_color2  clrBlue
#property indicator_color3  clrMagenta
#property indicator_color4  clrYellow

//---- input parameters
input
  int
    periodAMA = 50, // period of AMA
    nfast     = 15, // first noise filter parameter. Higher values make indicator less sensitive to spikes.
    nslow     = 10; // second noise filter parameter. Higher values make indicator less sensitive to spikes.

input
  double
    G   = 1.0,  // the power of filtered part in the moving average. Another way to make the signal line smoother.
    dK  = 0.1;  // doesn't really influence anything much.

input
  bool
    UseAlert  = false,  // if true then alerts will be used.
    UseSound  = false;  // if true then sound will be used in alerts.

input
  string
    SoundFile = "expert.wav"; // name of the sound file for alerts.

input
  int
    offsetInPips = 30;  // maximal offset signal dots from current price

//---- buffers
double
  kAMAbuffer[],
  kAMAupsig[],
  kAMAdownsig[],
  signalBuffer[];

//+------------------------------------------------------------------+
int
  cbars     = 0;

double
  slowSC,
  fastSC,
  dSC,
  dKPoint;

bool
  SoundBuy  = false,
  SoundSell = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void){
//---- indicators
  SetIndexStyle( 0, DRAW_LINE, 0, 2 );
  SetIndexStyle( 1, DRAW_ARROW, STYLE_SOLID, 2 );
  SetIndexArrow( 1, 159 );
  SetIndexStyle( 2, DRAW_ARROW, STYLE_SOLID, 2 );
  SetIndexArrow( 2, 159 );
  SetIndexStyle( 3, DRAW_ARROW, STYLE_SOLID, 1 );
  SetIndexArrow( 3, 159 );
   
  SetIndexBuffer( 0, kAMAbuffer );
  SetIndexBuffer( 1, kAMAupsig );
  SetIndexBuffer( 2, kAMAdownsig );
  SetIndexBuffer( 3, signalBuffer );
   
  IndicatorDigits( Digits );
  
//--- calculate this variables when start
  slowSC  = 2.0 / ( nslow + 1 );
  fastSC  = 2.0 / ( nfast + 1 );
  dSC     = fastSC - slowSC;
  dKPoint = dK * Point;

//--- initialization done
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const  int       rates_total,
                 const  int       prev_calculated,
                 const  datetime  &time[],
                 const  double    &open[],
                 const  double    &high[],
                 const  double    &low[],
                 const  double    &close[],
                 const  long      &tick_volume[],
                 const  long      &volume[],
                 const  int       &spread[])
{
  int
    pos = 0;
   
  double
    AMA,
    AMA0,
    signal,
    ER,
    ERSC,
    SSC,
    ddK;
  
  string
    message;
   
  if( prev_calculated == rates_total ) return( rates_total );
    
  cbars   = prev_calculated;
  
  if( rates_total <= ( periodAMA+2 ) ){
    return( rates_total );
  }

//---- check for possible errors
  if( cbars < 0 ) return(-1);

//---- last counted bar will be recounted
  if( cbars > 0 ) cbars--;
  
  pos   = rates_total - periodAMA - 2;
  AMA0  = close[ pos+1 ];
  
  for( int p=pos; p>=0; p-- ){
    signal    = MathAbs( close[ p ] - close[ p+periodAMA ] );
    ER        = signal / getNoise( close, p );
    ERSC      = ER * dSC;
    SSC       = ERSC + slowSC;
    ddK       = MathPow( SSC, G ) * ( close[p] - AMA0 );
    AMA       = AMA0 + ddK;
    AMA0      = AMA;
    
    int
      offset  = ( high[p] - low[p] ) / Point() * 2;

    if( offset < 5 )            offset = 5;
    if( offset > offsetInPips ) offset = offsetInPips;
    
    kAMAbuffer[p]   = AMA;
    kAMAupsig[p]    = 0;
    kAMAdownsig[p]  = 0;
    signalBuffer[p] = 0;

    if( MathAbs( ddK ) <= dKPoint )  continue;
    
    if( ddK > 0 ) kAMAupsig[p]    = AMA;
    if( ddK < 0 ) kAMAdownsig[p]  = AMA;

    if( kAMAupsig[p] != EMPTY_VALUE && kAMAupsig[p] != 0 && SoundBuy ){
      SoundBuy        = false;
      signalBuffer[p] = MathMin( close[p+1], low[p] ) - offset * Point;
      if( 0 == p )  showAlert( "BUY @ " + Ask );
    } 
  
    if ( !SoundBuy && ( EMPTY_VALUE == kAMAupsig[p] || 0 == kAMAupsig[p] ) ){
      SoundBuy = true;
    }
    
    if ( kAMAdownsig[p] != EMPTY_VALUE && kAMAdownsig[p] != 0 && SoundSell ){
      SoundSell       = false;
      signalBuffer[p] = MathMax( close[ p+1 ], high[p] ) + offset * Point;
      if( 0 == p )  showAlert( "Sell @" + Bid );
    }
  
    if( !SoundSell && ( EMPTY_VALUE == kAMAdownsig[p] || 0 == kAMAdownsig[p] )){
      SoundSell = true;
    }
  }
  

  return( rates_total );
}

double  getNoise( const double &close[], const int pos ){
  double
    noise = 0.000000001;
    
  for( int i=0; i<periodAMA; i++ ){
    noise += MathAbs( close[ pos+i ] - close[ pos+i+1 ] );
  }
  
  return noise;
}

void  showAlert( string message ){
  message  = TimeCurrent() + " " + Symbol() + " " + Period() + "M " + message;
  Comment( message );

  if( ! UseAlert ) return;
  if( UseSound ) PlaySound( SoundFile );
   
  Alert( message );
}

