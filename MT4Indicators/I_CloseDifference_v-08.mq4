//+------------------------------------------------------------------+
//|                                       I_CloseDifference_v-08.mq4 |
//|                                                    Luca Spinello |
//|                                https://mql4tradingautomation.com |
//+------------------------------------------------------------------+
#property copyright "Luca Spinello"
#property link      "https://mql4tradingautomation.com"
#property version   "0.8"
#property strict
#property description "This indicator analyses the price difference" 
#property description "comparing different values across multiple pairs"


#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrMagenta
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
//--- indicator parameters

enum Enum_CalculationMode{
   Mode_CurrentOpen=0,                 //CURR CLOSE vs CURR OPEN
   Mode_PreviousClose=1,               //CURR CLOSE vs PREVIOUS CLOSE
};

string CalculationModeDesc[]={
   "CURR CLOSE vs CURR OPEN",
   "CURR CLOSE vs PREVIOUS CLOSE",
};

input string comment_0="==========";               //Comparator Indicator
input string IndicatorName="CloseDifference";      //Indicator's Name

input string comment_1="==========";   //Currencies to Analyse
input bool UseEUR=true;                //EUR
input bool UseUSD=true;                //USD
input bool UseGBP=true;                //GBP
input bool UseJPY=true;                //JPY
input bool UseCAD=true;                //CAD
input bool UseAUD=true;                //AUD
input bool UseNZD=true;                //NZD
input bool UseCHF=true;                //CHF

input string comment_2="==========";   //Value to compare
input Enum_CalculationMode CalculationMode=Mode_CurrentOpen;        //Compare Method

input string comment_3="==========";   //Threshold for Strength
input int PairsToCount=7;              //Pairs in favor/against to be considered Strong/Weak

input string comment_4="==========";   //Show All Values
input bool ShowPartial=false;          //Show Detailed Pairs

input string comment_1b="==========";  //Positive and Negative Colors
input color PositiveColor=clrGreen;    //Positive Color
input color NegativeColor=clrRed;      //Negative Color

string Font="Lucida Console";

//List all the pairs
string AllPairs[]= 
{
   "AUDCAD",
   "AUDCHF",
   "AUDJPY",
   "AUDNZD",
   "AUDUSD",
   "CADCHF",
   "CADJPY",
   "CHFJPY",
   "EURAUD",
   "EURCAD",
   "EURCHF",
   "EURGBP",
   "EURJPY",
   "EURNZD",
   "EURUSD",
   "GBPAUD",
   "GBPCAD",
   "GBPCHF",
   "GBPJPY",
   "GBPNZD",
   "GBPUSD",
   "NZDCAD",
   "NZDCHF",
   "NZDJPY",
   "NZDUSD",
   "USDCAD",
   "USDCHF",
   "USDJPY"
};      


//List all the currencies
string AllCurrencies[]=
{
   "EUR",
   "USD",
   "GBP",
   "JPY",
   "AUD",
   "NZD",
   "CAD",
   "CHF"
};


//Define working variables
string CurrBase_Pairs[7];
string CurrQuote_Pairs[7];
double CurrBase_Diff[7];
double CurrQuote_Diff[7];
string CurrBase="";
string CurrQuote="";
double CurrBase_Strength[1];           //1-Strong, 0-Neutral, -1-Weak
double CurrQuote_Strength[1];          //1-Strong, 0-Neutral, -1-Weak


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(4);
//--- 
   IndicatorShortName(IndicatorName);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,CurrBase_Strength);      //1-Strong, 0-Neutral, -1-Weak
   SetIndexLabel(0,"BaseStrength");
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,CurrQuote_Strength);     //1-Strong, 0-Neutral, -1-Weak
   SetIndexLabel(1,"QuoteStrength");
   //Clean the chart from existing objects
   CleanChart();


//--- check for input parameters
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+

int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
   PopulatePairs();
   DetectCurrencies();
   PopulateDiffValues();
   CleanChart();
   UpdateLabels();

   return(0);
}
//+------------------------------------------------------------------+


//Remove existing labels
void CleanChart(){
   int Window=0;
   for(int i=0;i<ObjectsTotal(ChartID(),Window,-1);i++){
      if(StringFind(ObjectName(ChartID(),i,Window,OBJ_LABEL),IndicatorName,0)!=-1) ObjectDelete(ChartID(),ObjectName(ChartID(),i,Window,OBJ_LABEL));
   }
}


