//+------------------------------------------------------------------+
//|                                                       OBVMTF.mq4 |
//|                           Copyright 2019, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Roberto Jacobs (3rjfx) ~ By 3rjfx ~ Created: 2019/02/23"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property description "Indicator OBVMTF base on the On Balance Volume indicator with Signal"
#property description "and Alert for MetaTrader 4 and options to display signal on the chart."
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
//--
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
//--
enum YN
 {
   No,
   Yes
 };
//--
enum corner
 {  
   NotShow=-1,     // Not Show Arrow
   topchart=0,     // On Top Chart
   bottomchart=1   // On Bottom Chart
 };
//--
//--
input ENUM_APPLIED_PRICE obv_prc = PRICE_CLOSE; // OBV Applied Price
input corner                 cor = topchart;    // Arrow Move Position
input YN                  alerts = Yes;         // Display Alerts / Messages (Yes) or (No)
input YN              EmailAlert = No;          // Email Alert (Yes) or (No)
input YN              sendnotify = No;          // Send Notification (Yes) or (No)
input YN             displayinfo = Yes;         // Display Trade Info
input color            textcolor = clrSnow;     // Text Color
input color              ArrowUp = clrLime;     // Arrow Up Color
input color              ArrowDn = clrRed;      // Arrow Down Color
input color              NTArrow = clrYellow;   // Arrow No Signal
//---
//---- indicator buffers
double OBVMoveUp[];
double OBVMoveDn[];
//--
//--- spacing
int scaleX=35,scaleY=40,scaleYt=18,offsetX=250,offsetY=3,fontSize=7; // coordinate
int txttf,
    arrtf;
color arclr;
ENUM_BASE_CORNER bcor;
//--- arrays for various things
int OBVTF[]={1,5,15,30,60,240,1440,10080,43200};
int XOBV[10];
string periodStr[]={"M1","M5","M15","M30","H1","H4","D1","W1","MN","MOVE"}; // Text Timeframes
//--
double 
   pricepos;
datetime 
   cbartime;
int cur,prv;
int imnn,imnp;
int cmnt,pmnt;
int arr;
long CI;
static int fbar;
string posisi,
       sigpos,
       iname,
       msgText;
string frtext="obvwave";
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    IndicatorBuffers(2);
    //--
    SetIndexBuffer(0,OBVMoveUp);
    SetIndexBuffer(1,OBVMoveDn);
    //--
    SetIndexStyle(0,DRAW_NONE);
    SetIndexStyle(1,DRAW_NONE);
    //--
//----
    //-- name for DataWindow
    SetIndexLabel(0,"OBV_Up");
    SetIndexLabel(1,"OBV_Dn");
    //--
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
//---- indicator short name
    IndicatorDigits(_Digits);
    iname=WindowExpertName();
    IndicatorShortName(iname);
    CI=ChartID();
    arr=ArraySize(XOBV);
    //--
    if(cor>=0)
      {
        if(cor==topchart) {bcor=CORNER_LEFT_UPPER; txttf=45; arrtf=-20;}
        if(cor==bottomchart) {bcor=CORNER_LEFT_LOWER; txttf=45; arrtf=-12;}
      }
    else
     {
       string name;
       for(int i=ObjectsTotal()-1; i>=0; i--)
         {
           name=ObjectName(i);
           if(StringFind(name,frtext,0)>-1) ObjectDelete(0,name);
         }
     }
    //--
//---
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    Comment("");
    string name;
    for(int i=ObjectsTotal()-1; i>=0; i--)
      {
        name=ObjectName(i);
        if(StringFind(name,frtext,0)>-1) ObjectDelete(0,name);
      }
    //--
    GlobalVariablesDeleteAll();
//----
   return(0);
  }
