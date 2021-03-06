//+------------------------------------------------------------------+
//|                                               AG_Renko_Ñhart.mq4 |
//|                        Ïîñòðîåíèå ëèíèé ðåíêî íà öåíîâîì ãðàôèêå |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
//--- plot Direct
#property indicator_label1  "Renko"
#property indicator_color1  clrYellow
#property indicator_color2  clrRoyalBlue
#property indicator_color3  clrRed
#property indicator_color4  clrRoyalBlue
#property indicator_color5  clrRed
#property indicator_color6  clrDimGray
#property indicator_color7  clrBlue
#property indicator_color8  clrRed

//--- indicator buffers
double         Renco[];       // Ãðàôèê Ðåíêî
double         RencoUP[];     // Ðàñêëàäêà ïî öâåòàì
double         RencoDN[];     // Ðàñêëàäêà ïî öâåòàì
double         DirectUP[];    // Ñèãíàëû ââåðõ
double         DirectDN[];    // Ñèãíàëû âíèç
double         RencoDirect[]; // Òåêóùåå Íàïðàâëåíèå Ðåíêî
double         CandleWickUP[]; // Õâîñòû ðåíêî
double         CandleWickDN[]; // Õâîñòû ðåíêî
double         ZZ[];           // Çèãçàã

input int Step=250;       // Ðàçìåð êèðïè÷èêîâ Ðåíêî â ïóíêòàõ
input bool Signals=false; // Ïîêàçàòü ñèãíàëû
input bool ZigZag=false;  // Ðèñîâàòü ðåíêî-çèãçàã
input int Revers=2;       // Ðåâåðñ - êîëè÷åñòâî êèðïè÷èêîâ äëÿ ðàçâîðîòà

double step;
int TF=0;
int StartBar;
double Lewel;  // Êðóãëûé òåêóùèé óðîâåíü
double LewelX; // Ïîñëåäíèé êðóãëûé óðîâåíü â äâèæåíèè ðåíêî
double LewelR; // Ïîñëåäíèé êðóãëûé óðîâåíü â ðåâåðñå ðåíêî

double DIRECT; // Òåêóùåå íàïðàâëåíèå
double Start;  // Íà÷àëî ïîñëåäíåãî òðåíäà
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(9);
//--- indicator buffers mapping

//   Áóôåðû äëÿ âûâîäà ðåíêî
   SetIndexBuffer(0,Renco,INDICATOR_DATA);
   SetIndexStyle(0,DRAW_NONE,STYLE_SOLID,3);

   SetIndexBuffer(1,RencoUP,INDICATOR_DATA);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,3);

   SetIndexBuffer(2,RencoDN,INDICATOR_DATA);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,3);
// Áóôåðû äëÿ ñèãíàëîâ
   SetIndexBuffer(3,DirectUP,INDICATOR_DATA);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,3);
   SetIndexArrow(3,233);

   SetIndexBuffer(4,DirectDN,INDICATOR_DATA);
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,3);
   SetIndexArrow(4,234);

// Çèãçàã   
   SetIndexBuffer(5,ZZ,INDICATOR_DATA);
   SetIndexStyle(5,DRAW_SECTION,STYLE_SOLID,1);
   if(!ZigZag) SetIndexStyle(5,DRAW_NONE,STYLE_SOLID,1);

// Õâîñò ââåðõ
   SetIndexBuffer(6,CandleWickUP,INDICATOR_DATA);
   SetIndexStyle(6,DRAW_NONE,STYLE_SOLID,1);

// Õâîñò âíèç  
   SetIndexBuffer(7,CandleWickDN,INDICATOR_DATA);
   SetIndexStyle(7,DRAW_NONE,STYLE_SOLID,1);

// Ñëóæåáíûé áóôåð äëÿ ïîñëåäóþùåé ñâÿçè ñ ñîâåòíèêàìè, ìîæíî óäàëèòü, åñëè íå íóæåí      
   SetIndexBuffer(8,RencoDirect,INDICATOR_CALCULATIONS);
   SetIndexStyle(8,DRAW_NONE);
