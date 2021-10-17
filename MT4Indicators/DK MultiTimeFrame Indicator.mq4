//+------------------------------------------------------------------+
//|                                      DK MultiTimeFrame Indicator |
//|                                  DK MultiTimeFrame Indicator.mq4 |
//|                                       Copyright © 2009 Neels     |
//|                                                                  |
//| Version: 1.00                                                    |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Neels"
#property link      ""
#property indicator_separate_window

int scaleX=120,scaleY=20,offsetX=200,offsetY=4,fontSize=10;
int period[]={1,5,15,30,60,240};
string periodStr[]={"M1:","M5:","M15:","M30:","H1:","H4:"};
string signalNameStr[]={"Stoch(4,3,3):","Stoch(21,3,3):","FastMACross:","SlowMACross:","MACD(2,10,4):","Ac\Dc:","ADX(8):","CCI(14):","RSI(9):","PSAR(0.04,0.2):",};

//+------------------------------------------------------------------+
//| USER ADJUSTABLE                                                  |
//+------------------------------------------------------------------+
string  Stochastic1_Settings   = "*** Stochastic 1 Settings ***";
int     PercentK1              = 4;
int     PercentD1              = 3;
int     Slowing1               = 3;

string  Stochastic2_Settings   = "*** Stochastic 2 Settings ***";
int     PercentK2              = 21;
int     PercentD2              = 3;
int     Slowing2               = 3;

string  FastMACross_Settings   = "*** FastMACross Settings ***";
int     Fast_LWMA              = 1;
int     Slow_LWMA              = 4;

string  SlowMACross_Settings   = "*** SlowMACross Settings ***";
int     Fast_LWMA1             = 10;
int     Slow_SMA1              = 10;

string  AcDc                  = "*** Acceleration\Deceleration ***";

string  ADX                    = "*** ADX***";
int     ADXperiod              = 8;

string  CCI_Settings           = "*** CCI Settings ***";
int     Period_CCI             = 14;

string  RSI_Settings           = "*** RSI Settings ***";
int     Period_RSI             = 9;

string  ParabolicSAR_Settings  = "*** Parabolic SAR Settings ***";
double  SAR_Step               = 0.04;
double  SAR_Max                = 0.2;

string  My_Symbols            = "*** Misc Symbols ***";
int     UP                    = 233;
int     DOWN                  = 234;
int     FLAT                  = 232;
int     TrendUP               = 236;
int     TrendDOWN             = 238;

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()
  {
    //-- indicator short name
    IndicatorShortName("DK Multi Indicator");

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
      for (int y=0;y<10;y++)
      { ObjectDelete("tPs1"+x+y); } 
    //-- delete indicator readouts
    for (x=0;x<6;x++)
      for (y=0;y<10;y++)
      { ObjectDelete("dI1"+x+y); }
    //-- delete indicator text labels
    for(y=0;y<10;y++)
      { ObjectDelete("tInd1"+y); }             
    for (x=0;x<6;x++)
      for (y=0;y<10;y++)   
      { ObjectDelete("tI1"+x+y); } 
   
   return(0);
  }

//+------------------------------------------------------------------+
//| MAIN LOOP                                                        |
//+------------------------------------------------------------------+

