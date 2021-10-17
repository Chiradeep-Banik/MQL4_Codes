//+------------------------------------------------------------------+
//|                                                       Time_Table |
//|                                          Copyright 2016, Frostow |
//+------------------------------------------------------------------+
#property indicator_chart_window

input color Color=clrBlack;//text color
input int spread_x = -1;   // x of spread lable
input int spread_y = -1;   // y of spread lable
input int time_x = -1;     // x of time lable
input int time_y = -1;     // y of time lable
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   int width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

   int x_spread = 0;
   int y_spread = 0;
   int x_time = 0;
   int y_time = 0;

   if(spread_x>0 && spread_x<width)
      x_spread=spread_x;
   else
     {
      if(spread_x!=-1)
         Alert("spread_x - incorrect value");

      x_spread=width-210;
     }

   if(spread_y>0 && spread_y<height)
      y_spread=spread_y;
   else
     {
      if(spread_y!=-1)
         Alert("spread_y - incorrect value");

      y_spread=height-25;
     }

   if(time_x>0 && time_x<width)
      x_time=time_x;
   else
     {
      if(time_x!=-1)
         Alert("spread_x - incorrect value");

      x_time=width-145;
     }

   if(time_y>0 && time_y<height)
      y_time=time_y;
   else
     {
      if(time_y!=-1)
         Alert("spread_y - incorrect value");

      y_time=height-25;
     }

   ObjectCreate(0,"time_table",OBJ_LABEL,0,0,0);
   ObjectCreate(0,"spread",OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,"time_table",OBJPROP_XDISTANCE,x_time);
   ObjectSetInteger(0,"time_table",OBJPROP_YDISTANCE,y_time);

   ObjectSetInteger(0,"spread",OBJPROP_XDISTANCE,x_spread);
   ObjectSetInteger(0,"spread",OBJPROP_YDISTANCE,y_spread);

   ObjectSetInteger(0,"spread",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,"spread",OBJPROP_COLOR,Color);
   ObjectSetString(0,"spread",OBJPROP_TEXT,"SPREAD: "+MarketInfo(NULL,MODE_SPREAD));
   ObjectSetInteger(0,"spread",OBJPROP_BACK,false);
   ObjectSetInteger(0,"spread",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"spread",OBJPROP_SELECTABLE,false);

   ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: ");
   ObjectSetInteger(0,"time_table",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,"time_table",OBJPROP_COLOR,Color);
   ObjectSetInteger(0,"time_table",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"time_table",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"time_table",OBJPROP_BACK,false);

   EventSetMillisecondTimer(500);
   return 0;
  }
//+------------------------------------------------------------------+
//|Empty new tick function                                           |
//+------------------------------------------------------------------+
int start()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|On 0.5 second timer event                                           |
//+------------------------------------------------------------------+
void OnTimer()
  {
// seconds in 1 bar
   long tf=Period()*60;
// last server time
   long current_time=TimeCurrent();
// the time of ending current bar
   long time=iTime(NULL,0,0)+tf;

// the difference between current time and the time of the ending of this bar
   long dif=time-current_time;

   if(dif>=0)
     {
      // seconds
      if(dif<60)
        {
         ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+dif+"s");
        }
      // minutes and seconds
      if(dif>60 && dif<3600)
        {
         ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+
                         MathFloor(dif/60)+"m "+(dif-60*MathFloor(dif/60))+"s");
        }
      // hours and minutes and seconds
      if(dif>3600 && dif<=86400)
        {
         int h = MathFloor(dif / 3600);
         int m = MathFloor(dif / 60) - 60 * h;
         int s = dif - h * 3600 - 60 * m;

         if(h>0)
           {
            ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+h+"H "+m+"m "+s+"s");
           }
         else
           {
            if(m>0)
              {
               ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+m+"m "+s+"s");
              }
            else
              {
               ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+s+"s");
              }
           }
        }
      // days, hours and minutes
      if(dif>86400 && dif<=604800)
        {
         int d=MathFloor(dif/86400);
         h = MathFloor(dif / 3600) - 24 * d;
         m = MathFloor(dif / 60) - 1440 * d - 60 * h;
         s = dif - d * 86400 - h * 3600 - 60 * m;

         if(d>0)
           {
            ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+d+"D "+h+"H "+m+"m ");
           }
         else
           {
            if(h>0)
              {
               ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+h+"H "+m+"m "+s+"s");
              }
            else
              {
               if(m>0)
                 {
                  ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+m+"m "+s+"s");
                 }
               else
                 {
                  ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+s+"s");
                 }
              }
           }
        }
      // weeks, days and hours
      if(dif>604800)
        {
         int w=MathFloor(dif/604800);
         d = MathFloor(dif / 86400) - 7 * w;
         h = MathFloor(dif / 3600) - 24 * d - 168 * w;
         m = MathFloor(dif / 60) - 1440 * d - 60 * h - 10080 * w;
         s = dif - d * 86400 - h * 3600 - 60 * m - 604800 * w;

         if(w>0)
           {
            ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+w+"W "+d+"D "+h+"H ");
           }
         else
           {
            if(d>0)
              {
               ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+d+"D "+h+"H "+m+"m ");
              }
            else
              {
               if(h>0)
                 {
                  ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+h+"H "+m+"m "+s+"s");
                 }
               else
                 {
                  if(m>0)
                    {
                     ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+m+"m "+s+"s");
                    }
                  else
                    {
                     ObjectSetString(0,"time_table",OBJPROP_TEXT,"NEXT BAR IN: "+s+"s");
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Delete all used objects                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// deleting objects
   ObjectDelete(0,"time_table");
   ObjectDelete(0,"spread");
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| OnChartEvent function. Finding out if the chart was changed      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// if the chart's size was changed ==> change the position of labels
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      int height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
      int width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

      int x_spread = 0;
      int y_spread = 0;
      int x_time = 0;
      int y_time = 0;

      if(spread_x>0 && spread_x<width)
         x_spread=spread_x;
      else
        {
         if(spread_x!=-1)
            Alert("spread_x - incorrect value");

         x_spread=width-210;
        }

      if(spread_y>0 && spread_y<height)
         y_spread=spread_y;
      else
        {
         if(spread_y!=-1)
            Alert("spread_y - incorrect value");

         y_spread=height-25;
        }

      if(time_x>0 && time_x<width)
         x_time=time_x;
      else
        {
         if(time_x!=-1)
            Alert("spread_x - incorrect value");

         x_time=width-145;
        }

      if(time_y>0 && time_y<height)
         y_time=time_y;
      else
        {
         if(time_y!=-1)
            Alert("spread_y - incorrect value");

         y_time=height-25;
        }

      ObjectSetInteger(0,"time_table",OBJPROP_XDISTANCE,x_time);
      ObjectSetInteger(0,"time_table",OBJPROP_YDISTANCE,y_time);

      ObjectSetInteger(0,"spread",OBJPROP_XDISTANCE,x_spread);
      ObjectSetInteger(0,"spread",OBJPROP_YDISTANCE,y_spread);
     }
  }
//+------------------------------------------------------------------+
