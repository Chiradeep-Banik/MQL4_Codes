//+------------------------------------------------------------------+
//|                                                      Borders.mq4 |
//|                                      "»Ќƒ» ј“ќ–џ ƒЋя —јћќќЅћјЌј" |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  Olive
#property indicator_color2  Olive
#property indicator_color3  Olive
#property indicator_color4  Olive
#property indicator_color5  PowderBlue
#property indicator_color6  PowderBlue
#property indicator_color7  Yellow
//----
extern int  MaxPeriod          =60; 
extern int  MinPeriod          =24; 
extern bool Show_MaxPeriod     =true; // –исовать коридор по свечкам
                                      // с периодом MaxPeriod
extern bool Show_HistMaxPeriod =true; // –исовать коридор по свечкам
                                      // с периодом MaxPeriod
                                      // в виде гистограммы
extern bool Show_HistMinPeriod =true; // –исовать коридор по свечкам
                                      // с периодом MinPeriod
                                      // в виде гистограммы
extern bool Show_Signal        =true; // –исовать сигнальную
//----
double    TopBorder1[];
double    ind_buffer1[];
double    BottomBorder1[];
double    ind_buffer2[];
double    TopBorder2[];
double    BottomBorder2[];
double    Signal[];
//----
double Snake_Sum, Snake_Weight, Snake_Sum_Minus, Snake_Sum_Plus;
double indperiod,val1,val2;
string CommentStr;
//----
int init()
{
int    draw_begin;
   draw_begin=2*MaxPeriod+10;
   IndicatorBuffers(7);
   SetIndexBuffer(0,TopBorder1);
   SetIndexBuffer(1,ind_buffer1);
   SetIndexBuffer(2,BottomBorder1);
   SetIndexBuffer(3,ind_buffer2);
   SetIndexBuffer(4,TopBorder2);
   SetIndexBuffer(5,BottomBorder2);
   SetIndexBuffer(6,Signal);
   if(Show_MaxPeriod==true)
   { 
      if(Show_HistMaxPeriod==true)
      { 
         SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,2); 
         SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,2);
         SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,2);
         SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,2);
      }
      else 
      { 
         SetIndexStyle(0,DRAW_LINE,EMPTY,2); 
         SetIndexStyle(1,DRAW_NONE);
         SetIndexStyle(2,DRAW_LINE,EMPTY,2);
         SetIndexStyle(3,DRAW_NONE);
      }
   }
   else 
   { 
      SetIndexStyle(0,DRAW_NONE); 
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }
   if(Show_HistMinPeriod==true)
   { 
      SetIndexStyle(4,DRAW_HISTOGRAM);
      SetIndexStyle(5,DRAW_HISTOGRAM);
   }
   else 
   { 
      SetIndexStyle(4,DRAW_LINE);
      SetIndexStyle(5,DRAW_LINE);
   }
   if(Show_Signal==true) SetIndexStyle(6,DRAW_LINE);
   else                  SetIndexStyle(6,DRAW_NONE);
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);
   SetIndexDrawBegin(5,draw_begin);
   SetIndexDrawBegin(6,draw_begin);
   indperiod=1.0*MinPeriod*Period();
   if(indperiod<60)
   {
      CommentStr=DoubleToStr(indperiod,0);
      CommentStr=" M"+CommentStr;
   }
   else
   {
      indperiod=indperiod/60;
      if(indperiod>=24)
      {
         val1=MathAbs(MathRound(indperiod/24)-indperiod/24);
         if(val1<0.01)
         {
            CommentStr=DoubleToStr(indperiod/24,0);
            CommentStr=" D"+CommentStr;
         }
          else
         {
            CommentStr=DoubleToStr(indperiod/24,1);
            CommentStr=" D"+CommentStr;
         }
      }
      else
      {
         val1=MathAbs(MathRound(indperiod)-indperiod);
         if(val1<0.01)
         {
            CommentStr=DoubleToStr(indperiod,0);
            CommentStr=" H"+CommentStr;
         }
          else
         {
            CommentStr=DoubleToStr(indperiod,1);
            CommentStr=" H"+CommentStr;
         }
      }
   }
   CommentStr="SnakeInBorders"+CommentStr;
   if(Show_MaxPeriod==true)
   {
   indperiod=1.0*MaxPeriod*Period();
   if(indperiod<60)
      CommentStr=CommentStr+" in M"+DoubleToStr(indperiod,0);
   else
   {
      indperiod=indperiod/60;
      if(indperiod>=24)
      {
         val1=MathAbs(MathRound(indperiod/24)-indperiod/24);
         if(val1<0.01)
            CommentStr=CommentStr+" in D"+DoubleToStr(indperiod/24,0);
          else
            CommentStr=CommentStr+" in D"+DoubleToStr(indperiod/24,1);
      }
      else
      {
         val1=MathAbs(MathRound(indperiod)-indperiod);
         if(val1<0.01)
            CommentStr=CommentStr+" in H"+DoubleToStr(indperiod,0);
          else
            CommentStr=CommentStr+" in H"+DoubleToStr(indperiod,1);
      }
   }
   }
   return(0);
}
//----
void deinit()
{
  Comment("");
}
//----
int start()
{
int FirstPos, ExtCountedBars=0,i;
   if(Bars<=150) return(0);
   if(MinPeriod<21) return(0);
   if(MaxPeriod<=MinPeriod) return(0);
   ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   FirstPos=Bars-ExtCountedBars-1;
   if(FirstPos>Bars-MaxPeriod-7)
   {
      FirstPos=Bars-MaxPeriod-7;
      Signal[FirstPos+MaxPeriod]=SnakeFirstCalc(FirstPos+MaxPeriod);
      for(i=FirstPos+MaxPeriod-1;i>FirstPos;i--) SnakeNextCalc(i);
   }
   Snake(FirstPos);
   return(0);
}
//----
void Snake(int Pos)
{
int i;
   if(Pos<6) Pos=6;
   Signal[Pos]=SnakeFirstCalc(Pos);
   Drawing(Pos);
   Pos--;
   while(Pos>=5)
   {
      Signal[Pos]=SnakeNextCalc(Pos);
      Drawing(Pos);
      Pos--;
   }
   while(Pos>0)
   {
      Signal[Pos]=SnakeFirstCalc(Pos);
      Drawing(Pos);
      Pos--;
   }
   if(Pos==0) 
   {
      Signal[Pos]=iMA(NULL,0,6,0,MODE_LWMA,PRICE_TYPICAL,0);
      Drawing(Pos);
   }
   return;
}
//----
double SnakePrice(int Shift)
{
   return((2*Close[Shift]+High[Shift]+Low[Shift])/4);
}
//----
double SnakeFirstCalc(int Shift)
{
int i, j, w;
   Snake_Sum=0.0;
   if(Shift<5)
   {
      Snake_Weight=0.0;
      i=0;
      w=Shift+5;
      while(w>=Shift)
      {
         i++;
         Snake_Sum=Snake_Sum+i*SnakePrice(w);
         Snake_Weight=Snake_Weight+i;
         w--;
      }
      while(w>=0)
      {
         i--;
         Snake_Sum=Snake_Sum+i*SnakePrice(w);
         Snake_Weight=Snake_Weight+i;
         w--;
      }
   }
   else
   {
      Snake_Sum_Minus=0.0;
      Snake_Sum_Plus=0.0;
      for(j=Shift-5,i=Shift+5,w=1; w<=5; j++,i--,w++)
      {
         Snake_Sum=Snake_Sum+w*(SnakePrice(i)+SnakePrice(j));
         Snake_Sum_Minus=Snake_Sum_Minus+SnakePrice(i);
         Snake_Sum_Plus=Snake_Sum_Plus+SnakePrice(j);
      }
      Snake_Sum=Snake_Sum+6*SnakePrice(Shift);
      Snake_Sum_Minus=Snake_Sum_Minus+SnakePrice(Shift);
      Snake_Weight=36;
   }
   return(Snake_Sum/Snake_Weight);
}
//----
double SnakeNextCalc(int Shift)
{
   Snake_Sum_Plus=Snake_Sum_Plus+SnakePrice(Shift-5);
   Snake_Sum=Snake_Sum-Snake_Sum_Minus+Snake_Sum_Plus;
   Snake_Sum_Minus=Snake_Sum_Minus-SnakePrice(Shift+6)+SnakePrice(Shift);
   Snake_Sum_Plus=Snake_Sum_Plus-SnakePrice(Shift);
   return(Snake_Sum/Snake_Weight);
}
//----
void Drawing(int Shift)
{
int i;
   TopBorder1[Shift]=
   (5*Signal[ArrayMaximum(Signal,MaxPeriod,Shift)]+4*Signal[Shift])/9;
   BottomBorder1[Shift]=
   (5*Signal[ArrayMinimum(Signal,MaxPeriod,Shift)]+4*Signal[Shift])/9;
   TopBorder2[Shift]=
   (5*Signal[ArrayMaximum(Signal,MinPeriod,Shift)]+4*Signal[Shift])/9;
   ind_buffer1[Shift]=TopBorder2[Shift];
   BottomBorder2[Shift]=
   (5*Signal[ArrayMinimum(Signal,MinPeriod,Shift)]+4*Signal[Shift])/9;
   ind_buffer2[Shift]=BottomBorder2[Shift];
   if(Shift==0) ind_comment();
   return;
}
//----
void ind_comment()
{
string shortname,str;
int    i;
   shortname=CommentStr;
   str=DoubleToStr((TopBorder2[11]-BottomBorder2[11])/Point,0);
   shortname=shortname+" :   Walk .."+str+"п";
   for(i=10;i>=0;i--) 
   {
      str=DoubleToStr((TopBorder2[i]-BottomBorder2[i])/Point,0);
      shortname=shortname+".."+str+"п";
   }
   Comment(shortname);
   return;
}
//----

