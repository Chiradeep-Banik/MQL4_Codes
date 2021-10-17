
#property copyright  ""
#property link       ""

//---- indicator settings
#property  indicator_separate_window

#property  indicator_buffers  5

#property  indicator_color1  DodgerBlue
#property  indicator_color2  Crimson
#property  indicator_color3  CLR_NONE
#property  indicator_color4  CLR_NONE
#property  indicator_color5  CLR_NONE

#property  indicator_width1  1
#property  indicator_width2  1
#property  indicator_width3  1
#property  indicator_width4  1
#property  indicator_width5  1

// defines
#define N_CHECK_SHINNE  100

//---- indicator parameters
extern string  symbol      = "";
extern int     nShinNe     = 3;      // should be < N_CHECK_SHINNE
extern int     nBar        = 1000;
extern string  symTimeRef  = "";     // time reference
extern color   cUpFrame    = Lime;
extern color   cUpBody     = Black;
extern color   cDownFrame  = Lime;
extern color   cDownBody   = White;
extern int     nBodyWidth  = 3;
extern bool    bAlert      = true;
extern bool    bMail       = false;
extern int     markUp      = 233;    // mark for long signal
extern int     markDown    = 234;    // mark for short signal

//---- indicator buffers
double BufferLong[];
double BufferShort[];
double BufferClose[];
double BufferHigh[];
double BufferLow[];

//---- vars
string   sIndicatorName;
string   sIndSelf        = "Shin Ne Ashi";
int      nChart;
string   sVarChart       = "Shin Ne Ashi nChart";
string   sVarCount       = "Shin Ne Ashi count";
string   sUpFrameName    = "1upFrame";
string   sUpBodyName     = "2upBody";
string   sDownFrameName  = "1downFrame";
string   sDownBodyName   = "2downBody";
double   vOpen[N_CHECK_SHINNE];
double   vClose[N_CHECK_SHINNE];
bool     bUp[N_CHECK_SHINNE];
datetime tAlertLast;
int      alertCodeLast;
double   prevLongPeak;
double   prevShortPeak;

//----------------------------------------------------------------------
string getBarName(int i, string s)
{
    return(sIndicatorName + " bar" + i + " " + s);
}

//----------------------------------------------------------------------
void objInit(bool bInit)
{
    int win = WindowFind(sIndicatorName);
    
    for (int i = 0; i < nBar; i++) {
	string sUpFrame   = getBarName(i, sUpFrameName);
	string sUpBody    = getBarName(i, sUpBodyName);
	string sDownFrame = getBarName(i, sDownFrameName);
	string sDownBody  = getBarName(i, sDownBodyName);
	
	if (bInit) {
	    // create bars
	    // up bar
	    ObjectCreate(sUpFrame, OBJ_TREND, win, 0, 0);
	    ObjectSet(sUpFrame, OBJPROP_RAY, 0);
	    ObjectSet(sUpFrame, OBJPROP_WIDTH, nBodyWidth + 2);
	    ObjectSet(sUpFrame, OBJPROP_COLOR, cUpFrame);
	    ObjectSet(sUpFrame, OBJPROP_BACK, true);
	    
	    ObjectCreate(sUpBody,  OBJ_TREND, win, 0, 0);
	    ObjectSet(sUpBody, OBJPROP_RAY, 0);
	    ObjectSet(sUpBody, OBJPROP_WIDTH, nBodyWidth);
	    ObjectSet(sUpBody, OBJPROP_COLOR, cUpBody);
	    ObjectSet(sUpBody, OBJPROP_BACK, true);
	    
	    // down bar
	    ObjectCreate(sDownFrame, OBJ_TREND, win, 0, 0);
	    ObjectSet(sDownFrame, OBJPROP_RAY, 0);
	    ObjectSet(sDownFrame, OBJPROP_WIDTH, nBodyWidth + 2);
	    ObjectSet(sDownFrame, OBJPROP_COLOR, cDownFrame);
	    ObjectSet(sDownFrame, OBJPROP_BACK, true);
	    
	    ObjectCreate(sDownBody,  OBJ_TREND, win, 0, 0);
	    ObjectSet(sDownBody, OBJPROP_RAY, 0);
	    ObjectSet(sDownBody, OBJPROP_WIDTH, nBodyWidth);
	    ObjectSet(sDownBody, OBJPROP_COLOR, cDownBody);
	    ObjectSet(sDownBody, OBJPROP_BACK, true);
	} else {
	    // delete bars
	    ObjectDelete(sUpFrame);
	    ObjectDelete(sUpBody);
	    ObjectDelete(sDownFrame);
	    ObjectDelete(sDownBody);
	}
    }
}

