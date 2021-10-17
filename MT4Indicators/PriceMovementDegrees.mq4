//+------------------------------------------------------------------+
//|                                         PriceMovementDegrees.mq4 |
//|                           Copyright 2018, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roberto Jacobs (3rjfx) ~ Date Create: 2018/06/18"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
#property strict
#property description "Forex Indicator Price Movement Degrees with Trend Alerts."
#property description "This indicator will write value degrees of the latest position of price at the current Timeframes"
#property description "according to the Daily price movement, and when position and condition of trend status was changed"
#property description "the indicator will give an alerts."
//--
#property indicator_chart_window
//--
enum corner
 {  
   NotShow=-1, // Not Show Info
   LeftHand=0, // Left upper
   RightHand=1 // Right upper
 };
//--
enum YN
 {
   No,
   Yes
 };
//--
input corner                  cor = RightHand;     // Info Position Degree
input color             textcolor = clrSnow;       // Text Color
input color              buycolor = clrBlue;       // Bullish Color
input color             sellcolor = clrRed;        // Bearish Color
input ENUM_LINE_STYLE LGLineStyle = STYLE_SOLID;   // Linear Regression Line style
input int             LGLineWidth = 1;             // Linear Regression Line width
input YN                MsgAlerts = Yes;           // Message Alert (Yes) or (No)
input YN              eMailAlerts = No;            // Email Alert (Yes) or (No)
//--
double 
   LG[13],
   LR[10]; //14
//--
int total,
    dist_x,
    dist_xt,
    dist_y;
int xdis,
    patx,
    paty;
int fsize=8;
int dist=20;
int cmal,xmal;
int posalert,
    prevalert;
//--
ENUM_TIMEFRAMES ETF;
long CI;
datetime TIME[];
//--    
string name;
string dtext;
string Albase,AlSubj,AlMsg;
//--
int DGR[]={270,260,235,225,215,195,180,165,145,135,125,100,90};
color Lclr[]={clrRed,clrRed,clrOrchid,clrOrchid,clrOrchid,clrLime,clrYellow,clrLime,clrAqua,clrAqua,clrAqua,clrBlue,clrBlue};
color Rclr[]={clrRed,clrOrchid,clrYellow,clrAqua,clrBlue};
color rndclr;
color arrclr;
color trnclr;
color txtclr;
string objname[]={"PM_Degrees","PM_Degrees_signal","PM_Degrees_trend","PM_Degrees_time","PM_Degrees_CurrentTime"};
string cursignal="PM_Degrees_signal_2";
string font_mod="Arial Black";
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   CI=ChartID();
   total=111;
   IndicatorShortName("PM Degrees ("+_Symbol+")");
   name="PM Degrees";
   ETF=PERIOD_CURRENT;
   //--
   if(cor>=0)
     {
       dist_x=cor==1 ? 144 : 100;
       dist_xt=cor==1 ? 104 : 60;
       dist_y=80;
       xdis=cor==1 ? 100 : 145;
       patx=cor==1 ? 198 : 47;
       paty=180;
     }
   //--
   if(cor<0) ObjectsDeleteAll();
   //--
//---
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   if(reason==1)
     {
       //--
       ObjectsDeleteAll();
       GlobalVariablesDeleteAll(); 
     }
