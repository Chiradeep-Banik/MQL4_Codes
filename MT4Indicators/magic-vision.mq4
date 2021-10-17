//+------------------------------------------------------------------+
//|                                              Magic_Vision_V1.mq4 |
//|                                          Sergey Gulyaev. Maykop. |
//|                                     http://www.mebel-for-you.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window

int tf,
M1  = PERIOD_M1,
M5  = PERIOD_M5,
M15 = PERIOD_M15,
M30 = PERIOD_M30,
H1  = PERIOD_H1,
H4  = PERIOD_H4,
D1  = PERIOD_D1,
W1  = PERIOD_W1,
Period_MA;
extern int Period_MA_Fast= 5;
extern int Period_MA_Med = 15;
extern int Period_MA_Slow= 60;
int X,Y,n,
DislocationX_Base=100,
DislocationX_TimeFrame=0,
DislocationX_Stoch=50,
DislocationX_Vel_MA_Fast= 140,
DislocationX_Vel_MA_Med = 280,
DislocationX_Vel_MA_Slow= 420,
DislocationX_Sum_Abs_Speed=560;

color color_indic,
color_ind_UP=Lime,
color_ind_DOWN=Red,
color_ind_End_UP=LightGreen,
color_ind_End_DOWN=Coral,
color_tf=Gray,
color_sum=Red,
color_MA_Fast= Gold,
color_MA_Med = Lime,
color_MA_Slow= DodgerBlue;

double V;
double M_0,S_0,
M_1,S_1,
M_2,S_2;

int St_Moving_M1,
St_Moving_M5,
St_Moving_M15,
St_Moving_M30,
St_Moving_H1,
St_Moving_H4,
St_Moving_D1,
St_Moving_W1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- name for indicator window
   string name_window="*Magic_Vision_V1*";
   IndicatorShortName(name_window);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   if(iBars(NULL,M1)<=500)
     {
      Print("Not enough M1 bars. Exit");
      return(0);
     }
   if(iBars(NULL,M5)<=500)
     {
      Print("Not enough M5 bars. Exit");
      return(0);
     }
   if(iBars(NULL,M15)<=500)
     {
      Print("Not enough M15 bars. Exit");
      return(0);
     }
   if(iBars(NULL,M30)<=500)
     {
      Print("Not enough M30 bars. Exit");
      return(0);
     }
   if(iBars(NULL,H1)<=500)
     {
      Print("Not enough H1 bars. Exit");
      return(0);
     }
   if(iBars(NULL,H4)<=500)
     {
      Print("Not enough bars. Exit");
      return(0);
     }
   if(iBars(NULL,D1)<=500)
     {
      Print("Not enough bars. Exit");
      return(0);
     }

   if(iBars(NULL,W1)<=500)
     {
      Print("Not enough bars. Exit");
      return(0);
     }

// Timeframes (вывод названия строк) ---------------------------------
   X=DislocationX_Base+DislocationX_TimeFrame; Y=21;
   Creat_Name_Str ("tf_m1", "M1", color_tf, X, Y); Y = Y + 15;
   Creat_Name_Str ("tf_m5", "M5", color_tf, X, Y); Y = Y + 15;
   Creat_Name_Str ("tf_m15","M15",color_tf, X, Y); Y = Y + 15;
   Creat_Name_Str ("tf_m30","M30",color_tf, X, Y); Y = Y + 15;
   Creat_Name_Str ("tf_h1", "H1", color_tf, X, Y); Y = Y + 15;
   Creat_Name_Str ("tf_h4", "H4", color_tf, X, Y); Y = Y + 15;
   Creat_Name_Str ("tf_d1", "D1", color_tf, X, Y); Y = Y + 15;
   Creat_Name_Str ("tf_w1", "W1", color_tf, X, Y); Y = Y + 20;
   Creat_Name_Str("Sum_Common","Itog",color_tf,X,Y);
//--------------------------------------------------------------------
// Indicator (Stochastic)---------------------------------------------
   X=DislocationX_Base+DislocationX_Stoch; Y=5;
   Creat_Name_Column("Stoch","Stoch",SkyBlue,X,Y); Y=Y+17;
   tf = M1;  double Mov_St_M1  = Creat_Сell_Stoch (tf, "Trend_St_M1",  X, Y); Y = Y + 15;
   tf = M5;  double Mov_St_M5  = Creat_Сell_Stoch (tf, "Trend_St_M5",  X, Y); Y = Y + 15;
   tf = M15; double Mov_St_M15 = Creat_Сell_Stoch (tf, "Trend_St_M15", X, Y); Y = Y + 15;
   tf = M30; double Mov_St_M30 = Creat_Сell_Stoch (tf, "Trend_St_M30", X, Y); Y = Y + 15;
   tf = H1;  double Mov_St_H1  = Creat_Сell_Stoch (tf, "Trend_St_H1",  X, Y); Y = Y + 15;
   tf = H4;  double Mov_St_H4  = Creat_Сell_Stoch (tf, "Trend_St_H4",  X, Y); Y = Y + 15;
   tf = D1;  double Mov_St_D1  = Creat_Сell_Stoch (tf, "Trend_St_D1",  X, Y); Y = Y + 15;
   tf = W1;  double Mov_St_W1  = Creat_Сell_Stoch (tf, "Trend_St_W1",  X, Y);

   double Sum_Stochastic=(Mov_St_M1+Mov_St_M5+Mov_St_M15+Mov_St_M30+Mov_St_H1+Mov_St_H4+Mov_St_D1+
                          Mov_St_W1)/8;
   double Itog_St=Sum_Stochastic;