//---
   step=Step*Point; // Ïåðåñ÷åò êóáèêà èç ïóíêòîâ â ïðèðàùåíèå öåíû

   IndicatorShortName(_Symbol+" RencoChart TF="+(string)Period()+"  Step="+(string)Step+"            ");
   IndicatorDigits(Digits);

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
// Ñ÷èòàåì îò ïåðâîãî äîñòóïíîãî áàðà
   int ReversX=0;

   int limit=Bars-2;
   double c=0,h=0,l=0; // Öåíà çàêðûòèÿ

   if(prev_calculated==0) //Ñ÷èòàåì îò íà÷àëà ïðè çàïóñêå èíäèêàòîðà
     {
      c=iClose(_Symbol,TF,Bars-1);
      Renco[Bars-1]=1;
      Lewel=NormalizeDouble(MathRound(c/step)*step,Digits);
      DIRECT=1;
      LewelX=NormalizeDouble(Lewel+step,Digits);
      LewelR=NormalizeDouble(Lewel-Revers*step,Digits);
     }
   else limit=1; // Ïåðåñ÷èòûâàåòñÿ òîëüêî áàð ¹1

   for(int i=limit;i>=1;i--)
     {
      c=iClose(_Symbol,TF,i);
      h=iHigh(_Symbol,TF,i);
      l=iLow(_Symbol,TF,i);

      Renco[i]=Renco[i+1];
      CandleWickUP[i]=CandleWickUP[i+1];
      CandleWickDN[i]=CandleWickDN[i+1];

      Lewel=NormalizeDouble(MathRound(c/step)*step,Digits);

      if(l<CandleWickDN[i]) CandleWickDN[i]=l;
      if(h>CandleWickUP[i]) CandleWickUP[i]=h;

      // Ñîõðàíåíèå ñòàðòà è áàðà ïîñëåäíåãî ðåíêî-òðåíäà, ðàñ÷åò çèãçàãà
      if((DIRECT>0 && c<LewelR) || (DIRECT<0 && c>LewelR))
        {
         Start=NormalizeDouble(LewelX,Digits);
         ZZ[StartBar]=Start;
        }
      // Íàïðàâëåíèå ââåðõ èëè ðåâåðñ ââåðõ
      if((DIRECT>0 && c>LewelX) || (DIRECT<0 && c>LewelR))
        {
         DIRECT=1;
         if(DIRECT>0 && c>LewelX) StartBar=i;

         if(c<Lewel) {Lewel=NormalizeDouble(Lewel-step,Digits);}
         if(Lewel>LewelX) {LewelX=Lewel; CandleWickUP[i]=Lewel;CandleWickDN[i]=Lewel;}
         //         if (c<CandleWick[i]) CandleWick[i]=c;

         LewelR=NormalizeDouble(LewelX-Revers*step,Digits);

        }
      // Íàïðàâëåíèå âíèç èëè ðåâåðñ âíèç
      else if((DIRECT>0 && c<LewelR) || (DIRECT<0 && c<LewelX))
        {
         DIRECT=-1;
         if(DIRECT<0 && c<LewelX) StartBar=i;

         if(c>Lewel) {Lewel=NormalizeDouble(Lewel+step,Digits);}
         if(Lewel<LewelX) {LewelX=Lewel; CandleWickUP[i]=Lewel; CandleWickDN[i]=Lewel;}
         //         if (c>CandleWick[i]) CandleWick[i]=c;

         LewelR=NormalizeDouble(LewelX+Revers*step,Digits);
        }
      // Ðàñ÷åò ëèíèè ðåíêî è ðàñêëàäêà ïî öâåòàì            
      Renco[i]=NormalizeDouble(LewelX,Digits);
      if(DIRECT<0) RencoDN[i]=LewelX;
      if(DIRECT>0) RencoUP[i]=LewelX;
      // Óäàëåíèå ðàçðûâîâ â ãðàôèêå         
      if(RencoDN[i]!=EMPTY_VALUE && RencoDN[i+1]==EMPTY_VALUE) {RencoUP[i]=Renco[i];}
      if(RencoUP[i]!=EMPTY_VALUE && RencoUP[i+1]==EMPTY_VALUE) {RencoDN[i]=Renco[i];}
      // Ñèãíàëû         
      if(!Signals) continue;
      if(DIRECT>0 && RencoUP[i+1]==EMPTY_VALUE) DirectUP[i]=LewelX+step/2;
      if(DIRECT<0 && RencoDN[i+1]==EMPTY_VALUE) DirectDN[i]=LewelX-step/2;
     }

   Renco[0]=Renco[1]; // Â íóëåâîé áàð - çíà÷åíèå íà 1-ì áàðå
   CandleWickUP[0]=CandleWickUP[1];
   CandleWickDN[0]=CandleWickDN[1];

   ZZ[1]=EMPTY_VALUE; // Ðàñ÷åò çèãçàãà â 0-é òî÷êå
   ZZ[0]=LewelX;

// Â ñëóæåáíûé áóôåð â 0-é áàð âïèñûâàåòñÿ êîëè÷åñòâî êèðïè÷èêîâ â ïîñëåäíåì ðåíêî-òðåíäå
// Ñþäà ìîæíî ïèñàòü ÷òî óãîäíî, ÷òî ïîòîì ïîíàäîáèòñÿ â ñîâåòíèêàõ

   RencoDirect[0]=MathRound((Renco[0]-Start)/step);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