//---------//
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
    ArraySetAsSeries(open,true);
    ArraySetAsSeries(high,true);
    ArraySetAsSeries(low,true);
    ArraySetAsSeries(close,true);
    ArraySetAsSeries(time,true);
    ArraySetAsSeries(volume,true);
    int trn=0,xbup=0,xbdn=0,i;
    cbartime=time[0];
    arclr=NTArrow;
    //--
    imnn=Minute();
    if(imnn!=imnp)
      {
        ResetLastError();
        RefreshRates();
        if(cor>=0)
          {
            for(int x=0; x<arr; x++)
              {
                CreateArrowLabel(CI,frtext+"_tfx_arrow_"+string(x),periodStr[x],"Bodoni MT Black",fontSize,textcolor,bcor,
                                 txttf+x*scaleX+offsetX,scaleY+offsetY+7,true); //"Georgia" "Bodoni MT Black" "Verdana" "Arial Black"
              }
          }
        //--
        for(i=0; i<arr-1; i++)
          {
            XOBV[i]=GetDirection(OBVTF[i]);
            if(cor>=0)
              {
                if(XOBV[i]>0) arclr=ArrowUp;
                if(XOBV[i]<0) arclr=ArrowDn;
                CreateArrowLabel(CI,frtext+"_win_arrow_"+string(i),CharToString(108),"Wingdings",14,arclr,bcor,
                                 txttf+i*scaleX+offsetX,arrtf+scaleY+offsetY+7,true);
              }
            if(i<6)
              {
                if(XOBV[i]>0) xbup++;
                if(XOBV[i]<0) xbdn++;
              }
          }
        if(i==9)
          {
            if(xbup>=4) 
              {
                trn=1;
                XOBV[i]=xbup; arclr=ArrowUp; OBVMoveUp[0]=GetPrice(_Period,trn); 
                pricepos=OBVMoveUp[0]; 
                cur=1;
                fbar=iBarShift(_Symbol,0,cbartime,false);
              }
            else
            if(xbdn>=4) 
              {
                trn=-1;
                XOBV[i]=xbdn; arclr=ArrowDn; OBVMoveDn[0]=GetPrice(_Period,trn); 
                pricepos=OBVMoveDn[0]; 
                cur=-1;
                fbar=iBarShift(_Symbol,0,cbartime,false);
              }
            else 
              {
                XOBV[i]=0; 
                arclr=NTArrow; 
                OBVMoveDn[0]=0.0; 
                OBVMoveUp[0]=0.0; 
                pricepos=close[0];
                cur=0;
                fbar=iBarShift(_Symbol,0,time[0],false);
              }
            //--
            if(cor>=0) CreateArrowLabel(CI,frtext+"_win_arrow_"+string(i),CharToString(108),"Wingdings",14,arclr,bcor,
                                        txttf+i*scaleX+offsetX+8,arrtf+scaleY+offsetY+7,true);
          }
        //--
        imnp=imnn;
      }
    //--   
    if(alerts==Yes||EmailAlert==Yes||sendnotify==Yes) Do_Alerts(cur,fbar);
    if(displayinfo==Yes) ChartComm();
    //--
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------//

// Getting the applied price index shift
double GetAppliedPrice(int xtf,int nIndex)
  {
//---
   double dPrice=0.0;
   //--
   switch(obv_prc)
     {
      case PRICE_OPEN:  dPrice=iOpen(_Symbol,xtf,nIndex);                                                                 break;
      case PRICE_HIGH:  dPrice=iHigh(_Symbol,xtf,nIndex);                                                                 break;
      case PRICE_LOW:   dPrice=iLow(_Symbol,xtf,nIndex);                                                                  break;
      case PRICE_CLOSE:  dPrice=iClose(_Symbol,xtf,nIndex);                                                               break;
      case PRICE_MEDIAN:  dPrice=(iHigh(_Symbol,xtf,nIndex)+iLow(_Symbol,xtf,nIndex))/2.0;                                break;
      case PRICE_TYPICAL:  dPrice=(iHigh(_Symbol,xtf,nIndex)+iLow(_Symbol,xtf,nIndex)+iClose(_Symbol,xtf,nIndex))/3.0;    break;
      case PRICE_WEIGHTED:  dPrice=(iHigh(_Symbol,xtf,nIndex)+iLow(_Symbol,xtf,nIndex)+2*iClose(_Symbol,xtf,nIndex))/4.0; break;
     }
   //--
   return(dPrice);
//---
  }
//---------//

// getting the price direction
int GetDirection(int xtf) 
  {
//---
    int ret=0,
        bar=4,
        i;
    RefreshRates();
    //--
    double OBV[];
    ArrayResize(OBV,bar);
    ArraySetAsSeries(OBV,true);
     OBV[bar-1]=(double)iVolume(_Symbol,xtf,bar-1);
    //--
    for(i=bar-2; i>=0; i--)
      {
        double dCurrentPrice=GetAppliedPrice(xtf,i);
        double dPreviousPrice=GetAppliedPrice(xtf,i+1);
        if(dCurrentPrice==dPreviousPrice)
           OBV[i]=OBV[i+1];
        else
          {
            if(dCurrentPrice<dPreviousPrice)
              OBV[i]=OBV[i+1]-(double)iVolume(_Symbol,xtf,i);  
            else
              OBV[i]=OBV[i+1]+(double)iVolume(_Symbol,xtf,i); 
         }
      }
    //--
    if(OBV[0]>OBV[1]) ret=1;
    if(OBV[0]<OBV[1]) ret=-1;
    //--
    return(ret);
//---
  }
//---------//

// getting the price position
double GetPrice(int xtf,int bb)
  {
//---
    int bar=(int)480/xtf < 9 ? 5 : (int)480/xtf;
    if(bar>100) bar=100;
    double ppos=0;
    double hih[],
           lol[];
    ArrayResize(hih,bar);
    ArrayResize(lol,bar);
    ArraySetAsSeries(hih,true);
    ArraySetAsSeries(lol,true);
    //--
    for(int x=bar-1; x>=0; x--)
      {
        hih[x]=iHigh(_Symbol,xtf,x);
        lol[x]=iLow(_Symbol,xtf,x);
      }
    if(bb>0) {ppos=iLow(_Symbol,xtf,ArrayMinimum(lol,bar,0)); cbartime=iTime(_Symbol,xtf,ArrayMinimum(lol,bar,0));}
    if(bb<0) {ppos=iHigh(_Symbol,xtf,ArrayMaximum(hih,bar,0)); cbartime=iTime(_Symbol,xtf,ArrayMaximum(hih,bar,0));}
    //--
    return(ppos);
//---
  }
