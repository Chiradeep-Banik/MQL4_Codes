//+------------------------------------------------------------------+
//|                                  Standard Deviation Channels.mq4 |
//|                Copyright © 2006, tageiger, aka fxid10t@yahoo.com |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger, aka fxid10t@yahoo.com"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window

extern int STD.Rgres.period=0; /*default 0 means the channel will use the open 
                                 time from "x" bars back on which ever time period 
                                 the indicator is attached to.  one can change to 1,5,
                                 15,30,60...etc to "lock" the start time to a specific 
                                 period, and then view the "locked" channels on a different time period...*/

extern int STD.Rgres.length=56;     // bars back regression begins
extern double STD.Rgres.width=1.618;// widest channel
extern double STD.width=0.618;      // inside channel

int init()   { return(0);}
int deinit()   {
ObjectDelete("regression channel");ObjectDelete("std channel");return(0);}
int start()   {
//to refresh properly delete old objects...
   ObjectDelete("regression channel");ObjectDelete("std channel");
//widest channel   
   ObjectCreate("regression channel",OBJ_STDDEVCHANNEL,0,iTime(Symbol(),STD.Rgres.period,STD.Rgres.length),
               Close[STD.Rgres.length],Time[0],Close[0]);
   ObjectSet("regression channel",OBJPROP_DEVIATION,STD.Rgres.width);
   ObjectSet("regression channel",OBJPROP_COLOR,Orange);
   ObjectSet("regression channel",OBJPROP_RAY,true);
//inside channel
   ObjectCreate("std channel",OBJ_STDDEVCHANNEL,0,iTime(Symbol(),STD.Rgres.period,STD.Rgres.length),
               Close[STD.Rgres.length],Time[0],Close[0]);
   ObjectSet("std channel",OBJPROP_DEVIATION,STD.width);
   ObjectSet("std channel",OBJPROP_COLOR,Olive);
   ObjectSet("std channel",OBJPROP_RAY,true);

return(0);}//end start
//+------------------------------------------------------------------+