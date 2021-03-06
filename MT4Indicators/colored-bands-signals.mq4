//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                        VWMA+CG 4C AA MTF TT                          %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#property copyright   "" 
#property link        "" 
#property description ""
#property description ""
#property description "" 
#property version  "7.0"
//---
#property indicator_chart_window
#property indicator_buffers 7
//---
#property indicator_color1  clrDarkOrange  //DodgerBlue  //Silver //Gray
#property indicator_color2  clrDarkOrchid  //Magenta  //Red  //Maroon
#property indicator_color3  clrLightCyan  //LimeGreen  //DarkBlue
#property indicator_color4  clrRed  //Gold  
#property indicator_color5  clrLime  //Aqua  //Blue
#property indicator_color6  clrMagenta  //DarkOrchid  //
#property indicator_color7  clrLightSkyBlue //DeepSkyBlue
//---
#property indicator_width1  0
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  0
#property indicator_width5  0
#property indicator_width6  2
#property indicator_width7  2
//---
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_style6  STYLE_DOT
#property indicator_style7  STYLE_DOT
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                   Custom indicator ENUM settings                     %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
enum showCHL { NoLINES, onlyVWMA, onlyBANDS, allLINES };
enum calcARR { ArrowsOFF, TrendOCLH, ChangeCOLOR };
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                 Custom indicator input parameters                    %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

extern ENUM_TIMEFRAMES TimeFrame  =  PERIOD_CURRENT; // Time frame to use
extern bool          Interpolate  =  false;
extern int                Length  =  12;  //24;  //56;
extern int                Smooth  =  6;   //18;
extern ENUM_MA_METHOD       Mode  =  MODE_LWMA;
extern ENUM_APPLIED_PRICE  Price  =  PRICE_WEIGHTED;
extern double         Deviations  =  2.618;
extern showCHL          ShowVWMA  =  allLINES;  //onlyBANDS;
extern calcARR        CalcArrows  =  ChangeCOLOR;
extern bool         AlertsOnHiLo  =  false;
extern int             SIGNALBAR  =  1;   //На каком баре сигналить....
extern bool        AlertsMessage  =  true,   //false,    
                     AlertsSound  =  true,   //false,
                     AlertsEmail  =  false,
                    AlertsMobile  =  false;