int start()
  {
    //--- create timeframe text labels 
    for (int x=0;x<6;x++)
      for (int y=0;y<10;y++)
      {
        ObjectCreate("tPs1"+x+y,OBJ_LABEL,WindowFind("DK Multi Indicator"),0,0);
        ObjectSetText("tPs1"+x+y,periodStr[x],fontSize,"Arial Bold",SteelBlue);
        ObjectSet("tPs1"+x+y,OBJPROP_CORNER,0);
        ObjectSet("tPs1"+x+y,OBJPROP_XDISTANCE,x*scaleX+offsetX);
        ObjectSet("tPs1"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create indicator text labels
    for (y=0;y<10;y++)
      {
        ObjectCreate("tInd1"+y,OBJ_LABEL,WindowFind("DK Multi Indicator"),0,0);
        ObjectSetText("tInd1"+y,signalNameStr[y],fontSize,"Arial Bold",OrangeRed);
        ObjectSet("tInd1"+y,OBJPROP_CORNER,0);
        ObjectSet("tInd1"+y,OBJPROP_XDISTANCE,offsetX-95);
        ObjectSet("tInd1"+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create blanks for arrows
    for (x=0;x<6;x++)
      for (y=0;y<10;y++)
      {
        ObjectCreate("dI1"+x+y,OBJ_LABEL,WindowFind("DK Multi Indicator"),0,0);
          ObjectSetText("dI1"+x+y," ",10,"Wingdings",Goldenrod);
          ObjectSet("dI1"+x+y,OBJPROP_CORNER,0);
          ObjectSet("dI1"+x+y,OBJPROP_XDISTANCE,x*scaleX+(offsetX+90)); // scaleX == 120, offsetX == 200
          ObjectSet("dI1"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
    
    //--- create blanks for text
    for (x=0;x<6;x++)
      for (y=0;y<10;y++)
      {
        ObjectCreate("tI1"+x+y,OBJ_LABEL,WindowFind("DK Multi Indicator"),0,0);
          ObjectSetText("tI1"+x+y,"HELP",10,"Arial Bold",Goldenrod);
          ObjectSet("tI1"+x+y,OBJPROP_CORNER,0);
          ObjectSet("tI1"+x+y,OBJPROP_XDISTANCE,x*scaleX+(offsetX+45)); // scaleX == 120, offsetX == 200
          ObjectSet("tI1"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
      }
//==============================================================================================
    //--- Stoch 1 arrows
    //==================
    for(x=0;x<6;x++)
    {
      if((iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,1,MODE_MAIN,0)) >  
         (iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,1,MODE_SIGNAL,0)))
        ObjectSetText("dI1"+x+"0",CharToStr(UP),fontSize,"Wingdings",Lime);
      else if             
        ((iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,1,MODE_SIGNAL,0)) >
        (iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,1,MODE_MAIN,0)))
        ObjectSetText("dI1"+x+"0",CharToStr(DOWN),fontSize,"Wingdings",Red);         
      else
        ObjectSetText("dI1"+x+"0",CharToStr(FLAT),10,"Wingdings",Gray); 
    }
    
    //--- Stoch 1 text
    //================
    double Stoch1_Val;
    for(x=0;x<6;x++)
    {
      Stoch1_Val = (iStochastic(NULL,period[x],PercentK1,PercentD1,Slowing1,MODE_EMA,1,MODE_MAIN,0));
      if(Stoch1_Val < 20 || Stoch1_Val >80)
      {
      ObjectSetText("tI1"+x+"0", DoubleToStr(Stoch1_Val, 2),10,"Arial Bold",DeepPink);
      }
      else
      {
      ObjectSetText("tI1"+x+"0", DoubleToStr(Stoch1_Val, 2),10,"Arial Bold",Gold);
      }
    }    
//=============================================================================================        
    //--- Stoch 2 arrows
    //==================
    for(x=0;x<6;x++)
    {
      if((iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,1,MODE_MAIN,0)) >  
         (iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,1,MODE_SIGNAL,0)))
        ObjectSetText("dI1"+x+"1",CharToStr(UP),fontSize,"Wingdings",Lime);
      else if             
        ((iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,1,MODE_SIGNAL,0)) >
        (iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,1,MODE_MAIN,0)))
        ObjectSetText("dI1"+x+"1",CharToStr(DOWN),fontSize,"Wingdings",Red);         
      else
        ObjectSetText("dI1"+x+"1",CharToStr(FLAT),10,"Wingdings",Gray); 
    }
    
    //--- Stoch 2 text
    //================
    double Stoch2_Val;
    for(x=0;x<6;x++)
    {
      Stoch2_Val = (iStochastic(NULL,period[x],PercentK2,PercentD2,Slowing2,MODE_EMA,1,MODE_MAIN,0));
      if(Stoch2_Val < 20 || Stoch2_Val >80)
      {
      ObjectSetText("tI1"+x+"1", DoubleToStr(Stoch2_Val, 2),10,"Arial Bold",DeepPink); 
      }
      else
      {
      ObjectSetText("tI1"+x+"1", DoubleToStr(Stoch2_Val, 2),10,"Arial Bold",Gold); 
      } 
    }   


