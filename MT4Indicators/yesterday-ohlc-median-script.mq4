//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                  Yesterday_OHLCMedian_script.mq4 |
//|                                       Copyright © 2015, hapalkos |
//|                                                                  |
//|                                                       2007.02.02 |
//| to be used with Alerter EA by Tesla                              |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, hapalkos"

#property indicator_chart_window

string  HL_name1 = "Yesterday HIGH";      // Can be renamed to create a unique horizontal line.
string  HL_desc1 = "Alert_10";            // Alert_##    ## serves as a numerical set point for the Alerter EA by Tesla.
                                          // Set numerical value to desired distance from the horizontal line to receive alert.
color   HL_color1 = Red;
int     HL_style1 = 0;                    // STYLE:  0 - solid, 1 - dash, 2 - dot, 3 - dashdot, 4 - dashdotdot
int     HL_width1 = 2;                    // WIDTH:  1, 2, 3, 4, 5

string  HL_name2 = "Yesterday LOW";       
string  HL_desc2 = "Alert_10";         
color   HL_color2 = Blue;
int     HL_style2 = 0;                 
int     HL_width2 = 2;                 
 
string  HL_name3 = "Yesterday OPEN";       
string  HL_desc3 = "Alert_10";         
color   HL_color3 = Lime;
int     HL_style3 = 0;                 
int     HL_width3 = 3; 

string  HL_name4 = "Yesterday Close";       
string  HL_desc4 = "Alert_10";         
color   HL_color4 = Orange;
int     HL_style4 = 0;                 
int     HL_width4 = 3;                 
 
string  HL_name5 = "Yesterday MEDIAN";       
string  HL_desc5 = "Alert_10";         
color   HL_color5 = DarkBlue;
int     HL_style5 = 4;                 
int     HL_width5 = 1;      
        
int     iHr1 = 3600;       // one hour          Used to offset event time for visiual effect
int     iHr12 = 43200;     // twelve hours      Used to offset event time start for visual effect
   
double array_daily[3][6];

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
  
int start()
  {
      ObjectDelete(HL_name1);
      ObjectDelete(HL_name2);
      ObjectDelete(HL_name3);
      ObjectDelete(HL_name4);
      ObjectDelete(HL_name5);
  
      ArrayCopyRates(array_daily,Symbol(),PERIOD_D1);
      
      {
      datetime dtToday         = array_daily[0][0];
      double   dTodayOpen      = array_daily[0][1];
      datetime dtYesterday     = array_daily[1][0];
      double   dYesterdayHigh  = array_daily[1][3];
      double   dYesterdayLow   = array_daily[1][2];
      double   dYesterdayOpen  = array_daily[1][1];
      double   dYesterdayClose = array_daily[1][4];
      double   dYesterdayMedian = (dYesterdayHigh + dYesterdayLow)/2;
   
//----  
      {   
      DrawObjects(HL_name1,dtYesterday,dYesterdayHigh,TimeCurrent(),dYesterdayHigh,HL_color1,HL_style1,HL_width1,HL_desc1);
      DrawObjects(HL_name2,dtYesterday,dYesterdayLow,TimeCurrent(),dYesterdayLow,HL_color2,HL_style2,HL_width2,HL_desc2);
      DrawObjects(HL_name3,dtYesterday,dYesterdayOpen,TimeCurrent(),dYesterdayOpen,HL_color3,HL_style3,HL_width3,HL_desc3);
      DrawObjects(HL_name4,dtToday-iHr1,dYesterdayClose,TimeCurrent(),dYesterdayClose,HL_color4,HL_style4,HL_width4,HL_desc4);
      DrawObjects(HL_name5,dtToday-iHr12,dYesterdayMedian,TimeCurrent(),dYesterdayMedian,HL_color5,HL_style5,HL_width5,HL_desc5);      
      } 
    return(0);  
}
}
void DrawObjects(string sObjName,datetime dtTime1,double dPrice1,datetime dtTime2,double dPrice2,color HL_color,int HL_style,int HL_width, string sObjDesc)
   {
      ObjectCreate(sObjName,OBJ_TREND,0,dtTime1,dPrice1,dtTime2,dPrice2); 
      ObjectSet(sObjName,OBJPROP_COLOR,HL_color);
      ObjectSet(sObjName,OBJPROP_STYLE,HL_style);
      ObjectSet(sObjName,OBJPROP_WIDTH,HL_width);
      ObjectSetText(sObjName,sObjDesc,10,"Times New Roman",Black); 
   }
      
//+------------------------------------------------------------------+