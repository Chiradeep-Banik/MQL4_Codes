//+------------------------------------------------------------------+
//| A WolfWave finder based on ZIGZAG.MQ4                            |
//| fukinagashi a t gmx p o i n t net   
//| Patched by Nen @  http://onix-trade.net/forum/index.php?showtopic=373
//| Patched again by Maumax                                         |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Blue
#define MaxAnalyze 200
#define UpperDistance 15
#define LowerDistance 5
#define Title "WW"

//---- indicator parameters
extern int ExtDepth=12;
extern int ExtDeviation=3;
extern int ExtBackstep=2;

//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];
int timeFirstBar=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
//---- drawing settings

   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
     
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);

   ArraySetAsSeries(ExtMapBuffer,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
//---- indicator short name
   IndicatorShortName("WolfWave");
//---- initialization done

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
      for (int i=1;i<=5;i++)
       {
         ObjectDelete(Title + ""+i);
       }
   
      ObjectDelete(Title + "Line-2-4");   
      ObjectDelete(Title + "Line-1-3");
      ObjectDelete(Title + "Line-1-4");
      ObjectDelete(Title + "Line-2-5");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
   int num=0;

   int Peak[MaxAnalyze],h,i,j;
   int Wolf[6];
   string WolfWave="None";
   double Winkel1, Winkel2;
   bool found=false;

   //----+ проверка количества баров на достаточность дл€ корректного расчЄта индикатора
   if (Bars-1<ExtDepth)return(0);
   //----+ ¬ведение целых переменных пам€ти дл€ пересчЄта индикатора только на неподсчитанных барах
   static int time2,time3,time4;  
   //----+ ¬ведение переменных с плавающей точкой дл€ пересчЄта индикатора только на неподсчитанных барах
   static  double ZigZag2,ZigZag3,ZigZag4;
   //----+ ¬ведение целых переменных дл€ пересчЄта индикатора только на неподсчитанных барах и получение уже подсчитанных баров
   int MaxBar,limit,supr2_bar,supr3_bar,supr4_bar;
   //---- проверка на возможные ошибки
   if (counted_bars<0)return(-1);
   //---- последний подсчитанный бар должен быть пересчитан
   if (counted_bars>0) counted_bars--;
   //---- определение номера самого старого бара, начина€ с которого будет произедЄн полый пересчЄт всех баров
   MaxBar=Bars-ExtDepth; 
   //---- определение номера стартового  бара в цикле, начина€ с которого будет произедитьс€  пересчЄт новых баров
   if (counted_bars==0 || Bars-counted_bars>2)
     {
      limit=MaxBar;
     }
   else 
     {
      //----
      supr2_bar=iBarShift(NULL,0,time2,TRUE);
      supr3_bar=iBarShift(NULL,0,time3,TRUE);
      supr4_bar=iBarShift(NULL,0,time4,TRUE);
      //----
      limit=supr3_bar;      
      if ((supr2_bar<0)||(supr3_bar<0)||(supr4_bar<0))
         {
          limit=MaxBar;
         }
     }
     
   //---- инициализаци€ нул€
   if (limit>=MaxBar || timeFirstBar!=Time[Bars-1]) 
     {
      timeFirstBar=Time[Bars-1];
      for (shift=Bars-1; shift>0;shift--) {ExtMapBuffer[shift]=0.0; ExtMapBuffer2[shift]=0.0;}
      limit=MaxBar; 
     } 
   //----  

   
   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      if (Low[shift]==val) ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0; 
              } 
           }
        }
      if (High[shift]==val) ExtMapBuffer2[shift]=val;
     }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           }
         lasthigh=-1;
        }
     }
  
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         //if(res!=0.0) ExtMapBuffer[shift]=res;
         if(res>0.0) ExtMapBuffer[shift]=res;         
        }
     }

   // ѕроверка первого луча
   i=0;j=0;
   res=0;
   for (shift=0;i<3;shift++)
     {
      if (ExtMapBuffer[shift]>0)
        {
         i++;
         if (i==1 && ExtMapBuffer[shift]==High[shift])
           {
            j=shift;
            res=ExtMapBuffer[shift];
           }
         if (i==2 && res>0 && ExtMapBuffer[shift]==High[shift])
           {
            if (ExtMapBuffer[shift]>=ExtMapBuffer[j]) ExtMapBuffer[j]=0; else ExtMapBuffer[shift]=0;
            res=0;
            i=0;
            j=0;
            shift=0;
           }
        }
     }


   //+--- ¬осстановление значений индикаторного буффера, которые могли быть утер€ны 
   if (limit<MaxBar)
     {
      ExtMapBuffer[supr2_bar]=ZigZag2; 
      ExtMapBuffer[supr3_bar]=ZigZag3; 
      ExtMapBuffer[supr4_bar]=ZigZag4; 
      for(int qqq=supr4_bar-1; qqq>supr3_bar; qqq--)ExtMapBuffer[qqq]=0; 
      for(int ggg=supr3_bar-1; ggg>supr2_bar; ggg--)ExtMapBuffer[ggg]=0;
     }
   //+---+============================================+
  
   //+--- исправление возникающих горбов 
   double vel1, vel2, vel3, vel4;
   int bar1, bar2, bar3, bar4;
   int count;
   if (limit==MaxBar)supr4_bar=MaxBar;
   for(int bar=supr4_bar; bar>=0; bar--)
    {
     if (ExtMapBuffer[bar]!=0)
      {
       count++;
       vel4=vel3;bar4=bar3;
       vel3=vel2;bar3=bar2;
       vel2=vel1;bar2=bar1;
       vel1=ExtMapBuffer[bar];bar1=bar;
       if (count<3)continue; 
       if ((vel3<vel2)&&(vel2<vel1)){ExtMapBuffer[bar2]=0;bar=bar3+1;}
       if ((vel3>vel2)&&(vel2>vel1)){ExtMapBuffer[bar2]=0;bar=bar3+1;}
       if ((vel2==vel1)&&(vel1!=0 )){ExtMapBuffer[bar1]=0;bar=bar3+1;}
     }
    } 
   //+--- запоминание времени трЄх последних перегибов «игзага и значений индикатора в этих точках 
   time2=Time[bar2];
   time3=Time[bar3];
   time4=Time[bar4];
   ZigZag2=vel2;  
   ZigZag3=vel3; 
   ZigZag4=vel4; 
   //+---          

    