//+------------------------------------------------------------------+
//| FastMA Crossing                                                  |
//+------------------------------------------------------------------+
//--- MA text
for(x=0;x<6;x++)
 {
   int iMOV = 0;
   if(iMA(NULL, period[x], Fast_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV) > 
      iMA(NULL, period[x], Slow_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV)) 
     {
         while(iMA(NULL, period[x], Fast_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV) > 
               iMA(NULL, period[x], Slow_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV))
       {
           iMOV++;
           ObjectSetText("tI1"+x+"2", DoubleToStr(iMOV, 0),10,"Arial Bold",Gold);
       }
     }
   else 
     {
        while(iMA(NULL, period[x], Fast_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV) <= 
               iMA(NULL, period[x], Slow_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV))
       {
           iMOV++;
           ObjectSetText("tI1"+x+"2", DoubleToStr(iMOV, 0),10,"Arial Bold",Gold);
       }
     }
 }
//--- MA arrows
for(x=0;x<6;x++)
 {
   int iMOV1 = 0;
   if(iMA(NULL, period[x], Fast_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV1) > 
      iMA(NULL, period[x], Slow_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV1)) 
     {
         while(iMA(NULL, period[x], Fast_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV1) > 
               iMA(NULL, period[x], Slow_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV1))
       {
           iMOV1++;
           ObjectSetText("dI1"+x+"2", CharToStr(UP),10,"Wingdings",Lime);
       }
     }
   else 
     {
        while(iMA(NULL, period[x], Fast_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV1) <= 
               iMA(NULL, period[x], Slow_LWMA, 0, MODE_LWMA, PRICE_CLOSE, iMOV1))
       {
           iMOV1++;
           ObjectSetText("dI1"+x+"2", CharToStr(DOWN),10,"Wingdings",Red);
       }
     }
 }
 
//+------------------------------------------------------------------+
//| SlowMA Crossing                                                  |
//+------------------------------------------------------------------+
//--- MA text
for(x=0;x<6;x++)
 {
   int iiMOV = 0;
   if(iMA(NULL, period[x], Fast_LWMA1, 0, MODE_LWMA, PRICE_CLOSE, iiMOV) > 
      iMA(NULL, period[x], Slow_SMA1, 0, MODE_SMA, PRICE_CLOSE, iiMOV)) 
     {
         while(iMA(NULL, period[x], Fast_LWMA1, 0, MODE_LWMA, PRICE_CLOSE, iiMOV) > 
               iMA(NULL, period[x], Slow_SMA1, 0, MODE_SMA, PRICE_CLOSE, iiMOV))
       {
           iiMOV++;
           ObjectSetText("tI1"+x+"3", DoubleToStr(iiMOV, 0),10,"Arial Bold",Gold);
       }
     }
   else 
     {
        while(iMA(NULL, period[x], Fast_LWMA1, 0, MODE_LWMA, PRICE_CLOSE, iiMOV) <= 
               iMA(NULL, period[x], Slow_SMA1, 0, MODE_SMA, PRICE_CLOSE, iiMOV))
       {
           iiMOV++;
           ObjectSetText("tI1"+x+"3", DoubleToStr(iiMOV, 0),10,"Arial Bold",Gold);
       }
     }
 }
//--- MA arrows
for(x=0;x<6;x++)
 {
   int iiMOV1 = 0;
   if(iMA(NULL, period[x], Fast_LWMA1, 0, MODE_LWMA, PRICE_CLOSE, iiMOV1) > 
      iMA(NULL, period[x], Slow_SMA1, 0, MODE_SMA, PRICE_CLOSE, iiMOV1)) 
     {
         while(iMA(NULL, period[x], Fast_LWMA1, 0, MODE_LWMA, PRICE_CLOSE, iiMOV1) > 
               iMA(NULL, period[x], Slow_SMA1, 0, MODE_SMA, PRICE_CLOSE, iiMOV1))
       {
           iiMOV1++;
           ObjectSetText("dI1"+x+"3", CharToStr(UP),10,"Wingdings",Lime);
       }
     }
   else 
     {
        while(iMA(NULL, period[x], Fast_LWMA1, 0, MODE_LWMA, PRICE_CLOSE, iiMOV1) <= 
               iMA(NULL, period[x], Slow_SMA1, 0, MODE_SMA, PRICE_CLOSE, iiMOV1))
       {
           iiMOV1++;
           ObjectSetText("dI1"+x+"3", CharToStr(DOWN),10,"Wingdings",Red);
       }
     }
 }
 
