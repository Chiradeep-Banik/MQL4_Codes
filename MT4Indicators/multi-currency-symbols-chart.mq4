//+------------------------------------------------------------------+
//|                                            MultySymbolsChart.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "for-good-letters@yandex.ru"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Black
#property indicator_color2 Pink
#property indicator_color3 DodgerBlue
#property indicator_color4 Black
#property indicator_color5 Pink
#property indicator_color6 DodgerBlue
#property indicator_color7 Black


#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2

//---- input parameters
extern string Symbols="AUDUSD,EURUSD,GBPUSD,USDCAD,USDCHF,USDJPY";
extern int TimeFrame=0;
extern int BarsOfSymbol=21;
extern int SpaceBars=5;
extern color LblColor=Yellow; 
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
string sa[];
bool du[];
int Size;
string sn="MSC";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

void fArrayInvert_string(string & aArray[]){
   int tSize=ArraySize(aArray)-1;
      for(int ti=0;ti<ArraySize(aArray)/2;ti++){
         string tTmp=aArray[ti];
         aArray[ti]=aArray[tSize-ti];
         aArray[tSize-ti]=tTmp;
      }
}

int init(){

   fStrSplit(Symbols,sa,",");
   fArrStrTrimLR(sa);
   Size=ArraySize(sa);
   ArrayResize(du,Size);
   
   fArrayInvert_string(sa);
      
      
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer7);
         
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer1);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtMapBuffer2);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,ExtMapBuffer3);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,ExtMapBuffer4);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexBuffer(5,ExtMapBuffer5);
   SetIndexStyle(6,DRAW_HISTOGRAM);
   SetIndexBuffer(6,ExtMapBuffer6);
   
   SetIndexLabel(0,"");
   SetIndexLabel(1,"");
   SetIndexLabel(2,"");
   SetIndexLabel(3,"");
   SetIndexLabel(4,"");
   SetIndexLabel(5,"");
   SetIndexLabel(6,"");
   
   sn=sn+" "+fTimeFrameName(TimeFrame);
   
   IndicatorShortName(sn);
   
   IndicatorDigits(0);
   
   
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   if(UninitializeReason()!=REASON_CHARTCHANGE){   
      fObjDeleteByPrefix("MSC_"+TimeFrame);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){


                           for(int i=0;i<Size*(BarsOfSymbol+SpaceBars)+10;i++){
                              ExtMapBuffer1[i]=0;
                              ExtMapBuffer2[i]=0;                              
                              ExtMapBuffer3[i]=0;
                              ExtMapBuffer4[i]=0;           
                              ExtMapBuffer5[i]=0;
                              ExtMapBuffer6[i]=0;   
                              ExtMapBuffer7[i]=0;                                                         
                           }
                     
                        double MaxRange=0;
                           for(i=0;i<Size;i++){
                              du[i]=fCheckDataUpdate(sa[i],TimeFrame);
                                 if(du[i]){
                                    int hb=iHighest(sa[i],TimeFrame,MODE_HIGH,BarsOfSymbol,0);
                                    int lb=iLowest(sa[i],TimeFrame,MODE_LOW,BarsOfSymbol,0);
                                    double Max=iHigh(sa[i],TimeFrame,hb);
                                    double Min=iLow(sa[i],TimeFrame,lb);
                                    double Range=MathRound((Max-Min)/MarketInfo(sa[i],MODE_POINT));
                                    MaxRange=MathMax(MaxRange,Range);
                                 }
                           }
                        double DrawMedian=MathCeil(MaxRange/2);
                           for(i=0;i<Size;i++){
                                 if(du[i]){
                                    hb=iHighest(sa[i],TimeFrame,MODE_HIGH,BarsOfSymbol,0);
                                    lb=iLowest(sa[i],TimeFrame,MODE_LOW,BarsOfSymbol,0);
                                    Max=iHigh(sa[i],TimeFrame,hb);
                                    Min=iLow(sa[i],TimeFrame,lb);
                                    double Mediana=NormalizeDouble((Max+Min)/2,MarketInfo(sa[i],MODE_DIGITS));
                                       for(int j=0;j<BarsOfSymbol;j++){
                                          double o=DrawMedian+(iOpen(sa[i],TimeFrame,j)-Mediana)/MarketInfo(sa[i],MODE_POINT);
                                          double h=DrawMedian+(iHigh(sa[i],TimeFrame,j)-Mediana)/MarketInfo(sa[i],MODE_POINT);
                                          double l=DrawMedian+(iLow(sa[i],TimeFrame,j)-Mediana)/MarketInfo(sa[i],MODE_POINT);
                                          double c=DrawMedian+(iClose(sa[i],TimeFrame,j)-Mediana)/MarketInfo(sa[i],MODE_POINT);
                                         
                                          if(c==o){
                                             for(int k=j+1;k<iBars(sa[i],TimeFrame);k++){
                                                double o2=DrawMedian+(iOpen(sa[i],TimeFrame,k)-Mediana)/MarketInfo(sa[i],MODE_POINT);
                                                double h2=DrawMedian+(iHigh(sa[i],TimeFrame,k)-Mediana)/MarketInfo(sa[i],MODE_POINT);
                                                double l2=DrawMedian+(iLow(sa[i],TimeFrame,k)-Mediana)/MarketInfo(sa[i],MODE_POINT);
                                                double c2=DrawMedian+(iClose(sa[i],TimeFrame,k)-Mediana)/MarketInfo(sa[i],MODE_POINT);
                                                   if(c2>o2){
                                                      c=o+0.333;
                                                      h=MathMax(h,c);
                                                      break;
                                                   }
                                                   if(c2<o2){
                                                      c=o-0.333;  
                                                      l=MathMin(l,c);
                                                      break;
                                                   }                                                   
                                             }
                                          }
                                         
                                             if(c>o){
                                                ExtMapBuffer2[j+i*(BarsOfSymbol+SpaceBars)]=c;
                                                ExtMapBuffer3[j+i*(BarsOfSymbol+SpaceBars)]=o;  
                                                ExtMapBuffer5[j+i*(BarsOfSymbol+SpaceBars)]=h;
                                                ExtMapBuffer6[j+i*(BarsOfSymbol+SpaceBars)]=l;                                                  
                                                                                             
                                             }
                                             if(c<o){
                                                ExtMapBuffer1[j+i*(BarsOfSymbol+SpaceBars)]=o;
                                                ExtMapBuffer3[j+i*(BarsOfSymbol+SpaceBars)]=c;   
                                                ExtMapBuffer4[j+i*(BarsOfSymbol+SpaceBars)]=h;
                                                ExtMapBuffer6[j+i*(BarsOfSymbol+SpaceBars)]=l;                                                                                               
                                             }
                                         
                                        
                                       }
                                    fObjText("MSC_"+TimeFrame+"_"+sa[i],Time[i*(BarsOfSymbol+SpaceBars)+BarsOfSymbol/2],MaxRange*1.2,sa[i],LblColor,6,WindowFind(sn),"Arial",false);
                                 }
                                 else{
                                    ObjectDelete("MSC_"+TimeFrame+"_"+sa[i]);
                                 }
                               fObjVLine("MSC_"+TimeFrame+"_h_"+sa[i],Time[(i+1)*(BarsOfSymbol+SpaceBars)-SpaceBars/2-1],Gray,1,WindowFind(sn),0,false);   
                           }  
                           for(i=0;i<Size*(BarsOfSymbol+SpaceBars)+10;i++){ 
                              ExtMapBuffer7[i]=MaxRange*1.2;
                           }
                     SetLevelValue(0,0);
                     SetLevelValue(1,MaxRange);
   return(0);
  }
