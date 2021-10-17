//+------------------------------------------------------------------+ 
//|   tro_tick                                                       | 
//|                                                                  | 
//|   Copyright © 2008, Avery T. Horton, Jr. aka TheRumpledOne       |
//|                                                                  |
//|   PO BOX 43575, TUCSON, AZ 85733                                 |
//|                                                                  |
//|   GIFTS AND DONATIONS ACCEPTED                                   | 
//|                                                                  |
//|   therumpledone@gmail.com                                        |  
//+------------------------------------------------------------------+ 

#property indicator_separate_window
#property  indicator_buffers 1 
#property  indicator_color1  Lime
 

extern string mySymbol = "" ; 
 

//---- indicator buffers 
double     xBuffer[]; 
double     xBuffer1[]; 



int      window;  
int      corner;
int      totalLabels;

color  ColorLabels  = Gray;

color  color5 = Red;
color  color4 = Orange;
color  color3 = Yellow;
color  color2 = Green;
color  color1 = Lime;
color  coltrend;

string   labelNames;
string   shortName;

bool sFirst;
double XX;


string symbol  ;  


int    MODEDIGITS   ; 
double MODEPOINT   ;  
 
//+------------------------------------------------------------------+
int init()
  {


   if(mySymbol == "") { symbol       =  Symbol() ; } else { symbol = mySymbol ; }    
 


//---- drawing settings 

   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1); 
 
   
//---- indicator buffers mapping 

   SetIndexBuffer(0,xBuffer); 
 
   
//---- name for DataWindow and indicator subwindow label 

 
   SetIndexLabel(0,"tick"); 
 

    shortName="Tick by Tick " + symbol ;
   IndicatorShortName(shortName);   


//----
   return(0);
  }
  
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(window);


//----
   return(0);
  }
  
//+------------------------------------------------------------------+
int start()
  {
 
 
   window = WindowFind(shortName);        

    
   int limit, pBars; 
   int counted_bars=IndicatorCounted(); 
   
//---- last counted bar will be recounted 
  if(counted_bars>0) counted_bars--; 
//  limit=Bars-counted_bars; 

limit=counted_bars;   
 
  


for(int i=limit; i>=0; i--) { xBuffer[i+1] = xBuffer[i] ; }

xBuffer[0]  = iClose(symbol,1,0) ;



 

/*
Comment(
"ticks= ", ticks, "\n",
"XX= ", DoubleToStr(XX,Digits) , "\n",
"xBuffer[ticks]= ", DoubleToStr(xBuffer[ticks],Digits) , "\n",
"xBuffer[ticks-1]= ", DoubleToStr(xBuffer[ticks-1],Digits) , "\n",
"") ;

*/

   DoShowLegend() ;
   
       
   return(0);
  }
  


//+------------------------------------------------------------------+



void DoShowLegend()
{


RefreshRates();  
 
MODEDIGITS            = MarketInfo(symbol,MODE_DIGITS) ; 
MODEPOINT             = MarketInfo(symbol,MODE_POINT) ;  
 

int       X_trend               =  0; // 360;
int       Y_trend               =  0; // 20;

   corner = 1;
   string sClose = DoubleToStr(iClose(symbol,0,0),MODEDIGITS) ;

   string tHead  = symbol + " " + sClose  ;   
   
   string tik_Val = DoubleToStr(xBuffer[0],MODEDIGITS) ;
   
   

      if(xBuffer[0]  > xBuffer[1] ) { coltrend = Lime ;  } else { coltrend = Red ;  }  
 

     
   setObject(shortName+"TxT", tHead ,30,08, coltrend ,"Arial Bold" );
/*    
   ObjectCreate("tik_value", OBJ_LABEL, window, 0, 0);
   ObjectSetText("tik_value",tik_Val,30, "Arial Bold", coltrend );   // coltrend Trend_UP
   ObjectSet("tik_value", OBJPROP_CORNER, corner);
   ObjectSet("tik_value", OBJPROP_XDISTANCE, 1000+X_trend-900); // 955+X_trend-900
   ObjectSet("tik_value", OBJPROP_YDISTANCE, 26+Y_trend);    
*/    
}

//+------------------------------------------------------------------+

string next() { totalLabels++; return(totalLabels); }  
//+------------------------------------------------------------------+
void setObject(string name,string text,int x,int y,color theColor, string font = "Arial",int size=10,int angle=0)
{
   string labelName = StringConcatenate(labelNames,name);

      
      if (ObjectFind(labelName) == -1)
          {
             ObjectCreate(labelName,OBJ_LABEL,window,0,0);
             ObjectSet(labelName,OBJPROP_CORNER,corner);
             if (angle != 0)
                  ObjectSet(labelName,OBJPROP_ANGLE,angle);
          }               
       ObjectSet(labelName,OBJPROP_XDISTANCE,x);
       ObjectSet(labelName,OBJPROP_YDISTANCE,y);
       ObjectSetText(labelName,text,size,font,theColor);
}

//+------------------------------------------------------------------+

string MakeUniqueName(string first, string rest)
{
   string result = first+(MathRand()%1001)+rest;

   while (WindowFind(result)> 0)
          result = first+(MathRand()%1001)+rest;
   return(result);
}

//+------------------------------------------------------------------+  
 