//============================================================================
//--- MACD
//============================================================================  

   double ddraw,MACDVal;
   RefreshRates();

   for(x=0;x<6;x++) 
   {        
         ddraw = iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_MAIN,0);
         MACDVal = (iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_SIGNAL,0)*10000);          
         
         if(ddraw<0)       
         
             if((iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_MAIN,0)> iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_SIGNAL,0)))//&&ddraw>44)
                  { 
                  ObjectSetText("tI1"+x+"4",DoubleToStr(MACDVal,2),10,"Arial Bold",Green);
                  ObjectSetText("dI1"+x+"4", CharToStr(UP),10,"Wingdings",Green);  
                  }
             
                  else if((iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_MAIN,0)< iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_SIGNAL,0)))  
                           {
                           ObjectSetText("tI1"+x+"4",DoubleToStr(MACDVal,2),10,"Arial Bold",Red);
                           ObjectSetText("dI1"+x+"4", CharToStr(DOWN),10,"Wingdings",Red); 
                           }
                                      
                         else
                                 { 
                                 ObjectSetText("tI1"+x+"4",DoubleToStr(MACDVal,2),10,"Arial Bold",Gold);
                                 }                        
                               
                               
          else if(ddraw>0)   
           
               if((iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_MAIN,0)> iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_SIGNAL,0)))
                     {
                     ObjectSetText("tI1"+x+"4",DoubleToStr(MACDVal,2),10,"Arial Bold",Lime);
                     ObjectSetText("dI1"+x+"4", CharToStr(UP),10,"Wingdings",Lime); 
                     }
              
              else if((iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_MAIN,0)< iMACD(NULL, period[x],2,10,4,PRICE_CLOSE,MODE_SIGNAL,0)))
                        {
                        ObjectSetText("tI1"+x+"4",DoubleToStr(MACDVal,2),10,"Arial Bold",FireBrick);
                        ObjectSetText("dI1"+x+"4", CharToStr(DOWN),10,"Wingdings",FireBrick);
                        }
                  else 
                        { 
                        ObjectSetText("tI1"+x+"4",DoubleToStr(MACDVal,2),10,"Arial Bold",Gold);
                        }

//----
   } 
//============================================================================
//--- Acceleration/Deceleration arrows
//============================================================================
//AC/DC
//=====

for(x=0;x<6;x++)
 {

      double CurrentAC1 = (iAC(NULL, period[x], 0));
      double PreviousAC1 = (iAC(NULL, period[x], 1));
      
      if (CurrentAC1 > 0)
            {
               if(CurrentAC1 > PreviousAC1)
                  {
                     ObjectSetText("tI1"+x+"5",CharToStr(UP),10,"Wingdings",Lime);
                  }
               else
                  {
                     ObjectSetText("tI1"+x+"5",CharToStr(DOWN),10,"Wingdings",Red);
                  }
            }
  
  
      if (CurrentAC1 <= 0)
            {
               if(CurrentAC1 > PreviousAC1)
                  {
                     ObjectSetText("tI1"+x+"5",CharToStr(UP),10,"Wingdings",Green);
                  }
               else
                  {
                     ObjectSetText("tI1"+x+"5",CharToStr(DOWN),10,"Wingdings",FireBrick);
                  }
            }

      if (CurrentAC1 > 0)
            {
               if(CurrentAC1 > PreviousAC1)
                  {
                     ObjectSetText("dI1"+x+"5",CharToStr(UP),10,"Wingdings",Lime);
                  }
               else
                  {
                     ObjectSetText("dI1"+x+"5",CharToStr(DOWN),10,"Wingdings",Red);
                  }
            }
  
  
      if (CurrentAC1 <= 0)
            {
               if(CurrentAC1 > PreviousAC1)
                  {
                     ObjectSetText("dI1"+x+"5",CharToStr(UP),10,"Wingdings",Green);
                  }
               else
                  {
                     ObjectSetText("dI1"+x+"5",CharToStr(DOWN),10,"Wingdings",FireBrick);
                  }
            }
            
  }
  