//----------------------------------------------------------------------
void init()
{
    nChart = GlobalVariableGet(sVarChart) + 1;
    GlobalVariableSet(sVarChart, nChart);
    
    int count = GlobalVariableGet(sVarCount) + 1;
    GlobalVariableSet(sVarCount, count);
    
    if (symbol == "") {
	symbol = Symbol();
    }
    if (symTimeRef == "") {
	symTimeRef = Symbol();
    }
    if (nShinNe < 1) {
	nShinNe = 1;
    }
    
    sIndicatorName = sIndSelf + "(" + nShinNe + ") " + symbol + " " + count;
    
    IndicatorShortName(sIndicatorName);
    
    SetIndexBuffer(0, BufferLong);
    SetIndexBuffer(1, BufferShort);
    SetIndexBuffer(2, BufferClose);
    SetIndexBuffer(3, BufferHigh);
    SetIndexBuffer(4, BufferLow);
    
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexStyle(1, DRAW_ARROW);
    SetIndexStyle(2, DRAW_LINE);
    SetIndexStyle(3, DRAW_LINE);
    SetIndexStyle(4, DRAW_LINE);
    
    SetIndexArrow(0, markUp);
    SetIndexArrow(1, markDown);
    
    SetIndexLabel(0, "Long");
    SetIndexLabel(1, "Short");
    SetIndexLabel(2, "Close");
    SetIndexLabel(3, "High");
    SetIndexLabel(4, "Low");
}

//----------------------------------------------------------------------
void deinit()
{
    objInit(false);
    
    nChart = GlobalVariableGet(sVarChart);
    GlobalVariableSet(sVarChart, nChart - 1);
    
    if (nChart == 1) {
	GlobalVariableDel(sVarChart);
	GlobalVariableDel(sVarCount);
    }
}

//----------------------------------------------------------------------
void barMove(int i, datetime t, double open, double close)
{
    string sUpFrame   = getBarName(i, sUpFrameName);
    string sUpBody    = getBarName(i, sUpBodyName);
    string sDownFrame = getBarName(i, sDownFrameName);
    string sDownBody  = getBarName(i, sDownBodyName);
    
    double upOpen = 0;
    double upClose = 0;
    double downOpen = 0;
    double downClose = 0;
    
    if (close >= open) {
	upOpen  = open;
	upClose = close;
    } else {
	downOpen  = open;
	downClose = close;
    }
    
    ObjectMove(sUpFrame, 0, t, upOpen);
    ObjectMove(sUpFrame, 1, t, upClose);
    ObjectMove(sUpBody,  0, t, upOpen);
    ObjectMove(sUpBody,  1, t, upClose);
    
    ObjectMove(sDownFrame, 0, t, downOpen);
    ObjectMove(sDownFrame, 1, t, downClose);
    ObjectMove(sDownBody,  0, t, downOpen);
    ObjectMove(sDownBody,  1, t, downClose);
}

//----------------------------------------------------------------------
void shift(double open, double close)
{
    for (int k = nShinNe; k > 0; k--) {
	vOpen[k]  = vOpen[k - 1];
	vClose[k] = vClose[k - 1];
    }
    vOpen[0]  = open;
    vClose[0] = close;
}

//----------------------------------------------------------------------
string TimeFrameToStr(int timeFrame)
{
    switch (timeFrame) {
    case PERIOD_M1:  return("M1");
    case PERIOD_M5:  return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M30");
    case PERIOD_H1:  return("H1");
    case PERIOD_H4:  return("H4");
    case PERIOD_D1:  return("D1");
    case PERIOD_W1:  return("W1");
    case PERIOD_MN1: return("MN");
    }
    
    return("??");
}

//----------------------------------------------------------------------
void msg(string sMsg, bool bMail)
{
    string tf = TimeFrameToStr(Period());
    string sSub = "[" + sIndSelf + "][" + Symbol() + " " + tf + "]";
    string s = sSub + " " + sMsg;
    Alert(s);
    
    if (bMail) {
	SendMail(sSub, sSub + "\n" + sMsg);
    }
}

