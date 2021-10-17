//+------------------------------------------------------------------+
//|                 FXGuru_RSIHisto TripleStoch Divergence Alert.mq4 |
//|                               Copyright © 2009, the Guru Online. |
//|                                     http://www.theguruonline.biz |
//+------------------------------------------------------------------+
//| v1.0 Initial RSIHisto/TripleStoch Divergence Alert coding        |
//| v1.1 Restricted distance between bars to 55                      |
//| v1.2 Modified GrayZone inputs and Stoch Alert                    |
//| v1.3 Tweeked Divergence coding                                   |
//| v1.4 Made Divergence optional                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, the Guru Online."
#property link      "http://www.theguruonline.biz"

#property indicator_separate_window
#property indicator_buffers 7

//--- RSIHisto
#property indicator_width1 4
#property indicator_color1 Blue
#property indicator_style1 DRAW_HISTOGRAM
#property indicator_width2 4
#property indicator_color2 Red
#property indicator_style2 DRAW_HISTOGRAM
#property indicator_width3 3
#property indicator_color3 LightSlateGray
#property indicator_style3 DRAW_LINE
#property indicator_width4 4
#property indicator_color4 LightSlateGray
#property indicator_style4 DRAW_HISTOGRAM

//--- TripleStochastic
#property indicator_color5 Black
#property indicator_style5 DRAW_LINE
#property indicator_width5 2
#property indicator_levelcolor Black
#property indicator_levelstyle STYLE_DASH
#property indicator_levelwidth 1
#property indicator_level3 44
#property indicator_level4 -44
#define   indicator_minimum -53
#define   indicator_maximum 53

//--- Divergence
#property indicator_color6 MediumBlue
#property indicator_style6 DRAW_ARROW
#property indicator_width6 0
#property indicator_color7 Maroon
#property indicator_style7 DRAW_ARROW
#property indicator_width7 0

//+------------------------------------------------------------------+
//| Indicator variables                                              |
//+------------------------------------------------------------------+
static string   Indicator_Name            ="ATM_RSI TripleStoch";
static string   Version                   ="1.4";

extern string   a_                        =" : RSI Variables :";
extern int      RSI_Period                =13;
extern string   a1_                       =" : Price :";
extern string   a2_                       =" : : 0=Close price";
extern string   a3_                       =" : : 1=Open price";
extern string   a4_                       =" : : 2=High price";
extern string   a5_                       =" : : 3=Low price";
extern string   a6_                       =" : : 4=Median price, (high+low)/2";
extern string   a7_                       =" : : 5=Typical price, (high+low+close)/3";
extern string   a8_                       =" : : 6=Weighted close price, (high+low+close+close)/4";
extern int      RSI_Price                 =0;
extern bool     RSI_Alerts                =false;
extern double   BuyAlertLevel             =-44,
                SellAlertLevel            =44;
extern double   RSIHistoModify            =1.5;
extern int      RSIHisto_Width            =2;
extern color    RSIHistoUp_Color          =Blue;
extern color    RSIHistoDn_Color          =Red;
extern int      RSI_Width                 =2;
extern string   b_                        =" : GreyZone Variables :";
extern int      GrayZone_Limit            =13;
extern color    GrayZone_Color            =DarkGray;
extern string   c_                        =" : TripleStochastic Variables :";
extern int      TripleStochastic_KPeriod  =21;
extern int      TripleStochastic_Slowing  =8;
extern int      TripleStochastic_Price    =0;
extern int      TripleStochastic_Width    =2;
extern color    TripleStochastic_Color    =Black;
extern bool     TripleStochastic_Alerts   =false;
extern double   TripleStochastic_UpperZone=85,
                TripleStochastic_LowerZone=15;
extern int      TripleStochastic_LevelStyle=1;
extern int      TripleStochastic_LevelWidth=1;
extern color    TripleStochastic_LevelColor=Black;
extern string   d_                        =" : Divergence Variables :";
extern bool     Show_Divergence           =FALSE;
extern int      DivergenceMinBarLimit     =8;
extern int      DivergenceMaxBarLimit     =44;
extern int      DivergenceConfirmation    =3;
extern bool     drawDivergenceLines       =FALSE;
extern bool     Divergence_Alerts         =FALSE;
extern int      bullishDivergence_Arrow   =108;//SYMBOL_ARROWUP;
extern int      bearishDivergence_Arrow   =108;//SYMBOL_ARROWDOWN;
extern int      Divergence_Arrow_Size     =0;
extern bool     Divergence_ArrowInGrayZone=TRUE;
extern color    bullishDivergence_Color   =MediumBlue;
extern color    bearishDivergence_Color   =Maroon;