//+------------------------------------------------------------------+
//| ADX                                                              |
//+------------------------------------------------------------------+    
    //--- ADX arrows
    //==============
    for(x=0;x<6;x++)
    {
    int iiADX = 0;
   if(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,0) > iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,0)) 
     {
       while(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,iiADX) > iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,iiADX))
       {
           iiADX++;
           ObjectSetText("dI1"+x+"6", CharToStr(DOWN),10,"Wingdings",Red);
       }
     }
   else 
     {
       while(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,iiADX) < iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,iiADX))
       {
           iiADX++;
           ObjectSetText("dI1"+x+"6", CharToStr(UP),10,"Wingdings",Lime);
       }
     }
        
//==================================================================================================        
        
   if(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,0) < iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,0)) 
     {
       while(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,iiADX) > iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,iiADX))
       {
           iiADX++;
           ObjectSetText("dI1"+x+"6", CharToStr(DOWN),10,"Wingdings",Red);
       }
     }
   else 
     {
       while(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,iiADX) < iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,iiADX))
       {
           iiADX++;
           ObjectSetText("dI1"+x+"6", CharToStr(UP),10,"Wingdings",Lime);
       }
     }
  
    }
//==================================================================================================
//============    
//--- ADX text
//============
    for(x=0;x<6;x++)
    {
    int iiADX1 = 0;
   if(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,0) > iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,iiADX1)) 
     {
       while(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,iiADX1) > iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,iiADX1))
       {
           iiADX1++;
           ObjectSetText("tI1"+x+"6", DoubleToStr(iiADX1, 0),10,"Arial Bold",Gold);
       }
     }
   else 
     {
       while(iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_PLUSDI,iiADX1) < iADX(NULL,period[x],ADXperiod,PRICE_CLOSE,MODE_MINUSDI,iiADX1))
       {
           iiADX1++;
           ObjectSetText("tI1"+x+"6", DoubleToStr(iiADX1, 0),10,"Arial Bold",Gold);
       }
     } 
    } 
//+------------------------------------------------------------------+
//| CCI                                                              |
//+------------------------------------------------------------------+
//--- CCI text
//============
    for(x=0;x<6;x++)
       {  
        int iiCCI = 1;
        double CCIVal = (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0));
        
    if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) > -100) && 
       (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) < 100))
       {
       if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 1)) >
         (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0)))
         {
         ObjectSetText("tI1"+x+"7", DoubleToStr(CCIVal, 2),10,"Arial Bold",Red);
         }
        else
         {
        if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 1)) <
         (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0)))
         {
         ObjectSetText("tI1"+x+"7", DoubleToStr(CCIVal, 2),10,"Arial Bold",Lime);
         }
        }
       }
    if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) < -100) && 
       (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) > -400) )
       {
        ObjectSetText("tI1"+x+"7", DoubleToStr(CCIVal, 2),10,"Arial Bold",DeepPink);
        }
    if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) > 100) && 
       (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) < 400) )
       {
        ObjectSetText("tI1"+x+"7", DoubleToStr(CCIVal, 2),10,"Arial Bold",DeepPink);
       }
       }
//--- CCI arrows
//==============
    for(x=0;x<6;x++)
       {  
    if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) > -100) && 
       (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) < 100) )
       {
       if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 1)) >
         (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0)))
         {
         ObjectSetText("dI1"+x+"7", CharToStr(DOWN),10,"Wingdings",Red);
         }
        else
         {
        if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 1)) <
         (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0)))
         {
         ObjectSetText("dI1"+x+"7", CharToStr(UP),10,"Wingdings",Lime);
         }
        }
       }
    if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) < -100) && 
       (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) > -400) )
       {
        ObjectSetText("dI1"+x+"7", CharToStr(UP),10,"Wingdings",Lime);
        }
    if((iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) > 100) && 
       (iCCI(NULL, period[x], Period_CCI, PRICE_CLOSE, 0) < 400) )
       {
        ObjectSetText("dI1"+x+"7", CharToStr(DOWN),10,"Wingdings",Red);
       }
       
   }
