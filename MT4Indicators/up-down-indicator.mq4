//+------------------------------------------------------------------+
//|                                                      Up&Down.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Tomato
//---- input parameters
extern int       HL_period=3;
extern int       NumBars=200;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//------
double ur[][2];
int h1[];
int l1[];

int hh=0;
int ll=0;

double spread;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
//----
   ArrayResize(ur,NumBars+1);
   ArrayResize(h1,HL_period);
   ArrayResize(l1,HL_period);
   
   spread = Ask-Bid;
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  int   n,shift,Nbar,k,mm;
  double MaH,MaL;

//---- 
  if( Period() == 5 )
  {
    ArrayInitialize(ur,0);
    ArrayInitialize(h1,0);
    ArrayInitialize(l1,0);
    for( shift = NumBars; shift>=0; shift-- )
    {
      if( TimeHour(Time[shift + 1]) != TimeHour(Time[shift]) )
      {
        Nbar = -1;
        k = 0;
        mm = 0;
        n = shift - 15;
        while( n <= shift + HL_period * 12 + 5 )
        {
          if( n < 0 )
          {
            n = 1;
            Nbar = 0;
          }
          if( TimeHour(Time[n + 1]) != TimeHour(Time[n]) && Nbar == -1 )
          {
            Nbar = n;
            mm = n;
            n++;
            continue;
          }
          if( TimeHour(Time[n + 1]) != TimeHour(Time[n]) && Nbar != -1 )
          {
            h1[k] = Highest(NULL,0,MODE_HIGH,n - Nbar,n-(n-Nbar)+1);
            l1[k] = Lowest(NULL,0,MODE_LOW,n - Nbar,n-(n-Nbar)+1);
            k++;
            Nbar = n;
          }
          n++;
        }
        MaH = 0;
        MaL = 0;
        for( n = 0; n<HL_period; n++ )
        {
          MaH = MaH + High[h1[n]]+spread;
          MaL = MaL + Low[l1[n]];
        }
        MaH = MaH / HL_period;
        MaL = MaL / HL_period;
        ur[shift][0] = MaH;
        ur[shift][1] = MaL;
        if( Close[mm + 1]+spread/2 >= MaH ) { ll = 1; hh = 0; }
        if( Close[mm + 1]+spread/2 <= MaL ) { hh = 1; ll = 0; }
      }
      if( ur[shift,1] == 0 )
      {
        ur[shift][0] = ur[shift + 1][0];
        ur[shift][1] = ur[shift + 1][1];
      }
      if( ll == 1 )
      {
        ExtMapBuffer2[shift]=0;
        ExtMapBuffer1[shift]=ur[shift][1];
      }
      if( hh == 1 )
      {
        ExtMapBuffer1[shift]=0;
        ExtMapBuffer2[shift]=ur[shift][0];
      }
    }
    return(0);
  }
//-----------------------------
  if( Period() == 15 )
  {
    ArrayInitialize(ur,0);
    ArrayInitialize(h1,0);
    ArrayInitialize(l1,0);
    for( shift = NumBars; shift>=0; shift-- )
    {
      if( TimeHour(Time[shift + 1]) != TimeHour(Time[shift]) )
      {
        Nbar = -1;
        k = 0;
        mm = 0;
        n = shift - 5;
        while( n <= shift + HL_period * 4 + 2 )
        {
          if( n < 0 )
          {
            n = 1;
            Nbar = 0;
          }
          if( TimeHour(Time[n + 1]) != TimeHour(Time[n]) && Nbar == -1 )
          {
            Nbar = n;
            mm = n;
            n++;
            continue;
          }
          if( TimeHour(Time[n + 1]) != TimeHour(Time[n]) && Nbar != -1 )
          {
            h1[k] = Highest(NULL,0,MODE_HIGH,n - Nbar,n-(n-Nbar)+1);
            l1[k] = Lowest(NULL,0,MODE_LOW,n - Nbar,n-(n-Nbar)+1);
            k++;
            Nbar = n;
          }
          n++;
        }
        MaH = 0;
        MaL = 0;
        for( n = 0; n<HL_period; n++ )
        {
          MaH = MaH + High[h1[n]]+spread;
          MaL = MaL + Low[l1[n]];
        }
        MaH = MaH / HL_period;
        MaL = MaL / HL_period;
        ur[shift][0] = MaH;
        ur[shift][1] = MaL;
        if( Close[mm + 1]+spread/2 >= MaH ) { ll = 1; hh = 0; }
        if( Close[mm + 1]+spread/2 <= MaL ) { hh = 1; ll = 0; }
      }
      if( ur[shift,1] == 0 )
      {
        ur[shift][0] = ur[shift + 1][0];
        ur[shift][1] = ur[shift + 1][1];
      }
      if( ll == 1 )
      {
        ExtMapBuffer2[shift]=0;
        ExtMapBuffer1[shift]=ur[shift][1];
      }
      if( hh == 1 )
      {
        ExtMapBuffer1[shift]=0;
        ExtMapBuffer2[shift]=ur[shift][0];
      }
    }
    return(0);
  }
