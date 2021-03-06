#property copyright ""
#property link      ""    
//------
#property indicator_chart_window
#property indicator_buffers 5
//------
#property indicator_color1  clrRed  //Blue
#property indicator_color2  clrBlue
#property indicator_color3  clrGold  //Red
#property indicator_color4  clrMagenta  //Black
#property indicator_color5  clrLightCyan  //Blue
//------
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
//------
#property indicator_style3  STYLE_DOT
//------
enum calcDT { dotsOFF, CloseAll, PriceCross, HiLoTouch };
//------
extern int       CheckBars  =  225;  //150
extern int     Flexibility  =  5;
extern double    Deviation  =  1.618;  //2.0;
extern bool    ShowMIDline  =  true;
extern calcDT     CalcDots  =  HiLoTouch;  //CloseAll;
extern int       SIGNALBAR  =  0;
extern bool  AlertsMessage  =  true,   //false,    
               AlertsSound  =  true,   //false,
               AlertsEmail  =  false,
              AlertsMobile  =  false;
extern string    SoundFile  =  "news.wav";   //"stops.wav"   //"alert2.wav"   //"expert.wav"
extern bool         Coment  =  true;
//extern bool     AlertsOn  =  true;  //старый вариант Алертов....
//------
//------
double BandMD[], BandHI[], BandLO[];
double DotHI[], DotLO[];
//------
datetime TimeBar=0;   int i, v, w, x, y, z, FLEX;
//------
double Gda_108[30][30]; //[10]
double Gda_112[30];
double Gda_116[30];
double Gda_120[60]; //[20]
//------
double Gd_124, Gd_144, Gd_152, Gd_160, Gd_188;
////datetime lastSellSignal = 0;
////datetime lastBuySignal = 0;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() 
{  //---- и какая-то хрень....
   CheckBars = fmin(55555,CheckBars);   FLEX = fmin(fmax(1,Flexibility+1),29);  
   Deviation = fmax(Deviation,0);       if (Coment) Comment("Forex Atron: "+(string)CheckBars+"*"+(string)FLEX+"±"+DoubleToStr(Deviation,2));   	
//----
   IndicatorBuffers(5);   IndicatorDigits(Digits);   //if (Digits==3 || Digits==5) IndicatorDigits(Digits-1);
//---- 5 распределенных буфера индикатора 
   SetIndexBuffer(0, BandHI);
   SetIndexBuffer(1, BandLO);
   SetIndexBuffer(2, BandMD);
   SetIndexBuffer(3, DotHI);
   SetIndexBuffer(4, DotLO);
//---- настройка параметров отрисовки 
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   int MDL=DRAW_NONE;   if (ShowMIDline) MDL=DRAW_LINE;
   SetIndexStyle(2, MDL);
   SetIndexStyle(3, DRAW_ARROW);   SetIndexArrow(3, 108);
   SetIndexStyle(4, DRAW_ARROW);   SetIndexArrow(4, 108);
//---- пропуск отрисовки первых баров
   for (i=0; i<6; i++) SetIndexDrawBegin(i,Bars-CheckBars-1); 
//---- отображение в DataWindow 
  	SetIndexLabel(0,"Band HI +"+DoubleToStr(Deviation,2));
   SetIndexLabel(1,"Band LO -"+DoubleToStr(Deviation,2));
  	SetIndexLabel(2,"Band MID ["+(string)CheckBars+"*"+(string)FLEX+"]");
   SetIndexLabel(3,EnumToString(CalcDots)+": Dot HI = SELL");
   SetIndexLabel(4,EnumToString(CalcDots)+": Dot LO = BUY");   
//---- "короткое имя" для DataWindow и подокна индикатора 
   IndicatorShortName(WindowExpertName()+" ["+(string)CheckBars+"*"+(string)FLEX+"±"+DoubleToStr(Deviation,2)+"]");  
//----
return(0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() { Comment("");  return(0); }

// EA2B2676C28C0DB26D39331A336C6B92
int start() 
{
   Gda_120[1] = CheckBars + 1;
//+++======================================================================+++

   for (i = 1; i <= FLEX * 2 - 2; i++) {
      Gd_124 = 0;
      for (x=0; x <=CheckBars; x++) Gd_124 += MathPow(x, i);
      Gda_120[i + 1] = Gd_124;
   }
//+++======================================================================+++

   for (i = 1; i <= FLEX; i++) {
      Gd_124 = 0.0;
      for (x=0; x <=CheckBars; x++) {
         if (i == 1) Gd_124 += Close[x];
         else Gd_124 += Close[x] * MathPow(x, i - 1);
      }
      Gda_112[i] = Gd_124;
   }
//+++======================================================================+++

   for (z = 1; z <= FLEX; z++) {
      for (y = 1; y <= FLEX; y++) {
         w = y + z - 1;
         Gda_108[y][z] = Gda_120[w];
      }
   }
//+++======================================================================+++
//+++======================================================================+++

   for (w = 1; w <= FLEX - 1; w++)
    {
      v = 0;
      Gd_152 = 0;
      for (y = w; y <= FLEX; y++) {
         if (MathAbs(Gda_108[y][w]) > Gd_152) {
            Gd_152 = MathAbs(Gda_108[y][w]);
            v = y;
         }
      }
      
      if (v == 0) return(0);
      
      if (v != w) {
         for (z = 1; z <= FLEX; z++) {
            Gd_160 = Gda_108[w][z];
            Gda_108[w][z] = Gda_108[v][z];
            Gda_108[v][z] = Gd_160;
         }
         Gd_160 = Gda_112[w];
         Gda_112[w] = Gda_112[v];
         Gda_112[v] = Gd_160;
      }
      
      for (y = w + 1; y <= FLEX; y++) {
         Gd_144 = Gda_108[y][w] / Gda_108[w][w];
         for (z = 1; z <= FLEX; z++) {
            if (z == w) Gda_108[y][z] = 0;
            else Gda_108[y][z] = Gda_108[y][z] - Gd_144 * Gda_108[w][z];
         }
         Gda_112[y] = Gda_112[y] - Gd_144 * Gda_112[w];
      }
    }
//+++======================================================================+++
//+++======================================================================+++
   
   Gda_116[FLEX] = Gda_112[FLEX] / Gda_108[FLEX][FLEX];
   
   for (y = FLEX - 1; y >= 1; y--) {
      Gd_160 = 0;
      for (z = 1; z <= FLEX - y; z++) {
         Gd_160 += (Gda_108[y][y + z]) * (Gda_116[y + z]);
         Gda_116[y] = 1 / Gda_108[y][y] * (Gda_112[y] - Gd_160);
      }
   }
//+++======================================================================+++

   for (x=0; x <=CheckBars; x++) {
      Gd_124 = 0;
      for (w = 1; w <= Flexibility; w++) Gd_124 += (Gda_116[w + 1]) * MathPow(x, w);
      BandMD[x] = Gda_116[1] + Gd_124;
   }
//+++======================================================================+++
   
   Gd_188 = 0.0;
   
   for (x=0; x <=CheckBars; x++) Gd_188 += MathPow(Close[x] - BandMD[x], 2);
     Gd_188 = MathSqrt(Gd_188 / (CheckBars + 1)) * Deviation;
//+++======================================================================+++

   for (x=0; x <=CheckBars; x++) {
     BandHI[x] = BandMD[x] + Gd_188;
     BandLO[x] = BandMD[x] - Gd_188;
   }
//+++======================================================================+++
//+++======================================================================+++

   if (CalcDots!=0) 
    {
     for (i=CheckBars; i >= 0; i--)   ////enum calcDT { dotsOFF, CloseAll, PriceCross, HiLoTouch };
      {
       DotHI[i]=EMPTY_VALUE;  DotLO[i]=EMPTY_VALUE; 
     //------
       if (CalcDots==1) 
        {
         if (Close[i] >= BandHI[i])  DotHI[i] = Close[i];   else DotHI[i]=EMPTY_VALUE;
         if (Close[i] <= BandLO[i])  DotLO[i] = Close[i];   else DotLO[i]=EMPTY_VALUE; 
        }
     //------
       if (CalcDots==2) 
        {
         if (Close[i] > BandHI[i] && Close[i+1] <= BandHI[i+1])  DotHI[i] = Close[i];   else DotHI[i]=EMPTY_VALUE;
         if (Close[i] < BandLO[i] && Close[i+1] >= BandLO[i+1])  DotLO[i] = Close[i];   else DotLO[i]=EMPTY_VALUE; 
        }
     //------
       if (CalcDots==3) 
        {
         if (High[i] > BandHI[i] && High[i+1] <= BandHI[i+1])  DotHI[i] = High[i];   else DotHI[i]=EMPTY_VALUE;
         if (Low[i] < BandLO[i] && Low[i+1] >= BandLO[i+1])  DotLO[i] = Low[i];   else DotLO[i]=EMPTY_VALUE; 
        }
      }
    }
//+++======================================================================+++
   
   if (CalcDots!=0 && (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)) 
    {
     string messageDN = WindowExpertName() + ": "+_Symbol+", "+stringMTF(_Period)+" << DOT HI  <<  SELL";   //SSL Channel TT  //HA CLH 4C SHLD TT  //MA 3x3 TT
     string messageUP = WindowExpertName() + ": "+_Symbol+", "+stringMTF(_Period)+" >> DOT LO  >>  BUY";    //SSL Channel TT  //HA CLH 4C SHLD TT  //MA 3x3 TT       
   //------
     if (TimeBar!=Time[0] && DotHI[SIGNALBAR]!=EMPTY_VALUE) {  ///Close[SIGNALBAR] <= BandLO[SIGNALBAR]) { 
         if (AlertsMessage) Alert(messageDN);
         if (AlertsEmail)   SendMail(_Symbol,messageDN);
         if (AlertsMobile)  SendNotification(messageDN);
         if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"
         TimeBar=Time[0]; }  //return(0);       
   //------
     else 
     if (TimeBar!=Time[0] && DotLO[SIGNALBAR]!=EMPTY_VALUE) {  ///Close[SIGNALBAR] >= BandHI[SIGNALBAR]) {
         if (AlertsMessage) Alert(messageUP);
         if (AlertsEmail)   SendMail(_Symbol,messageUP);
         if (AlertsMobile)  SendNotification(messageUP);
         if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"                       
         TimeBar=Time[0]; }  //return(0);
    }   ///*конец* АЛЕРТОВ
//+++======================================================================+++
//       старый вариант Алертов....
//         
//   if (Close[Gi_92] >= BandHI[Gi_92])
//    {
//     if (lastSellSignal != Time[0])
//      {
//       if (AlertsOn) Alert(_Symbol, ",M", _Period, " ForexAtron SELL signal");
//       lastSellSignal = Time[0];
//      }
//    }
//   if (Close[Gi_92] <= BandLO[Gi_92])
//    {
//     if (lastBuySignal != Time[0])
//      {
//       if (AlertsOn) Alert(_Symbol, ",M", _Period, " ForexAtron BUY signal");
//       lastBuySignal = Time[0];
//      }
//    }
//+++======================================================================+++
return(0);
}
//+++======================================================================+++
//+++                        iTrend LITE AA DD+TT                          +++   
//+++======================================================================+++
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
//+++======================================================================+++
//+++              Custom indicator deinitialization function              +++
//+++======================================================================+++