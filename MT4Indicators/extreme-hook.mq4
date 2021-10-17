//+------------------------------------------------------------------+
//|                                                  ExtremeHook.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window

int TextSize = 8;
int timeframes[] = {1,5,15,30,60,240,1440,PERIOD_W1,PERIOD_MN1};
string post;
int cciper = 14;

extern color GridColor = White;
extern color TextColor = Yellow;
extern string pair1s = "EURUSD";
extern string pair2s = "EURGBP";
extern string pair3s = "EURJPY";
extern string pair4s = "GBPUSD";
extern string pair5s = "GBPJPY";
extern string pair6s = "USDCHF";
extern string pair7s = "AUDUSD";
extern string pair8s = "USDCAD";
extern int ExtremeCCIhigh = 100;
extern int ExtremeCCIlow = -100;

string pair1[44000];
string pair2[44000];
string pair3[44000];
string pair4[44000];
string pair5[44000];
string pair6[44000];
string pair7[44000];
string pair8[44000];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   int lenstr = StringLen(Symbol())-1;
   if(lenstr > 5){
      post=StringSubstr(Symbol(),6,lenstr-6);
      }

int x=30;
      //DrawText("EU",10,12,TextColor,10,"Ariel",StringConcatenate(Symbol()," - ",TimeLeft()),true);
      DrawText("EU0",19,x,GridColor,10,"Ariel","TF",true);
      DrawText("EU0-1",58,x,GridColor,TextSize,"Ariel",pair1s,true);
      DrawText("EU0-2",107,x,GridColor,TextSize,"Ariel",pair2s,true);
      DrawText("EU0-3",156,x,GridColor,TextSize,"Ariel",pair3s,true);
      DrawText("EU0-4",205,x,GridColor,TextSize,"Ariel",pair4s,true);
      DrawText("EU0-5",254,x,GridColor,TextSize,"Ariel",pair5s,true);
      DrawText("EU0-6",303,x,GridColor,TextSize,"Ariel",pair6s,true);
      DrawText("EU0-7",352,x,GridColor,TextSize,"Ariel",pair7s,true);
      DrawText("EU0-8",401,x,GridColor,TextSize,"Ariel",pair8s,true);
      
      DrawText("EU1",10,x+20,TextColor,10,"Ariel","1-min",true);
      DrawText("EU5",10,x+40,TextColor,10,"Ariel","5-min",true);
      DrawText("EU15",10,x+60,TextColor,10,"Ariel","15-min",true);
      DrawText("EU30",10,x+80,TextColor,10,"Ariel","30-min",true);
      DrawText("EU60",10,x+100,TextColor,10,"Ariel","1-Hr",true);
      DrawText("EU4H",10,x+120,TextColor,10,"Ariel","4-Hr",true);
      DrawText("EU1D",10,x+140,TextColor,10,"Ariel","1-Day",true);
      DrawText("EU1W",10,x+160,TextColor,10,"Ariel","1-Wk",true);
      DrawText("EU1M",10,x+180,TextColor,10,"Ariel","1-Mo",true);
      
      string horiz="_______________________________________________________________";
      DrawText("Line1",5,13,GridColor,10,"Ariel",horiz,false);
      DrawText("Line2",5,x+5,GridColor,10,"Ariel",horiz,false);
      DrawText("Line3",5,x+25,GridColor,10,"Ariel",horiz,false);
      DrawText("Line4",5,x+45,GridColor,10,"Ariel",horiz,false);
      DrawText("Line5",5,x+65,GridColor,10,"Ariel",horiz,false);
      DrawText("Line6",5,x+85,GridColor,10,"Ariel",horiz,false);
      DrawText("Line7",5,x+105,GridColor,10,"Ariel",horiz,false);
      DrawText("Line8",5,x+125,GridColor,10,"Ariel",horiz,false);
      DrawText("Line9",5,x+145,GridColor,10,"Ariel",horiz,false);
      DrawText("Line10",5,x+165,GridColor,10,"Ariel",horiz,false);
      DrawText("Line11",5,x+185,GridColor,10,"Ariel",horiz,false);
      
      int colum[]={4,52,101,150,199,248,297,346,395,444};
      for(int h=0; h<10; h++){
         DrawText("Line11-"+h,colum[h],22,GridColor,14,"Ariel","|",false);
         DrawText("Line12-"+h,colum[h],40,GridColor,14,"Ariel","|",false);
         DrawText("Line13-"+h,colum[h],58,GridColor,14,"Ariel","|",false);
         DrawText("Line14-"+h,colum[h],76,GridColor,14,"Ariel","|",false);
         DrawText("Line15-"+h,colum[h],94,GridColor,14,"Ariel","|",false);
         DrawText("Line16-"+h,colum[h],110,GridColor,14,"Ariel","|",false);
         DrawText("Line17-"+h,colum[h],128,GridColor,14,"Ariel","|",false);
         DrawText("Line18-"+h,colum[h],146,GridColor,14,"Ariel","|",false);
         DrawText("Line19-"+h,colum[h]-1,166,GridColor,15,"Ariel","|",false);
         DrawText("Line20-"+h,colum[h]-1,185,GridColor,17,"Ariel","|",false);
         DrawText("Line21-"+h,colum[h]-1,204,GridColor,17,"Ariel","|",false);
         }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   ObjectsDeleteAll(0,OBJ_LABEL);

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   DrawText("EU",10,12,TextColor,10,"Ariel",StringConcatenate(Symbol()," - ",TimeLeft()),true);
   for(int n=0; n<9; n++) {
      pair1[timeframes[n]]=CCIhook(pair1s,timeframes[n]);
      pair2[timeframes[n]]=CCIhook(pair2s,timeframes[n]);
      pair3[timeframes[n]]=CCIhook(pair3s,timeframes[n]);
      pair4[timeframes[n]]=CCIhook(pair4s,timeframes[n]);
      pair5[timeframes[n]]=CCIhook(pair5s,timeframes[n]);
      pair6[timeframes[n]]=CCIhook(pair6s,timeframes[n]);
      pair7[timeframes[n]]=CCIhook(pair7s,timeframes[n]);
      pair8[timeframes[n]]=CCIhook(pair8s,timeframes[n]);
      }
   
   //int colum[]={55,101,150,199,248,297,346,395,444};
   int y=52;
      for(int h=0; h<9; h++){
         DrawText("EHLine1-"+timeframes[h],58,y,GridColor,TextSize,"Ariel",pair1[timeframes[h]],false); 
         DrawText("EHLine2-"+timeframes[h],107,y,GridColor,TextSize,"Ariel",pair2[timeframes[h]],false); 
         DrawText("EHLine3-"+timeframes[h],156,y,GridColor,TextSize,"Ariel",pair3[timeframes[h]],false); 
         DrawText("EHLine4-"+timeframes[h],205,y,GridColor,TextSize,"Ariel",pair4[timeframes[h]],false); 
         DrawText("EHLine5-"+timeframes[h],254,y,GridColor,TextSize,"Ariel",pair5[timeframes[h]],false); 
         DrawText("EHLine6-"+timeframes[h],303,y,GridColor,TextSize,"Ariel",pair6[timeframes[h]],false); 
         DrawText("EHLine7-"+timeframes[h],352,y,GridColor,TextSize,"Ariel",pair7[timeframes[h]],false); 
         DrawText("EHLine8-"+timeframes[h],401,y,GridColor,TextSize,"Ariel",pair8[timeframes[h]],false); y=y+20;
         
         }
   return(0);
  }