//-------------------------
  if( Period() == 30 )
  {
    ArrayInitialize(ur,0);
    ArrayInitialize(h1,0);
    ArrayInitialize(l1,0);
    for( shift = NumBars; shift>=0; shift-- )
    {
      if( TimeMinute(Time[shift])==0 && (TimeHour(Time[shift])==0 || TimeHour(Time[shift])==4 || TimeHour(Time[shift])==8 || TimeHour(Time[shift])==12 || TimeHour(Time[shift])==16 || TimeHour(Time[shift])==20) )
      {
        Nbar = -1;
        k = 0;
        mm = 0;
        n = shift - 10;
        while( n <= shift + HL_period * 8 + 5 )
        {
          if( n < 0 )
          {
            n = 1;
            Nbar = 0;
          }
          if( TimeMinute(Time[n])==0 && (TimeHour(Time[n])==0 || TimeHour(Time[n])==4 || TimeHour(Time[n])==8 || TimeHour(Time[n])==12 || TimeHour(Time[n])==16 || TimeHour(Time[n])==20) && Nbar == -1 )
          {
            Nbar = n;
            mm = n;
            n++;
            continue;
          }
          if( TimeMinute(Time[n])==0 && (TimeHour(Time[n])==0 || TimeHour(Time[n])==4 || TimeHour(Time[n])==8 || TimeHour(Time[n])==12 || TimeHour(Time[n])==16 || TimeHour(Time[n])==20) && Nbar != -1 )
          {
            h1[k] = Highest(NULL,0,MODE_HIGH,n - Nbar,n-(n-Nbar)+1);
            l1[k] = Lowest(NULL,0,MODE_LOW,n - Nbar,n-(n-Nbar)+1);
            k++;
            Nbar = n;
          }
          n++;
        }
        MaH = 0;
        MaL = 0;
        for( n = 0; n<HL_period; n++ )
        {
          MaH = MaH + High[h1[n]]+spread;
          MaL = MaL + Low[l1[n]];
        }
        MaH = MaH / HL_period;
        MaL = MaL / HL_period;
        ur[shift][0] = MaH;
        ur[shift][1] = MaL;
        if( Close[mm + 1]+spread/2 >= MaH ) { ll = 1; hh = 0; }
        if( Close[mm + 1]+spread/2 <= MaL ) { hh = 1; ll = 0; }
      }
      if( ur[shift,1] == 0 )
      {
        ur[shift][0] = ur[shift + 1][0];
        ur[shift][1] = ur[shift + 1][1];
      }
      if( ll == 1 )
      {
        ExtMapBuffer2[shift]=0;
        ExtMapBuffer1[shift]=ur[shift][1];
      }
      if( hh == 1 )
      {
        ExtMapBuffer1[shift]=0;
        ExtMapBuffer2[shift]=ur[shift][0];
      }
    }
    return(0);
  }