//+------------------------------------------------------------------+
//| RSI                                                              |
//+------------------------------------------------------------------+
//--- RSI text
//============
   for(x=0;x<6;x++)
   {  
   double RSIVal = (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0));
   
    if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) >= 20) && 
       (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) <= 80))
       {
       if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 1)) >=
         (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0)))
         {
         ObjectSetText("tI1"+x+"8", DoubleToStr(RSIVal, 2),10,"Arial Bold",Red);
         }
       else
         {
         if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 1)) <
         (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0)))
          {
          ObjectSetText("tI1"+x+"8", DoubleToStr(RSIVal, 2),10,"Arial Bold",Lime);
          }
         }
       }
    if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) < 20) && 
       (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) > 0) )
       {
        ObjectSetText("tI1"+x+"8", DoubleToStr(RSIVal, 2),10,"Arial Bold",DeepPink);
       }
    if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) > 80) && 
       (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) < 300) )
       {
        ObjectSetText("tI1"+x+"8", DoubleToStr(RSIVal, 2),10,"Arial Bold",DeepPink);
       }
    }
//--- RSI arrows
//==============
   for(x=0;x<6;x++)
   {  
    if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) > 20) && 
       (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) < 80))
       {
       if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 1)) >
         (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0)))
         {
         ObjectSetText("dI1"+x+"8", CharToStr(DOWN),10,"Wingdings",Red);
         }
       else
         {
         if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 1)) <
         (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0)))
          {
          ObjectSetText("dI1"+x+"8", CharToStr(UP),10,"Wingdings",Lime);
          }
         }
       }
    if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) < 20) && 
       (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) > 0) )
       {
        ObjectSetText("dI1"+x+"8", CharToStr(DOWN),10,"Wingdings",Red);
       }
    if((iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) > 80) && 
       (iRSI(NULL, period[x], Period_RSI, PRICE_CLOSE, 0) < 300) )
       {
        ObjectSetText("dI1"+x+"8", CharToStr(UP),10,"Wingdings",Lime);
       }
    }
    
//+------------------------------------------------------------------+
//| Parabolic SAR                                                    |
//+------------------------------------------------------------------+    
    //--- Parabolic SAR arrows
    //========================
    for(x=0;x<6;x++)
    {
         int iiPSar = 0;
   if(iSAR(NULL, period[x], SAR_Step, SAR_Max, 0) > iClose(NULL, period[x], iiPSar)) 
     {
       while(iSAR(NULL, period[x], SAR_Step, SAR_Max, iiPSar) > iClose(NULL, period[x], iiPSar))
       {
           iiPSar++;
           ObjectSetText("dI1"+x+"9", CharToStr(DOWN),10,"Wingdings",Red);
       }
     }
   else 
     {
       while(iSAR(NULL, period[x], SAR_Step, SAR_Max, iiPSar) < iClose(NULL, period[x], iiPSar))
       {
           iiPSar++;
           ObjectSetText("dI1"+x+"9", CharToStr(UP),10,"Wingdings",Lime);
       }
     } 
    }
    
//--- Parabolic SAR text
//======================
    for(x=0;x<6;x++)
    {
    int iiSar = 0;
   if(iSAR(NULL, period[x], SAR_Step, SAR_Max, 0) > iClose(NULL, period[x], iiSar)) 
     {
       while(iSAR(NULL, period[x], SAR_Step, SAR_Max, iiSar) > iClose(NULL, period[x], iiSar))
       {
           iiSar++;
           ObjectSetText("tI1"+x+"9", DoubleToStr(iiSar, 0),10,"Arial Bold",Gold);
       }
     }
   else 
     {
       while(iSAR(NULL, period[x], SAR_Step, SAR_Max, iiSar) < iClose(NULL, period[x], iiSar))
       {
           iiSar++;
           ObjectSetText("tI1"+x+"9", DoubleToStr(iiSar, 0),10,"Arial Bold",Gold);
       }
     } 
    }               
  return(0);
  }
  //+------------------------------------------------------------------+
  //| END MAIN LOOP                                                    |
  //+------------------------------------------------------------------+

   