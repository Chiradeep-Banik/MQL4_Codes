//+------------------------------------------------------------------+
//|                                          DK Stochastic Indicator |
//|                                      DK Stochastic Indicator.mq4 |
//|                                       Copyright © 2009 Neels     |
//|                                                                  |
//| Version: 1.00                                                    |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Neels"
#property link      ""
#property indicator_separate_window

int scaleX=120,scaleY=20,offsetX=200,offsetY=3,fontSize=8;
int period[]={1,5,15,30,60,240,1440};
string periodStr[]={"M1:","M5:","M15:","M30:","H1:","H4:"};
string signalNameStr[]={"Stoch 1:","Stoch 2:","Stoch 3:"};

//+------------------------------------------------------------------+
//| USER ADJUSTABLE                                                  |
//+------------------------------------------------------------------+
extern  string  Stochastic1_Settings   = "*** Stochastic 1 Settings ***";
extern  int     PercentK1              = 4;
extern  int     PercentD1              = 3;
extern  int     Slowing1               = 3;
extern  string  Stochastic2_Settings   = "*** Stochastic 2 Settings ***";
extern  int     PercentK2              = 21;
extern  int     PercentD2              = 3;
extern  int     Slowing2               = 3;
extern  string  Stochastic3_Settings   = "*** Stochastic 3 Settings ***";
extern  int     PercentK3              = 89;
extern  int     PercentD3              = 3;
extern  int     Slowing3               = 3;

string  My_Symbols            = "*** Misc Symbols ***";
int     UP                    = 233;
int     DOWN                  = 234;
int     FLAT                  = 54;

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()
  {
    //-- indicator short name
    IndicatorShortName("DK Stochastic Indicator");

    return(0);
  }