//----
  if( Period() == 60 )
  {
    ArrayInitialize(ur,0);
    ArrayInitialize(h1,0);
    ArrayInitialize(l1,0);
    for( shift = NumBars; shift>=0; shift-- )
    {
      if( TimeMinute(Time[shift])==0 && (TimeHour(Time[shift])==0 || TimeHour(Time[shift])==4 || TimeHour(Time[shift])==8 || TimeHour(Time[shift])==12 || TimeHour(Time[shift])==16 || TimeHour(Time[shift])==20) )
      {
        Nbar = -1;
        k = 0;
        mm = 0;
        n = shift - 6;
        while( n <= shift + HL_period * 4 + 3 )
        {
          if( n < 0 )
          {
            Nbar = 0;
            n = 1;
          }
          if( TimeMinute(Time[n])==0 && (TimeHour(Time[n])==0 || TimeHour(Time[n])==4 || TimeHour(Time[n])==8 || TimeHour(Time[n])==12 || TimeHour(Time[n])==16 || TimeHour(Time[n])==20) && Nbar == -1 )
          {
            Nbar = n;
            mm = n;
            n++;
            continue;
          }
          if( TimeMinute(Time[n])==0 && (TimeHour(Time[n])==0 || TimeHour(Time[n])==4 || TimeHour(Time[n])==8 || TimeHour(Time[n])==12 || TimeHour(Time[n])==16 || TimeHour(Time[n])==20) && Nbar != -1 )
          {
            h1[k] = Highest(NULL,0,MODE_HIGH,n - Nbar,n-(n-Nbar)+1);
            l1[k] = Lowest(NULL,0,MODE_LOW,n - Nbar,n-(n-Nbar)+1);
            k++;
            Nbar = n;
          }
          n++;
        }
        MaH = 0;
        MaL = 0;
        for( n = 0; n<HL_period; n++ )
        {
          MaH = MaH + High[h1[n]]+spread;
          MaL = MaL + Low[l1[n]];
        }
        MaH = MaH / HL_period;
        MaL = MaL / HL_period;
        ur[shift][0] = MaH;
        ur[shift][1] = MaL;
        if( Close[mm + 1]+spread/2 >= MaH ) { ll = 1; hh = 0; }
        if( Close[mm + 1]+spread/2 <= MaL ) { hh = 1; ll = 0; }
      }
      if( ur[shift,1] == 0 )
      {
        ur[shift][0] = ur[shift + 1][0];
        ur[shift][1] = ur[shift + 1][1];
      }
      if( ll == 1 )
      {
        ExtMapBuffer2[shift]=0;
        ExtMapBuffer1[shift]=ur[shift][1];
      }
      if( hh == 1 )
      {
        ExtMapBuffer1[shift]=0;
        ExtMapBuffer2[shift]=ur[shift][0];
      }
    }
    return(0);
  }
//--------------  
  if( Period() == 240 )
  {
    ArrayInitialize(ur,0);
    ArrayInitialize(h1,0);
    ArrayInitialize(l1,0);
    for( shift = NumBars; shift>=0; shift-- )
    {
      if( TimeDay(Time[shift + 1]) != TimeDay(Time[shift]) )
      {
        Nbar = -1;
        k = 0;
        mm = 0;
        n = shift - 8;
        while( n <= shift + HL_period * 8 + 4 )
        {
          if( n < 0 )
          {
            Nbar = 0;
            n = 1;
          }
          if( TimeDay(Time[n + 1]) != TimeDay(Time[n]) && Nbar == -1 )
          {
            Nbar = n;
            mm = n;
            n++;
            continue;
          }
          if( TimeDay(Time[n + 1]) != TimeDay(Time[n]) && Nbar != -1 )
          {
            h1[k] = Highest(NULL,0,MODE_HIGH,n - Nbar,n-(n-Nbar)+1);
            l1[k] = Lowest(NULL,0,MODE_LOW,n - Nbar,n-(n-Nbar)+1);
            k++;
            Nbar = n;
          }
          n++;
        }
        MaH = 0;
        MaL = 0;
        for( n = 0; n<HL_period; n++ )
        {
          MaH = MaH + High[h1[n]]+spread;
          MaL = MaL + Low[l1[n]];
        }
        MaH = MaH / HL_period;
        MaL = MaL / HL_period;
        ur[shift][0] = MaH;
        ur[shift][1] = MaL;
        if( Close[mm + 1]+spread/2 >= MaH ) { ll = 1; hh = 0; }
        if( Close[mm + 1]+spread/2 <= MaL ) { hh = 1; ll = 0; }
      }
      if( ur[shift,1] == 0 )
      {
        ur[shift][0] = ur[shift + 1][0];
        ur[shift][1] = ur[shift + 1][1];
      }
      if( ll == 1 )
      {
        ExtMapBuffer2[shift]=0;
        ExtMapBuffer1[shift]=ur[shift][1];
      }
      if( hh == 1 )
      {
        ExtMapBuffer1[shift]=0;
        ExtMapBuffer2[shift]=ur[shift][0];
      }
    }
    return(0);
  }