//----
   return;
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
   if(rates_total<total) return(0);
   else total=111; //2+WindowFirstVisibleBar();
   if(prev_calculated>0) 
     total=111; //2+WindowFirstVisibleBar();
   //Print("bar total : "+string(total));
   //--
   ResetLastError();
   WindowRedraw();
   ChartRedraw(CI);
   //--
   PriceInit();
   RefreshRates();
   int inH=iHighest(_Symbol,ETF,MODE_HIGH,total,0);
   int inL=iLowest(_Symbol,ETF,MODE_LOW,total,0);
   double MaxPrc=high[inH];
   double MinPrc=low[inL];
   double maxmin=MaxPrc-MinPrc;
   double degree=maxmin/180;
   //--
   LG[12]=MaxPrc; // WindowPriceMax(0) 90 degree
   LG[11]=NormalizeDouble(MaxPrc-(10*degree),_Digits); // 100 degree
   LG[10]=NormalizeDouble(MaxPrc-(35*degree),_Digits); // 125 degree
   LG[9]=NormalizeDouble(MaxPrc-(45*degree),_Digits);  // 135 degree
   LG[8]=NormalizeDouble(MaxPrc-(55*degree),_Digits);  // 145 degree
   LG[7]=NormalizeDouble(MaxPrc-(75*degree),_Digits);  // 165 degree
   LG[6]=NormalizeDouble(MinPrc+(maxmin/2),_Digits);   // 180 degree
   LG[5]=NormalizeDouble(MinPrc+(75*degree),_Digits);  // 195 degree
   LG[4]=NormalizeDouble(MinPrc+(55*degree),_Digits);  // 215 degree
   LG[3]=NormalizeDouble(MinPrc+(45*degree),_Digits);  // 225 degree
   LG[2]=NormalizeDouble(MinPrc+(35*degree),_Digits);  // 235 degree
   LG[1]=NormalizeDouble(MinPrc+10*degree,_Digits);    // 260 degree
   LG[0]=MinPrc; // WindowPriceMin(0) 270 Degree
   //--
   for(int i=0; i<ArraySize(LG) && !IsStopped(); i++)
     {
       CreateTrendLine(CI,"PMD"+string(i),TIME[0],LG[i],TIME[total-1],LG[i],LGLineWidth,LGLineStyle,Lclr[i],false,true);
       CreateText(CI,"LD"+string(i),TIME[0],LG[i],CharToString(108),"Wingdings",8,Lclr[i],ANCHOR_LEFT);
       CreateText(CI,"PD"+string(i),TIME[0],LG[i],"   "+string(DGR[i])+""+CharToString(176),"Arial Black",7,textcolor,ANCHOR_LEFT);
     }
   //-- 
   trnclr=inH>inL ? sellcolor : buycolor;
   CreateTrendLine(CI,"ZZTrend",TIME[inH],high[inH],TIME[inL],low[inL],2,LGLineStyle,trnclr,false,true);
   //--
   double suma=0.0,
          sumb1=0.0,
          sumab=0.0,
          sumb2=0.0;
   double LRD=0;      
   double a,b,c,dtxt;
   bool dgrsUp=false;
   bool dgrsDn=false;
   txtclr=textcolor;
   int bar=ArraySize(LR);
   //--
   for(int i=0; i<bar; i++)
     {
      suma+=iMA(_Symbol,ETF,1,0,MODE_LWMA,PRICE_WEIGHTED,i);
      sumab+=iMA(_Symbol,ETF,1,0,MODE_LWMA,PRICE_WEIGHTED,i)*i;
      sumb1+=i;
      sumb2+=i*i;
     }
   //--
   a=sumb2*bar-sumb1*sumb1;
   b=(sumab*bar-sumb1*suma)/a;
   c=(suma-sumb1*b)/bar;
   //--
   //-- Linear regression MA Trend
   for(int i=0; i<bar; i++) LR[i]=c+b*i;
   //--
   LRD=NormalizeDouble(270-(((LR[0]-MinPrc)/(MaxPrc-MinPrc))*180),2);
   if(LRD<90.0) LRD=90.0;
   if(LRD>270.0) LRD=270.0;
   //--
   dtext=StringTrimRight(StringConcatenate(DoubleToString(LRD,1),"",CharToString(176)));
   if(StringLen(dtext)>5) {dtxt=25;}
   else if(StringLen(dtext)==5) {dtxt=23;}
   else {dtxt=19;}
   //--
   if(LR[0]>LR[bar-1])  {dgrsUp=true; dgrsDn=false; arrclr=buycolor; posalert=1;}
   if(LR[0]<LR[bar-1])  {dgrsDn=true; dgrsUp=false; arrclr=sellcolor; posalert=-1;}
   if(LR[0]==LR[bar-1]) {dgrsUp=false; dgrsDn=false; arrclr=Rclr[2]; posalert=0;}
   //--
   if((LRD<=DGR[0] && LRD>DGR[2]))   rndclr=Rclr[0];
   if((LRD<=DGR[2] && LRD>DGR[5]))   rndclr=Rclr[1];
   if((LRD<=DGR[5] && LRD>=DGR[7]))  rndclr=Rclr[2];
   if((LRD<DGR[7] && LRD>=DGR[10]))  rndclr=Rclr[3];
   if((LRD>=DGR[12] && LRD<DGR[10])) rndclr=Rclr[4];
   if(rndclr==Rclr[2]||rndclr==Rclr[3]) txtclr=clrBlack;
   //--
   if(cor>=0)
     {
       int addt=cor==1 ? 0 : 31;
       int adda=cor==1 ? 20 : 60;
       CreateRoundDegrees(CI,"LRDegrees","Wingdings",CharToString(108),67,rndclr,cor,dist_x,dist_y,true);
       //--
       CreateRoundDegrees(CI,"TextDegrees","Bodoni MT Black",dtext,8,txtclr,cor,dist_xt+addt+(int)dtxt,dist_y+41,true);    
       //--
       if(dgrsUp) 
         CreateArrowDegrees(CI,"ArrUpDegrees","ArrDnDegrees","Wingdings",CharToString(217),23,arrclr,cor,dist_xt+adda,dist_y-2,true);
       //--
       if(dgrsDn) 
         CreateArrowDegrees(CI,"ArrDnDegrees","ArrUpDegrees","Wingdings",CharToString(218),23,arrclr,cor,dist_xt+adda,dist_y+63,true);
     }
   //--
   SignalPower(dgrsUp,dgrsDn);
   //--
   RefreshRates();
   WindowRedraw();
   ChartRedraw(CI);
   if(MsgAlerts==1||eMailAlerts==1) PosAlerts(posalert);
   //--
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------//