//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit()
  {
   //-- needed to delete objects should user remove indicator
   ObjectsDeleteAll(0,OBJ_LABEL);
    //-- delete timeframe text labels   
    for(int x=0;x<6;x++)
      for (int y=0;y<3;y++)
      { ObjectDelete("tPs"+x+y); } 
    //-- delete indicator readouts
    for (x=0;x<6;x++)
      for (y=0;y<3;y++)
      { ObjectDelete("dI"+x+y); }
    //-- delete indicator text labels
    for(y=0;y<3;y++)
      { ObjectDelete("tInd"+y); }             
    for (x=0;x<6;x++)
      for (y=0;y<4;y++)   
      { ObjectDelete("tI"+x+y); } 
   
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
        ObjectCreate("tPs"+x+y,OBJ_LABEL,WindowFind("DK Stochastic Indicator"),0,0);
        ObjectSetText("tPs"+x+y,periodStr[x],fontSize,"Arial Bold",LightSteelBlue);
        ObjectSet("tPs"+x+y,OBJPROP_CORNER,0);
        ObjectSet("tPs"+x+y,OBJPROP_XDISTANCE,x*scaleX+offsetX);
        ObjectSet("tPs"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create indicator text labels
    for (y=0;y<3;y++)
      {
        ObjectCreate("tInd"+y,OBJ_LABEL,WindowFind("DK Stochastic Indicator"),0,0);
        ObjectSetText("tInd"+y,signalNameStr[y],fontSize,"Arial Bold",PaleGoldenrod);
        ObjectSet("tInd"+y,OBJPROP_CORNER,0);
        ObjectSet("tInd"+y,OBJPROP_XDISTANCE,offsetX-55);
        ObjectSet("tInd"+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create blanks for arrows
    for (x=0;x<6;x++)
      for (y=0;y<3;y++)
      {
        ObjectCreate("dI"+x+y,OBJ_LABEL,WindowFind("DK Stochastic Indicator"),0,0);
          ObjectSetText("dI"+x+y," ",9,"Wingdings",Goldenrod);
          ObjectSet("dI"+x+y,OBJPROP_CORNER,0);
          ObjectSet("dI"+x+y,OBJPROP_XDISTANCE,x*scaleX+(offsetX+80)); // scaleX == 120, offsetX == 200
          ObjectSet("dI"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create blanks for text
    for (x=0;x<6;x++)
      for (y=0;y<3;y++)
      {
        ObjectCreate("tI"+x+y,OBJ_LABEL,WindowFind("DK Stochastic Indicator"),0,0);
          ObjectSetText("tI"+x+y,"TEST",9,"Arial Bold",Goldenrod);
          ObjectSet("tI"+x+y,OBJPROP_CORNER,0);
          ObjectSet("tI"+x+y,OBJPROP_XDISTANCE,x*scaleX+(offsetX+45)); // scaleX == 120, offsetX == 200
          ObjectSet("tI"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- Stoch 1 arrows
    for(x=0;x<6;x++)
    {
      if((iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,0,MODE_MAIN,0)) >  
         (iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,0,MODE_SIGNAL,0)))
        ObjectSetText("dI"+x+"0",CharToStr(UP),fontSize,"Wingdings",Lime);
      else if             
        ((iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,0,MODE_SIGNAL,0)) >
        (iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,0,MODE_MAIN,0)))
        ObjectSetText("dI"+x+"0",CharToStr(DOWN),fontSize,"Wingdings",Red);         
      else
        ObjectSetText("dI"+x+"0",CharToStr(FLAT),10,"Wingdings",Khaki); 
    }
    
    //--- Stoch 1 text
    double Stoch1_Val;
    for(x=0;x<6;x++)
    {
      Stoch1_Val = (iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,1,MODE_MAIN,0));
      ObjectSetText("tI"+x+"0", DoubleToStr(Stoch1_Val, 2),9,"Arial Bold",Gold);
    }    
        
    //--- Stoch 2 arrows
    for(x=0;x<6;x++)
    {
      if((iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,0,MODE_MAIN,0)) >  
         (iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,0,MODE_SIGNAL,0)))
        ObjectSetText("dI"+x+"1",CharToStr(UP),fontSize,"Wingdings",Lime);
      else if             
        ((iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,0,MODE_SIGNAL,0)) >
        (iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,0,MODE_MAIN,0)))
        ObjectSetText("dI"+x+"1",CharToStr(DOWN),fontSize,"Wingdings",Red);         
      else
        ObjectSetText("dI"+x+"1",CharToStr(FLAT),10,"Wingdings",Khaki); 
    }
    
    //--- Stoch 2 text
    double Stoch2_Val;
    for(x=0;x<6;x++)
    {
      Stoch2_Val = (iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,1,MODE_MAIN,0));
      ObjectSetText("tI"+x+"1", DoubleToStr(Stoch2_Val, 2),9,"Arial Bold",Gold); 
    }   

    //--- Stoch 3 arrows
    for(x=0;x<6;x++)
    {
      if((iStochastic(NULL,period[x],PercentK3,PercentD3,Slowing3,MODE_EMA,0,MODE_MAIN,0)) >  
         (iStochastic(NULL,period[x],PercentK3,PercentD3,Slowing3,MODE_EMA,0,MODE_SIGNAL,0)))
        ObjectSetText("dI"+x+"2",CharToStr(UP),fontSize,"Wingdings",Lime);
      else if             
        ((iStochastic(NULL,period[x],PercentK3,PercentD3,Slowing3,MODE_EMA,0,MODE_SIGNAL,0)) >
        (iStochastic(NULL,period[x],PercentK3,PercentD3,Slowing3,MODE_EMA,0,MODE_MAIN,0)))
        ObjectSetText("dI"+x+"2",CharToStr(DOWN),fontSize,"Wingdings",Red);         
      else
        ObjectSetText("dI"+x+"2",CharToStr(FLAT),10,"Wingdings",Khaki); 
    }
    
    //--- Stoch 3 text
    double Stoch3_Val;
    for(x=0;x<6;x++)
    {
      Stoch3_Val = (iStochastic(NULL,period[x],PercentK3,PercentD3,Slowing3,MODE_EMA,1,MODE_MAIN,0));
      ObjectSetText("tI"+x+"2", DoubleToStr(Stoch3_Val, 2),9,"Arial Bold",Gold);
    }    
   
        
        
  return(0);
  }
  //+------------------------------------------------------------------+
  //| END MAIN LOOP                                                    |
  //+------------------------------------------------------------------+

   