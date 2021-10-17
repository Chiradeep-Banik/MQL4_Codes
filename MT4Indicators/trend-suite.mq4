//+-------------------------------------------------------------------------------------------+
//|                                                                                           |
//|                                      Trend Suite.mq4                                      |
//|                                                                                           |
//+-------------------------------------------------------------------------------------------+
#property copyright "Copyright @ 2015 traderathome and qFish"
#property link      "email: traderathome@msn.com"

/*---------------------------------------------------------------------------------------------
User Notes:

This indicator is coded to run on MT4 Build 600+.  It offers several display configurations of
a moving average (Trend).  HLC prices are used.  The period and type can be changed to suit.

Trend Configurations -
   1. Band:
      You can show the Trend as a "filled" band (uses HL prices and vertical dot lines).  This
      option does not display a center line.
   2. Line:
      You can show the Trend using three lines (HLC prices) or by options use just the outer
      lines, or just the center line (single moving average line display).  Center and outer
      lines can be set to style, width and color.  The center line can be accented by using
      two lines of different widths and colors.
   3. Solid:
      You can show the Trend solidly colored, intended for use with the Candles Suite indy.
      This requires the MT4 price display be "Line chart" with CLR_NONE" as color, and not
      be set to foreground.  If using MT4 price styles instead of the Candles Suite indy,
      do not set them to foreground and do use one of the other Trend configuration options,
      because this solid coloring option obscures MT4 price styles not set to foreground,
      and to set them to foreground interferes with the display of the Trade Levels indy.

Configuration Label -
      You can select to show a Configuration Label located at the bottom center of the chart.
      To adjust centering the label background, use the "__Label_Shift" input.
      To adjust centering the label text, use the "__Text_Shift" input.
      This label shows the configuration (period and type) selected for the Trend.

                                                                   - Traderathome, 05-30-2015
----------------------------------------------------------------------------------------------
Suggested Colors             White Chart        Black Chart        Remarks

Band Display-
Fill                         C'130,162,204'     C'102,099,163'

Line Display-
Hi/Lo Lines                  DeepSkyBlue        C'102,099,163'     Hi/Lo Lines
Center                       Crimson            C'198,000,069'     Center Line
Center Alternate             DeepSkyBlue        C'102,099,163'     Center Line Alt
Accent Base                  SlateBlue          C'102,099,163'     Accent Base
Accent Top                   Aqua               Black              Accent Top

Solid Display-
indicator_color1-2           C'221,238,255'     C'033,035,078'     H/L Histo Fill
indicator_color3-4           C'210,233,255'     C'037,040,092'     H/L MA Fill
indicator_color5             C'240,249,255'     C'020,020,020'     Center Area
indicator_color6             C'021,138,255'     C'079,102,198'     Center Line
indicator_color7             Black              DimGray            Trend Line

Label Display-
Panel                        White              C'010,010,010'
text                         C'000,000,159'     C'139,139,203'
---------------------------------------------------------------------------------------------*/


//+-------------------------------------------------------------------------------------------+
//| Indicator Global Inputs                                                                   |
//+-------------------------------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers  6

//Solid Coloring-
#property indicator_color1   C'033,035,078'     //high histo fill
#property indicator_color2   C'033,035,078'     //low histo fill
#property indicator_color3   C'037,040,092'     //high ma fill   
#property indicator_color4   C'037,040,092'     //low ma fill
#property indicator_color5   C'020,020,020'     //center area
#property indicator_color6   C'079,102,198'     //center line

#property indicator_style1   STYLE_SOLID
#property indicator_style2   STYLE_SOLID
#property indicator_style3   STYLE_SOLID
#property indicator_style4   STYLE_SOLID
#property indicator_style5   STYLE_SOLID
#property indicator_style6   STYLE_SOLID

#property indicator_width1   3
#property indicator_width2   3
#property indicator_width3   3
#property indicator_width4   3
#property indicator_width5   5
#property indicator_width6   1

//global external inputs
extern bool   Indicator_On                    = true;