//----
  if( Period() == 1440 )
  {
    ArrayInitialize(ur,0);
    ArrayInitialize(h1,0);
    ArrayInitialize(l1,0);
    for( shift = NumBars; shift>=0; shift-- )
    {
      if( TimeDayOfWeek(Time[shift + 1]) == 5 && TimeDayOfWeek(Time[shift]) == 1 )
      {
        Nbar = -1;
        k = 0;
        mm = 0;
        n = shift - 6;
        while( n <= shift + HL_period * 5 + 3 )
        {
          if( n < 0 )
          {
            Nbar = 0;
            n = 1;
          }
          if( TimeDayOfWeek(Time[n + 1])==5 && TimeDayOfWeek(Time[n])==1 && Nbar == -1 )
          {
            Nbar = n;
            mm = n;
            n++;
            continue;
          }
          if( TimeDayOfWeek(Time[n + 1])==5 && TimeDayOfWeek(Time[n])==1 && Nbar != -1 )
          {
            h1[k] = Highest(NULL,0,MODE_HIGH,n - Nbar,n-(n-Nbar)+1);
            l1[k] = Lowest(NULL,0,MODE_LOW,n - Nbar,n-(n-Nbar)+1);
            k++;
            Nbar = n;
          }
          n++;
        }
        MaH = 0;
        MaL = 0;
        for( n = 0; n<HL_period; n++ )
        {
          MaH = MaH + High[h1[n]]+spread;
          MaL = MaL + Low[l1[n]];
        }
        MaH = MaH / HL_period;
        MaL = MaL / HL_period;
        ur[shift][0] = MaH;
        ur[shift][1] = MaL;
        if( Close[mm + 1]+spread/2 >= MaH ) { ll = 1; hh = 0; }
        if( Close[mm + 1]+spread/2 <= MaL ) { hh = 1; ll = 0; }
      }
      if( ur[shift,1] == 0 )
      {
        ur[shift][0] = ur[shift + 1][0];
        ur[shift][1] = ur[shift + 1][1];
      }
      if( ll == 1 )
      {
        ExtMapBuffer2[shift]=0;
        ExtMapBuffer1[shift]=ur[shift][1];
      }
      if( hh == 1 )
      {
        ExtMapBuffer1[shift]=0;
        ExtMapBuffer2[shift]=ur[shift][0];
      }
    }
    return(0);
  }
//----
  if( Period() == 10080 )
  {
    ArrayInitialize(ur,0);
    ArrayInitialize(h1,0);
    ArrayInitialize(l1,0);
    for( shift = NumBars; shift>=0; shift-- )
    {
      if( TimeMonth(Time[shift + 1]+1440*60) != TimeMonth(Time[shift]+1440*60) )
      {
        Nbar = -1;
        k = 0;
        mm = 0;
        n = shift - 8;
        while( n <= shift + HL_period * 8 + 4 )
        {
          if( n < 0 )
          {
            Nbar = 0;
            n = 1;
          }
          if( TimeMonth(Time[n + 1]+1440*60) != TimeMonth(Time[n]+1440*60) && Nbar == -1 )
          {
            Nbar = n;
            mm = n;
            if( n>NumBars-18 ) Print(TimeToStr(Time[n]));
            n++;
            continue;
          }
          if( TimeMonth(Time[n + 1]+1440*60) != TimeMonth(Time[n]+1440*60) && Nbar != -1 )
          {
            h1[k] = Highest(NULL,0,MODE_HIGH,n - Nbar,n-(n-Nbar)+1);
            l1[k] = Lowest(NULL,0,MODE_LOW,n - Nbar,n-(n-Nbar)+1);
            k++;
            Nbar = n;
          }
          n++;
        }
        MaH = 0;
        MaL = 0;
        for( n = 0; n<HL_period; n++ )
        {
          MaH = MaH + High[h1[n]]+spread;
          MaL = MaL + Low[l1[n]];
        }
        MaH = MaH / HL_period;
        MaL = MaL / HL_period;
        ur[shift][0] = MaH;
        ur[shift][1] = MaL;
        if( Close[mm + 1]+spread/2 >= MaH ) { ll = 1; hh = 0; }
        if( Close[mm + 1]+spread/2 <= MaL ) { hh = 1; ll = 0; }
      }
      if( ur[shift,1] == 0 )
      {
        ur[shift][0] = ur[shift + 1][0];
        ur[shift][1] = ur[shift + 1][1];
      }
      if( ll == 1 )
      {
        ExtMapBuffer2[shift]=0;
        ExtMapBuffer1[shift]=ur[shift][1];
      }
      if( hh == 1 )
      {
        ExtMapBuffer1[shift]=0;
        ExtMapBuffer2[shift]=ur[shift][0];
      }
    }
    return(0);
  }
//----
  return(0);
}
//+------------------------------------------------------------------+