void PriceInit(void)
  {
//---
    ArrayResize(TIME,total);
    ArraySetAsSeries(TIME,true);
    //--
    for(int i=total-1; i>=0; i--) 
      TIME[i]=iTime(_Symbol,ETF,i);
    //--
    return;
//---
  }
//---------//

void SignalPower(bool ups,bool dwn)
  {
//---
    if(cor>=0)
      {
        int nextcan=0;
        string power="",
               sign="",
               nextc="";
        color sigcolor=0;
        double mfi=iMFI(_Symbol,0,14,0);
        if(ups)
          {
            sign="BUY";
            sigcolor=buycolor;
            if(mfi<45) power="Weak";
            if(mfi>=45 && mfi<=65) power="Medium";
            if(mfi>65) power="Strong";
          }
        //--
        if(dwn)
          {
            sign="SELL";
            sigcolor=sellcolor;
            if(mfi>55) power="Weak";
            if(mfi>=35 && mfi<=55) power="Medium";
            if(mfi<35) power="Strong";
          }
        //--
        if(_Period==1)
          {
            nextcan=60-Seconds();
            nextc=string(nextcan)+"S";
          }
        if(_Period>1 && _Period<=60)
          {
            int next=_Period-1-(TimeMinute(TimeCurrent())-TimeMinute(TIME[0]));
            if(next>0)
              {
                nextcan=next;
                nextc=string(nextcan)+"M:"+string(60-Seconds())+"S";
              }
            else 
              {
                nextcan=60-Seconds();
                nextc=string(nextcan)+"S";
              }
          }
        else
          {
            int next=0;
            if(_Period==240)
              {
                double per=fmod((double)Hour(),4);
                next=(4-(int)per)*60-(TimeMinute(TimeCurrent())-TimeMinute(TIME[0]));
              }
            if(_Period==1440)
              {
                next=(24-Hour())*60-(TimeMinute(TimeCurrent())-TimeMinute(TIME[0]));
              }
            if(_Period==10080)
              {
                next=(7-TimeDayOfWeek(TimeCurrent())-1)*24*60-(TimeMinute(TimeCurrent())-TimeMinute(TIME[0]));
              }
            if(_Period==43200)
              {
                int nexm=TimeDay(StringToTime("01"+"/"+string(TimeMonth(TimeCurrent())+1)+"/"+"00")-1);
                next=(nexm-TimeDay(TimeCurrent())+1)*24*60+(24-Hour()*60)-(TimeMinute(TimeCurrent())-TimeMinute(TIME[0]));
              }
            if(next>0)
              {
                nextcan=next;
                nextc=string(nextcan)+"M:"+string(60-Seconds())+"S";
              }
            else 
              {
                nextcan=60-Seconds();
                nextc=string(nextcan)+"S";
              }
          }
        //--
        CreateLabel(CI,objname[0],"PM Degrees"+" : Period "+strTF(_Period),font_mod,fsize,textcolor,cor,patx,paty+0*dist);
        CreateLabel(CI,objname[1],"Current Signal:",font_mod,fsize,textcolor,cor,patx,paty+1*dist);
        if(ups||dwn) CreateLabel(CI,cursignal,sign,font_mod,fsize,sigcolor,cor,xdis,paty+dist);
        CreateLabel(CI,objname[2],"Trend Power: "+power,font_mod,fsize,textcolor,cor,patx,paty+2*dist);
        CreateLabel(CI,objname[3],"Time until next bar: "+nextc,font_mod,fsize,textcolor,cor,patx,paty+3*dist);
        CreateLabel(CI,objname[4],"Current Time: "+TimeToString(TimeCurrent(),TIME_SECONDS),font_mod,fsize,textcolor,cor,patx,paty+4*dist);
      }
    //--
    return; 
//---
  }