//Create and update the labels
void UpdateLabels(){
   int LabelsBase=0;
   int LabelsQuote=0;
   int Window=0;
   if(ShowPartial){
      for(int i=0;i<7;i++){
         if(CurrBase_Pairs[i]!=NULL){
            CreateLabel("BASE",CurrBase_Pairs[i],CurrBase_Diff[i],Window,LabelsBase);
            LabelsBase++;
         }
         else{
            DeleteLabel("BASE",CurrBase_Pairs[i]);
         }
         if(CurrQuote_Pairs[i]!=NULL){
            CreateLabel("QUOTE",CurrQuote_Pairs[i],CurrQuote_Diff[i],Window,LabelsQuote);
            LabelsQuote++;
         }
         else{
            DeleteLabel("QUOTE",CurrQuote_Pairs[i]);
         }
      }
   }
   string CalcModeLabel=StringConcatenate(IndicatorName,"CalculationMode");
   if(ObjectFind(ChartID(),CalcModeLabel)>=0) ObjectDelete(ChartID(),CalcModeLabel);
   ObjectCreate(ChartID(),CalcModeLabel,OBJ_LABEL,Window,0,0);
   ObjectSet(CalcModeLabel,OBJPROP_XDISTANCE,5);
   ObjectSet(CalcModeLabel,OBJPROP_YDISTANCE,20);
   ObjectSetText(CalcModeLabel,"Period : "+Period()+" - Compare : "+CalculationModeDesc[CalculationMode],8,Font,clrDimGray);
   string BaseCurrLabel=StringConcatenate(IndicatorName,"BaseLabel");
   string BaseTitle=CurrBase;
   color BaseTitleColor=clrDimGray;
   string StrTmp;
   if(MathRound(CurrBase_Strength[0])==1){
      StrTmp=" is Strong";
      BaseTitleColor=PositiveColor;
   }
   if(MathRound(CurrBase_Strength[0])==0){
      StrTmp=" is Neutral";
      BaseTitleColor=clrDimGray;
   }
   if(MathRound(CurrBase_Strength[0])==-1){
      StrTmp=" is Weak";
      BaseTitleColor=NegativeColor;
   }
   BaseTitle=StringConcatenate(BaseTitle,StrTmp);
   ObjectCreate(ChartID(),BaseCurrLabel,OBJ_LABEL,Window,0,0);
   ObjectSet(BaseCurrLabel,OBJPROP_XDISTANCE,5);
   ObjectSet(BaseCurrLabel,OBJPROP_YDISTANCE,40);
   ObjectSetText(BaseCurrLabel,BaseTitle,8,Font,BaseTitleColor);
   string QuoteCurrLabel=StringConcatenate(IndicatorName,"QuoteLabel");
   string QuoteTitle=CurrQuote;
   color QuoteTitleColor=clrDimGray;
   if(MathRound(CurrQuote_Strength[0])==1){
      StrTmp=" is Strong";
      QuoteTitleColor=PositiveColor;
   }
   if(MathRound(CurrQuote_Strength[0])==0){
      StrTmp=" is Neutral";
      QuoteTitleColor=clrDimGray;
   }
   if(MathRound(CurrQuote_Strength[0])==-1){
      StrTmp=" is Weak";
      QuoteTitleColor=NegativeColor;
   }   
   QuoteTitle=StringConcatenate(QuoteTitle,StrTmp);
   ObjectCreate(ChartID(),QuoteCurrLabel,OBJ_LABEL,Window,0,0);
   ObjectSet(QuoteCurrLabel,OBJPROP_XDISTANCE,120);
   ObjectSet(QuoteCurrLabel,OBJPROP_YDISTANCE,40);
   ObjectSetText(QuoteCurrLabel,QuoteTitle,8,Font,QuoteTitleColor);
}


//Create individual label
void CreateLabel(string Type, string Pair, double Value, int Window, int L){
   string LabelName=StringConcatenate(IndicatorName,"Label",Type,Pair);
   int Xoff;
   int Yoff=L*15;
   if(Type=="BASE") Xoff=5;
   if(Type=="QUOTE") Xoff=120;
   string LabelString=StringConcatenate(Pair," ",Value>=0 ? "+":"",DoubleToStr(Value,4));
   color Color;
   if(Value>=0) Color=PositiveColor;
   else Color=NegativeColor;
   ObjectCreate(ChartID(),LabelName,OBJ_LABEL,Window,0,0);
   ObjectSet(LabelName,OBJPROP_XDISTANCE,Xoff);
   ObjectSet(LabelName,OBJPROP_YDISTANCE,Yoff+60);
   ObjectSetText(LabelName,LabelString,8,Font,Color);
}


void DeleteLabel(string Type, string Pair){
   int Window=0;
   ObjectsDeleteAll(ChartID(),IndicatorName,Window);
}