//---------//

void Do_Alerts(int fcur,int fb)
  {
    //--
    cmnt=Minute();
    if(cmnt!=pmnt)
      {
        //--
        if(fcur==1)
          {
            msgText="On Balance Volume Up Start"+" at bars: "+string(fb);
            posisi="Bullish"; 
            sigpos="Open BUY Order";
          }
        else
        if(fcur==-1)
          {
            msgText="On Balance Volume Down Start"+" at bars: "+string(fb);
            posisi="Bearish"; 
            sigpos="Open SELL Order";
          }
        else
          {
            msgText="On Balance Volume Signal Not Found!";
            posisi="Not Found!"; 
            sigpos="Wait for Confirmation!";
          }
        //--
        if(fcur!=prv)
          {
            Print(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                  "\n--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(alerts==Yes)
              Alert(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                    "--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(EmailAlert==Yes) 
              SendMail(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(sendnotify==Yes) 
              SendNotification(iname+"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);                
            //--
            prv=fcur;
            //pbartime=fbartime;
          }
        //--
        pmnt=cmnt;
      }
    //--
    return;
    //---
  }
//---------//

string TF2Str(int period)
  {
   switch(period)
     {
       //--
       case PERIOD_M1: return("M1");
       case PERIOD_M5: return("M5");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_H1: return("H1");
       case PERIOD_H4: return("H4");
       case PERIOD_D1: return("D1");
       case PERIOD_W1: return("W1");
       case PERIOD_MN1: return("MN");
       //--
     }
   return(string(period));
  }  
//---------//

string AccountMode() // function: to known account trade mode
   {
//----
//--- Demo, Contest or Real account 
   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
 //---
   string trade_mode;
   //--
   switch(account_type) 
     { 
      case  ACCOUNT_TRADE_MODE_DEMO: 
         trade_mode="Demo"; 
         break; 
      case  ACCOUNT_TRADE_MODE_CONTEST: 
         trade_mode="Contest"; 
         break; 
      default: 
         trade_mode="Real"; 
         break; 
     }
   //--
   return(trade_mode);
//----
   } //-end AccountMode()
//---------//

void ChartComm() // function: write comments on the chart
  {
//----
   //--
   Comment("\n     :: Server Date Time : ",(string)Year(),".",(string)Month(),".",(string)Day(), "   ",TimeToString(TimeCurrent(),TIME_SECONDS), 
      "\n     ------------------------------------------------------------", 
      "\n      :: Broker             :  ",TerminalCompany(), 
      "\n      :: Acc. Name       :  ",AccountName(), 
      "\n      :: Acc, Number    :  ",(string)AccountNumber(),
      "\n      :: Acc,TradeMode :  ",AccountMode(),
      "\n      :: Acc. Leverage   :  1 : ",(string)AccountLeverage(), 
      "\n      :: Acc. Balance     :  ",DoubleToString(AccountBalance(),2),
      "\n      :: Acc. Equity       :  ",DoubleToString(AccountEquity(),2), 
      "\n      --------------------------------------------",
      "\n      :: Indicator Name  :  ",iname,
      "\n      :: Currency Pair    :  ",_Symbol,
      "\n      :: Current Spread  :  ",IntegerToString(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),0),
      "\n      :: Signal Start       : at bar ",string(fbar),
      "\n      :: Price Start        :  ",DoubleToString(pricepos,_Digits), 
      "\n      :: Indicator Signal :  ",posisi,
      "\n      :: Suggested        :  ",sigpos);
   //---
   ChartRedraw();
   return;
//----
  } //-end ChartComm()  
//---------//

bool CreateArrowLabel(long   chart_id, 
                      string lable_name, 
                      string label_text,
                      string font_model,
                      int    font_size,
                      color  label_color,
                      int    chart_corner,
                      int    x_cor, 
                      int    y_cor,
                      bool   price_hidden)
  { 
//--- 
    //--
    ObjectDelete(chart_id,lable_name);
    //--
    if(!ObjectCreate(chart_id,lable_name,OBJ_LABEL,0,0,0,0,0)) 
      { 
        Print(__FUNCTION__, 
            ": failed to create \"Arrow Label\" sign! Error code = ",GetLastError());
        return(false); 
      } 
    //--
    ObjectSetString(chart_id,lable_name,OBJPROP_TEXT,label_text);
    ObjectSetString(chart_id,lable_name,OBJPROP_FONT,font_model); 
    ObjectSetInteger(chart_id,lable_name,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_COLOR,label_color);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_CORNER,chart_corner);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_XDISTANCE,x_cor);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_YDISTANCE,y_cor);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_HIDDEN,price_hidden);
    //--- successful execution 
    return(true);
    //--
  }
//---------//  
//+------------------------------------------------------------------+