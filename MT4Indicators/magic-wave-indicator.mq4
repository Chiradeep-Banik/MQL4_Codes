//-----------------------------------------------------------------------------------------------------------------------------//
#property copyright             "Copyright © 2016, Crossluck"
#property version               "1.00"
#property description           "Magic Wave"
#property strict
#property indicator_chart_window
#property indicator_buffers      2
//-----------------------------------------------------------------------------------------------------------------------------//
extern string S1                 = "Настройки индикатора Envelopes";
extern int    ma_period          = 14;                 //Период
extern int    ma_shift           = 0;                  //Сдвиг
extern double deviation          = 0.10;               //Отклонение
extern string S2                 = "Настройки графики";
extern bool   ClearAllObjects    = true;               //Удалить все объекты
extern int    CountedBars        = 1000;               //Пересчёт баров
extern int    SizeUp             = 1;                  //Размер верхней стрелки
extern int    SizeDown           = 1;                  //Размер нижней стрелки
extern color  ColorUp            = Green;              //Цвет верхней стрелки
extern color  ColorDown          = Red;                //Цвет нижней стрелки
extern int    IndentUp           = 50;                 //Отступ верхней стрелки
extern int    IndentDown         = 50;                 //Отступ нижней стрелки
extern int    CodeUp             = 217;                //Код верхней стрелки
extern int    CodeDown           = 218;                //Код нижней стрелки
extern string S3                 = "Настройки звука";
extern string SoundFile          = "alert.wav";        //Звуковой файл
extern bool   UseSound           = true;               //Использование звука
extern bool   UseNotification    = false;              //Использование телефона
extern bool   UseMail            = false;              //Использование почты
//-----------------------------------------------------------------------------------------------------------------------------//
int           current            = 0;
double        up[];
double        down[];
bool          buy                = false;
bool          sell               = false;
bool          soundbuy           = false; 
bool          soundsell          = false;
//-----------------------------------------------------------------------------------------------------------------------------//
int OnInit(){
   if(ClearAllObjects)ObjectsDeleteAll();
   IndicatorShortName("Magic Wave");
   IndicatorBuffers(2);
   SetIndexBuffer(0,up);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,SizeUp,ColorUp);
   SetIndexArrow(0,CodeUp);
   SetIndexBuffer(1,down);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,SizeDown,ColorDown);
   SetIndexArrow(1,CodeDown);
   return(INIT_SUCCEEDED);
}
int deinit(){
   if(ClearAllObjects)ObjectsDeleteAll();
   return(0);
}
int start(){
   Tick();
   return(0);
}
void Tick(){
   for(int i=CountedBars;i>=0;i--){
      current=i;
      up();
      down();
   }
}
void up(){
      if(buy==false)
      if(current<Bars)
      if(Open[current]>(Close[current+1])
      &&
      (Open[current+1]>(Close[current+2])
      &&
      (Open[current]>(Low[current+1])
      &&
      (Open[current+1]>(Low[current+2])
      &&
      (High[current]>(iEnvelopes(Symbol(),Period(),ma_period,MODE_SMMA,ma_shift,PRICE_OPEN,deviation,MODE_UPPER,current))))))){
         arrows_up();
   }
}
void arrows_up(){
   up[current]=Low[current]-IndentUp*Point();
   buy=true;
   sell=false;
}
void down(){
      if(sell==false)
      if(current<Bars)
      if(Open[current]<(Close[current+1])
      &&
      (Open[current+1]<(Close[current+2])
      &&
      (Open[current]<(High[current+1])
      &&
      (Open[current+1]<(High[current+2])
      &&
      (Low[current]<(iEnvelopes(Symbol(),Period(),ma_period,MODE_SMMA,ma_shift,PRICE_OPEN,deviation,MODE_LOWER,current))))))){
         arrows_down();
   }
}
void arrows_down(){
   down[current]=High[current]+IndentDown*Point();
   buy=false;
   sell=true;
   if(up[0]!=EMPTY_VALUE&&up[0]!=0&&soundbuy){
      soundbuy=false;
      if(UseSound)PlaySound(SoundFile);
      Alert("(Magic Wave)" " Поступил сигнал на покупку по символу " + Symbol() + ", на тайм-фрейме " + (string)Period() + " мин.," + " по цене " + (string)Bid); 
      if(UseMail)
      SendMail("(Magic Wave)" " Поступил сигнал на покупку по символу.. ",  " Поступил сигнал на покупку по символу " + Symbol()+ ", на тайм-фрейме " + (string)Period() + " мин" + ", по цене " + (string)Bid );
      if(UseNotification)
      SendNotification("(Magic Wave)" " Поступил сигнал на покупку по символу " + Symbol() + ", на тайм-фрейме " + (string)Period() + " мин " + ", по цене " + (string)Bid);    
   }
   if(!soundbuy&&(up[0]==EMPTY_VALUE||up[0]==0))soundbuy=true;
   if(down[0]!=EMPTY_VALUE&&down[0]!=0&&soundsell){
      soundsell=false;
      if(UseSound)PlaySound(SoundFile);
      Alert("(Magic Wave)" " Поступил сигнал на продажу по символу " + Symbol()+ ", на тайм-фрейе " + (string)Period() + " мин.," + " по цене " + (string)Bid);
      if(UseMail)
      SendMail("(Magic Wave)" " Поступил сигнал на продажу по символу.. ",  " Поступил сигнал на продажу по символу " + Symbol()+ ", на тайм-фрейе " + (string)Period()+ " минут" + ", по цене " + (string)Bid );
      if(UseNotification)
      SendNotification("(Magic Wave)" " Поступил сигнал на продажу по символу " + Symbol() + ", на тайм-фрейме " + (string)Period() + " минут " + ", по цене " + (string)Bid);  
   }
   if(!soundsell&&(down[0]==EMPTY_VALUE||down[0]==0))soundsell=true;
}
//END -----------------------------------------------------------------------------------------------------------------------------//