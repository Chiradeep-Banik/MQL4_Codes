//+------------------------------------------------------------------+
//|                                              RIS SolarSystem.mq4 |
//|                              Copyright 2018, Radian Infosystems. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Radian Infosystems."
#property link      "https://www.radianinfosystems.in"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_color2 Red
#property indicator_color3 Snow
#property indicator_color4 Magenta
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
enum targettype
  {
   Fixed=0,
   Moving=1
  };

input string               string1           = "=== Robo Settings ===";
input bool                 EnableRobo        = false;
input int                  Qty               = 1;
input int                  Alignment         = 1;
input bool                 EnablePartialExit = true;
input targettype           TargetType        = Moving;
input double               TGT_value         = 10;
extern int                 toCheck           = 0;

input string               string3="=== Indicator Settings ===";
extern int period=35;
extern int smooth=10;
extern bool DoAlert=false;
extern bool alertMail=false;

input string               string4="=== General Settings ===";
input int                  ArrowGap=2;                  //Arrow Gap
input int                  digits            = 2;
input bool                 Bid_Ask_Colors    = True;
extern color               FontColorPrice    = Yellow;
input int                  Corner            = 1;
input int                  FontSizePrice     = 26;
input int                  FontSize          = 12;
input string               FontName          = "Arial Black";

datetime lastAlertTime;

double         ExtBuffer0[];
double         ExtBuffer1[];
double         ExtBuffer2[];
double         ExtBuffer3[];
double         ExtBuffer4[];
double         ExtBuffer5[];
double         ExtBufferh1[];
double         ExtBufferh2[];

#define LinesIdentifier "signalLines"

double Up_Arrow_TK[],Dn_Arrow_TK[],SymTarget[],SymBreakEven[],SymExit[];
string sigType="",SigStatus="";
double Old_Price,OldCrossPrice,CrossPrice,BuyCrossPrice,SellCrossPrice,BuyCondPrice,SellCondPrice,points=0,nettPL=0,PartialCrossPrice,tgt,buyBE,sellBE,sl;
bool buyPartialExit=false,sellPartialExit=false,buyBEven=false,sellBEven=false;
bool TakeNewEntry=FALSE,FreshEntry=FALSE,FirstTime=TRUE,TimeExit=FALSE,FirstSignal=TRUE,readyToBuy=False,readyToSell=False,buySL=false,sellSL=false;
double buyCondition=0,sellCondition=0;
double TotalValue=0,AvgValue=0,AvgDiff=0,AvgPL=0,NettPL=0,Over_All_Pending_Lot=0;
int EntryCounter=0,unit=1,CrossTime=0,ss;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(4);

   SetIndexBuffer(0,Up_Arrow_TK);
   SetIndexStyle(0,DRAW_ARROW,0,2);
   SetIndexArrow(0,233);

   SetIndexBuffer(1,Dn_Arrow_TK);
   SetIndexStyle(1,DRAW_ARROW,0,2);
   SetIndexArrow(1,234);

   SetIndexStyle(2,DRAW_ARROW,0,3);
   SetIndexArrow(2,252);
   SetIndexBuffer(2,SymTarget);

   ArrayResize(ExtBuffer0,100000,100000);
   ArrayInitialize(ExtBuffer0,EMPTY_VALUE);

   ArrayResize(ExtBuffer1,100000,100000);
   ArrayInitialize(ExtBuffer1,EMPTY_VALUE);
   ArrayResize(ExtBuffer2,100000,100000);
   ArrayInitialize(ExtBuffer2,EMPTY_VALUE);
   ArrayResize(ExtBuffer3,100000,100000);
   ArrayInitialize(ExtBuffer3,EMPTY_VALUE);
   ArrayResize(ExtBuffer4,100000,100000);
   ArrayInitialize(ExtBuffer4,EMPTY_VALUE);
   ArrayResize(ExtBuffer5,100000,100000);
   ArrayInitialize(ExtBuffer5,EMPTY_VALUE);
   ArrayResize(ExtBufferh1,100000,100000);
   ArrayInitialize(ExtBufferh1,EMPTY_VALUE);
   ArrayResize(ExtBufferh2,100000,100000);
   ArrayInitialize(ExtBufferh2,EMPTY_VALUE);
