//+------------------------------------------------------------------+
//|                                              Stealth BUYSELL.mq4 |
//|                                                         Virginia |
//|                                      http://www.stealthforex.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 4

#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Black
#property indicator_color4 Black

//------- Внешние параметры ------------------------------------------
extern int SMAPeriod = 18; // Период ЕМА
extern int LSMAPeriod = 18; // Период LSMA
extern int FromZero = 3; // Расстояние от нулевого уровня

//------- Буферы индикатора ------------------------------------------
double LineHighSMA[];
double LineLowSMA[];
double LSMABuffer1[];
double LSMABuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
void init() {
IndicatorDigits(2);

SetIndexBuffer(0, LineHighSMA);
SetIndexLabel (0, "SMA выше цены");
SetIndexStyle (0, DRAW_LINE, STYLE_SOLID, 3);
SetIndexBuffer(1, LineLowSMA);
SetIndexLabel (1, "SMA ниже цены");
SetIndexStyle (1, DRAW_LINE, STYLE_SOLID, 3);
SetIndexBuffer(2, LSMABuffer1);
SetIndexLabel (2, "LSMA выше цены");
SetIndexStyle (2, DRAW_LINE, STYLE_SOLID, 3);
SetIndexBuffer(3, LSMABuffer2);
SetIndexLabel (3, "LSMA ниже цены");
SetIndexStyle (3, DRAW_LINE, STYLE_SOLID, 3);
Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start() {
double sum, lengthvar, tmp, wt;
int i, shift, counted_bars = IndicatorCounted();
int Draw4HowLong, loopbegin;

if (counted_bars<0) return;
if (counted_bars>0) counted_bars--;
counted_bars = Bars - counted_bars;
for (shift=0; shift<counted_bars; shift++) {
LineLowSMA[shift] = -FromZero;
LineHighSMA[shift] = -FromZero;

double SmaValue = iMA(NULL, 0, SMAPeriod, 0, MODE_SMA, PRICE_TYPICAL,
shift);
if (Close[shift]>SmaValue) LineHighSMA[shift] = EMPTY_VALUE;
if (Close[shift]<SmaValue) LineLowSMA[shift] = EMPTY_VALUE;
}

Draw4HowLong = Bars-LSMAPeriod - 5;
loopbegin = Draw4HowLong - LSMAPeriod - 1;

for(shift=loopbegin; shift>=0; shift--) {
sum = 0;
for (i=LSMAPeriod; i>=1; i--) {
lengthvar = LSMAPeriod + 1;
lengthvar /= 3;
tmp = 0;
tmp = (i - lengthvar) * Close[LSMAPeriod-i+shift];
sum+=tmp;
}
wt = sum * 6 / (LSMAPeriod * (LSMAPeriod + 1));

LSMABuffer1[shift] = FromZero;
LSMABuffer2[shift] = FromZero;

if (wt>Close[shift]) LSMABuffer2[shift] = EMPTY_VALUE;
if (wt<Close[shift]) LSMABuffer1[shift] = EMPTY_VALUE;
}
}
//+------------------------------------------------------------------+


