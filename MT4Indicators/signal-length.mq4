//+------------------------------------------------------------------+
//|                                                 signallength.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
extern color Color_resistance = Orange;
extern color Color_support     = Aqua;
extern int Set=4,
           time_set=10;
int X1u,X2u,X3u,X1d,X2d,X3d,bar_1u,bar_2u,bar_3u,bar_1d,bar_2d,bar_3d,time_period,
    X1g,X2g,per;
double Y1vg,Y2vg,Y1ng,Y2ng,Y1u,Y2u,Y3u,Y1d,Y2d,Y3d;
double channel_width;
extern bool delete_segments = true;//delete segments after the period change
#property indicator_chart_window
//+------------------------------------------------------------------+
int init()
{
   per=Period();
   return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete("Resistance line");
   ObjectDelete("Support line");
   del("Crossing ");
   if (delete_segments==true) del("border");
   return(0);
}
//+------------------------------------------------------------------+
int start()
{
   while(true)
   {
      if (time_period!=Time[0])
      {
         if (bar_3u != find_fractal(0, 1) || (ObjectFind("Resistance line")!=0))
         {
            bar_3u = find_fractal(0,     1);
            bar_2u = find_fractal(bar_3u,-1);
            bar_1u = find_fractal(bar_2u, 1);
            X1u=Time[bar_1u];Y1u=High[bar_1u];X2u=Time[bar_3u];Y2u=High[bar_3u];
            ObjectDelete("Resistance line");
            ObjectCreate("Resistance line", OBJ_TREND, 0,X1u,Y1u,X2u,Y2u);
            ObjectSet   ("Resistance line", OBJPROP_COLOR, Color_resistance);
            ObjectSet   ("Resistance line", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet   ("Resistance line", OBJPROP_WIDTH, 0);
            ObjectSet   ("Resistance line", OBJPROP_BACK,  true);
            ObjectSet   ("Resistance line", OBJPROP_RAY,   true);
            draw_borders(Color_resistance,X1u,Y1u,X2u,Y2u);
         }
         //-----------------------------------------------------------------------
         if (bar_3d != find_fractal(0,-1) || (ObjectFind("Support line")!=0))
         {
            bar_3d = find_fractal(0,    -1);
            bar_2d = find_fractal(bar_3d, 1);
            bar_1d = find_fractal(bar_2d,-1);
            X1d=Time[bar_1d];Y1d=Low[bar_1d];X2d=Time[bar_3d];Y2d=Low[bar_3d];
            ObjectDelete("Support line");
            ObjectCreate("Support line", OBJ_TREND, 0,X1d,Y1d,X2d,Y2d);
            ObjectSet   ("Support line", OBJPROP_COLOR, Color_support);
            ObjectSet   ("Support line", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet   ("Support line", OBJPROP_WIDTH, 0);
            ObjectSet   ("Support line", OBJPROP_BACK,  true);    
            ObjectSet   ("Support line", OBJPROP_RAY,   true);
            draw_borders(Color_support,X1d,Y1d,X2d,Y2d);
         }
         //-----------------------------------------------------------------------
         int d=0;
         int    X_1,X_2;
         double Y_1,Y_2;
         color COLOR;
         for(int n=ObjectsTotal()-1; n>=0; n--) 
         {
            string Obj_N=ObjectName(n);
            if (StringFind(Obj_N,"border",0)!=-1 && ObjectType(Obj_N)==OBJ_TREND)
            // we have found an object - trend for calculation of the approach
            {
               X_1 = ObjectGet(Obj_N, OBJPROP_TIME1); 
               X_2 = ObjectGet(Obj_N, OBJPROP_TIME2); 
               if (X_1==X_2) {ObjectDelete(Obj_N);continue;}
               Y_1 = ObjectGet(Obj_N, OBJPROP_PRICE1);
               Y_2 = ObjectGet(Obj_N, OBJPROP_PRICE2);
               COLOR= ObjectGet(Obj_N, OBJPROP_COLOR);
               // drawing the control zone (Obj_N, COLOR, X_1,Y_1,X_2,Y_2);
               if (X_1<=Time[0] && X_2>=Time[0])//it's in the time range
               {
                  X3d=Time[0];Y3d=Y_1+(Y_2-Y_1)*(X3d-X_1)/(X_2-X_1);// line equation
                  //Comment((Y3d-Bid)/Point);
                  if (MathAbs(Y3d-Bid)/Point < Set)
                  { 
                     if (COLOR==Color_resistance)//Lower border
                           {d=-1;break;}
                     else  {d= 1;break;}
                  }
               }
            }
         }
         //-----------------------------------------------------------------------
         if (d!=0)
         {
            ObjectCreate("Crossing "+Obj_N+" "+Time[0], OBJ_ARROW,0,Time[0],Bid,0,0,0,0);
            ObjectSet   ("Crossing "+Obj_N+" "+Time[0], OBJPROP_WIDTH, 0);
            if (d==1)
            {
               ObjectSet   ("Crossing "+Obj_N+" "+Time[0], OBJPROP_ARROWCODE,233);
               ObjectSet   ("Crossing "+Obj_N+" "+Time[0], OBJPROP_COLOR, Color_support);    // Color   
               Alert(Symbol()+"Crossing the border of support "+Obj_N);
            }
            else
            {
               ObjectSet   ("Crossing "+Obj_N+" "+Time[0], OBJPROP_ARROWCODE,234);
               ObjectSet   ("Crossing "+Obj_N+" "+Time[0], OBJPROP_COLOR, Color_resistance);    // Color
               Alert(Symbol()+"Crossing the border of resistance "+Obj_N);
            }
            time_period=Time[0];
         }
      }
      if ((ObjectFind("Lower border "+string_period(per))==0)&&(ObjectFind("Upper border "+string_period(per))==0)) 
         return(0);
      else 
      {
         ObjectDelete("Resistance line");
         ObjectDelete("Support line");
         time_period=Time[1];
      }
   }
}
//+------------------------------------------------------------------+
int find_fractal(int bar, int UP_DN)
{
   while(true)//looking for 1 fractal after bar
   {
      bar++;
      if (UP_DN == 1 && iFractals(NULL, 0, MODE_UPPER, bar) != 0) return(bar);
      if (UP_DN ==-1 && iFractals(NULL, 0, MODE_LOWER, bar) != 0) return(bar);
   } 
   return(0);  
}
//+------------------------------------------------------------------+
int del(string Ob)
{
   for(int n=ObjectsTotal()-1; n>=0; n--) 
   {
      string Obj_Name=ObjectName(n);
      if (StringFind(Obj_Name,Ob,0) != -1) ObjectDelete(Obj_Name);
   }
   return;
}
//+------------------------------------------------------------------+
string string_period(int p)
{  switch(p)
   {  case 1    : return("M_1"); break;  //1 min
      case 5    : return("M_5"); break;  //5 min
      case 15   : return("M15"); break; //15 min
      case 30   : return("M30"); break; //30 min
      case 60   : return("H 1"); break;  //1 hour
      case 240  : return("H_4"); break;  //4 hours
      case 1440 : return("D_1"); break;  //1 day
      case 10080: return("W_1"); break;  //1 week
      case 43200: return("MN1"); break; //1 month
   }return("period error");
}
//+------------------------------------------------------------------+
int draw_borders(color COLOR,int X1,double Y1,int X2,double Y2)
{
   string Name = "border "+string_period(per);
   if (COLOR==Color_resistance) Name = "Upper "+Name;
   if (COLOR==Color_support)     Name = "Lower " +Name;
   if (ObjectFind(Name)==0) return; //If the object exists
   X1g=Time[0];X2g=Time[0]+per*60*time_set;
   if (COLOR==Color_resistance) {Y1vg=Y1+(Y2-Y1)*(X1g-X1)/(X2-X1);Y2vg=Y1+(Y2-Y1)*(X2g-X1)/(X2-X1);
                                  ObjectCreate(Name, OBJ_TREND, 0,X1g,Y1vg,X2g,Y2vg);}
   if (COLOR==Color_support)     {Y1ng=Y1+(Y2-Y1)*(X1g-X1)/(X2-X1);Y2ng=Y1+(Y2-Y1)*(X2g-X1)/(X2-X1);
                                  ObjectCreate(Name, OBJ_TREND, 0,X1g,Y1ng,X2g,Y2ng);}
   ObjectSet   (Name, OBJPROP_COLOR, COLOR);
   ObjectSet   (Name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet   (Name, OBJPROP_WIDTH, 4);
   ObjectSet   (Name, OBJPROP_BACK,  false);
   ObjectSet   (Name, OBJPROP_RAY,   false);
   return;
}
//+------------------------------------------------------------------+