extern string Trend_Settings____________      = "";
extern int    Trend_Period                    = 50;
extern bool   Trend_EMA_vs_SMA                = true;
extern int    Show_Band_Line_Solid_123        = 3;
extern string Band_Settings                   = "";
extern color  __Fill_Color                    = C'102,099,163';
extern string Line_Settings                   = "";
extern bool   __Show_High_Low_Lines           = true;
extern color  ____High_Low_Color              = C'102,099,163';
extern int    ____High_Low_Style              = 0;
extern int    ____High_Low_Width              = 1;
extern bool   __Show_Centerline               = true;
extern bool   ____Use_Default_Color           = true;
extern color  ____Default_Color               = C'198,000,069';
extern color  ____Alternate_Color             = C'102,099,163';
extern int    ____Line_Style                  = 0;
extern int    ____Line_Width                  = 1;
extern bool   __Accent_Centerline             = false;
extern color  ____Base_Color                  = C'102,099,163';
extern int    ____Base_Width                  = 3;
extern color  ____Top_Color                   = Black;
extern int    ____Top_Style                   = 0;
extern int    ____Top_Width                   = 1;

extern string Label_____________________      = "";
extern bool   Show_Configuration_Label        = true;
extern int    __Label_Shift                   = 552;
extern color  __Label_Color                   = C'010,010,010';
extern int    __Text_Shift                    = 582;
extern color  __Text_Color                    = C'139,139,203';

extern string Display_TFs________________     = "";
extern int    Display_Max_TF                  = 43200;
extern string TF_Choices                      = "1-5-15-30-60-240-1440-10080-43200";

//Global Buffers and Variables
bool          Deinitialized;
int           Chart_Scale,BarShift,counted_bars,limit,cntr;
string        ShortName;
string        text;
string        item1  = "z[Trend Suite] Label";
string        item2  = "z[Trend Suite] Text";

//Trend-
int           Bar_Width,Bands,Trend_Type;
double        TrendHigh[],TrendLow[],TrendTop[],
              TrendBot[],TrendCntr1[],TrendCntr2[];
string        Trendtype;

/*General notes:
MAType  = 0=SMA,1=EMA,2=SMMA,3=LWMA
MAPrice = 0=CLOSE,1=OPEN,2=TrendHigh,3=LOW,4=MEDIAN,5=PP,6=WEIGHT
*/