//---------------------------------------------------- Draw text routine
void DrawText(string oname, int x, int y, color Color, int fontSize, string font, string text, bool shadow)
{
   
   string name = oname+".";
   ObjectDelete(name);
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
   ObjectSet(name, OBJPROP_COLOR, Color);
   ObjectSet(name, OBJPROP_BACK, false);
   ObjectSetText(name,text,fontSize,font);
      
   name = oname;
   ObjectDelete(name);
   
   if (!shadow) return;
   
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name, OBJPROP_XDISTANCE, x+1);
   ObjectSet(name, OBJPROP_YDISTANCE, y+1);
   ObjectSet(name, OBJPROP_COLOR, Black);
   ObjectSet(name, OBJPROP_BACK, false);
   ObjectSetText(name,text,fontSize,font);
}
//----------------------------------------------------- Time left in current bar for header 
string TimeLeft()
{
   string tl;
	double i;
   int m,s,k;
   m=Time[0]+Period()*60-CurTime();
   i=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
   tl=StringConcatenate(m," minutes ",s," seconds left to bar end");
   
   return(tl);
}
//-------------------------------------------------------------- CCI extreme hook
string CCIhook(string symbol, int timeframe)
{
   int cci=iCCI(symbol+post,timeframe,cciper,PRICE_TYPICAL,0);
   int ccip=iCCI(symbol+post,timeframe,cciper,PRICE_TYPICAL,1);
   int ccipp=iCCI(symbol+post,timeframe,cciper,PRICE_TYPICAL,2);
   
   //CCIhook[timeframe] = "";
   if(ccip>ExtremeCCIhigh && cci<ccip && ccipp<ccip) return("Bear"); // removed && iClose(NULL,timeframe,0)>iClose(NULL,timeframe,1)
   if(ccip<ExtremeCCIlow && cci>ccip && ccipp>ccip) return("Bull");
   
   return("");
}