// цвет
   int St_Moving=St_Moving_M1+St_Moving_M5+St_Moving_M15+St_Moving_M30+St_Moving_H1+
                 St_Moving_H4+St_Moving_D1+St_Moving_W1;
   if(St_Moving > 0)color_indic = color_ind_UP;
   if(St_Moving < 0)color_indic = color_ind_DOWN;
   if(St_Moving==0)color_indic=White;
   Sum_Stochastic=MathRound(MathAbs(Sum_Stochastic));
// позиция 
   if(Sum_Stochastic<10) n=X+27;
   if(Sum_Stochastic >= 10 && Sum_Stochastic < 100) n = X + 20;
   if(Sum_Stochastic >= 100) n = X + 13;
   ObjectCreate("Sum_St",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Sum_St",DoubleToStr(Sum_Stochastic,0),7,"Verdana",color_indic);
   ObjectSet("Sum_St",OBJPROP_CORNER,0);
   ObjectSet("Sum_St",OBJPROP_XDISTANCE,n);
   ObjectSet("Sum_St",OBJPROP_YDISTANCE,147);
//--------------------------------------------------------------------   
// Indicator (Speed_MA_Fast)----------------------------------------------
   X=DislocationX_Base+DislocationX_Vel_MA_Fast; Y=5;
   Period_MA=Period_MA_Fast;

   Creat_Name_Column("VL"+DoubleToStr(Period_MA,0),"MA"+Period_MA+" Abs  Rel Acc ",color_MA_Fast,X,Y); Y=Y+17;
   tf=M1;  double Abs_Speed_MA_Fast_M1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Fast_M1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Fast_M1  = speed_acc(tf, Period_MA);
   tf=M5;  double Abs_Speed_MA_Fast_M5=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Fast_M5  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Fast_M5  = speed_acc(tf, Period_MA);
   tf=M15; double Abs_Speed_MA_Fast_M15=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Fast_M15 = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Fast_M15 = speed_acc(tf, Period_MA);
   tf=M30; double Abs_Speed_MA_Fast_M30=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Fast_M30 = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Fast_M30 = speed_acc(tf, Period_MA);
   tf=H1;  double Abs_Speed_MA_Fast_H1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Fast_H1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Fast_H1  = speed_acc(tf, Period_MA);
   tf=H4;  double Abs_Speed_MA_Fast_H4=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Fast_H4  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Fast_H4  = speed_acc(tf, Period_MA);
   tf=D1;  double Abs_Speed_MA_Fast_D1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Fast_D1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Fast_D1  = speed_acc(tf, Period_MA);
   tf=W1;  double Abs_Speed_MA_Fast_W1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+20;
   double Rel_Speed_MA_Fast_W1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Fast_W1  = speed_acc(tf, Period_MA);
   double Itog_Abs_Speed_MA_Fast=(Abs_Speed_MA_Fast_M1+Abs_Speed_MA_Fast_M5/5+Abs_Speed_MA_Fast_M15/15+Abs_Speed_MA_Fast_M30/30+
                                  Abs_Speed_MA_Fast_H1/60+Abs_Speed_MA_Fast_H4/240+Abs_Speed_MA_Fast_D1/1440+Abs_Speed_MA_Fast_W1/10080)/8;
// цвет
   if(Itog_Abs_Speed_MA_Fast > 0)color_indic = color_ind_UP;
   if(Itog_Abs_Speed_MA_Fast < 0)color_indic = color_ind_DOWN;
   if(Itog_Abs_Speed_MA_Fast==0)color_indic=White;
   Itog_Abs_Speed_MA_Fast=MathAbs(Itog_Abs_Speed_MA_Fast);
// позиция 
   n=X+7;
   ObjectCreate("Abs_Speed_MA_Fast",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Abs_Speed_MA_Fast",DoubleToStr(Itog_Abs_Speed_MA_Fast,Digits),7,"Verdana",color_indic);
   ObjectSet("Abs_Speed_MA_Fast",OBJPROP_CORNER,0);
   ObjectSet("Abs_Speed_MA_Fast",OBJPROP_XDISTANCE,n);
   ObjectSet("Abs_Speed_MA_Fast",OBJPROP_YDISTANCE,Y);

   double Itog_Rel_Speed_MA_Fast=(Rel_Speed_MA_Fast_M1+Rel_Speed_MA_Fast_M5+Rel_Speed_MA_Fast_M15+Rel_Speed_MA_Fast_M30+
                                  Rel_Speed_MA_Fast_H1+Rel_Speed_MA_Fast_H4+Rel_Speed_MA_Fast_D1+Rel_Speed_MA_Fast_W1)/8;
// цвет
   if(Itog_Rel_Speed_MA_Fast > 0)color_indic = color_ind_UP;
   if(Itog_Rel_Speed_MA_Fast < 0)color_indic = color_ind_DOWN;
   if(Itog_Rel_Speed_MA_Fast==0)color_indic=White;
   Itog_Rel_Speed_MA_Fast=MathRound(MathAbs(Itog_Rel_Speed_MA_Fast));
// позиция 
   if(Itog_Rel_Speed_MA_Fast<10) n=X+78;
   if(Itog_Rel_Speed_MA_Fast >= 10 && Itog_Rel_Speed_MA_Fast < 100) n = X + 71;
   if(Itog_Rel_Speed_MA_Fast >= 100) n = X + 64;
   ObjectCreate("Itog_Rel_Speed_MA_Fast",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Itog_Rel_Speed_MA_Fast",DoubleToStr(Itog_Rel_Speed_MA_Fast,0),7,"Verdana",color_indic);
   ObjectSet("Itog_Rel_Speed_MA_Fast",OBJPROP_CORNER,0);
   ObjectSet("Itog_Rel_Speed_MA_Fast",OBJPROP_XDISTANCE,n);
   ObjectSet("Itog_Rel_Speed_MA_Fast",OBJPROP_YDISTANCE,147);

//--------------------------------------------------------------------
// Indicator (Speed_MA_Med)---------------------------------------------
   X=DislocationX_Base+DislocationX_Vel_MA_Med; Y=5;
   Period_MA=Period_MA_Med;
   Creat_Name_Column("VL"+DoubleToStr(Period_MA,0),"MA"+Period_MA+" Abs  Rel Acc ",color_MA_Med,X,Y); Y=Y+17;
   tf=M1;  double Abs_Speed_MA_Med_M1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Med_M1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Med_M1  = speed_acc(tf, Period_MA);
   tf=M5;  double Abs_Speed_MA_Med_M5=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Med_M5  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Med_M5  = speed_acc(tf, Period_MA);
   tf=M15; double Abs_Speed_MA_Med_M15=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Med_M15 = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Med_M15 = speed_acc(tf, Period_MA);
   tf=M30; double Abs_Speed_MA_Med_M30=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Med_M30 = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Med_M30 = speed_acc(tf, Period_MA);
   tf=H1;  double Abs_Speed_MA_Med_H1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Med_H1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Med_H1  = speed_acc(tf, Period_MA);
   tf=H4;  double Abs_Speed_MA_Med_H4=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Med_H4  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Med_H4  = speed_acc(tf, Period_MA);
   tf=D1;  double Abs_Speed_MA_Med_D1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Med_D1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Med_D1  = speed_acc(tf, Period_MA);
   tf=W1;  double Abs_Speed_MA_Med_W1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+20;
   double Rel_Speed_MA_Med_W1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Med_W1  = speed_acc(tf, Period_MA);
   double Sum_Abs_Speed_MA_Med=(Abs_Speed_MA_Med_M1+Abs_Speed_MA_Med_M5/5+Abs_Speed_MA_Med_M15/15+Abs_Speed_MA_Med_M30/30+Abs_Speed_MA_Med_H1/60+
                                Abs_Speed_MA_Med_H4/240+Abs_Speed_MA_Med_D1/1440+Abs_Speed_MA_Med_W1/10080)/8;
// цвет
   if(Sum_Abs_Speed_MA_Med > 0)color_indic = color_ind_UP;
   if(Sum_Abs_Speed_MA_Med < 0)color_indic = color_ind_DOWN;
   if(Sum_Abs_Speed_MA_Med==0)color_indic=White;
   Sum_Abs_Speed_MA_Med=MathAbs(Sum_Abs_Speed_MA_Med);
// позиция 
   n=X+7;
   ObjectCreate("Abs_Speed_MA_Med",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Abs_Speed_MA_Med",DoubleToStr(Sum_Abs_Speed_MA_Med,Digits),7,"Verdana",color_indic);
   ObjectSet("Abs_Speed_MA_Med",OBJPROP_CORNER,0);
   ObjectSet("Abs_Speed_MA_Med",OBJPROP_XDISTANCE,n);
   ObjectSet("Abs_Speed_MA_Med",OBJPROP_YDISTANCE,Y);

   double Itog_Rel_Speed_MA_Med=(Rel_Speed_MA_Med_M1+Rel_Speed_MA_Med_M5+Rel_Speed_MA_Med_M15+Rel_Speed_MA_Med_M30+
                                 Rel_Speed_MA_Med_H1+Rel_Speed_MA_Med_H4+Rel_Speed_MA_Med_D1+Rel_Speed_MA_Med_W1)/8;
// цвет
   if(Itog_Rel_Speed_MA_Med > 0)color_indic = color_ind_UP;
   if(Itog_Rel_Speed_MA_Med < 0)color_indic = color_ind_DOWN;
   if(Itog_Rel_Speed_MA_Med==0)color_indic=White;
   Itog_Rel_Speed_MA_Med=MathRound(MathAbs(Itog_Rel_Speed_MA_Med));
// позиция 
   if(Itog_Rel_Speed_MA_Med<10) n=X+78;
   if(Itog_Rel_Speed_MA_Med >= 10 && Itog_Rel_Speed_MA_Med < 100) n = X + 71;
   if(Itog_Rel_Speed_MA_Med >= 100) n = X + 64;
   ObjectCreate("Itog_Rel_Speed_MA_Med",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Itog_Rel_Speed_MA_Med",DoubleToStr(Itog_Rel_Speed_MA_Med,0),7,"Verdana",color_indic);
   ObjectSet("Itog_Rel_Speed_MA_Med",OBJPROP_CORNER,0);
   ObjectSet("Itog_Rel_Speed_MA_Med",OBJPROP_XDISTANCE,n);
   ObjectSet("Itog_Rel_Speed_MA_Med",OBJPROP_YDISTANCE,147);

//--------------------------------------------------------------------
// Indicator (Speed_MA_Slow)---------------------------------------------
   X=DislocationX_Base+DislocationX_Vel_MA_Slow; Y=5;
   Period_MA=Period_MA_Slow;
   Creat_Name_Column("VL"+DoubleToStr(Period_MA,0),"MA"+Period_MA+" Abs  Rel Acc ",color_MA_Slow,X,Y); Y=Y+17;
   tf=M1;  double Abs_Speed_MA_Slow_M1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Slow_M1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Slow_M1  = speed_acc(tf, Period_MA);
   tf=M5;  double Abs_Speed_MA_Slow_M5=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Slow_M5  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Slow_M5  = speed_acc(tf, Period_MA);
   tf=M15; double Abs_Speed_MA_Slow_M15=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Slow_M15 = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Slow_M15 = speed_acc(tf, Period_MA);
   tf=M30; double Abs_Speed_MA_Slow_M30=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Slow_M30 = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Slow_M30 = speed_acc(tf, Period_MA);
   tf=H1;  double Abs_Speed_MA_Slow_H1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Slow_H1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Slow_H1  = speed_acc(tf, Period_MA);
   tf=H4;  double Abs_Speed_MA_Slow_H4=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Slow_H4  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Slow_H4  = speed_acc(tf, Period_MA);
   tf=D1;  double Abs_Speed_MA_Slow_D1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+15;
   double Rel_Speed_MA_Slow_D1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Slow_D1  = speed_acc(tf, Period_MA);
   tf=W1;  double Abs_Speed_MA_Slow_W1=Creat_Сell_Speed_MA(tf,"VL"+DoubleToStr(Period_MA,0)+"_"+DoubleToStr(tf,0),Period_MA,X,Y); Y=Y+20;
   double Rel_Speed_MA_Slow_W1  = speed_rel(tf, Period_MA);
   int    Acc_Speed_MA_Slow_W1  = speed_acc(tf, Period_MA);
   double Sum_Abs_Speed_MA_Slow=(Abs_Speed_MA_Slow_M1+Abs_Speed_MA_Slow_M5/5+Abs_Speed_MA_Slow_M15/15+Abs_Speed_MA_Slow_M30/30+
                                 Abs_Speed_MA_Slow_H1/60+Abs_Speed_MA_Slow_H4/240+Abs_Speed_MA_Slow_D1/1440+Abs_Speed_MA_Slow_W1/10080)/8;
// цвет
   if(Sum_Abs_Speed_MA_Slow > 0)color_indic = color_ind_UP;
   if(Sum_Abs_Speed_MA_Slow < 0)color_indic = color_ind_DOWN;
   if(Sum_Abs_Speed_MA_Slow==0)color_indic=White;
   Sum_Abs_Speed_MA_Slow=MathAbs(Sum_Abs_Speed_MA_Slow);
// позиция 
   n=X+7;
   ObjectCreate("Abs_Speed_MA_Slow",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Abs_Speed_MA_Slow",DoubleToStr(Sum_Abs_Speed_MA_Slow,Digits),7,"Verdana",color_indic);
   ObjectSet("Abs_Speed_MA_Slow",OBJPROP_CORNER,0);
   ObjectSet("Abs_Speed_MA_Slow",OBJPROP_XDISTANCE,n);
   ObjectSet("Abs_Speed_MA_Slow",OBJPROP_YDISTANCE,Y);

   double Itog_Rel_Speed_MA_Slow=(Rel_Speed_MA_Slow_M1+Rel_Speed_MA_Slow_M5+Rel_Speed_MA_Slow_M15+Rel_Speed_MA_Slow_M30+
                                  Rel_Speed_MA_Slow_H1+Rel_Speed_MA_Slow_H4+Rel_Speed_MA_Slow_D1+Rel_Speed_MA_Slow_W1)/8;
// цвет
   if(Itog_Rel_Speed_MA_Slow > 0)color_indic = color_ind_UP;
   if(Itog_Rel_Speed_MA_Slow < 0)color_indic = color_ind_DOWN;
   if(Itog_Rel_Speed_MA_Slow==0)color_indic=White;
   Itog_Rel_Speed_MA_Slow=MathRound(MathAbs(Itog_Rel_Speed_MA_Slow));
// позиция 
   if(Itog_Rel_Speed_MA_Slow<10) n=X+78;
   if(Itog_Rel_Speed_MA_Slow >= 10 && Itog_Rel_Speed_MA_Slow < 100) n = X + 71;
   if(Itog_Rel_Speed_MA_Slow >= 100) n = X + 64;
   ObjectCreate("Itog_Rel_Speed_MA_Slow",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Itog_Rel_Speed_MA_Slow",DoubleToStr(Itog_Rel_Speed_MA_Slow,0),7,"Verdana",color_indic);
   ObjectSet("Itog_Rel_Speed_MA_Slow",OBJPROP_CORNER,0);
   ObjectSet("Itog_Rel_Speed_MA_Slow",OBJPROP_XDISTANCE,n);
   ObjectSet("Itog_Rel_Speed_MA_Slow",OBJPROP_YDISTANCE,147);

//--------------------------------------------------------------------
//-- Sum_Abs_Speed_MA_tf -------------------------------------------------
   X=DislocationX_Base+DislocationX_Sum_Abs_Speed; Y=5;
   Creat_Name_Column("Sum_Abs_Speed_tf","Sum  Abs    Rel",color_sum,X,Y); Y=Y+17;
   int Round=Digits;
   tf = M1;  double Sum_Abs_Speed_M1  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Abs_Speed_tf"+DoubleToStr(tf,0),Abs_Speed_MA_Fast_M1,Abs_Speed_MA_Med_M1,Abs_Speed_MA_Slow_M1, X, Y); Y = Y + 15;
   tf = M5;  double Sum_Abs_Speed_M5  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Abs_Speed_tf"+DoubleToStr(tf,0),Abs_Speed_MA_Fast_M5,Abs_Speed_MA_Med_M5,Abs_Speed_MA_Slow_M5, X, Y); Y = Y + 15;
   tf = M15; double Sum_Abs_Speed_M15 = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Abs_Speed_tf"+DoubleToStr(tf,0),Abs_Speed_MA_Fast_M15,Abs_Speed_MA_Med_M15,Abs_Speed_MA_Slow_M15, X, Y); Y = Y + 15;
   tf = M30; double Sum_Abs_Speed_M30 = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Abs_Speed_tf"+DoubleToStr(tf,0),Abs_Speed_MA_Fast_M30,Abs_Speed_MA_Med_M30,Abs_Speed_MA_Slow_M30, X, Y); Y = Y + 15;
   tf = H1;  double Sum_Abs_Speed_H1  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Abs_Speed_tf"+DoubleToStr(tf,0),Abs_Speed_MA_Fast_H1,Abs_Speed_MA_Med_H1,Abs_Speed_MA_Slow_H1, X, Y); Y = Y + 15;
   tf = H4;  double Sum_Abs_Speed_H4  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Abs_Speed_tf"+DoubleToStr(tf,0),Abs_Speed_MA_Fast_H4,Abs_Speed_MA_Med_H4,Abs_Speed_MA_Slow_H4, X, Y); Y = Y + 15;
   tf = D1;  double Sum_Abs_Speed_D1  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Abs_Speed_tf"+DoubleToStr(tf,0),Abs_Speed_MA_Fast_D1,Abs_Speed_MA_Med_D1,Abs_Speed_MA_Slow_D1, X, Y); Y = Y + 15;
   tf = W1;  double Sum_Abs_Speed_W1  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Abs_Speed_tf"+DoubleToStr(tf,0),Abs_Speed_MA_Fast_W1,Abs_Speed_MA_Med_W1,Abs_Speed_MA_Slow_W1, X, Y); Y = Y + 20;
   double Itog_Abs_Speed_tf=(Sum_Abs_Speed_M1+Sum_Abs_Speed_M5/5+Sum_Abs_Speed_M15/15+Sum_Abs_Speed_M30/30+
                             Sum_Abs_Speed_H1/60+Sum_Abs_Speed_H4/240+Sum_Abs_Speed_D1/1440+Sum_Abs_Speed_W1/10080)/8;
// цвет
   if(Itog_Abs_Speed_tf > 0)color_indic = color_ind_UP;
   if(Itog_Abs_Speed_tf < 0)color_indic = color_ind_DOWN;
   if(Itog_Abs_Speed_tf==0)color_indic=White;
   Itog_Abs_Speed_tf=MathAbs(Itog_Abs_Speed_tf);
// позиция 
   if(Itog_Abs_Speed_tf<10) n=X+16;
   if(Itog_Abs_Speed_tf >= 10 && Itog_Abs_Speed_tf < 100) n = X+8;
   if(Itog_Abs_Speed_tf >= 100) n = X;
   ObjectCreate("Itog_Abs_Speed_tf",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Itog_Abs_Speed_tf",DoubleToStr(Itog_Abs_Speed_tf,Digits),7,"Verdana",color_indic);
   ObjectSet("Itog_Abs_Speed_tf",OBJPROP_CORNER,0);
   ObjectSet("Itog_Abs_Speed_tf",OBJPROP_XDISTANCE,n);
   ObjectSet("Itog_Abs_Speed_tf",OBJPROP_YDISTANCE,Y);
//--------------------------------------------------------------------
//-- Sum_Rel_Speed_MA_tf -------------------------------------------------
   Y=22; X=X+69; Round=0;
   tf = M1;  double Sum_Rel_Speed_M1  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Rel_Speed_tf"+DoubleToStr(tf,0),Rel_Speed_MA_Fast_M1,Rel_Speed_MA_Med_M1,Rel_Speed_MA_Slow_M1, X, Y); Y = Y + 15;
   tf = M5;  double Sum_Rel_Speed_M5  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Rel_Speed_tf"+DoubleToStr(tf,0),Rel_Speed_MA_Fast_M5,Rel_Speed_MA_Med_M5,Rel_Speed_MA_Slow_M5, X, Y); Y = Y + 15;
   tf = M15; double Sum_Rel_Speed_M15 = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Rel_Speed_tf"+DoubleToStr(tf,0),Rel_Speed_MA_Fast_M15,Rel_Speed_MA_Med_M15,Rel_Speed_MA_Slow_M15, X, Y); Y = Y + 15;
   tf = M30; double Sum_Rel_Speed_M30 = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Rel_Speed_tf"+DoubleToStr(tf,0),Rel_Speed_MA_Fast_M30,Rel_Speed_MA_Med_M30,Rel_Speed_MA_Slow_M30, X, Y); Y = Y + 15;
   tf = H1;  double Sum_Rel_Speed_H1  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Rel_Speed_tf"+DoubleToStr(tf,0),Rel_Speed_MA_Fast_H1,Rel_Speed_MA_Med_H1,Rel_Speed_MA_Slow_H1, X, Y); Y = Y + 15;
   tf = H4;  double Sum_Rel_Speed_H4  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Rel_Speed_tf"+DoubleToStr(tf,0),Rel_Speed_MA_Fast_H4,Rel_Speed_MA_Med_H4,Rel_Speed_MA_Slow_H4, X, Y); Y = Y + 15;
   tf = D1;  double Sum_Rel_Speed_D1  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Rel_Speed_tf"+DoubleToStr(tf,0),Rel_Speed_MA_Fast_D1,Rel_Speed_MA_Med_D1,Rel_Speed_MA_Slow_D1, X, Y); Y = Y + 15;
   tf = W1;  double Sum_Rel_Speed_W1  = Creat_Сell_Sum_Speed_MA_tf (tf, Round, "Sum_Rel_Speed_tf"+DoubleToStr(tf,0),Rel_Speed_MA_Fast_W1,Rel_Speed_MA_Med_W1,Rel_Speed_MA_Slow_W1, X, Y); Y = Y + 20;
   double Itog_Rel_Speed_tf=(Sum_Rel_Speed_M1+Sum_Rel_Speed_M5+Sum_Rel_Speed_M15+Sum_Rel_Speed_M30+
                             Sum_Rel_Speed_H1+Sum_Rel_Speed_H4+Sum_Rel_Speed_D1+Sum_Rel_Speed_W1)/8;
// цвет
   if(Itog_Rel_Speed_tf > 0)color_indic = color_ind_UP;
   if(Itog_Rel_Speed_tf < 0)color_indic = color_ind_DOWN;
   if(Itog_Rel_Speed_tf==0)color_indic=White;
   Itog_Rel_Speed_tf=MathRound(MathAbs(Itog_Rel_Speed_tf));
// позиция 
   if(Itog_Rel_Speed_tf<10) n=X+16;
   if(Itog_Rel_Speed_tf >= 10 && Itog_Rel_Speed_tf < 100) n = X+8;
   if(Itog_Rel_Speed_tf >= 100) n = X;
   ObjectCreate("Itog_Rel_Speed_tf",OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("Itog_Rel_Speed_tf",DoubleToStr(Itog_Rel_Speed_tf,0),7,"Verdana",color_indic);
   ObjectSet("Itog_Rel_Speed_tf",OBJPROP_CORNER,0);
   ObjectSet("Itog_Rel_Speed_tf",OBJPROP_XDISTANCE,n);
   ObjectSet("Itog_Rel_Speed_tf",OBJPROP_YDISTANCE,Y);
//--------------------------------------------------------------------
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------ вывод названий строк --------------------------------+
int Creat_Name_Str(string Name_Obj,string Name_Str,color color_tf,int shiftX,int shiftY)
  {
   ObjectCreate(Name_Obj,OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText(Name_Obj,Name_Str,9,"Verdana",color_tf);
   ObjectSet(Name_Obj,OBJPROP_CORNER,0);
   ObjectSet(Name_Obj,OBJPROP_XDISTANCE,shiftX);
   ObjectSet(Name_Obj,OBJPROP_YDISTANCE,shiftY);
   return;
  }
//+------------------------------------------------------------------+
//+------------ вывод названий столбцов------------------------------+
int Creat_Name_Column(string Name_Obj,string Name_Str,color color_name,int shiftX,int shiftY)
  {
   ObjectCreate(Name_Obj,OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText(Name_Obj,Name_Str,9,"Verdana",color_name);
   ObjectSet(Name_Obj,OBJPROP_CORNER,0);
   ObjectSet(Name_Obj,OBJPROP_XDISTANCE,shiftX);
   ObjectSet(Name_Obj,OBJPROP_YDISTANCE,shiftY);
   return;
  }
//+------------------------------------------------------------------+
//+------------ вывод стохастика ------------------------------------+
double Creat_Сell_Stoch(int tf,string Name_Obj,int shiftX,int shiftY)
  {
   int St_Moving=0;
   M_0=iStochastic(NULL,tf,5,3,3,MODE_SMA,0,MODE_MAIN,  0);// 0 бар
   M_1=iStochastic(NULL,tf,5,3,3,MODE_SMA,0,MODE_MAIN,  1);// 1 бар
   S_0=iStochastic(NULL,tf,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);// 0 бар
   S_1=iStochastic(NULL,tf,5,3,3,MODE_SMA,0,MODE_SIGNAL,1);// 1 бар
   if(M_0>S_0) // Зеленая выше красной - UP
     { color_indic=color_ind_UP; St_Moving=1;}
   if(M_0<S_0) // Зеленая ниже красной - DOWN
     { color_indic=color_ind_DOWN; St_Moving=-1;}
   if(M_1>S_1 && M_0<=S_0) // Зелёная пересекает красную вниз
     { color_indic=color_ind_End_UP; St_Moving=1;}
   if(M_1<S_1 && M_0>=S_0) // Зелёная пересекает красную вверх
     { color_indic=color_ind_End_DOWN; St_Moving=-1;}
   switch(tf)
     {
      case PERIOD_M1: St_Moving_M1  = St_Moving; break;
      case PERIOD_M5: St_Moving_M5  = St_Moving; break;
      case PERIOD_M15:St_Moving_M15 = St_Moving; break;
      case PERIOD_M30:St_Moving_M30 = St_Moving; break;
      case PERIOD_H1: St_Moving_H1  = St_Moving; break;
      case PERIOD_H4: St_Moving_H4  = St_Moving; break;
      case PERIOD_D1: St_Moving_D1  = St_Moving; break;
      case PERIOD_W1: St_Moving_W1  = St_Moving; break;
      default: break;
     }
   M_0=MathRound(M_0);
   if(M_0<10) n=shiftX+27;
   if(M_0 >= 10 && M_0 < 100) n = shiftX + 20;
   if(M_0 >= 100) n = shiftX + 13;
   ObjectCreate(Name_Obj,OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText(Name_Obj,DoubleToStr(M_0,0),7,"Verdana",color_indic);
   ObjectSet(Name_Obj,OBJPROP_CORNER,0);
   ObjectSet(Name_Obj,OBJPROP_XDISTANCE,n);
   ObjectSet(Name_Obj,OBJPROP_YDISTANCE,shiftY);
   return(M_0);
  }
//+------------------------------------------------------------------+
//+----------- абсолютная скорость MA -------------------------------+
double speed_abs(int tf,int Period_MA)
  {
   double MA_0  = iMA(NULL,tf,Period_MA,0,MODE_SMA,PRICE_CLOSE,0);
   double MA_1  = iMA(NULL,tf,Period_MA,0,MODE_SMA,PRICE_CLOSE,1);
   double Speed_MA=MA_0-MA_1;
   return(Speed_MA);
  }
//+------------------------------------------------------------------+
//+----------- относительная скорость MA ----------------------------+
double speed_rel(int tf,int Period_MA)
  {
//- ИЩЕМ МАКСИМАЛЬНОЕ ИЗМЕНЕНИЕ _М_А ЗА 1 БАР ----
//--- (принимаем это значение за 100 процентов)
   int i;
   double MA_0,
   MA_1,
   Dif_MA = 0,
   Max_MA = 0,
   Speed_MA=0;
   i=0;
   while(i<500)
     {
      MA_0  = iMA(NULL,tf,Period_MA,0,MODE_SMA,PRICE_CLOSE,i);
      MA_1  = iMA(NULL,tf,Period_MA,0,MODE_SMA,PRICE_CLOSE,i+1);
      Dif_MA= MathAbs(MA_0-MA_1);
      if(Max_MA<Dif_MA)Max_MA=Dif_MA;
      i++;                          // Расчёт индекса следующего бара
     }
//------------- определяем скорость 
   Speed_MA=(speed_abs(tf,Period_MA))/(0.01*Max_MA);
   return(Speed_MA);
  }
//+------------------------------------------------------------------+
//+------------ изменение скорости MA (замедление - ускорение) ------+
int speed_acc(int tf,int Period_MA)
  {
   int acc;
   double MA_0  = iMA(NULL,tf,Period_MA,0,MODE_SMA,PRICE_CLOSE,0);
   double MA_1  = iMA(NULL,tf,Period_MA,0,MODE_SMA,PRICE_CLOSE,1);
   double MA_2  = iMA(NULL,tf,Period_MA,0,MODE_SMA,PRICE_CLOSE,2);
   if(MathAbs(MA_0 - MA_1) > MathAbs(MA_1 - MA_2)) acc = 1;
   if(MathAbs(MA_0 - MA_1) < MathAbs(MA_1 - MA_2)) acc = -1;
   if(MathAbs(MA_0-MA_1)==MathAbs(MA_1-MA_2)) acc=0;
   return(acc);
  }
//+------------------------------------------------------------------+
//+-- вывод абсолютной скорости, относительной скорости и ускорения -+
double Creat_Сell_Speed_MA(int tf,string Name_Obj,int Period_MA,int shiftX,int shiftY)
  {
   V=speed_abs(tf,Period_MA); double V_abs=V;
   if(V>0) { color_indic=color_ind_UP;} //  UP
   if(V<0) { color_indic=color_ind_DOWN;}  //  DOWN
   V = MathAbs(V);
   n = shiftX + 7;
   ObjectCreate("VLS"+Name_Obj,OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("VLS"+Name_Obj,DoubleToStr(V,Digits),7,"Verdana",color_indic);
   ObjectSet("VLS"+Name_Obj,OBJPROP_CORNER,0);
   ObjectSet("VLS"+Name_Obj,OBJPROP_XDISTANCE,n);
   ObjectSet("VLS"+Name_Obj,OBJPROP_YDISTANCE,shiftY);
   V=speed_rel(tf,Period_MA);
   if(V>0) { color_indic=color_ind_UP;} //  UP
   if(V<0) { color_indic=color_ind_DOWN;}  //  DOWN  
   V=MathRound(MathAbs(V));
// позиция 
   if(V<10) n=shiftX+78;
   if(V >= 10 && V < 100) n = shiftX + 71;
   if(V >= 100) n = shiftX + 64;
   ObjectCreate("VLR"+Name_Obj,OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("VLR"+Name_Obj,DoubleToStr(V,0),7,"Verdana",color_indic);
   ObjectSet("VLR"+Name_Obj,OBJPROP_CORNER,0);
   ObjectSet("VLR"+Name_Obj,OBJPROP_XDISTANCE,n);
   ObjectSet("VLR"+Name_Obj,OBJPROP_YDISTANCE,shiftY);
   string acc;
   V=speed_acc(tf,Period_MA);
   if(V == 1)acc = "+";
   if(V == -1)acc = "-";
   if(V == 0)acc = "0";
   n=shiftX+100;
   ObjectCreate("VLACC"+Name_Obj,OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText("VLACC"+Name_Obj,acc,7,"Verdana",color_indic);
   ObjectSet("VLACC"+Name_Obj,OBJPROP_CORNER,0);
   ObjectSet("VLACC"+Name_Obj,OBJPROP_XDISTANCE,n);
   ObjectSet("VLACC"+Name_Obj,OBJPROP_YDISTANCE,shiftY);
   return(V_abs);
  }
//+------------------------------------------------------------------+
//+------- Сумма скоростей по таймфреймам ---------------------------+
double Creat_Сell_Sum_Speed_MA_tf(int tf,int Round,string Name_Obj,double Speed_MA_Fast,double Speed_MA_Med,double Speed_MA_Slow,int shiftX,int shiftY)
  {
   double Sum=(Speed_MA_Fast+Speed_MA_Med+Speed_MA_Slow)/3;
   double Sum_Ret=Sum;
// цвет
   if(Sum > 0)color_indic = color_ind_UP;
   if(Sum < 0)color_indic = color_ind_DOWN;
   if(Sum==0)color_indic=White;
   Sum=MathAbs(Sum);
// позиция 
   if(Sum<10) n=X+16;
   if(Sum >= 10 && Sum < 100) n = X + 8;
   if(Sum >= 100) n = X;
   ObjectCreate(Name_Obj,OBJ_LABEL,WindowFind("*Magic_Vision_V1*"),0,0);
   ObjectSetText(Name_Obj,DoubleToStr(Sum,Round),7,"Verdana",color_indic);
   ObjectSet(Name_Obj,OBJPROP_CORNER,0);
   ObjectSet(Name_Obj,OBJPROP_XDISTANCE,n);
   ObjectSet(Name_Obj,OBJPROP_YDISTANCE,shiftY);
   return(Sum_Ret);
  }
//+------------------------------------------------------------------+