// Basic Modification ==>

   i=0;
   for(h=0; h<Bars && i<MaxAnalyze; h++)
   {
      if ((ExtMapBuffer[h]!=0) || (ExtMapBuffer2[h]!=0)) {
         Peak[i]= h;
         i++;    
      }
   }
   
   for(j=0;j<i && j<MaxAnalyze && found==false;j++) {
      Wolf[1]=Peak[j+4]; // 1 High
      Wolf[2]=Peak[j+3]; // 2 Low
      Wolf[3]=Peak[j+2]; // 3 High 
      Wolf[4]=Peak[j+1]; // 4 Low 
      Wolf[5]=Peak[j+0]; // 5 High
      if (     // Buy Wolfwave
         Low[Wolf[1]]<High[Wolf[2]] &&  // 1. + 3.a.//1-3
         Low[Wolf[3]]<Low[Wolf[1]] &&   // 2. + 3.b. //3-1
         Low[Wolf[3]]<High[Wolf[4]]  // 4//3-4
         ) {
            WolfWave="Buy";
      } else if 
         (     // Sell Wolfwave
         High[Wolf[1]]>Low[Wolf[2]] &&  // 1. + 3.a.
         High[Wolf[3]]>High[Wolf[1]] &&   // 2. + 3.b. 
         High[Wolf[3]]>Low[Wolf[4]]  // 4
         ) {
            WolfWave="Sell";
         } else {
            WolfWave="Not";
      }
      
      if(WolfWave=="Buy") {
      	ObjectCreate(Title + "Line-1-3", OBJ_TREND, 0, Time[Wolf[1]],Low[Wolf[1]], Time[Wolf[3]],Low[Wolf[3]] );
        //	ObjectSet(Title + "Line-1-3",OBJPROP_RAY,0);
        	ObjectSet(Title + "Line-1-3", OBJPROP_COLOR, Lime);
          	ObjectSet(Title + "Line-1-3", OBJPROP_WIDTH, 2);
          //	ObjectSet(Title + "Line-1-3",OBJPROP_BACK,1);
          	
        	if (ObjectGetValueByShift(Title + "Line-1-3", Wolf[3]) >= Low[Wolf[3]]) {
           	ObjectCreate(Title + "1", OBJ_TEXT, 0, Time[Wolf[1]],Low[Wolf[1]]-LowerDistance*Point );
           	ObjectSetText(Title + "1", ""+DoubleToStr(1,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "2", OBJ_TEXT, 0, Time[Wolf[2]],High[Wolf[2]]+UpperDistance*Point );
           	ObjectSetText(Title + "2", ""+DoubleToStr(2,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "3", OBJ_TEXT, 0, Time[Wolf[3]],Low[Wolf[3]]-LowerDistance*Point );
           	ObjectSetText(Title + "3", ""+DoubleToStr(3,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "4", OBJ_TEXT, 0, Time[Wolf[4]],High[Wolf[4]]+UpperDistance*Point );
           	ObjectSetText(Title + "4", ""+DoubleToStr(4,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "5", OBJ_TEXT, 0, Time[Wolf[5]],Low[Wolf[5]]-LowerDistance*Point );
           	ObjectSetText(Title + "5", ""+DoubleToStr(5,0), 10, "Arial", Blue);
           	
           	ObjectCreate(Title + "Line-1-4", OBJ_TREND, 0, Time[Wolf[1]],Low[Wolf[1]], Time[Wolf[4]],High[Wolf[4]] );
           	ObjectSet(Title + "Line-1-4", OBJPROP_COLOR, Red);
           //	ObjectSet(Title + "Line-1-4",OBJPROP_RAY,0);
           	ObjectSet(Title,OBJPROP_STYLE,STYLE_DOT);
          	ObjectSet(Title + "Line-1-4", OBJPROP_WIDTH, 0);
          	ObjectSet(Title + "Line-1-4",OBJPROP_BACK,0);
          	ObjectSet(Title + "Line-2-5",OBJPROP_BACK,0);
          	
          //	ObjectCreate(Title + "Line-2-5", OBJ_TREND, 0, Time[Wolf[2]],High[Wolf[2]], Time[Wolf[5]],Low[Wolf[5]] );
            //ObjectSet(Title,OBJPROP_STYLE,STYLE_DOT);
           // ObjectSet(Title + "Line-2-5",OBJPROP_RAY,0);
            //ObjectSet(Title + "Line-2-5", OBJPROP_COLOR, Lime);
           // ObjectSet(Title + "Line-2-5", OBJPROP_WIDTH, 1);
          	
           //	Comment("Buy Wolfwave (" + TimeToStr(Time[Wolf[5]],TIME_DATE|TIME_MINUTES) + ") at " + (ObjectGetValueByShift("Line-1-3", Wolf[5])-5*Point) + " SL " + High[Wolf[5]]);
          	// found=true;
         //} //else {
           // ObjectDelete(Title + "Line-1-3");
         }
      } else if (WolfWave=="Sell") {
            ObjectCreate(Title + "Line-1-3", OBJ_TREND, 0, Time[Wolf[1]],High[Wolf[1]], Time[Wolf[3]],High[Wolf[3]] );
         //ObjectSet(Title + "Line-1-3",OBJPROP_RAY,0);
         	ObjectSet(Title + "Line-1-3", OBJPROP_COLOR, Lime);
          	ObjectSet(Title + "Line-1-3", OBJPROP_WIDTH, 2);
          //	ObjectSet(Title + "Line-1-3",OBJPROP_BACK,1);
          	
         if ( ObjectGetValueByShift(Title + "Line-1-3", Wolf[3]) <= High[Wolf[3]] ) {
           	ObjectCreate(Title + "1", OBJ_TEXT, 0, Time[Wolf[1]],High[Wolf[1]]+UpperDistance*Point );
            ObjectSetText(Title + "1", ""+DoubleToStr(1,0), 10, "Arial", Blue);
            ObjectCreate(Title + "2", OBJ_TEXT, 0, Time[Wolf[2]],Low[Wolf[2]]-LowerDistance*Point );
            ObjectSetText(Title + "2", ""+DoubleToStr(2,0), 10, "Arial", Blue);
            ObjectCreate(Title + "3", OBJ_TEXT, 0, Time[Wolf[3]],High[Wolf[3]]+UpperDistance*Point );
            ObjectSetText(Title + "3", ""+DoubleToStr(3,0), 10, "Arial", Blue);
            ObjectCreate(Title + "4", OBJ_TEXT, 0, Time[Wolf[4]],Low[Wolf[4]]-LowerDistance*Point );
            ObjectSetText(Title + "4", ""+DoubleToStr(4,0), 10, "Arial", Blue);
            ObjectCreate(Title + "5", OBJ_TEXT, 0, Time[Wolf[5]],High[Wolf[5]]+UpperDistance*Point );
            ObjectSetText(Title + "5", ""+DoubleToStr(5,0), 10, "Arial", Blue);
            
            ObjectCreate(Title + "Line-1-4", OBJ_TREND, 0, Time[Wolf[1]],High[Wolf[1]], Time[Wolf[4]],Low[Wolf[4]] );
            ObjectSet(Title + "Line-1-4", OBJPROP_COLOR, Red);
            //ObjectSet(Title + "Line-1-4",OBJPROP_RAY,0);
            ObjectSet(Title,OBJPROP_STYLE,STYLE_DOT);
            ObjectSet(Title + "Line-1-4", OBJPROP_WIDTH, 0);
            ObjectSet(Title + "Line-1-4",OBJPROP_BACK,0);
            
            
           // ObjectCreate(Title + "Line-2-5", OBJ_TREND, 0, Time[Wolf[2]],Low[Wolf[2]], Time[Wolf[5]],High[Wolf[5]] );
           //// ObjectSet(Title,OBJPROP_STYLE,STYLE_DOT);
           // ObjectSet(Title + "Line-2-5",OBJPROP_RAY,0);
           // ObjectSet(Title + "Line-2-5", OBJPROP_COLOR, Yellow);
           // ObjectSet(Title + "Line-2-5", OBJPROP_WIDTH, 1);
          //  ObjectSet(Title + "Line-2-5",OBJPROP_BACK,0);
      
    
            // found=true;
         } //else {
                //ObjectDelete(Title + "Line-1-3");
                 ObjectsRedraw();
         //}
      } 
   }
   return(0);
  }
//+------------------------------------------------------------------+