//----------------------------------------------------------------------
void start()
{
    int limit;
    int counted_bars = IndicatorCounted();
    
    if (counted_bars > 0) {
	counted_bars--;
    }
    
    limit = Bars - counted_bars;
    
    int i, x;
    datetime t;
    for (i = 0; i < limit; i++) {
	t = iTime(symTimeRef, 0, i);
	x = iBarShift(symbol, 0, t);
	BufferClose[i] = iClose(symbol, 0, x);
    }
    
    objInit(true);
    
    int w = WindowBarsPerChart();
    int b = WindowFirstVisibleBar() + MathMax(0, (nBar - w) / 2);
    if (b < nBar) {
	b = nBar - 1;
    }
    if (b > Bars) {
	b = Bars;
    }
    
    double open, close;
    bool bTrendChanged = false;
    int k;
    
    for (i = 0; i < nBar; i++) {
	
	BufferLong[i] = EMPTY_VALUE;
	BufferShort[i] = EMPTY_VALUE;
	
	int iRef = b - i;
	
	if (iRef >= 0) {
	    t = iTime(symTimeRef, 0, iRef);
	    x = iBarShift(symbol, 0, t);
	} else {
	    t = iTime(symTimeRef, 0, 0);
	    x = -1;
	}
	
	close = iClose(symbol, 0, x);
	
	if (i == 0) {
	    for (k = 0; k <= nShinNe; k++) {
		vOpen[k]  = close;
		vClose[k] = close;
	    }
	} else if (i == 1) {
	    vOpen[0]  = close;
	    vClose[0] = close;
	} else {
	    double prevPeak;
	    
	    for (k = 0; k <= nShinNe; k++) {
		bUp[k] = (vClose[k] >= vClose[k + 1]);
	    }
	    
	    if (bUp[0]) {
		// up trend
		if (close > vClose[0]) {
		    shift(vClose[0], close);
		    bTrendChanged = false;
		} else {
		    prevPeak = vOpen[0];
		    for (k = 1; k < nShinNe; k++) {
			if (!bUp[k]) {
			    prevPeak = vOpen[k];
			    break;
			}
		    }
		    if (k == nShinNe) {
			prevPeak = vClose[nShinNe];
		    }
		    if (close < prevPeak) {
			shift(vOpen[0], close);
			bTrendChanged = true;
			BufferShort[iRef] = close;
			prevShortPeak = prevPeak;
		    }
		}		    
	    } else {
		// down trend
		if (close < vClose[0]) {
		    shift(vClose[0], close);
		    bTrendChanged = false;
		} else {
		    prevPeak = vOpen[0];
		    for (k = 1; k < nShinNe; k++) {
			if (bUp[k]) {
			    prevPeak = vOpen[k];
			    break;
			}
		    }
		    if (k == nShinNe) {
			prevPeak = vClose[nShinNe];
		    }
		    if (close > prevPeak) {
			shift(vOpen[0], close);
			bTrendChanged = true;
			BufferLong[iRef] = close;
			prevLongPeak = prevPeak;
		    }
		}
	    }
	}
	
	open = vOpen[0];
	close = vClose[0];
	
	if (x < 0) {
	    open = 0;
	    close = 0;
	}
	barMove(i, t, open, close);
	
	double ofst = Point * 3;
	BufferHigh[iRef] = MathMax(open, close) + ofst;
	BufferLow[iRef] = MathMin(open, close) - ofst;
    }
    
    WindowRedraw();
    
    if (bAlert) {
	bool bLong = (BufferLong[1] != EMPTY_VALUE);
	bool bShort = (BufferShort[1] != EMPTY_VALUE);
	int alertCode = 0;
	if (bLong)  alertCode |= 1;
	if (bShort) alertCode |= 2;
	if (alertCode != 0) {
	    datetime t0 = Time[0];
	    if (t0 != tAlertLast || alertCode != alertCodeLast) {
		tAlertLast = t0;
		alertCodeLast = alertCode;
		double spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
		string sBidAsk = "Bid/Ask= " +  DoubleToStr(Close[0], Digits) + "/" + DoubleToStr(Close[0] + spread, Digits);
		if (bLong) {
		    msg("Long, " + sBidAsk + ", prevPeak= " + DoubleToStr(prevLongPeak, Digits), bMail);
		}
		if (bShort) {
		    msg("Short, " + sBidAsk + ", prevPeak= " + DoubleToStr(prevShortPeak, Digits), bMail);
		}
	    }
	}
    }
}