//+------------------------------------------------------------------+
//|                                                     Trend Friend |
//|                                                      TF_1.01.mq4 |
//|                                       Copyright © 2008 Tom Balfe |
//|                                                                  |
//| This is a trend indicator that gives you three signals on        |
//| multiple timeframes. It bases it's recommendations on short and  |
//| long moving averages and MACD.                                   |
//|                                                                  |
//| Version: 1.01                                                    |
//|                                                                  |
//| Changelog:                                                       |
//|                                                                  |
//|    1.01  - fixed arrows stuff                                    |
//|    1.00  - first version,unreleased, incomplete                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008 Tom Balfe"
#property link      ""
#property indicator_separate_window

//--- spacing
int     scaleX=120,scaleY=20,offsetX=200,offsetY=4,fontSize=8;
//--- arrays for various things
int     TF[]              = {1,5,15,30,60,240};
string  periodStr[]       = {"1 MIN:","5 MIN:","15 MIN:","30 MIN:","1 HR:","4 HR:"};
string  signalNameStr[]   = {"MACD","EMA Set1","EMA Set2"};

//+------------------------------------------------------------------+
//| USER ADJUSTABLE STUFF                                            |
//+------------------------------------------------------------------+

extern  string  MACD_Settings         = "=== MACD Settings ===";
extern  int     FastEMA               = 12;
extern  int     SlowEMA               = 24;
extern  int     MACDsp                = 6;

extern  string  EMA_Settings          = "=== MA Settings ===";
extern  int     shortP1               = 7;
extern  int     shortP2               = 14;
extern  int     longP1                = 34;
extern  int     longP2                = 72;

extern  string  My_Symbols            = "=== Wingdings Symbols ===";
extern  int     sBuy                  = 233;
extern  int     sSell                 = 234;
extern  int     sWait                 = 54;

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()
  {
    //-- indicator short name
    IndicatorShortName("Trend Friend 1.01 ");

    return(0);
  }
//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit()
  {
   //-- need to delete objects should user remove indicator
   ObjectsDeleteAll(0,OBJ_LABEL);
   
    //-- delete timeframe text labels   
    for(int x=0;x<6;x++)
      for (int y=0;y<3;y++)
      { ObjectDelete("textTF"+x+y); } 
    
    //-- delete indicator text labels
    for(y=0;y<3;y++)
      { ObjectDelete("textLab"+y); }       
    
    //-- delete indicator arrows
    for (x=0;x<6;x++)
      for (y=0;y<3;y++)
      { ObjectDelete("doubleArr"+x+y); }
    
    //-- delete indicator text      
    for (x=0;x<6;x++)
      for (y=0;y<3;y++)   
      { ObjectDelete("textInd"+x+y); } 
   
   return(0);
  }

//+------------------------------------------------------------------+
//| MAIN LOOP                                                        |
//+------------------------------------------------------------------+

