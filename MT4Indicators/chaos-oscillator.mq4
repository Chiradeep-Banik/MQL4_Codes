#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 1.0
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 C'0x0D,0x0D,0x41'
#property indicator_color3 C'0x41,0x0D,0x0D'

extern int gi_76 = 21;
extern bool UseSound=true;
extern bool AlertSound=true;
extern string SoundFileBuy ="tada.wav";
extern string SoundFileSell="email.wav";
extern bool SendMailPossible = false;
bool SoundBuy  = False;
bool SoundSell = False;
#define SIGNAL_BAR 0
double g_ibuf_80[];
double g_ibuf_84[];
double g_ibuf_88[];

int init() {
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, g_ibuf_80);
   SetIndexBuffer(1, g_ibuf_84);
   SetIndexBuffer(2, g_ibuf_88);
   IndicatorShortName(" ");
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   return (0);
}

int start() {
   double ld_8;
   double ld_16;
   double ld_80;
   int li_4 = IndicatorCounted();
   double ld_32 = 0;
   double ld_40 = 0;
   double ld_unused_48 = 0;
   double ld_unused_56 = 0;
   double ld_64 = 0;
   double ld_unused_72 = 0;
   double low_88 = 0;
   double high_96 = 0;
   if (li_4 > 0) li_4--;
   int li_0 = Bars - li_4;
   for (int li_104 = 0; li_104 < Bars; li_104++) {
      high_96 = High[iHighest(NULL, 0, MODE_HIGH, gi_76, li_104)];
      low_88 = Low[iLowest(NULL, 0, MODE_LOW, gi_76, li_104)];
      ld_80 = (High[li_104] + Low[li_104]) / 2.0;
      if (high_96 - low_88 == 0.0) ld_32 = 0.67 * ld_40 + (-0.33);
      else ld_32 = 0.66 * ((ld_80 - low_88) / (high_96 - low_88) - 0.5) + 0.67 * ld_40;
      ld_32 = MathMin(MathMax(ld_32, -0.999), 0.999);
      if (1 - ld_32 == 0.0) g_ibuf_80[li_104] = ld_64 / 2.0 + 0.5;
      else g_ibuf_80[li_104] = MathLog((ld_32 + 1.0) / (1 - ld_32)) / 2.0 + ld_64 / 2.0;
      ld_40 = ld_32;
      ld_64 = g_ibuf_80[li_104];
   }
   bool li_108 = TRUE;
   for (li_104 = Bars; li_104 >= 0; li_104--) {
      ld_16 = g_ibuf_80[li_104];
      ld_8 = g_ibuf_80[li_104 + 1];
      if ((ld_16 < 0.0 && ld_8 > 0.0) || ld_16 < 0.0) li_108 = FALSE;
      if ((ld_16 > 0.0 && ld_8 < 0.0) || ld_16 > 0.0) li_108 = TRUE;
      if (!li_108) {
         g_ibuf_88[li_104] = 1.0;
         g_ibuf_84[li_104] = 0.0;
      } else {
         g_ibuf_84[li_104] = 1.0;
         g_ibuf_88[li_104] = 0.0;
      }
   }
//+------------------------------------------------------------------+         
        if (g_ibuf_84[SIGNAL_BAR] != EMPTY_VALUE && g_ibuf_84[SIGNAL_BAR] != 0 && SoundBuy)
         {
         SoundBuy = False;
            if (UseSound) PlaySound (SoundFileBuy);
               if(AlertSound){         
               Alert("#Chaos Oscillator (", Symbol(), ", ", Period(), ")  -  BUY!!!");                             
               if (SendMailPossible) SendMail(Symbol()+ " M"+ Period()+ " #Chaos Oscillator -  BUY!", ""); 
            }              
         } 
      if (!SoundBuy && (g_ibuf_84[SIGNAL_BAR] == EMPTY_VALUE || g_ibuf_84[SIGNAL_BAR] == 0)) SoundBuy = True;  
            
  
     if (g_ibuf_88[SIGNAL_BAR] != EMPTY_VALUE && g_ibuf_88[SIGNAL_BAR] != 0 && SoundSell)
         {
         SoundSell = False;
            if (UseSound) PlaySound (SoundFileSell); 
             if(AlertSound){                    
             Alert("#Chaos Oscillator (", Symbol(), ", ", Period(), ")  -  SELL!!!");             
             if (SendMailPossible) SendMail(Symbol()+ " M"+ Period()+ " #Chaos Oscillator -  SELL!!!", ""); 
             }            
         } 
      if (!SoundSell && (g_ibuf_88[SIGNAL_BAR] == EMPTY_VALUE || g_ibuf_88[SIGNAL_BAR] == 0)) SoundSell = True; 
      
       //+------------------------------------------------------------------+  
   return (0);
}