extern string          SoundFile  =  "alert.wav";  //"news.wav";  //"expert.wav";  //   //"stops.wav"   //   //

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                     Custom indicator buffers                         %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
double tmBuffer[], upBuffer[], dnBuffer[];
double clrSEL[], clrBUY[];     double arrSEL[], arrBUY[];
double wuBuffer[], wdBuffer[], FLAG[];
//---
string IndikName;  bool calculateVwma = false;   bool returnBars  = false;
string  messageUP, messageDN, sufix;  datetime TimeBar=0;  
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%              Custom indicator initialization function                %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int init()
{
   Length = MathMax(Length,1);
   Smooth = MathMax(Smooth,1);
   //---
   IndikName     = WindowExpertName();
   returnBars    = TimeFrame==-99;
   calculateVwma = TimeFrame==PERIOD_CURRENT;
   TimeFrame     = MathMax(TimeFrame,_Period);
   //---
   IndicatorBuffers(10);   IndicatorDigits(Digits);
   //---  //enum showCHL { NoLINES, onlyVWMA, onlyBANDS, allLINES };
   int TMT = (ShowVWMA==1 || ShowVWMA==3) ? DRAW_LINE : DRAW_NONE;  
   SetIndexBuffer(0,tmBuffer);  SetIndexStyle(0,TMT);   //SetIndexDrawBegin(0,Length);
   int BNT = (ShowVWMA==2 || ShowVWMA==3) ? DRAW_LINE : DRAW_NONE;  
   SetIndexBuffer(1,upBuffer);  SetIndexStyle(1,BNT);   //SetIndexDrawBegin(1,Length);
   SetIndexBuffer(2,dnBuffer);  SetIndexStyle(2,BNT);   //SetIndexDrawBegin(2,Length);
   SetIndexBuffer(3,arrSEL);    SetIndexStyle(3,DRAW_ARROW);  SetIndexArrow(3,234);
   SetIndexBuffer(4,arrBUY);    SetIndexStyle(4,DRAW_ARROW);  SetIndexArrow(4,233);
   SetIndexBuffer(5,clrSEL);    SetIndexStyle(5,BNT);   //SetIndexDrawBegin(5,Length);
   SetIndexBuffer(6,clrBUY);    SetIndexStyle(6,BNT);   //SetIndexDrawBegin(6,Length);
   SetIndexBuffer(7,wuBuffer);
   SetIndexBuffer(8,wdBuffer);
   SetIndexBuffer(9,FLAG);
   //---
   for (int i=0; i<=10; i++) {
        //SetIndexStyle(i,DRAW_HISTOGRAM);   //--- настройка параметров отрисовки
        SetIndexEmptyValue(i,0.0);           //--- значение 0 отображаться не будет 
        //SetIndexShift(11,SlowShift);       //--- установка сдвига линий при отрисовке  
        SetIndexDrawBegin(i,Length); }   //--- пропуск отрисовки первых баров

//--- отображение в DataWindow 
   SetIndexLabel(0,stringMTF(TimeFrame)+": VMMA ["+(string)Length+"+"+(string)Smooth+"]"); 
   SetIndexLabel(1,"Band UP  +"+DoubleToStr(Deviations,2));
   SetIndexLabel(2,"Band LO  -"+DoubleToStr(Deviations,2));
   SetIndexLabel(3,"Arrow SELL  ["+EnumToString(CalcArrows)+"]");
   SetIndexLabel(4,"Arrow BUY   ["+EnumToString(CalcArrows)+"]");
   SetIndexLabel(5,"Hard SELL");
   SetIndexLabel(6,"Weak BUY");

//--- "короткое имя" для DataWindow и подокна индикатора + и/или "уникальное имя индикатора"
   IndicatorShortName(stringMTF(TimeFrame)+": VWMA+CG 4C ["+(string)Length+"+"+(string)Smooth+"]");
//---
return(0);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%              Custom indicator deinitialization function              &&&
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int deinit() { Comment("");  return(0); }
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                 Custom indicator iteration function                  %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int start()
{
   int CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   if (CountedBars>0) CountedBars--;
   int i, y, x, limit = MathMin(Bars-1,Bars-CountedBars+Length);
   //---
   if (returnBars)  { tmBuffer[0] = limit+1;  return(0); }
   if (calculateVwma) { calculateVWMA(limit);  return(0); }
   if (TimeFrame > _Period) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,IndikName,-99,0,0)*TimeFrame/_Period));
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   for (i=limit; i>=0; i--)
    {
     y = iBarShift(NULL,TimeFrame,Time[i]);
     x = y;  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);
     //---
     tmBuffer[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,Interpolate,Length,Smooth,Mode,Price,Deviations,0,y);
     upBuffer[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,Interpolate,Length,Smooth,Mode,Price,Deviations,1,y);
     dnBuffer[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,Interpolate,Length,Smooth,Mode,Price,Deviations,2,y);
     FLAG[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,Interpolate,Length,Smooth,Mode,Price,Deviations,9,y);
     //---
     if (!Interpolate) {
         if (x!=y) {
             arrSEL[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,Interpolate,Length,Smooth,Mode,Price,Deviations,3,y);
             arrBUY[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,Interpolate,Length,Smooth,Mode,Price,Deviations,4,y); } 
         //---
         clrSEL[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,Interpolate,Length,Smooth,Mode,Price,Deviations,5,y);
         clrBUY[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,Interpolate,Length,Smooth,Mode,Price,Deviations,6,y); }
     //---
     //---
     if (TimeFrame!=_Period) { if (CalcArrows==1) setupARROWS(i);  setupALERTS(FLAG); }
     //---
     //---
     if (TimeFrame <= _Period || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;
     if (!Interpolate) continue; 
     //---
     datetime time=iTime(NULL,TimeFrame,y);
     for (int n=1; i+n<Bars && Time[i+n]>=time; n++) continue;
     double factor=1.0/n;
     for (int k=1; k<n; k++)
      {
       tmBuffer[i+k] = k*factor*tmBuffer[i+n] + (1.0-k*factor)*tmBuffer[i];
       upBuffer[i+k] = k*factor*upBuffer[i+n] + (1.0-k*factor)*upBuffer[i];
       dnBuffer[i+k] = k*factor*dnBuffer[i+n] + (1.0-k*factor)*dnBuffer[i];
       //clrSEL[i+k] = k*factor*clrSEL[i+n] + (1.0-k*factor)*clrSEL[i];
       //clrBUY[i+k] = k*factor*clrBUY[i+n] + (1.0-k*factor)*clrBUY[i]; 
      }  
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    } //*конец цикла*  for (i=limit; i>=0; i--)
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   if (Interpolate) { for (i=limit; i>=0; i--) { setupCOLOR(i);  if (CalcArrows==2) setupARROWS(i); } }
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//---
return(0);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                        VWMA+CG 4C AA MTF TT                          %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void calculateVWMA(int limit)
{
   int i, j;  //, k;
   double FullLength = 2.0*Length+1.0;
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   for (i=limit; i>=0; i--)
    {
     double volw = Volume[i];
     for (j=0; j<=Smooth; j++) volw += Volume[j];
     volw /= Smooth;
     //---
     double sum  = volw*iMA(NULL,0,Smooth,0,Mode,Price,i);  //(Length+1)*iMA(NULL,0,1,0,MODE_SMA,Price,i);
     double sumw = volw;  //(Length+1);
     //---
     for (j=0; j<=Length; j++)  //for (j=1, k=Length; j<=Length; j++, k--)
      {
       sum  += volw*iMA(NULL,0,Smooth,0,Mode,Price,i+j); //*k; 
       sumw += volw;  //k;
      }
     //---
     tmBuffer[i]=sum/sumw;
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     double diff = iMA(NULL,0,Smooth,0,Mode,Price,i)-tmBuffer[i];
     if (i> (Bars-Length-1)) continue;
     if (i==(Bars-Length-1))
      {
       upBuffer[i] = tmBuffer[i];
       dnBuffer[i] = tmBuffer[i];
       //---
       if (diff>=0)
        {
         wuBuffer[i] = MathPow(diff,2);
         wdBuffer[i] = 0;
        }
       //---
       if (diff<0)
        {               
         wdBuffer[i] = MathPow(diff,2);
         wuBuffer[i] = 0;
        }                  
       continue;
      }
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     if (diff>=0)
      {
       wuBuffer[i] = (wuBuffer[i+1]*(FullLength-1)+MathPow(diff,2))/FullLength;
       wdBuffer[i] =  wdBuffer[i+1]*(FullLength-1)/FullLength;
      }
     //---
     if (diff<0)
      {
       wdBuffer[i] = (wdBuffer[i+1]*(FullLength-1)+MathPow(diff,2))/FullLength;
       wuBuffer[i] =  wuBuffer[i+1]*(FullLength-1)/FullLength;
      }
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     upBuffer[i] = tmBuffer[i] + Deviations*MathSqrt(wuBuffer[i]);
     dnBuffer[i] = tmBuffer[i] - Deviations*MathSqrt(wdBuffer[i]);
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     FLAG[i]=0;
     //---
     if (AlertsOnHiLo)       
      {
       if (High[i] > upBuffer[i] && High[i+1] < upBuffer[i+1]) { FLAG[i]=-444;  sufix="High"; }
       if (Low[i]  < dnBuffer[i] && Low[i+1]  > dnBuffer[i+1]) { FLAG[i]=444;  sufix="Low"; }
      }     
     //---
     if (!AlertsOnHiLo)       
      {
       if (Close[i] > upBuffer[i] && Close[i+1] < upBuffer[i+1]) { FLAG[i]=-888;  sufix="Close"; }
       if (Close[i]  < dnBuffer[i] && Close[i+1]  > dnBuffer[i+1]) { FLAG[i]=888;  sufix="Close"; }
      }     
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     if (TimeFrame==_Period) { setupARROWS(i);  setupALERTS(FLAG); }
     if (!Interpolate) { setupCOLOR(i); }
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    } //*конец цикла*
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                        VWMA+CG 4C AA MTF TT                          %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void setupCOLOR(int i)
{
   clrSEL[i]=upBuffer[i];
   clrBUY[i]=dnBuffer[i];
   //---
   if (upBuffer[i] > upBuffer[i+1] && upBuffer[i+1] > upBuffer[i+2]) clrSEL[i+1]=0;
   if (dnBuffer[i] > dnBuffer[i+1] && dnBuffer[i+1] > dnBuffer[i+2]) clrBUY[i+1]=0;
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                        VWMA+CG 4C AA MTF TT                          %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void setupARROWS(int i)   //enum calcARR { ArrowsOFF, TrendOCLH, ChangeCOLOR };
{
   arrSEL[i]=0;   arrBUY[i]=0;
   //---
   if (CalcArrows==1) {
       if (High[i+1] > upBuffer[i+1] && Close[i+1] > Open[i+1] && Close[i] < Open[i]) arrSEL[i] = High[i]+iATR(NULL,0,48,i);
       if (Low[i+1] < dnBuffer[i+1] && Close[i+1] < Open[i+1] && Close[i] > Open[i]) arrBUY[i] = Low[i]-iATR(NULL,0,48,i); }
   //---
   if (CalcArrows==2) {
       if (upBuffer[i] < upBuffer[i+1] && upBuffer[i+1] > upBuffer[i+2]) arrSEL[i] = High[i]+iATR(NULL,0,48,i);
       if (dnBuffer[i] > dnBuffer[i+1] && dnBuffer[i+1] < dnBuffer[i+2]) arrBUY[i] = Low[i]-iATR(NULL,0,48,i); }
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                        VWMA+CG 4C AA MTF TT                          %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void setupALERTS(double& flag[])
{
   if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound) 
    {
     messageUP = WindowExpertName()+":  "+_Symbol+", "+stringMTF(_Period)+"  >>  " +sufix+ " touched BandLO  >>  BUY";
     messageDN = WindowExpertName()+":  "+_Symbol+", "+stringMTF(_Period)+"  <<  " +sufix+ " touched BandUP  <<  SELL"; 
   //------
     if (TimeBar!=Time[0] &&  (flag[SIGNALBAR]==444 || flag[SIGNALBAR]==888)) {             
         if (AlertsMessage) Alert(messageUP);  
         if (AlertsEmail)   SendMail(_Symbol,messageUP);  
         if (AlertsMobile)  SendNotification(messageUP);  
         if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"  
         TimeBar=Time[0]; } //return(0);
   //------
     else 
     if (TimeBar!=Time[0] &&  (flag[SIGNALBAR]==-444 || flag[SIGNALBAR]==-888)) {     
         if (AlertsMessage) Alert(messageDN);  
         if (AlertsEmail)   SendMail(_Symbol,messageDN);  
         if (AlertsMobile)  SendNotification(messageDN);  
         if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"                
         TimeBar=Time[0]; } //return(0); 
    } //*конец* Алертов
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                        VWMA+CG 4C AA MTF TT                          %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
string stringMTF(int perMTF)
{  
   if (perMTF==0)      perMTF=_Period;
   if (perMTF==1)      return("M1");
   if (perMTF==5)      return("M5");
   if (perMTF==15)     return("M15");
   if (perMTF==30)     return("M30");
   if (perMTF==60)     return("H1");
   if (perMTF==240)    return("H4");
   if (perMTF==1440)   return("D1");
   if (perMTF==10080)  return("W1");
   if (perMTF==43200)  return("MN1");
   if (perMTF== 2 || 3  || 4  || 6  || 7  || 8  || 9 ||       /// нестандартные периоды для грфиков Renko
               10 || 11 || 12 || 13 || 14 || 16 || 17 || 18)  return("M"+(string)_Period);
//------
   return("Ошибка периода");
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                        VWMA+CG 4C AA MTF TT                          %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%