//+------------------------------------------------------------------+

void fObjDeleteByPrefix(string aPrefix){
   for(int i=ObjectsTotal()-1;i>=0;i--){
      if(StringFind(ObjectName(i),aPrefix,0)==0){
         ObjectDelete(ObjectName(i));
      }
   }
}

void fObjVLine(
   string aObjectName,  // 1 имя
   datetime aTime_1,    // 2 время
   color aColor=Red,    // 3 цвет
   int aWidth=1,        // 4 толщина
   int aWindowNumber=0, // 5 окно
   int aStyle=0,        // 6 0-STYLE_SOLID, 1-STYLE_DASH, 2-STYLE_DOT, 3-STYLE_DASHDOT, 4-STYLE_DASHDOTDOT
   bool aBack=false     // 7 фон
   ){
      if(ObjectFind(aObjectName)!=aWindowNumber){
         ObjectCreate(aObjectName,OBJ_VLINE,aWindowNumber,aTime_1,0);
      }      
   ObjectSet(aObjectName,OBJPROP_TIME1,aTime_1);   
   ObjectSet(aObjectName,OBJPROP_COLOR,aColor);
   ObjectSet(aObjectName,OBJPROP_WIDTH,aWidth);
   ObjectSet(aObjectName,OBJPROP_BACK,aBack);     
   ObjectSet(aObjectName,OBJPROP_STYLE,aStyle);       
}