//+-------------------------------------------------------------------------------------------+
//| Indicator De-initialization                                                               |
//+-------------------------------------------------------------------------------------------+
int deinit()
  {
  int obj_total= ObjectsTotal();
  for(int k= obj_total; k>=0; k--)
    {
    string name= ObjectName(k);
    if(StringSubstr(name,0,7)=="z[Trend") {ObjectDelete(name);}
    }
  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Indicator Initialization                                                                  |
//+-------------------------------------------------------------------------------------------+
int init()
  {
  Deinitialized = false;

  //Determine the current chart scale (chart scale number should be 0-5)
  Chart_Scale = ChartScaleGet();

  //Set Dragon band and bar widths per chart zoom selection
      if(Chart_Scale == 0) {Bar_Width = 1; Bands = 1; cntr = 1;}
  else {if(Chart_Scale == 1) {Bar_Width = 2; Bands = 1; cntr = 1;}
  else {if(Chart_Scale == 2) {Bar_Width = 3; Bands = 3; cntr = 5;}
  else {if(Chart_Scale == 3) {Bar_Width = 5; Bands = 7; cntr = 7;}
  else {if(Chart_Scale == 4) {Bar_Width = 9; Bands = 14; cntr = 9;}
  else {if(Chart_Scale == 5) {Bar_Width = 17; Bands = 26; cntr = 11;} }}}}}

  //Trend Indicators
  if(Trend_EMA_vs_SMA) {Trendtype = " ema"; Trend_Type = 1;}
  else {Trendtype = " sma"; Trend_Type = 0;}

  //Indicators- Solid
  if(Show_Band_Line_Solid_123 == 3)
    {
    //Area fill either side of center
    SetIndexBuffer(0, TrendHigh);
    SetIndexStyle(0, DRAW_HISTOGRAM, 0, Bar_Width, indicator_color1);
    SetIndexEmptyValue(0,0);
    SetIndexBuffer(1, TrendLow);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, Bar_Width, indicator_color2);
    SetIndexEmptyValue(1,0);
    //Area fill top and bottom
    SetIndexBuffer(2, TrendTop);
    SetIndexStyle(2, DRAW_LINE, 0, Bands, indicator_color3);
    SetIndexEmptyValue(2,0);
    SetIndexBuffer(3, TrendBot);
    SetIndexStyle(3, DRAW_LINE, 0, Bands, indicator_color4);
    SetIndexEmptyValue(3,0);
    //Center line Area
    SetIndexBuffer(4, TrendCntr1);
    SetIndexStyle(4, DRAW_LINE, 0, cntr, indicator_color5);
    SetIndexEmptyValue(4,0);
    //Center line
    SetIndexBuffer(5, TrendCntr2);
    SetIndexStyle(5, DRAW_LINE, 0, indicator_width6, indicator_color6);
    SetIndexEmptyValue(5,0);
    }
  //Indicators- Band
  else
    {
    if(Show_Band_Line_Solid_123 == 1)
      {
      //Area fill either side of center
      SetIndexBuffer(0, TrendHigh);
      SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_DOT, 1, __Fill_Color);
      SetIndexEmptyValue(0,0);
      SetIndexBuffer(1, TrendLow);
      SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_DOT, 1, __Fill_Color);
      SetIndexEmptyValue(1,0);
      //Lines top and bottom
      SetIndexBuffer(2, TrendTop);
      SetIndexStyle(2, DRAW_LINE, 0, 1, __Fill_Color);
      SetIndexEmptyValue(2,0);
      SetIndexBuffer(3, TrendBot);
      SetIndexStyle(3, DRAW_LINE, 0, 1, __Fill_Color);
      SetIndexEmptyValue(3,0);
      SetIndexBuffer(4, TrendCntr2);
      SetIndexStyle(4, DRAW_LINE, ____Line_Style, ____Line_Width, CLR_NONE);
      SetIndexEmptyValue(4,0);
      }
    //Indicators- Line
    else if(Show_Band_Line_Solid_123 == 2)
      {
      if(__Show_Centerline)
        {
        if(__Show_High_Low_Lines)
          {
          SetIndexBuffer(0, TrendHigh);
          SetIndexStyle(0, DRAW_LINE, ____High_Low_Style, ____High_Low_Width, ____High_Low_Color);
          SetIndexEmptyValue(0,0);
          SetIndexBuffer(1, TrendLow);
          SetIndexStyle(1, DRAW_LINE, ____High_Low_Style, ____High_Low_Width, ____High_Low_Color);
          SetIndexEmptyValue(1,0);
          }
        if(!__Accent_Centerline)
          {
          if(____Use_Default_Color)
            {
            SetIndexBuffer(2, TrendCntr2);
            SetIndexStyle(2, DRAW_LINE, ____Line_Style, ____Line_Width, ____Default_Color);
            SetIndexEmptyValue(2,0);
            }
          else  //Use Alternate Color
            {
            SetIndexBuffer(2, TrendCntr2);
            SetIndexStyle(2, DRAW_LINE, ____Line_Style, ____Line_Width, ____Alternate_Color);
            SetIndexEmptyValue(2,0);
            }
          }
        else  //Accent Centerline
          {
          SetIndexBuffer(2, TrendCntr1);
          SetIndexStyle(2, DRAW_LINE, 0, ____Base_Width, ____Base_Color);
          SetIndexEmptyValue(2,0);
          SetIndexBuffer(3, TrendCntr2);
          SetIndexStyle(3, DRAW_LINE, ____Top_Style, ____Top_Width, ____Top_Color);
          SetIndexEmptyValue(3,0);
          }
        }
      if(!__Show_Centerline)
        {
        if(__Show_High_Low_Lines)
          {
          SetIndexBuffer(0, TrendHigh);
          SetIndexStyle(0, DRAW_LINE, ____High_Low_Style, ____High_Low_Width, ____High_Low_Color);
          SetIndexEmptyValue(0,0);
          SetIndexBuffer(1, TrendLow);
          SetIndexStyle(1, DRAW_LINE, ____High_Low_Style, ____High_Low_Width, ____High_Low_Color);
          SetIndexEmptyValue(1,0);
          }
        SetIndexBuffer(2, TrendCntr2);
        SetIndexStyle(2, DRAW_LINE, ____Line_Style, ____Line_Width, CLR_NONE);
        SetIndexEmptyValue(2,0);
        }
      }
    }

  //Indicator ShortName
  IndicatorShortName ("Trend Suite");

  //Configurations Label
  if(Show_Configuration_Label)
    {
    text= IntegerToString(Trend_Period) + Trendtype + " Trend";
    }

  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Indicator Start                                                                           |