//---------//

void CreateTrendLine(long     chartid, 
                     string   line_name,
                     datetime line_time1,
                     double   line_price1,
                     datetime line_time2,
                     double   line_price2,
                     int      line_width,
                     int      line_style,
                     color    line_color,
                     bool     ray_right,
                     bool     line_hidden)
  {  
//---
   ObjectDelete(chartid,line_name);
   //--
   if(ObjectCreate(chartid,line_name,OBJ_TREND,0,line_time1,line_price1,line_time2,line_price2)) // create trend line
     {
       ObjectSetInteger(chartid,line_name,OBJPROP_WIDTH,line_width);
       ObjectSetInteger(chartid,line_name,OBJPROP_STYLE,line_style);
       ObjectSetInteger(chartid,line_name,OBJPROP_COLOR,line_color);
       ObjectSetInteger(chartid,line_name,OBJPROP_RAY_RIGHT,ray_right);
       ObjectSetInteger(chartid,line_name,OBJPROP_HIDDEN,line_hidden);
     } 
   else 
      {Print("Failed to create the object OBJ_TREND ",line_name,", Error code = ", GetLastError());}
   //--
   return;
//---
  }   
//---------//

void CreateText(long   chart_id, 
                string text_name,
                datetime txt_time,
                double   txt_price,
                string label_text,
                string font_model,
                int    font_size,
                color  text_color,
                int    anchor)
  { 
//--- 
   ObjectDelete(chart_id,text_name);
   //--
   if(ObjectCreate(chart_id,text_name,OBJ_TEXT,0,txt_time,txt_price))
     { 
       ObjectSetString(chart_id,text_name,OBJPROP_TEXT,label_text);
       ObjectSetString(chart_id,text_name,OBJPROP_FONT,font_model); 
       ObjectSetInteger(chart_id,text_name,OBJPROP_FONTSIZE,font_size);
       ObjectSetInteger(chart_id,text_name,OBJPROP_COLOR,text_color);
       ObjectSetInteger(chart_id,text_name,OBJPROP_ANCHOR,anchor);
     } 
   else 
      {Print("Failed to create the object OBJ_TEXT ",text_name,", Error code = ", GetLastError());}
   //---
   return;
  }
//---------//

void CreateRoundDegrees(long   chartid, 
                        string lable_name, 
                        string lable_font_model,
                        string lable_obj_text,
                        int    lable_font_size,
                        color  lable_color,
                        int    lable_corner,
                        int    lable_xdist,
                        int    lable_ydist,
                        bool   lable_hidden)
  {  
//---
    ObjectDelete(chartid,lable_name);
    //--
    ObjectCreate(chartid,lable_name,OBJ_LABEL,0,0,0,0,0); // create rounded degrees
    ObjectSetInteger(chartid,lable_name,OBJPROP_FONTSIZE,lable_font_size); 
    ObjectSetString(chartid,lable_name,OBJPROP_FONT,lable_font_model);
    ObjectSetString(chartid,lable_name,OBJPROP_TEXT,lable_obj_text);
    ObjectSetInteger(chartid,lable_name,OBJPROP_COLOR,lable_color);
    ObjectSetInteger(chartid,lable_name,OBJPROP_CORNER,lable_corner);
    ObjectSetInteger(chartid,lable_name,OBJPROP_XDISTANCE,lable_xdist);
    ObjectSetInteger(chartid,lable_name,OBJPROP_YDISTANCE,lable_ydist);
    ObjectSetInteger(chartid,lable_name,OBJPROP_HIDDEN,lable_hidden);
    //--
    return;
//---
  }   
//---------//

