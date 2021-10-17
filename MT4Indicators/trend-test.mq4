//+------------------------------------------------------------------+
//|                                                   Trend_Test.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int i;
//--- indicator buffers mapping
//--- create a text label on the chart
   if(!LabelCreate(0,"label_trend",0,105,70,CORNER_RIGHT_UPPER,"Trend :","Arial",12, clrGray,0,ANCHOR_RIGHT,false,false,true,0)) return(INIT_SUCCEEDED);
//if(!LabelCreate(0,"trend",0,90,70,CORNER_RIGHT_UPPER,"UP","Arial",12, clrLightGreen,0,ANCHOR_LEFT,false,false,true,0)) return(INIT_SUCCEEDED);
   for(i=0;i<=15;i++) 
     {
      LabelCreate(0,"STrend"+IntegerToString(i),0,100-(i*5),70,CORNER_RIGHT_UPPER,"I","Impact",12,clrRed,0,ANCHOR_LEFT,false,false,false,0);
      //LabelCreate(0,"STrend1",0,91,70,CORNER_RIGHT_UPPER,"I","Impact",12, clrRed,0,ANCHOR_LEFT,false,false,false,0);
     }

//--- redraw the chart and wait for half a second
   ChartRedraw();
   Sleep(500);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit()
  {
   int i;
//---- 
   LabelDelete(0,"label_trend");
   for(i=0;i<=15;i++) 
     {
      LabelDelete(0,"STrend"+IntegerToString(i));
      //LabelDelete(0,"STrend1");
     }
//---- 
   ChartRedraw();
   Sleep(500);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
//Declare
   int i;
   double ema200cur;

//if(Volume[0]>1) return(0);
//Print("TF()=", TF());
   ema200cur=iMA(NULL,TF(),200,0,MODE_EMA,PRICE_CLOSE,0);
   for(i=1;i<=16;i++) 
     {
      if(ema200cur>iMA(NULL,TF(),200,0,MODE_EMA,PRICE_CLOSE,i+2))
        {
         if(!LabelTextChange(0,"STrend"+IntegerToString(i-1),"I","Impact",12,clrLime)) return;
           }else{
         if(!LabelTextChange(0,"STrend"+IntegerToString(i-1),"I","Impact",12,clrRed)) return;
        }

      ema200cur=iMA(NULL,TF(),200,0,MODE_EMA,PRICE_CLOSE,i+2);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool LabelTextChange(const long   chart_ID=0,   // chart's ID
                     const string name="Label", // object name
                     const string text="Text",
                     const string font="Impact",
                     const int    font_size=12,
                     const color  clr=clrGreen) // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetText(name,text,font_size,font,clr))
     {
      Print(__FUNCTION__,
            ": failed to change the text and Color! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete a text label                                              |
//+------------------------------------------------------------------+
bool LabelDelete(const long   chart_ID=0,   // chart's ID
                 const string name="Label") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TF()
  {
   int nextTF;
   switch(Period())
     {
      case PERIOD_M1 : nextTF=PERIOD_M5;    break;
      case PERIOD_M5 : nextTF=PERIOD_M15;   break;
      case PERIOD_M15: nextTF=PERIOD_M30;   break;
      case PERIOD_M30: nextTF=PERIOD_H1;    break;
      case PERIOD_H12: nextTF=PERIOD_H4;    break;
      case PERIOD_H4 : nextTF=PERIOD_D1;    break;
      default: nextTF=PERIOD_CURRENT;
     }

   return nextTF;
  }
//+------------------------------------------------------------------+