static int      Positive=0, Negative=0;
extern string   e_                        =" : Alert Variables :";
extern bool     Alert_EveryTick           =FALSE;
extern bool     Alert_Popup               =false;
extern bool     Alert_Mail                =FALSE;
extern string   Alert_Mail_Subject        ="";
extern string   Alert_Audible             ="nothing.wav";
static datetime Alert_Time;

extern string   f_                        =" : Display Variables :";
extern string   f1_                       =" : Corner : 0=Top Left";
extern string   f2_                       =" : : 1=Top Right";
extern string   f3_                       =" : : 2=Bottom Left";
extern string   f4_                       =" : : 3=Bottom Right";
static int      Display_Corner            =3;
extern color    color_text                =Black;

static bool     DebugLogger               =FALSE;
static datetime lastAlertTime, BarTimeLastAlert;
static string   indicatorShortName;
static int      indicatorWindow;

double RSI_Up[],
       RSI_Dn[],
       RSI_Main[],
       RSI_Gray[],
       TripleStochastic[],
       bullishDivergence[],
       bearishDivergence[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(7);
   SetIndexStyle( 0, DRAW_HISTOGRAM, EMPTY, RSIHisto_Width, RSIHistoUp_Color );
   SetIndexBuffer( 0, RSI_Up );
   SetIndexStyle( 1, DRAW_HISTOGRAM, EMPTY, RSIHisto_Width, RSIHistoDn_Color );
   SetIndexBuffer( 1, RSI_Dn );
   SetIndexStyle( 2, DRAW_LINE, STYLE_SOLID, RSI_Width, GrayZone_Color );
   SetIndexBuffer( 2, RSI_Main );
   SetIndexStyle( 3, DRAW_HISTOGRAM, EMPTY, RSIHisto_Width, GrayZone_Color );
   SetIndexBuffer( 3, RSI_Gray );

   SetIndexStyle( 4, DRAW_LINE, STYLE_SOLID, TripleStochastic_Width, TripleStochastic_Color );
   SetIndexBuffer( 4, TripleStochastic );
   SetLevelStyle( TripleStochastic_LevelStyle, TripleStochastic_LevelWidth, TripleStochastic_LevelColor );
   SetLevelValue( 0, ( TripleStochastic_UpperZone/100*80 )-40 );
   SetLevelValue( 1, ( TripleStochastic_LowerZone/100*80 )-40 );

   SetIndexStyle( 5, DRAW_ARROW, STYLE_SOLID, Divergence_Arrow_Size, bullishDivergence_Color );
   SetIndexBuffer( 5, bullishDivergence );
   SetIndexArrow( 5, bullishDivergence_Arrow );
   SetIndexStyle( 6, DRAW_ARROW, STYLE_SOLID, Divergence_Arrow_Size, bearishDivergence_Color );
   SetIndexBuffer( 6, bearishDivergence );
   SetIndexArrow( 6, bearishDivergence_Arrow );

   indicatorShortName="RSI ["+DoubleToStr( RSI_Period, 0 )+","+DoubleToStr( RSI_Price, 0 )+","+DoubleToStr( RSIHistoModify, 2 )
      +"X] 3xStoc ["+DoubleToStr( TripleStochastic_KPeriod, 0 )+","+DoubleToStr( TripleStochastic_Slowing, 0 )+","+DoubleToStr( TripleStochastic_Price, 0 )+"]";

   if( Show_Divergence )
     {
      Indicator_Name=Indicator_Name+" Divergence";
      indicatorShortName=indicatorShortName+" Divergence";
     }

   if( ( RSI_Alerts || TripleStochastic_Alerts || Divergence_Alerts ) && ( Alert_Popup || Alert_Mail || Alert_Audible!="" ) )
     {
      Indicator_Name=Indicator_Name+" Alert";
      indicatorShortName=indicatorShortName+" Alert";
      if( Alert_Mail_Subject=="" ) Alert_Mail_Subject=Indicator_Name;
     }

   IndicatorShortName( indicatorShortName );
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for( int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string label = ObjectName(i);
      if( StringSubstr(label, 0, 14) != "DivergenceLine")
         continue;
      ObjectDelete(label);   
     }
   Comment( "" );
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   string Alert_Message="";
   indicatorWindow=WindowFind( indicatorShortName );
   if( indicatorWindow<1 ) return(0);
   _Draw_Label(  5,  1,  7, "Copyright", CharToStr( 169 )+" "+Year()+", ElectroLegal.com & the Guru : [v"+Version+"] "+Indicator_Name, color_text, "Arial Narrow", 3 );
   _Draw_Label(  5, 10, 14, "ATM",       "ATM",                                                                                        color_text, "Arial Black",  3 );
   if( ObjectFind( "["+Indicator_Name+"] GrayZone" )==-1 )
     {
      ObjectCreate( "["+Indicator_Name+"] GrayZone", OBJ_RECTANGLE, indicatorWindow, 0, GrayZone_Limit, 0, -GrayZone_Limit );
      ObjectSet( "["+Indicator_Name+"] GrayZone", OBJPROP_STYLE, STYLE_SOLID );
      ObjectSet( "["+Indicator_Name+"] GrayZone", OBJPROP_COLOR, GrayZone_Color );
      ObjectSet( "["+Indicator_Name+"] GrayZone", OBJPROP_BACK, TRUE );
      ObjectSet( "["+Indicator_Name+"] GrayZone", OBJPROP_TIME1, Time[Bars] );
     }
   ObjectSet( "["+Indicator_Name+"] GrayZone", OBJPROP_TIME2, Time[0]+Period()*60 );

   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if( counted_bars<0 ) return(-1);
//---- last counted bar will be recounted
   if( counted_bars>0 ) counted_bars--;

   int limit=Bars-31;
   if( counted_bars>=31 ) limit=Bars-counted_bars-1;
//----
   for( int I=limit; I>=0; I-- )
     {
//--- RSI Histo
      RSI_Main[I]=( ( iRSI( 0, 0, RSI_Period, RSI_Price, I )-50 )*RSIHistoModify );
      if( RSI_Main[I]>GrayZone_Limit )
        {
         RSI_Up[I]=RSI_Main[I];
         RSI_Dn[I]=GrayZone_Limit;
         RSI_Gray[I]=GrayZone_Limit;
        }
      else if( RSI_Main[I]<-GrayZone_Limit )
        {
         RSI_Up[I]=-GrayZone_Limit;
         RSI_Dn[I]=RSI_Main[I];
         RSI_Gray[I]=-GrayZone_Limit;
        }
      else
        {
         RSI_Dn[I]=EMPTY_VALUE;
         RSI_Up[I]=EMPTY_VALUE;
         RSI_Gray[I]=EMPTY_VALUE;
        }
      if( RSI_Main[I]>BuyAlertLevel && RSI_Alerts )
        {
         if( Positive==0 )
           {
            Positive=1;
            Negative=0;
            if( BuyAlertLevel>0 ) Alert_Message=Alert_Message+"ATM Possible PAB Buy Heads Up.\n";
           }
        }
      else if( RSI_Main[I]<SellAlertLevel && RSI_Alerts )
        {
         if( Negative==0 )
           {
            Negative=1;
            Positive=0;
            if( SellAlertLevel<0 ) Alert_Message=Alert_Message+"ATM Possible PAB Sell Heads Up.\n";
           }
        }
//--- Triple Stochastic
      TripleStochastic[I]=( ( (
         iStochastic( NULL, 0, TripleStochastic_KPeriod*1, 1, TripleStochastic_Slowing*1, 0, TripleStochastic_Price, MODE_MAIN, I )+
         iStochastic( NULL, 0, TripleStochastic_KPeriod*2, 1, TripleStochastic_Slowing*2, 0, TripleStochastic_Price, MODE_MAIN, I )+
         iStochastic( NULL, 0, TripleStochastic_KPeriod*3, 1, TripleStochastic_Slowing*3, 0, TripleStochastic_Price, MODE_MAIN, I ) )/3.0
         )/100*80 )-40;
      if( I<1 )
        {
         if( iTime( NULL, 0, I )>BarTimeLastAlert )
           {
            BarTimeLastAlert=Time[0];
            if( TripleStochastic[I]>=( TripleStochastic_LowerZone/100*80 )-40 && TripleStochastic[I+1]<( TripleStochastic_LowerZone/100*80 )-40 && TripleStochastic_Alerts )
              {
               Alert_Message=Alert_Message+"ATM Stoch heads OVERBOUGHT.\n";
              }
            if( TripleStochastic[I]<=( TripleStochastic_UpperZone/100*80 )-40 && TripleStochastic[I+1]>( TripleStochastic_UpperZone/100*80 )-40 && TripleStochastic_Alerts )
              {
               Alert_Message=Alert_Message+"ATM Stoch heads OVERSOLD.\n";
              }
           }
        }
//--- Divergence
      if( Show_Divergence )
        {
         ObjectDelete( "DivergenceLine #"+DoubleToStr( I+DivergenceConfirmation, 0 ) );
         ObjectDelete( "DivergenceLine PA#"+DoubleToStr( I+DivergenceConfirmation, 0 ) );
         bearishDivergence[I+DivergenceConfirmation]=EMPTY_VALUE;
         if( IsIndicatorPeak( I+DivergenceConfirmation ) )
           {
            int currentPeak=I+DivergenceConfirmation;
            int lastPeak   =GetIndicatorLastPeak( I+DivergenceConfirmation );
            if(
                  lastPeak>0
               && RSI_Main[currentPeak]<RSI_Main[lastPeak]
               && High[currentPeak]>High[lastPeak]
              )
              {
                if( Divergence_ArrowInGrayZone ) bearishDivergence[currentPeak]=0;
                else                             bearishDivergence[currentPeak]=RSI_Main[currentPeak];
                if( drawDivergenceLines )
                  {
                    DrawPriceTrendLine( Time[currentPeak], Time[lastPeak], High[currentPeak], 
                                        High[lastPeak], bearishDivergence_Color, STYLE_SOLID );
                    DrawIndicatorTrendLine( Time[currentPeak], Time[lastPeak], RSI_Main[currentPeak],
                                            RSI_Main[lastPeak], bearishDivergence_Color, STYLE_SOLID );
                  }
               if( Divergence_Alerts ) Alert_Message=Alert_Message+"Classic bearish divergence @"+Ask+".\n";
              }
            if(
                  lastPeak>0
               && RSI_Main[currentPeak]>RSI_Main[lastPeak]
               && High[currentPeak]<High[lastPeak]
              )
              {
                if( Divergence_ArrowInGrayZone ) bearishDivergence[currentPeak]=0;
                else                             bearishDivergence[currentPeak]=RSI_Main[currentPeak];
                if( drawDivergenceLines )
                  {
                    DrawPriceTrendLine( Time[currentPeak], Time[lastPeak], High[currentPeak], 
                                        High[lastPeak], bearishDivergence_Color, STYLE_DOT );
                    DrawIndicatorTrendLine( Time[currentPeak], Time[lastPeak], RSI_Main[currentPeak],
                                            RSI_Main[lastPeak], bearishDivergence_Color, STYLE_DOT );
                  }
               if( Divergence_Alerts ) Alert_Message=Alert_Message+"Reverse bearish divergence @"+Ask+".\n";
              }
           }
         bullishDivergence[I+DivergenceConfirmation]=EMPTY_VALUE;
         if( IsIndicatorTrough( I+DivergenceConfirmation ) )
           {
            int currentTrough=I+DivergenceConfirmation;
            int lastTrough   =GetIndicatorLastTrough( I+DivergenceConfirmation );
            if(
                  lastTrough>0
               && RSI_Main[currentTrough]>RSI_Main[lastTrough]
               && Low[currentTrough]<Low[lastTrough]
              )
              {
               if( Divergence_ArrowInGrayZone ) bullishDivergence[currentTrough]=0;
               else                             bullishDivergence[currentTrough]=RSI_Main[currentTrough];
               if( drawDivergenceLines )
                 {
                   DrawPriceTrendLine( Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                                       Low[lastTrough], bullishDivergence_Color, STYLE_SOLID );
                   DrawIndicatorTrendLine( Time[currentTrough], Time[lastTrough], RSI_Main[currentTrough],
                                           RSI_Main[lastTrough], bullishDivergence_Color, STYLE_SOLID );
                 }
               if( Divergence_Alerts ) Alert_Message=Alert_Message+"Classic bullish divergence @"+Ask+".\n";
              }
            if(
                  lastTrough>0
               && RSI_Main[currentTrough]<RSI_Main[lastTrough]
               && Low[currentTrough]>Low[lastTrough]
              )
              {
               if( Divergence_ArrowInGrayZone ) bullishDivergence[currentTrough]=0;
               else                             bullishDivergence[currentTrough]=RSI_Main[currentTrough];
               if( drawDivergenceLines==true )
                 {
                   DrawPriceTrendLine( Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                                       Low[lastTrough], bullishDivergence_Color, STYLE_DOT );
                   DrawIndicatorTrendLine( Time[currentTrough], Time[lastTrough], RSI_Main[currentTrough],
                                           RSI_Main[lastTrough], bullishDivergence_Color, STYLE_DOT );
                 }
               if( Divergence_Alerts ) Alert_Message=Alert_Message+"Reverse bullish divergence @"+Ask+".\n";
              }
           }
        } //- end Divergence
     }
   if( ( Alert_Time!=Time[0] || Alert_EveryTick ) && Alert_Message!="" )
     {
      if( Alert_Popup ) Alert( Symbol()+" M"+Period()+":"+Alert_Message );
      if( Alert_Mail  ) SendMail( Symbol()+" M"+Period()+":"+Alert_Mail_Subject, Alert_Message );
      if( Alert_Audible!="" ) PlaySound( Alert_Audible );
      Alert_Time=Time[0];
      Alert_Message="";
     }
   return(0);
}
//+------------------------------------------------------------------+
//| Draws a label                                                    |
//+------------------------------------------------------------------+
void _Draw_Label( int _x, int _y, int _fontSize, string _name, string _text, color _color, string _fontName, int _Display_Corner=-1 )
  {
   if( _Display_Corner==-1 ) _Display_Corner=Display_Corner;
   ObjectDelete( "["+Indicator_Name+"] "+_name );
   ObjectCreate( "["+Indicator_Name+"] "+_name, OBJ_LABEL, indicatorWindow, 0, 0 );
   ObjectSetText( "["+Indicator_Name+"] "+_name, _text, _fontSize, _fontName, _color );
   ObjectSet( "["+Indicator_Name+"] "+_name, OBJPROP_BACK, TRUE );
   ObjectSet( "["+Indicator_Name+"] "+_name, OBJPROP_CORNER, _Display_Corner );
   ObjectSet( "["+Indicator_Name+"] "+_name, OBJPROP_XDISTANCE, _x );
   ObjectSet( "["+Indicator_Name+"] "+_name, OBJPROP_YDISTANCE, _y );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak( int shift )
  {
   if(
      RSI_Main[shift]>GrayZone_Limit
     )
     {
      for( int i=1; i<=DivergenceConfirmation; i++)
        {
         if(
               RSI_Main[shift+i]<GrayZone_Limit
            || RSI_Main[shift]<RSI_Main[shift+i]
//            || RSI_Main[shift-i]<GrayZone_Limit
            || RSI_Main[shift]<RSI_Main[shift-i]
           )
            return( FALSE );
        }
      return( TRUE );
     }   
   return( FALSE );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough( int shift )
  {
   if(
      RSI_Main[shift]<-GrayZone_Limit
     )
     {
      for( int i=1; i<=DivergenceConfirmation; i++)
        {
         if(
               RSI_Main[shift+i]>-GrayZone_Limit
            || RSI_Main[shift]>RSI_Main[shift+i]
//            || RSI_Main[shift-i]>-GrayZone_Limit
            || RSI_Main[shift]>RSI_Main[shift-i]
           )
            return( FALSE );
        }
      return( TRUE );
     }   
   return( FALSE );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak( int shift )
  {
   for( int i=shift+DivergenceMinBarLimit; i<shift+DivergenceMaxBarLimit; i++ )
     {
      if(
            IsIndicatorPeak( i )
         && RSI_Main[shift]<RSI_Main[i]
         && High[shift]>High[i]
        )
         return( i );
     }
   return( -1 );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough( int shift )
  {  
   for( int i=shift+DivergenceMinBarLimit; i<shift+DivergenceMaxBarLimit; i++ )
     {
      if(
         IsIndicatorTrough( i )
         && RSI_Main[shift]>RSI_Main[i]
         && Low[shift]<Low[i]
        )
         return( i );
     }
   return( -1 );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, double y2, color lineColor, double style )
  {
   string label = "DivergenceLine PA#" + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, double y2, color lineColor, double style)
  {
//   int indicatorWindow = WindowFind("RSI HistoAlert ["+RSI_Period+","+RSI_Price+","+RSI_Signal+","+RSI_Mode+","+DoubleToStr(RSIHistoModify,2)+"X]");
   if(indicatorWindow < 0)
       return;
   string label = "DivergenceLine #" + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+

