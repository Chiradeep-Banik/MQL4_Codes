//+------------------------------------------------------------------+
//|                                                VelocityWeves.mq4 |
//|                               Copyright © 2010, Vladimir Hlystov |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Vladimir Hlystov"
#property link      "http://cmillion.narod.ru"
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue
extern bool DrawVisualization = true;
//---- indicator ZIGZAG parameters
extern int Zigzag_Depth    = 12;
extern int Zigzag_Deviation= 5;
extern int Zigzag_Backstep = 3;
//----
extern color WevesColor    = Gray;
extern color TrendUpColor  = Red;
extern color TrendDnColor  = Blue;
extern int   TotalTrend    = 10;
extern int   AlertON       = 20;
//---- indicator buffers
double HighMapBuffer[];
double LowMapBuffer[];
double Weves[101][2];
//+------------------------------------------------------------------+
int init()
  {
   if (TotalTrend>98) TotalTrend=98;
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,HighMapBuffer);
   SetIndexBuffer(1,LowMapBuffer);
   SetIndexEmptyValue(0,0.0);
   IndicatorShortName("VelocityWeves("+Zigzag_Depth+","+Zigzag_Deviation+","+Zigzag_Backstep+")");
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   double shift_Y = (WindowPriceMax()-WindowPriceMin()) / 45;
   double ZigzagBuffer,H_Wave,S_Wave,V_olum,
          v_tek_trend,s_tek_trend=0,h_tek_trend;
   int n,T_Wave,k,k1,max_bulls_trend,max_bears_trend=1000000,max_bulls,max_bears,
       t_tek_trend;
   string txt,rec;
   int i=0;
   while (true)
   {
      if (n==TotalTrend+2) break;
      ZigzagBuffer=iCustom(NULL, 0, "Zigzag",Zigzag_Depth,Zigzag_Deviation,Zigzag_Backstep,0,i);
      if (ZigzagBuffer!=0) 
      {
         Weves[n][0]=ZigzagBuffer;
         Weves[n][1]=i;
         n++;
      }
      i++;
   }
   for (i=n-2; i>=0; i--)
   {
      T_Wave=(Weves[i+1][1]-Weves[i][1])*Period()/60;
      H_Wave=(Weves[i][0]-Weves[i+1][0])/Point;
      if (T_Wave!=0) S_Wave=H_Wave/T_Wave;
      V_olum=SrVolume(Weves[i+1][1],Weves[i][1]);
      if (max_bulls_trend<H_Wave) {max_bulls_trend=H_Wave;max_bulls=i;}
      if (max_bears_trend>H_Wave) {max_bears_trend=H_Wave;max_bears=i;}
      k=Weves[i][1];k1=Weves[i+1][1];
      if (DrawVisualization)
      {
         txt=StringConcatenate("info  ",i);
         rec=StringConcatenate("trend ",i);
         ObjectDelete(txt);
         ObjectDelete(rec);
         ObjectCreate(rec, OBJ_RECTANGLE, 0, Time[k1],Weves[i+1][0], Time[k],Weves[i][0]);
         if (H_Wave>0) {ObjectSet   (rec, OBJPROP_COLOR, TrendUpColor);}
         else          {ObjectSet   (rec, OBJPROP_COLOR, TrendDnColor);}
         ObjectCreate (txt, OBJ_TEXT,0,Time[k1]+(Time[k]-Time[k1])/2,Weves[i][0],0,0,0,0);
         ObjectSetText(txt, StringConcatenate(" h",H_Wave,
                                              " v",DoubleToStr(V_olum,2),
                                              " s",DoubleToStr(S_Wave,2)
                                              ),8,"Arial");
         ObjectSet   (txt, OBJPROP_COLOR, WevesColor);
         ObjectSet   (rec, OBJPROP_STYLE, STYLE_DOT);
         ObjectSet   (rec, OBJPROP_WIDTH,1);
         ObjectSet   (rec, OBJPROP_BACK, false);
      }
   }
   int nullbar=Weves[1][1];
   //t_tek_trend=(TimeCurrent()-Time[nullbar])/60;//*Period();
   t_tek_trend=Weves[1][1]*Period()/60;
   if (Weves[1][0]!=0) h_tek_trend=(Bid-Weves[1][0])/Point; else h_tek_trend=0;
   v_tek_trend=SrVolume(Weves[1][1],0);
   if (t_tek_trend!=0) s_tek_trend=h_tek_trend/(t_tek_trend); else s_tek_trend = 0;
   if (AlertON!=0 && AlertON<t_tek_trend) Alert("Текущий тренд превысил ",t_tek_trend," п");
   Comment("h ",DoubleToStr(h_tek_trend,0),
        "   v ",DoubleToStr(v_tek_trend,2),
        "   s ",DoubleToStr(s_tek_trend,2));
return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(0,OBJ_TEXT);
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
   return(0);
}
//+------------------------------------------------------------------+
double SrVolume(int start,int end)
{
   double Vol;
   for (int i=start+1; i>=end; i--)
   {
      Vol=Vol+Volume[i];
   }
   if (start!=end) Vol=Vol/(start-end);
   return(Vol);
}
//+------------------------------------------------------------------+

