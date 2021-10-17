//+------------------------------------------------------------------+
//|                                       MTF_Resistance&Support.mq4 |
//|                                         StarLimit Software Corp. |
//|                                            starlimit03@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "StarLimit Software Corp."
#property link      "starlimit03@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Red
#property indicator_color6 Blue

//---- buffers
double mabel01[],mabel02[],mabel11[],mabel12[],mabel21[],mabel22[];

int shift[3],per[3];
extern bool showinfo=false;
extern bool autoset=true;
extern bool showlines=false;
extern int TimeFrame1=0,TimeFrame2=0,TimeFrame3=0;
double mabel1;
double mabel2;
int i,h;
double high0,high1,high2,low0,low1,low2;
 string auto =" FALSE";
string last="exit";
bool first=true;
int init()
  {
//---- indicators
   //----
  IndicatorBuffers(6);
 
//---- drawing settings
 SetIndexArrow(0, 158);
 SetIndexArrow(1, 158);
 SetIndexArrow(2, 159);
 SetIndexArrow(3, 159);
 SetIndexArrow(4, 159);
 SetIndexArrow(5, 159);
   
   SetIndexLabel(0,"Resistance_1");
   SetIndexStyle(0,DRAW_ARROW,STYLE_DOT,1,Red);
   SetIndexDrawBegin(0,i-1);
   SetIndexBuffer(0, mabel01);
   SetIndexLabel(1,"Support_1");
   SetIndexStyle(1,DRAW_ARROW,STYLE_DOT,1,Blue);
   SetIndexDrawBegin(1,i-1);
   SetIndexBuffer(1, mabel02);
   
   SetIndexLabel(2,"Resistance_2");   
   SetIndexStyle(2,DRAW_ARROW,STYLE_DOT,2,Red);
   SetIndexDrawBegin(2,i-1);
   SetIndexBuffer(2, mabel11);
   SetIndexLabel(3,"Support_2");
   SetIndexStyle(3,DRAW_ARROW,STYLE_DOT,2,Blue);
   SetIndexDrawBegin(3,i-1);
   SetIndexBuffer(3, mabel12);
   
   SetIndexLabel(4,"Resistance_3");   
   SetIndexStyle(4,DRAW_ARROW,STYLE_DOT,4,Red);
   SetIndexDrawBegin(4,i-1);
   SetIndexBuffer(4, mabel21);
   SetIndexLabel(5,"Support_3");
   SetIndexStyle(5,DRAW_ARROW,STYLE_DOT,4,Blue);
   SetIndexDrawBegin(5,i-1);
   SetIndexBuffer(5, mabel22);
   
  if( autoset)
  { 
   auto=" TRUE";
    if(Period()==1)
   {TimeFrame1=5;TimeFrame2=15;TimeFrame3=30;}     //1, 5, 30
   else if(Period()==5)
   {TimeFrame1=1;TimeFrame2=5;TimeFrame3=30;}
   
   else if(Period()==15)
   {TimeFrame1=5;TimeFrame2=15;TimeFrame3=60;}
   
   else if(Period()==30)
   {TimeFrame1=5;TimeFrame2=30;TimeFrame3=240;}
   
   else if(Period()==60)
   {TimeFrame1=15;TimeFrame2=60;TimeFrame3=240;}
   
   else if(Period()==240)
   {TimeFrame1=60;TimeFrame2=240;TimeFrame3=1440;}
   
   else if(Period()==1440)
   {TimeFrame1=240;TimeFrame2=1440;TimeFrame3=10080;}
   else if(Period()==10080)
   {TimeFrame1=1440;TimeFrame2=10080;TimeFrame3=43200;}
  } 
   per[0]=TimeFrame1;
   per[1]=TimeFrame2;
   per[2]=TimeFrame3;
   
   first=true;
   return(0);
  }
  
int deinit()
   {
      Comment(" ");
      for( int  i =0; i<=70000;i++)
      {
       ObjectDelete("hor"+i);
      } 
      
   return(0);
   }