//---
   return(INIT_SUCCEEDED);
  }
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
//int     period=10;
   int    limit;
   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   double price;
   double MinL=0;
   double MaxH=0;

   if(EnableRobo)
      Comment("Activated");
   else
      Comment("Not Activated");

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars-1;
   string sAlertMsg;

//limit=Bars-1;
/*
   string name="ChartScreenShot"+"CHART_BEGIN"+string(limit)+".gif";
//--- Show the name on the chart as a comment
   Comment(name);
//--- Save the chart screenshot in a file in the terminal_directory\MQL4\Files\
   if(ChartScreenShot(0,name,800,600,ALIGN_LEFT))
      Print("We've saved the screenshot ",name);
*/
   for(int i=limit; i>=0; i--)
     {
      MaxH=High[Highest(NULL,0,MODE_HIGH,period,i)];
      MinL= Low[Lowest(NULL,0,MODE_LOW,period,i)];
      price = (High[i]+Low[i])/2;
      Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;
      Value=MathMin(MathMax(Value,-0.999),0.999);
      ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      Value1=Value;
      Fish1=ExtBuffer0[i];
      if(ExtBuffer0[i]>0) ExtBuffer1[i]=10; else ExtBuffer1[i]=-10;
     }

   for(int i=limit; i>=0; i--)
     {
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<smooth && (i+k)<Bars; k++)
        {
         double weight=smooth-k;
         sumw  += weight;
         sum   += weight*ExtBuffer1[i+k];
        }
      if(sumw!=0)
         ExtBuffer2[i]=sum/sumw;
      else  ExtBuffer2[i]=0;
     }
   for(int i=limit; i>=0; i--)
     {
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<smooth && (i-k)>=0; k++)
        {
         double weight=smooth-k;
         sumw  += weight;
         sum   += weight*ExtBuffer2[i-k];
        }
      if(sumw!=0)
         ExtBuffer3[i]=sum/sumw;
      else  ExtBuffer3[i]=0;
     }
   for(int i=limit; i>=0; i--)
     {
      ExtBuffer4[i]=EMPTY_VALUE;
      ExtBuffer5[i]=EMPTY_VALUE;
      ExtBufferh1[i]=EMPTY_VALUE;
      ExtBufferh2[i]=EMPTY_VALUE;
      if(ExtBuffer3[i]>0) { ExtBuffer4[i]=ExtBuffer3[i]; ExtBufferh1[i]=ExtBuffer3[i]; }
      if(ExtBuffer3[i]<0) { ExtBuffer5[i]=ExtBuffer3[i]; ExtBufferh2[i]=ExtBuffer3[i]; }

      if(ExtBuffer3[i+1]<0 && ExtBuffer3[i]>0 && ss!=12 && (int)Time[i]>CrossTime)
        {
         ss=12;
         Up_Arrow_TK[i]=Low[i]*(1-0.0001*ArrowGap);
         sigType="BUY";
         OldCrossPrice=CrossPrice;
         CrossTime=(int)Time[i];
         CrossPrice=Open[i];
         BuyCrossPrice=CrossPrice;
         PartialCrossPrice=BuyCrossPrice+TGT_value;
         buyPartialExit=true;
         sl=0;
         SigStatus="NEW";

         Over_All_Pending_Lot=(EntryCounter==0) ? Qty :(sellPartialExit==false) ? Qty : Qty*2;
         TotalValue=OldCrossPrice*Over_All_Pending_Lot;
         AvgValue=TotalValue/Over_All_Pending_Lot;
         points = (EntryCounter==0) ? 0 : NormalizeDouble(OldCrossPrice - CrossPrice,digits);
         NettPL = NormalizeDouble(points * Qty,digits);

         sAlertMsg="Solar Wind - "+Symbol()+" "+TF2Str(Period())+": cross UP";

         if(DoAlert)
            Alert(sAlertMsg);
         if(alertMail)
            SendMail(sAlertMsg,"MT4 Alert!\n"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"\n"+sAlertMsg);

        }
      else if(ExtBuffer3[i+1]>0 && ExtBuffer3[i]<0 && ss!=6 && (int)Time[i]>CrossTime)
        {
         ss=6;
         Dn_Arrow_TK[i]=High[i]*(1+0.0001*ArrowGap);
         sigType="SELL";
         OldCrossPrice=CrossPrice;
         CrossTime=(int)Time[i];
         CrossPrice=Open[i];
         SellCrossPrice=CrossPrice;
         PartialCrossPrice=SellCrossPrice-TGT_value;
         sellPartialExit=true;
         sl=0;
         SigStatus="NEW";

         Over_All_Pending_Lot=(EntryCounter==0) ? Qty :(buyPartialExit==false) ? Qty : Qty*2;
         TotalValue=OldCrossPrice*Over_All_Pending_Lot;
         AvgValue=TotalValue/Over_All_Pending_Lot;
         points = (EntryCounter==0) ? 0 : NormalizeDouble(CrossPrice - OldCrossPrice,digits);
         NettPL = NormalizeDouble(points * Qty,digits);

         sAlertMsg="Solar Wind - "+Symbol()+" "+TF2Str(Period())+": cross DOWN";
         if(DoAlert)
            Alert(sAlertMsg);
         if(alertMail)
            SendMail(sAlertMsg,"MT4 Alert!\n"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"\n"+sAlertMsg);
         // 

        }

      //if(i<15)
      //    Print("ExtBuffer3="+ExtBuffer3[i]+" ExtBuffer1="+ExtBuffer1[i]+" ExtBuffer2="+ExtBuffer2[i]+" ExtBuffer4="+ExtBuffer4[i]+" ExtBuffer5="+ExtBuffer5[i]+" i="+i);

      bool buyExit=(TargetType==Fixed) ?(High[i]>=PartialCrossPrice) :(ExtBuffer3[i+1]==10 && ExtBuffer3[i]<ExtBuffer3[i+1]);
      bool sellExit=(TargetType==Fixed) ?(Low[i]<=PartialCrossPrice) :(ExtBuffer3[i+1]==-10 && ExtBuffer3[i]>ExtBuffer3[i+1]);

      if(EnablePartialExit==true && buyExit && ss==12 && buyPartialExit==true)
        {
         SymTarget[i]=High[i]*(1+0.0001*ArrowGap);
         CrossTime=(int)Time[i];
         sigType="BUY";
         SigStatus="TGT";
         buyPartialExit=false;

         Over_All_Pending_Lot=Qty;
         TotalValue=OldCrossPrice*Over_All_Pending_Lot;
         AvgValue=TotalValue/Over_All_Pending_Lot;
         points= NormalizeDouble(Close[i] - CrossPrice,digits);
         NettPL=NormalizeDouble(points*Qty,digits);

        }

      else if(EnablePartialExit==true && sellExit && ss==6 && sellPartialExit==true)
        {
         SymTarget[i]=Low[i]*(1-0.0001*ArrowGap);
         CrossTime=(int)Time[i];
         sigType="SELL";
         SigStatus="TGT";
         sellPartialExit=false;

         Over_All_Pending_Lot=Qty;
         TotalValue=OldCrossPrice*Over_All_Pending_Lot;
         AvgValue=TotalValue/Over_All_Pending_Lot;
         points= NormalizeDouble(CrossPrice - Close[i],digits);
         NettPL=NormalizeDouble(points*Qty,digits);

        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(sigType=="BUY")
     {
      MyObjectPrint("myPriceLabel","Buy Price @: "+DoubleToStr(BuyCrossPrice,digits),FontSize,FontName,LimeGreen,5,55,Corner);

      MyObjectPrint("myPips","Profit in Pips: "+(string)NormalizeDouble(Close[0]-BuyCrossPrice,digits),FontSize,FontName,LimeGreen,5,80,Corner);

      MyObjectPrint("mysl","Stop Loss: "+DoubleToStr(sl,digits),FontSize,FontName,Yellow,5,100,Corner);

      MyObjectPrint("mytarget","Target: "+DoubleToStr(PartialCrossPrice,digits),FontSize,FontName,Pink,5,125,Corner);

      MyObjectPrint("mystatus","Status: "+SigStatus,FontSize,FontName,Yellow,5,150,Corner);

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(sigType=="SELL")
     {
      MyObjectPrint("myPriceLabel","Sell Price @: "+DoubleToStr(SellCrossPrice,digits),FontSize,FontName,Red,5,55,Corner);

      MyObjectPrint("myPips","Profit in Pips: "+(string)NormalizeDouble(SellCrossPrice-Close[0],digits),FontSize,FontName,LimeGreen,5,80,Corner);

      MyObjectPrint("mysl","Stop Loss: "+DoubleToStr(sl,digits),FontSize,FontName,Yellow,5,100,Corner);

      MyObjectPrint("mytarget","Target: "+DoubleToStr(PartialCrossPrice,digits),FontSize,FontName,Pink,5,125,Corner);

      MyObjectPrint("mystatus","Status: "+SigStatus,FontSize,FontName,Yellow,5,150,Corner);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Bid_Ask_Colors==True)
     {
      if(Bid > Old_Price) FontColorPrice=Lime;
      if(Bid < Old_Price) FontColorPrice=Red;
      Old_Price=Bid;
     }

   string Market_Price=DoubleToStr(Bid,digits);

   MyObjectPrint("Market_Price_Label",Market_Price,FontSizePrice,FontName,FontColorPrice,15,5,Corner);

   PlotLine("CrossPrice-Line",CrossPrice,CrossTime,Pink,2);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

// function: TF2Str()
// Description: Convert time-frame to a string
//-----------------------------------------------------------------------------
string TF2Str(int iPeriod)
  {
   switch(iPeriod)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN1");
      default: return("M"+IntegerToString(iPeriod));
     }
  }
//+------------------------------------------------------------------+
//PLOT LINE OBJECT
void PlotLine(string name,double Price,int CTime,color colorname,int style)
  {
   ObjectDelete(name);
   ObjectCreate(name,OBJ_TREND,0,CTime,Price,Time[0],Price);
   ObjectSet(name,OBJPROP_COLOR,colorname);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectSet(name,OBJPROP_WIDTH,0);
   ObjectSet(name,OBJPROP_RAY,true);

   ObjectDelete(name+" txt");
   ObjectCreate(name+" txt",OBJ_TEXT,0,Time[0]+8*Period()*120,Price);
   ObjectSetText(name+" txt",name+": "+DoubleToStr(Price,Digits),8,"Tahoma",colorname);
  }
//OBJECT PRITING SECTION
void MyObjectPrint(string objname,string valueToPrint,int fsize,string fname,color colorname,int x,int y,int objPosition)
  {
   ObjectDelete(objname);
   ObjectCreate(objname,OBJ_LABEL,0,0,0);
   ObjectSetText(objname,valueToPrint,fsize,fname,colorname);
   ObjectSet(objname,OBJPROP_XDISTANCE,x);
   ObjectSet(objname,OBJPROP_YDISTANCE,y);
   ObjectSet(objname,OBJPROP_CORNER,objPosition);
  }
//+------------------------------------------------------------------+
