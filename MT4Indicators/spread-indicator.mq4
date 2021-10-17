#property copyright ""
#property indicator_chart_window
extern bool BigDisplay = 1;
extern int   DisplaySize = 12;
extern color DisplayColor = Yellow;
extern int   Display_y   =10;
extern int   Display_x   =0;

int deinit(){Comment(""); ObjectDelete("sp"); return(0); }

int start()
   {
   double myPoint, Sp;
      
   if(Digits==5||Digits==3) {myPoint=Point*10;} else {myPoint=Point;}
   Sp=(Ask-Bid)/myPoint;
   Comment("Spread = ",Sp);
   if (BigDisplay)
      {
      Comment("");
      ObjectCreate("sp", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("sp","Spread = "+DoubleToStr(Sp,1),DisplaySize, "Arial Bold", DisplayColor);
      ObjectSet("sp", OBJPROP_CORNER, 0);
      ObjectSet("sp", OBJPROP_XDISTANCE, Display_x);
      ObjectSet("sp", OBJPROP_YDISTANCE, Display_y);       
      }
   return(0);
   }



   