string fTimeFrameName(int arg){

   // fTimeFrameName();

   int v;
      if(arg==0){
         v=Period();
      }
      else{
         v=arg;
      }
      switch(v){
         case 0:
            return("0");
         case 1:
            return("M1");
         case 5:
            return("M5");                  
         case 15:
            return("M15");
         case 30:
            return("M30");             
         case 60:
            return("H1");
         case 240:
            return("H4");                  
         case 1440:
            return("D1");
         case 10080:
            return("W1");          
         case 43200:
            return("MN1");
         default:
            return("M"+arg);          
      }
}

void fObjText(
   string aObjectName,     // 1 имя
   datetime aTime_1,       // 2 время
   double aPrice_1,        // 3 цена
   string aText,           // 4 текст
   color aColor=Red,       // 5 цвет
   int aFontSize=8,        // 6 размер шрифта
   int aWindowNumber=0,    // 7 окно
   string aFont="Arial",   // 8 шрифт
   bool aBack=false        // 9 фон
   
   ){
   
   // fText("",Time[1],Close[1],"",Red,8);
   // fText("",Time[1],Close[1],"",Red,8,0,"Arial",false);
   
      if(ObjectFind(aObjectName)!=aWindowNumber){
         ObjectCreate(aObjectName,OBJ_TEXT,aWindowNumber,aTime_1,aPrice_1);
      }      
   ObjectSet(aObjectName,OBJPROP_TIME1,aTime_1);
   ObjectSet(aObjectName,OBJPROP_PRICE1,aPrice_1);   
   ObjectSetText(aObjectName,aText,aFontSize,aFont,aColor);
   ObjectSet(aObjectName,OBJPROP_BACK,aBack);
}


void fStrSplit(string aString,string & aArray[],string aDelimiter){
   int tCounter=0;
   int tDelimiterLength=StringLen(aDelimiter);
   ArrayResize(aArray,tCounter);
   int tPos1=0;
   int tPos2=StringFind(aString,aDelimiter,0);
      while(tPos2!=-1){
            if(tPos2>tPos1){
               tCounter++;
               ArrayResize(aArray,tCounter);
               aArray[tCounter-1]=StringSubstr(aString,tPos1,tPos2-tPos1);
            }
         tPos1=tPos2+tDelimiterLength;
         tPos2=StringFind(aString,aDelimiter,tPos1);
      }
   tPos2=StringLen(aString);      
      if(tPos2>tPos1){
         tCounter++;   
         ArrayResize(aArray,tCounter);
         aArray[tCounter-1]=StringSubstr(aString,tPos1,tPos2-tPos1);      
      }
}
void fArrStrTrimLR(string & aArray[]){
   for(int ti=0;ti<ArraySize(aArray);ti++){
      aArray[ti]=StringTrimLeft(StringTrimRight(aArray[ti]));
   }
}

bool fCheckDataUpdate(string aSymbol,int aTimeFrame){
   datetime daytimes[];
      if(iClose(aSymbol,aTimeFrame,0)==0){
         return(false);
      }
   ArrayCopySeries(daytimes,MODE_TIME,aSymbol,aTimeFrame);
      if(GetLastError()==4066){
         return(false);
      }
   return(true);      
}