//+-------------------------------------------------------------------------------------------+
int start()
  {
  //If indicator is "Off" or chart TF is out of range deinitialize only once, not every tick.
  if((!Indicator_On) || (Period() > Display_Max_TF))
    {
    if (!Deinitialized) {deinit(); Deinitialized = true;}
    return(0);
    }

  //Confirm range of chart bars for calculations
  //check for possible errors
  counted_bars = IndicatorCounted();
  if(counted_bars < 0)  return(-1);
  //last counted bar will be recounted
  if(counted_bars > 0) counted_bars--;
  limit = Bars - counted_bars;

  //Begin the loop of calculations for the range of chart bars.
  for(int i = limit - 1; i >= 0; i--)
    {    
    BarShift = iBarShift(NULL,NULL,Time[i],true);
    TrendHigh[i]  = iMA(NULL,NULL,Trend_Period,0,Trend_Type,2,BarShift);
    TrendLow[i]   = iMA(NULL,NULL,Trend_Period,0,Trend_Type,3,BarShift);
    TrendTop[i]   = iMA(NULL,NULL,Trend_Period,0,Trend_Type,2,BarShift);
    TrendBot[i]   = iMA(NULL,NULL,Trend_Period,0,Trend_Type,3,BarShift);
    TrendCntr1[i] = iMA(NULL,NULL,Trend_Period,0,Trend_Type,0,BarShift);
    TrendCntr2[i] = iMA(NULL,NULL,Trend_Period,0,Trend_Type,0,BarShift);
    }

  //Display Configurations Label
  ObjectDelete(item1);
  ObjectDelete(item2);
  if(Show_Configuration_Label)
    {
    //display panel
    ObjectCreate(item1,OBJ_LABEL,0,0,0);
    ObjectSet(item1,OBJPROP_CORNER,2);
    ObjectSet(item1,OBJPROP_YDISTANCE,-2);
    ObjectSet(item1,OBJPROP_XDISTANCE,__Label_Shift);
    ObjectSet(item1,OBJPROP_BACK,false);
    ObjectSetText(item1,strRepeat("g",(StringLen(text)/2)),16,"Webdings",__Label_Color);
    //display text
    ObjectCreate(item2,OBJ_LABEL,0,0,0);
    ObjectSet(item2,OBJPROP_CORNER,2);
    ObjectSet(item2,OBJPROP_YDISTANCE,4);
    ObjectSet(item2,OBJPROP_XDISTANCE,__Text_Shift);
    ObjectSet(item2,OBJPROP_BACK,false);
    ObjectSetText(item2,text,8,"Tahoma",__Text_Color);
    }

  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Subroutine: Returns string expression (s) repeated (n) times                              |
//+-------------------------------------------------------------------------------------------+
string strRepeat(string s, int n)
  {
  string result = "";
  for(int i=0; i<n; i++) {result = result + s;}
  return(result);
  }

//+-------------------------------------------------------------------------------------------+
//| Subroutine:  Set up to get the chart scale number                                         |
//+-------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
  Chart_Scale = ChartScaleGet();
  init();
  }

//+-------------------------------------------------------------------------------------------+
//| Subroutine:  Get the chart scale number                                                   |
//+-------------------------------------------------------------------------------------------+
int ChartScaleGet()
  {
  long result = -1;
  ChartGetInteger(0,CHART_SCALE,0,result);
  return((int)result);
  }

//+-------------------------------------------------------------------------------------------+
//| Indicator End                                                                             |
//+-------------------------------------------------------------------------------------------+