//Calculate the pairs to analyze
void PopulatePairs(){
   int j=0;
   int k=0;
   for(int i=0;i<ArraySize(AllPairs);i++){
      if(StringFind(AllPairs[i],CurrBase,0)!=-1){
         if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1 && CurrBase!="EUR") CurrBase_Pairs[j]=AllPairs[i];
         if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1 && CurrBase!="AUD") CurrBase_Pairs[j]=AllPairs[i];
         if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1 && CurrBase!="GBP") CurrBase_Pairs[j]=AllPairs[i];
         if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1 && CurrBase!="USD") CurrBase_Pairs[j]=AllPairs[i];
         if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1 && CurrBase!="NZD") CurrBase_Pairs[j]=AllPairs[i];
         if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1 && CurrBase!="CAD") CurrBase_Pairs[j]=AllPairs[i];
         if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1 && CurrBase!="CHF") CurrBase_Pairs[j]=AllPairs[i];
         if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1 && CurrBase!="JPY") CurrBase_Pairs[j]=AllPairs[i];
         j++;
      }
      //Print(UseCAD);
      if(StringFind(AllPairs[i],CurrQuote,0)!=-1){
         if(UseEUR && StringFind(AllPairs[i],"EUR",0)!=-1 && CurrQuote!="EUR") CurrQuote_Pairs[k]=AllPairs[i];
         if(UseAUD && StringFind(AllPairs[i],"AUD",0)!=-1 && CurrQuote!="AUD") CurrQuote_Pairs[k]=AllPairs[i];
         if(UseGBP && StringFind(AllPairs[i],"GBP",0)!=-1 && CurrQuote!="GBP") CurrQuote_Pairs[k]=AllPairs[i];
         if(UseUSD && StringFind(AllPairs[i],"USD",0)!=-1 && CurrQuote!="USD") CurrQuote_Pairs[k]=AllPairs[i];
         if(UseNZD && StringFind(AllPairs[i],"NZD",0)!=-1 && CurrQuote!="NZD") CurrQuote_Pairs[k]=AllPairs[i];
         if(UseCAD && StringFind(AllPairs[i],"CAD",0)!=-1 && CurrQuote!="CAD") CurrQuote_Pairs[k]=AllPairs[i];
         if(UseCHF && StringFind(AllPairs[i],"CHF",0)!=-1 && CurrQuote!="CHF") CurrQuote_Pairs[k]=AllPairs[i];
         if(UseJPY && StringFind(AllPairs[i],"JPY",0)!=-1 && CurrQuote!="JPY") CurrQuote_Pairs[k]=AllPairs[i];
         k++;
      }
   }
}


//Detect current currencies in the chart
void DetectCurrencies(){
   string Curr1="";
   string Curr2="";
   int Curr1Pos,Curr2Pos;
   for(int i=0;i<ArraySize(AllCurrencies);i++){
      int Curr1PosTmp=StringFind(Symbol(),AllCurrencies[i],0);
      int Curr2PosTmp=StringFind(Symbol(),AllCurrencies[i],0);
      if(Curr1=="" && Curr1PosTmp!=-1){
         Curr1=AllCurrencies[i];
         Curr1Pos=Curr1PosTmp;
      }
      if(Curr1!="" && Curr2PosTmp!=-1){
         Curr2=AllCurrencies[i];
         Curr2Pos=Curr2PosTmp;
      }
   }
   if(Curr1Pos<Curr2Pos){
      CurrBase=Curr1;
      CurrQuote=Curr2;
   }
   else{
      CurrBase=Curr2;
      CurrQuote=Curr1;
   }
}


//Populate the current values
void PopulateDiffValues(){
   int BaseStrong=0;
   int QuoteStrong=0;
   int BaseWeak=0;
   int QuoteWeak=0;
   for(int i=0;i<7;i++){
      if(CurrBase_Pairs[i]!=NULL){
         CurrBase_Diff[i]=CalculateDiff(CurrBase_Pairs[i]);
         if((StringFind(CurrBase_Pairs[i],CurrBase,0)==0 && CurrBase_Diff[i]>=0) || (StringFind(CurrBase_Pairs[i],CurrBase,0)>0 && CurrBase_Diff[i]<0)) BaseStrong++;
         if((StringFind(CurrBase_Pairs[i],CurrBase,0)==0 && CurrBase_Diff[i]<0) || (StringFind(CurrBase_Pairs[i],CurrBase,0)>0 && CurrBase_Diff[i]>=0)) BaseWeak++;
      }
      if(CurrQuote_Pairs[i]!=NULL){
         CurrQuote_Diff[i]=CalculateDiff(CurrQuote_Pairs[i]);
         if((StringFind(CurrQuote_Pairs[i],CurrQuote,0)==0 && CurrQuote_Diff[i]>=0) || (StringFind(CurrQuote_Pairs[i],CurrQuote,0)>0 && CurrQuote_Diff[i]<0)) QuoteStrong++;
         if((StringFind(CurrQuote_Pairs[i],CurrQuote,0)==0 && CurrQuote_Diff[i]<0) || (StringFind(CurrQuote_Pairs[i],CurrQuote,0)>0 && CurrQuote_Diff[i]>=0)) QuoteWeak++;
      }
   }
   if(BaseStrong>=PairsToCount) CurrBase_Strength[0]=1;
   else if(BaseWeak>=PairsToCount) CurrBase_Strength[0]=-1;
   else CurrBase_Strength[0]=0;
   if(QuoteStrong>=PairsToCount) CurrQuote_Strength[0]=1;
   else if(QuoteWeak>=PairsToCount) CurrQuote_Strength[0]=-1;
   else CurrQuote_Strength[0]=0;
}


//Calculate individual value
double CalculateDiff(string Pair){
   double Evalue=iClose(Pair,0,0);
   double Svalue=0;
   switch(CalculationMode){
      case 0:
         Svalue=iOpen(Pair,0,0);
         break;
      case 1:
         Svalue=iClose(Pair,0,1);
         break;
   }
   double Diff=NormalizeDouble((Evalue*1000/Svalue)-1000,4);
   return Diff;
}