void CreateArrowDegrees(long   chartid, 
                        string lable_name1,
                        string lable_name2,
                        string lable_font_model,
                        string lable_obj_text,
                        int    lable_font_size,
                        color  lable_color,
                        int    lable_corner,
                        int    lable_xdist,
                        int    lable_ydist,
                        bool   lable_hidden)
  {  
//---
    ObjectDelete(chartid,lable_name2);
    ObjectDelete(chartid,lable_name1);
    //--
    ObjectCreate(chartid,lable_name1,OBJ_LABEL,0,0,0,0,0); // create arrow degrees
    ObjectSetInteger(chartid,lable_name1,OBJPROP_FONTSIZE,lable_font_size); 
    ObjectSetString(chartid,lable_name1,OBJPROP_FONT,lable_font_model);
    ObjectSetString(chartid,lable_name1,OBJPROP_TEXT,lable_obj_text);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_COLOR,lable_color);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_CORNER,lable_corner);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_XDISTANCE,lable_xdist);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_YDISTANCE,lable_ydist);
    ObjectSetInteger(chartid,lable_name1,OBJPROP_HIDDEN,lable_hidden);
    //--
    return;
//---
  }   
//---------//

void CreateLabel(long   chart_id, 
                 string lable_name, 
                 string label_text,
                 string font_model,
                 int    font_size,
                 color  label_color,
                 int    chart_corner,
                 int    x_cor, 
                 int    y_cor) 
  { 
//--- 
   if(ObjectFind(chart_id,lable_name)<0)
     {
       if(ObjectCreate(chart_id,lable_name,OBJ_LABEL,0,0,0,0,0)) 
         { 
           ObjectSetString(chart_id,lable_name,OBJPROP_TEXT,label_text);
           ObjectSetString(chart_id,lable_name,OBJPROP_FONT,font_model); 
           ObjectSetInteger(chart_id,lable_name,OBJPROP_FONTSIZE,font_size);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_COLOR,label_color);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_CORNER,chart_corner);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_XDISTANCE,x_cor);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_YDISTANCE,y_cor);
         } 
       else 
          {Print("Failed to create the object OBJ_LABEL ",lable_name,", Error code = ", GetLastError());}
     }
   else
     {
       ObjectSetString(chart_id,lable_name,OBJPROP_TEXT,label_text);
       ObjectSetString(chart_id,lable_name,OBJPROP_FONT,font_model); 
       ObjectSetInteger(chart_id,lable_name,OBJPROP_FONTSIZE,font_size);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_COLOR,label_color);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_CORNER,chart_corner);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_XDISTANCE,x_cor);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_YDISTANCE,y_cor);
     }
   //--
   return;
//----
  } //-end CreateLabel()
//---------//

string strTF(int period)
  {
//---
   string periodcur;
   switch(period)
     {
       //--
       case PERIOD_M1: periodcur="M1"; break;
       case PERIOD_M5: periodcur="M5"; break;
       case PERIOD_M15: periodcur="M15"; break;
       case PERIOD_M30: periodcur="M30"; break;
       case PERIOD_H1: periodcur="H1"; break;
       case PERIOD_H4: periodcur="H4"; break;
       case PERIOD_D1: periodcur="D1"; break;
       case PERIOD_W1: periodcur="W1"; break;
       case PERIOD_MN1: periodcur="MN"; break;
       //--
     }
   //--
   return(periodcur);
   //---
  } //-end strTF()
//---------//

void DoAlerts(string msgText,string eMailSub)
  {
//---
    if (MsgAlerts==1) Alert(msgText);
    if (eMailAlerts==1) SendMail(eMailSub,msgText);
//---
  }
//---------//

void PosAlerts(int curalerts)
   {
    //---
    cmal=Minute();
    if(cmal!=xmal)
      {
        //--
        if((curalerts!=prevalert)&&(curalerts==1))
          {
            Albase=name+" "+_Symbol+", TF: "+strTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" The Price Began to Rise, Open BUY Position";
            AlMsg=AlSubj+" @ "+TimeToStr(TimeLocal(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //---
        if((curalerts!=prevalert)&&(curalerts==-1))
          {     
            Albase=name+" "+_Symbol+", TF: "+strTF(_Period)+", Position "+dtext;
            AlSubj=Albase+" The Price Began to Down, Open SELL Position";
            AlMsg=AlSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoAlerts(AlMsg,AlSubj);
            prevalert=curalerts;
          }
        //--
        xmal=cmal;
      }
    //---
    return;
   //----
   } //-end PosAlerts()
//---------//
//+------------------------------------------------------------------+