int start()
  {
    RefreshRates();
   int Counted_bars=IndicatorCounted();
   if(first)
      int newbars =Bars-Counted_bars-1;
   else newbars =40;
   for(int a=0;a<=3;a++)    // M1 ,M5, M15, M30 ,H1   get all data values
      {
        for( i=newbars;i>=0; i--)          // back shifts to use
         {
            datetime time = iTime(NULL,Period(),i);
        int h=i;
            shift[a]=iBarShift(NULL,per[a],time,true);
            mabel1 = iFractals(NULL, per[a], MODE_UPPER,shift[a]);
            mabel2 = iFractals(NULL, per[a], MODE_LOWER,shift[a]);
            double low=iLow(NULL,per[a],shift[a]);
            double high=iHigh(NULL,per[a],shift[a]);
            double open=iOpen(NULL,per[a],shift[a]);
      
  
         switch(a)
         {
          case 0:
                 if (mabel1 > 0) 
                   mabel01[i]=high;
                else
                   mabel01[i] = mabel01[i+1]; 
                   
                 if (mabel2 > 0) 
                   mabel02[i]=low;
                else
                   mabel02[i] = mabel02[i+1];

               high0=mabel01[i];
               low0=mabel02[i];   
              break;
       
          case 1:
                 if (mabel1 > 0) 
                   mabel11[i]=high;
                else
                   mabel11[i] = mabel11[i+1]; 
                 if (mabel2 > 0) 
                   mabel12[i]=low;
                else
                   mabel12[i] = mabel12[i+1];
               high1=mabel11[i];
               low1=mabel12[i];
              break;
       
          case 2:
                 if (mabel1 > 0) 
                   mabel21[i]=high;
                else
                   mabel21[i] = mabel21[i+1]; 
                 if (mabel2 > 0) 
                   mabel22[i]=low;
                else
                   mabel22[i] = mabel22[i+1];
                 high2=mabel21[i];
               low2=mabel22[i];
              break;
        case 3:
 if(showinfo)        Comment(" \n\n\n\n MultiTimeFrame Resistance and Support\n\n AUTHOR : Olowoyo Olufikayo \n\n CREATED :18/05/2009.... LAST UPDATED: 17/08/2009 \n\n AUTOSET TIMEFRAME IS SET TO",auto,"\n LOW TIMEFRAME= ",TimeFrame1,"\n OWN TIMEFRAME= ",TimeFrame2,"\n HIGH TIMEFRAME= ",TimeFrame3,
      "\n\n Last High on ",TimeFrame1," is ",high0,".....Last Low is ",low0,
      "\n Last High on ",TimeFrame2," is ",high1,".....Last Low is ",low1,
      "\n Last High on ",TimeFrame3," is ",high2,".....Last Low is ",low2,
      "\n\n Buying Price is ; ",Ask,"...........Selling Price is : ",Bid);
         break;
        }// end  of switch///////////////
       }
    }  
   
    for( i=newbars;i>=0; i--)          // back shifts to use
     if(showlines&& mabel01[i]==mabel11[i] && mabel11[i]== mabel21[i] && mabel02[i]==mabel12[i] && mabel12[i]== mabel22[i] && last=="sell") 
        {
       h++;
       ObjectCreate("hor"+h,OBJ_VLINE,0,0,0);
           ObjectSet("hor"+h, OBJPROP_TIME1, Time[i]);  
           ObjectSet("hor"+h, OBJPROP_COLOR, Aqua);
           ObjectSet("hor"+h, OBJPROP_STYLE, 3);
           ObjectSet("hor"+h, OBJPROP_WIDTH, 2);
           last="buy";
       } 
    else if(showlines&&mabel01[i]==mabel11[i] && mabel11[i]== mabel21[i] && mabel02[i]==mabel12[i] && mabel12[i]== mabel22[i] && last=="buy") 
        {
       h++;
       ObjectCreate("hor"+h,OBJ_VLINE,0,0,0);
           ObjectSet("hor"+h, OBJPROP_TIME1, Time[i]);  
           ObjectSet("hor"+h, OBJPROP_COLOR, Red);
           ObjectSet("hor"+h, OBJPROP_STYLE, 3);
           ObjectSet("hor"+h, OBJPROP_WIDTH, 2);
           last="sell";
       } 
        
  else if(showlines&& mabel01[i]==mabel11[i] && mabel11[i]== mabel21[i]) 
      {
       h++;
       ObjectCreate("hor"+h,OBJ_VLINE,0,0,0);
           ObjectSet("hor"+h, OBJPROP_TIME1, Time[i]);  
           ObjectSet("hor"+h, OBJPROP_COLOR, Red);
           ObjectSet("hor"+h, OBJPROP_STYLE, 3);
           ObjectSet("hor"+h, OBJPROP_WIDTH, 2);
           last="sell";
      }
   else  if(showlines&&mabel02[i]==mabel12[i] && mabel12[i]== mabel22[i]) 
      {
       h++;
       ObjectCreate("hor"+h,OBJ_VLINE,0,0,0);
           ObjectSet("hor"+h, OBJPROP_TIME1, Time[i]);  
           ObjectSet("hor"+h, OBJPROP_COLOR, Aqua);
           ObjectSet("hor"+h, OBJPROP_STYLE, 3);
           ObjectSet("hor"+h, OBJPROP_WIDTH, 2);
           last="buy";
      }
   else last="exit";
   return(0);
  }
 
//+------------------------------------------------------------------+