int start()
  {
    //--- create timeframe text labels 
    for (int x=0;x<6;x++)
      for (int y=0;y<3;y++)
      {
        ObjectCreate("textTF"+x+y,OBJ_LABEL,WindowFind("Trend Friend 1.01 "),0,0);
        ObjectSetText("textTF"+x+y,periodStr[x],fontSize,"Arial Bold",LightSteelBlue);
        ObjectSet("textTF"+x+y,OBJPROP_CORNER,0);
        ObjectSet("textTF"+x+y,OBJPROP_XDISTANCE,x*scaleX+offsetX);
        ObjectSet("textTF"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create indicator text labels
    for (y=0;y<3;y++)
      {
        ObjectCreate("textLab"+y,OBJ_LABEL,WindowFind("Trend Friend 1.01 "),0,0);
        ObjectSetText("textLab"+y,signalNameStr[y],fontSize,"Arial Bold",PaleGoldenrod);
        ObjectSet("textLab"+y,OBJPROP_CORNER,0);
        ObjectSet("textLab"+y,OBJPROP_XDISTANCE,offsetX-65);
        ObjectSet("textLab"+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create blanks for arrows
    for (x=0;x<6;x++)
      for (y=0;y<3;y++)
      {
        ObjectCreate("doubleArr"+x+y,OBJ_LABEL,WindowFind("Trend Friend 1.01 "),0,0);
          ObjectSetText("doubleArr"+x+y," ",10,"Wingdings",Goldenrod);
          ObjectSet("doubleArr"+x+y,OBJPROP_CORNER,0);
          ObjectSet("doubleArr"+x+y,OBJPROP_XDISTANCE,x*scaleX+(offsetX+80)); // scaleX == 120, offsetX == 200
          ObjectSet("doubleArr"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create blanks for text
    for (x=0;x<6;x++)
      for (y=0;y<3;y++)
      {
        ObjectCreate("textInd"+x+y,OBJ_LABEL,WindowFind("Trend Friend 1.01 "),0,0);
          ObjectSetText("textInd"+x+y,"    ",9,"Arial Bold",Goldenrod);
          ObjectSet("textInd"+x+y,OBJPROP_CORNER,0);
          ObjectSet("textInd"+x+y,OBJPROP_XDISTANCE,x*scaleX+(offsetX+45)); // scaleX == 120, offsetX == 200
          ObjectSet("textInd"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- MACD arrows
    for(x=0;x<6;x++)
    {
      if ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0))>0) { // macd above zero
        if ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0)) >
            (iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_SIGNAL,0)))
          ObjectSetText("doubleArr"+x+"0",CharToStr(sBuy),fontSize,"Wingdings",Lime);
        else if 
           ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0)) <
            (iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_SIGNAL,0)))
          ObjectSetText("doubleArr"+x+"0",CharToStr(sSell),fontSize,"Wingdings",Red); 
        else
          ObjectSetText("doubleArr"+x+"0",CharToStr(sWait),fontSize,"Wingdings",Khaki);  
        }
      
      else if ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0))<0) { // macd below zero
        if ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0)) <
            (iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_SIGNAL,0)))
          ObjectSetText("doubleArr"+x+"0",CharToStr(sSell),fontSize,"Wingdings",Red);
        else if
           ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0)) > 
             (iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_SIGNAL,0)))
          ObjectSetText("doubleArr"+x+"0",CharToStr(sBuy),fontSize,"Wingdings",Lime);
        else
          ObjectSetText("doubleArr"+x+"0",CharToStr(sWait),fontSize,"Wingdings",Khaki);   
      }
    } 
    
    //--- MACD text
    for(x=0;x<6;x++)
    {
      if ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0))>0) { // macd above zero
        if ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0)) >
            (iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_SIGNAL,0)))  
          ObjectSetText("textInd"+x+"0"," BUY",9,"Arial Bold",Lime);  
        else if  
           ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0)) < 
            (iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_SIGNAL,0)))
          ObjectSetText("textInd"+x+"0","SELL",9,"Arial Bold",Red);
        else  
          ObjectSetText("textInd"+x+"0","WAIT",9,"Arial Bold",Khaki);
        }
            
      else if ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0))<0) { // macd below zero    
        if ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0)) <
            (iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_SIGNAL,0)))    
          ObjectSetText("textInd"+x+"0","SELL",9,"Arial Bold",Red);  
        else if
           ((iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_MAIN,0)) > 
            (iMACD(NULL,TF[x],FastEMA,SlowEMA,MACDsp,0,MODE_SIGNAL,0)))
          ObjectSetText("textInd"+x+"0"," BUY",9,"Arial Bold",Lime);
        else  
          ObjectSetText("textInd"+x+"0","WAIT",9,"Arial Bold",Khaki);
      }
    }
    
    //--- MA Set1 arrows
    for(x=0;x<6;x++)
    {
      if ((iMA(NULL,TF[x],shortP1,0,MODE_EMA,PRICE_CLOSE,0)) >
          (iMA(NULL,TF[x],shortP2,0,MODE_EMA,PRICE_CLOSE,0)))
        ObjectSetText("doubleArr"+x+"1",CharToStr(sBuy),fontSize,"Wingdings",Lime);
      else if ((iMA(NULL,TF[x],shortP1,0,MODE_EMA,PRICE_CLOSE,0)) <
          (iMA(NULL,TF[x],shortP2,0,MODE_EMA,PRICE_CLOSE,0)))
        ObjectSetText("doubleArr"+x+"1",CharToStr(sSell),fontSize,"Wingdings",Red);    
      else 
        ObjectSetText("doubleArr"+x+"1",CharToStr(sWait),fontSize,"Wingdings",Khaki);  
    }
    
    //--- MA Set1 text
    for(x=0;x<6;x++)
    {
      if ((iMA(NULL,TF[x],shortP1,0,MODE_EMA,PRICE_CLOSE,0)) >
          (iMA(NULL,TF[x],shortP2,0,MODE_EMA,PRICE_CLOSE,0)))
        ObjectSetText("textInd"+x+"1"," BUY",9,"Arial Bold",Lime);  
      else if ((iMA(NULL,TF[x],shortP1,0,MODE_EMA,PRICE_CLOSE,0)) <
          (iMA(NULL,TF[x],shortP2,0,MODE_EMA,PRICE_CLOSE,0)))
        ObjectSetText("textInd"+x+"1","SELL",9,"Arial Bold",Red);  
      else
        ObjectSetText("textInd"+x+"1","WAIT",9,"Arial Bold",Khaki);
    }
    
    //--- MA Set2 arrows
    for(x=0;x<6;x++)
    {
      if ((iMA(NULL,TF[x],longP1,0,MODE_EMA,PRICE_CLOSE,0)) >
          (iMA(NULL,TF[x],longP2,0,MODE_EMA,PRICE_CLOSE,0)))
        ObjectSetText("doubleArr"+x+"2",CharToStr(sBuy),fontSize,"Wingdings",Lime);
      else if ((iMA(NULL,TF[x],longP1,0,MODE_EMA,PRICE_CLOSE,0)) <
          (iMA(NULL,TF[x],longP2,0,MODE_EMA,PRICE_CLOSE,0)))
        ObjectSetText("doubleArr"+x+"2",CharToStr(sSell),fontSize,"Wingdings",Red);    
      else 
        ObjectSetText("doubleArr"+x+"2",CharToStr(sWait),fontSize,"Wingdings",Khaki);  
    }
   
    //--- MA Set2 text
    for(x=0;x<6;x++)
    {
      if ((iMA(NULL,TF[x],longP1,0,MODE_EMA,PRICE_CLOSE,0)) >
          (iMA(NULL,TF[x],longP2,0,MODE_EMA,PRICE_CLOSE,0)))
        ObjectSetText("textInd"+x+"2"," BUY",9,"Arial Bold",Lime);  
      else if ((iMA(NULL,TF[x],longP1,0,MODE_EMA,PRICE_CLOSE,0)) <
          (iMA(NULL,TF[x],longP2,0,MODE_EMA,PRICE_CLOSE,0)))
        ObjectSetText("textInd"+x+"2","SELL",9,"Arial Bold",Red);  
      else
        ObjectSetText("textInd"+x+"2","WAIT",9,"Arial Bold",Khaki);
    }   
         
  return(0);
  }
  //+------------------------------------------------------------------+
  //| END MAIN LOOP                                                    |
  //+------------------------------------------------------------------+
   