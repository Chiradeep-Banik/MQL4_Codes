#property  copyright "Copyright © 2005, FxCompas Project."
#property  link "http://www.fxcompas.com"

#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Red
#property  indicator_color2  Cyan 
#property  indicator_level1  3
#property  indicator_level2  11
#property  indicator_level3  15.5
#property  indicator_level4  20
#property  indicator_level5  28
#property  indicator_level6  0
#property  indicator_level7  31
#property  indicator_minimum -1
#property  indicator_maximum 32

double arr_global_76[];
extern int    key = 678999942;
extern double Smooth = 1;
double var_92 = 100;
extern int    bars = 1000;
int    var_104 = 0;
extern int    Progression = 8;
extern int    Len = 3;
extern int    Sensitivity = 30;
int    var_120 = 1;
int    var_124 = 0;
double var_128 = 0;
double var_136;
double var_144;
double var_152;
double var_160;
double var_168;
double var_176;
double var_184;
double var_192;
double var_200 = 0;
int    var_208;
int    var_212;
int    var_216;
int    var_220;
int    var_224;
int    var_228;
int    var_232;
int    var_236;
int    var_240;
int    var_244;
int    var_248;
int    var_252;
int    var_256 = 0;
double var_260;
double var_268;
double var_276;
double var_284;
double var_292;
double var_300;
double var_308;
double var_316;
double var_324;
double var_332;
double var_340;
double var_348;
double var_356;
double var_364;
double var_372;
double var_380;
double var_388;
double var_396;
double var_404;
double var_412;
double var_420;
double var_428;
double var_436;
double var_444;
double var_452;
double var_460 = 0;
int    var_468;
int    var_472;
int    var_476;
int    var_480;
int    var_484;
int    var_488 = 0;
double arr_global_492[128];
double arr_global_496[128];
double arr_global_500[11];
double arr_global_504[62];
double arr_global_508[300];
int    var_512;
int    var_516;
int    var_520;
int    var_524;
int    var_528;
int    var_532;
double var_536;
double var_544;
int    var_552;
double arr_global_556[];
double arr_global_560[15000];
double arr_global_564[15000];
double var_568;
double var_576 = 0;
double var_584;
double var_592;
double var_600 = 0;

//+------------------------------------------------------------------+

int init()
{
for (var_208 = 0; var_208 < 128; var_208++) arr_global_492[var_208] = 0.0;
for (var_208 = 0; var_208 < 128; var_208++) arr_global_496[var_208] = 0.0;
for (var_208 = 0; var_208 < 11;  var_208++) arr_global_500[var_208] = 0.0;
for (var_208 = 0; var_208 < 62;  var_208++) arr_global_504[var_208] = 0.0;
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,arr_global_76);
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,arr_global_556);
return(0);
}

//+------------------------------------------------------------------+

int start()
{
int    var_start_0;
int    var_start_4;
int    var_start_8;

Comment("Копия #10049");
var_start_0 = 3006;
var_start_4 = 7;
var_start_8 = 1;

if ((Year() >= 3006) && (Month() >= 7) && (Day() >= var_start_8))
   {
   Comment("Индикатор не может быть загружен. Обратитесь за обновлением!");
   return(-1);
   }

if ((Year() >= var_start_0) && (Month() >= var_start_4) && (Day() >= var_start_8))
   {
   Comment("Индикатор не может быть загружен. Обратитесь за обновлением!");
   return(-1);
   }
      else
   {
   Comment("Копия #10049");
   switch (key)
      {
      case 34562788: loadJMA(); break;
      default: if (Bars > var_600)
                  {
                  var_600 = Bars;
                  int var_start_16 = 0;
                  for (int i = 0; i < bars; i++)
                     {
                     var_584 = 0;
                     var_592 = 0;
                     for (int var_start_24 = Len; var_start_24 <= Len + Progression * Sensitivity; var_start_24 = var_start_24 + Progression)
                        {
                        var_568 = iCustom(NULL,0,"ULTRA_TREND",34562788,var_start_24,bars,0,i);
                        var_576 = iCustom(NULL,0,"ULTRA_TREND",34562788,var_start_24,bars,0,i + 1);
                        if (var_568 > var_576) var_584++; else var_592++;
                        }
                     arr_global_560[i] = var_584;
                     arr_global_564[i] = var_592;
                     }
                  lenars(arr_global_560,1);
                  lenars(arr_global_564,2);
                  return(0);
                  }
      }
   }
return(0);
}

//+------------------------------------------------------------------+

void loadJMA()
{
double var_loadJMA_0;

var_220 = 63;
var_224 = 64;
if (var_120 == 1)
   {
   for (var_208 = 1; var_208 < var_220 + 1; var_208++)  arr_global_492[var_208] = -1000000;
   for (var_208 = var_224; var_208 < 128; var_208++) arr_global_492[var_208] = 1000000;
   var_120 = 0;
   }

var_468 = 1;
if (Smooth <= 1.0) var_380 = 0.0000000001; else var_380 = (Smooth - 1.0) / 2;

if (var_92 < -100.0) { var_268 = 0.5; } else
if (var_92 > 100.0)  { var_268 = 2.5; } else
                     { var_268 = var_92 / 100 + 1.5; }

var_144 = MathLog(MathSqrt(var_380));
var_152 = var_144;
if ((var_144 / MathLog(2.0) + 2.0) < 0.0) var_160 = 0; else var_160 = var_152 / MathLog(2.0) + 2.0;
var_404 = var_160;
if ((var_404 - 2.0) >= 0.5) var_388 = var_404 - 2.0; else var_388 = 0.5;
var_372 = MathSqrt(var_380) * var_404;
var_396 = var_372 / (var_372 + 1.0);
var_380 = var_380 * 0.9;
var_332 = var_380 / (var_380 + 2.0);
var_468 = 1;
if (bars == 0) bars = Bars;
for (var_124 = bars + 1000; var_124 >= 0; var_124--)
   {
   switch (var_104)
      {
      case 0: var_loadJMA_0 = Close[var_124]; break;
      case 1: var_loadJMA_0 = Open[var_124];  break;
      case 2: var_loadJMA_0 = (Open[var_124] + High[var_124] + Low[var_124] + Close[var_124]) / 4; break;
      case 3: var_loadJMA_0 = High[var_124];  break;
      case 4: var_loadJMA_0 = Low[var_124];   break;
      default:var_loadJMA_0 = Close[var_124];
      }
   if (var_484 < 61)
      {
      var_484 = var_484 + 1;
      arr_global_504[var_484] = var_loadJMA_0;
      }
   if (var_484 > 30)
      {
      if (var_468 != 0)
         {
         var_468 = 0;
         var_212 = 0;
         for (var_208 = 1; var_208 < 30; var_208++)
            {
            if (arr_global_504[var_208 + 1] != arr_global_504[var_208]) var_212 = 1;
            }
         var_472 = var_212 * 30;
         if (var_472 == 0) var_308 = var_loadJMA_0; else var_308 = arr_global_504[1];
         var_276 = var_308;
         if (var_472 > 29) var_472 = 29;
         }
            else
         {
         var_472 = 0;
         }
      for (var_208 = var_472; var_208 >= 0; var_208--)
         {
         if (var_208 == 0) var_260 = var_loadJMA_0; else var_260 = arr_global_504[31 - var_208];
         var_292 = var_260 - var_276;
         var_324 = var_260 - var_308;
         if (MathAbs(var_292) > MathAbs(var_324)) var_152 = MathAbs(var_292); else var_152 = MathAbs(var_324);
         var_412 = var_152;
         var_136 = var_412 + 0.0000000001;
         if (var_236 <= 1) var_236 = 127; else var_236--;
         if (var_240 <= 1) var_240 = 10; else var_240--;
         if (var_256 < 128) var_256++;
         var_176 = var_176 + var_136 - arr_global_500[var_240];
         arr_global_500[var_240] = var_136;
         if (var_256 > 10) var_200 = var_176 * 0.1; else var_200 = var_176 / var_256;
         if (var_256 == 30) var_516 = 0;
         if (var_256 > 127)
            {
            var_184 = arr_global_496[var_236];
            arr_global_496[var_236] = var_200;
            var_252 = 64;
            var_244 = var_252;
            var_512 = var_244;
            while (var_252 > 1)
               {
               if (arr_global_492[var_244] < var_184)
                  {
                  var_252 = var_252 / 2;
                  var_244 = var_244 + var_252;
                  var_512 = var_244;
                  }
                     else
                  {
                  if (arr_global_492[var_244] <= var_184)
                     {
                     var_252 = 1;
                     }
                        else
                     {
                     var_252 = var_252 / 2;
                     var_244 = var_244 - var_252;
                     var_512 = var_244;
                     }
                  }
               }
            }
               else
            {
            arr_global_496[var_236] = var_200;
            if (var_220 + var_224 > 127)
               {
               var_224--;
               var_244 = var_224;
               var_512 = var_244;
               }
                  else
               {
               var_220++;
               var_244 = var_220;
               var_512 = var_244;
               }
            if (var_220 > 96) var_228 = 96; else var_228 = var_220;
            if (var_224 < 32) var_232 = 32; else var_232 = var_224;
            }
         var_252 = 64;
         var_248 = var_252;
         while (var_252 > 1)
            {
            if (arr_global_492[var_248] >= var_200)
               {
               if (arr_global_492[var_248 - 1] <= var_200)
                  {
                  var_252 = 1;
                  }
                     else
                  {
                  var_252 = var_252 / 2;
                  var_248 = var_248 - var_252;
                  }
               }
                  else
               {
               var_252 = var_252 / 2;
               var_248 = var_248 + var_252;
               }
            if ((var_248 == 127) && (var_200 > arr_global_492[127])) var_248 = 128;
            }
         if (var_256 > 127)
            {
            if (var_244 >= var_248)
               {
               if ((var_228 + 1 > var_248) && (var_232 - 1 < var_248))
                  {
                  var_192 = var_192 + var_200;
                  }
                     else
                  {
                  if ((var_232 > var_248) && (var_232 - 1 < var_244))
                     {
                     var_192 = var_192 + arr_global_492[var_232 - 1];
                     }
                  }
               }
                  else
               {
               if (var_232 >= var_248)
                  {
                  if ((var_228 + 1 < var_248) && (var_228 + 1 > var_244))
                     {
                     var_192 = var_192 + arr_global_492[var_228 + 1];
                     }
                  }
                     else
                  {
                  if (var_228 + 2 > var_248)
                     {
                     var_192 = var_192 + var_200;
                     }
                        else
                     {
                     if ((var_228 + 1 < var_248) && (var_228 + 1 > var_244))
                        {
                        var_192 = var_192 + arr_global_492[var_228 + 1];
                        }
                     }
                  }
               }
            if (var_244 > var_248)
               {
               if ((var_232 - 1 < var_244) && (var_228 + 1 > var_244))
                  {
                  var_192 = var_192 - arr_global_492[var_244];
                  }
                     else
                  {
                  if ((var_228 < var_244) && (var_228 + 1 > var_248))
                     {
                     var_192 = var_192 - arr_global_492[var_228];
                     }
                  }
               }
                  else
               {
               if ((var_228 + 1 > var_244) && (var_232 - 1 < var_244))
                  {
                  var_192 = var_192 - arr_global_492[var_244];
                  }
                     else
                  {
                  if ((var_232 > var_244) && (var_232 < var_248))
                     {
                     var_192 = var_192 - arr_global_492[var_232];
                     }
                  }
               }
            }
         if (var_244 <= var_248)
            {
            if (var_244 >= var_248)
               {
               arr_global_492[var_248] = var_200;
               }
                  else
               {
               for (var_516 = var_244 + 1; var_516 < var_248; var_516++) { arr_global_492[var_516 - 1] = arr_global_492[var_516]; }
               arr_global_492[var_248 - 1] = var_200;
               }
            }
               else
            {
            for (var_520 = var_244 - 1; var_520 >= var_248; var_520--) { arr_global_492[var_520 + 1] = arr_global_492[var_520]; }
            arr_global_492[var_248] = var_200;
            }
         if (var_256 <= 127)
            {
            var_192 = 0;
            for (var_528 = var_232; var_528 < var_228 + 1; var_528++) var_192 = var_192 + arr_global_492[var_528];
            }
         var_348 = var_192 / (var_228 - var_232 + 1);
         if (var_488 + 1 > 31) var_488 = 31; else var_488++;
         if (var_488 <= 30)
            {
            if (var_292 > 0.0) var_276 = var_260; else var_276 = var_260 - var_292 * var_396;
            if (var_324 < 0.0) var_308 = var_260; else var_308 = var_260 - var_324 * var_396;
            var_436 = var_loadJMA_0;
            if (var_488 != 30) continue;
            var_444 = var_loadJMA_0;
            if (MathCeil(var_372) >= 1.0) var_168 = MathCeil(var_372); else var_168 = 1;
            var_480 = var_168;
            if (MathFloor(var_372) >= 1.0) var_152 = MathFloor(var_372); else var_152 = 1;
            var_476 = var_152;
            if (var_480 == var_476)
               {
               var_356 = 1;
               }
                  else
               {
               var_168 = var_480 - var_476;
               var_356 = (var_372 - var_476) / var_168;
               }
            if (var_476 <= 29) var_212 = var_476; else var_212 = 29;
            if (var_480 <= 29) var_216 = var_480; else var_216 = 29;
            var_420 = (var_loadJMA_0 - arr_global_504[var_484 - var_212]) * (1 - var_356) / var_476 + (var_loadJMA_0 - arr_global_504[var_484 - var_216]) * var_356 / var_480;
            }
               else
            {
            if (var_404 >= MathPow(MathAbs(var_412 / var_348),var_388)) var_144 = MathPow(MathAbs(var_412 / var_348),var_388); else var_144 = var_404;
            if (var_144 < 1.0)
               {
               var_152 = 1.0;
               }
                  else
               {
               if (var_404 >= MathPow(MathAbs(var_412 / var_348),var_388)) var_160 = MathPow(MathAbs(var_412 / var_348),var_388); else var_160 = var_404;
               var_152 = var_160;
               }
            var_340 = var_152;
            var_364 = MathPow(var_396,MathSqrt(var_340));
            if (var_292 > 0.0) var_276 = var_260; else var_276 = var_260 - var_292 * var_364;
            if (var_324 < 0.0) var_308 = var_260; else var_308 = var_260 - var_324 * var_364;
            }
         }
      if (var_488 > 30)
         {
         var_300 = MathPow(var_332,var_340);
         var_444 = (1 - var_300) * var_loadJMA_0 + var_300 * var_444;
         var_452 = (var_loadJMA_0 - var_444) * (1 - var_332) + var_332 * var_452;
         var_460 = var_268 * var_452 + var_444;
         var_284 = var_300 * (-2.0);
         var_316 = var_300 * var_300;
         var_428 = var_284 + var_316 + 1.0;
         var_420 = (var_460 - var_436) * var_428 + var_316 * var_420;
         var_436 = var_436 + var_420;
         }
      }
   var_128 = var_436;
   arr_global_76[var_124] = var_128;
   }
return;
}

//+------------------------------------------------------------------+

void lenars(double arr_lenars_0[], int inp_lenars_4)
{
double var_lenars_8;

var_220 = 63;
var_224 = 64;
if (var_120 == 1)
   {
   for (var_208 = 1; var_208 < var_220 + 1; var_208++) arr_global_492[var_208] = -1000000;
   for (var_208 = var_224; var_208 < 128; var_208++) arr_global_492[var_208] = 1000000;
   var_120 = 0;
   }

var_468 = 1;
if (Smooth <= 1.0) var_380 = 0.0000000001; else var_380 = (Smooth - 1.0) / 2;

if (var_92 < -100.0) { var_268 = 0.5; } else
if (var_92 > 100.0)  { var_268 = 2.5; } else
                     { var_268 = var_92 / 100 + 1.5; }

var_144 = MathLog(MathSqrt(var_380));
var_152 = var_144;
if (var_144 / MathLog(2.0) + 2.0 < 0.0) var_160 = 0; else var_160 = var_152 / MathLog(2.0) + 2.0;
var_404 = var_160;
if (var_404 - 2.0 >= 0.5) var_388 = var_404 - 2.0; else var_388 = 0.5;
var_372 = MathSqrt(var_380) * var_404;
var_396 = var_372 / (var_372 + 1.0);
var_380 = var_380 * 0.9;
var_332 = var_380 / (var_380 + 2.0);
var_468 = 1;
if (bars == 0) bars = Bars;

for (var_124 = bars + 30; var_124 >= 0; var_124--)
   {
   var_lenars_8 = arr_lenars_0[var_124];
   if (var_484 < 61)
      {
      var_484 = var_484 + 1;
      arr_global_504[var_484] = var_lenars_8;
      }
   if (var_484 > 30)
      {
      if (var_468 != 0)
         {
         var_468 = 0;
         var_212 = 0;
         for (var_208 = 1; var_208 < 30; var_208++)
            {
            if (arr_global_504[var_208 + 1] != arr_global_504[var_208]) var_212 = 1;
            }
         var_472 = var_212 * 30;
         if (var_472 == 0) var_308 = var_lenars_8; else var_308 = arr_global_504[1];
         var_276 = var_308;
         if (var_472 > 29) var_472 = 29;
         }
            else
         {
         var_472 = 0;
         }
      for (var_208 = var_472; var_208 >= 0; var_208--)
         {
         if (var_208 == 0) var_260 = var_lenars_8; else var_260 = arr_global_504[31 - var_208];
         var_292 = var_260 - var_276;
         var_324 = var_260 - var_308;
         if (MathAbs(var_292) > MathAbs(var_324)) var_152 = MathAbs(var_292); else var_152 = MathAbs(var_324);
         var_412 = var_152;
         var_136 = var_412 + 0.0000000001;
         if (var_236 <= 1) var_236 = 127; else var_236--;
         if (var_240 <= 1) var_240 = 10; else var_240--;
         if (var_256 < 128) var_256++;
         var_176 = var_176 + var_136 - arr_global_500[var_240];
         arr_global_500[var_240] = var_136;
         if (var_256 > 10) var_200 = var_176 * 0.1; else var_200 = var_176 / var_256;
         if (var_256 == 30) var_516 = 0;
         if (var_256 > 127)
            {
            var_184 = arr_global_496[var_236];
            arr_global_496[var_236] = var_200;
            var_252 = 64;
            var_244 = var_252;
            var_512 = var_244;
            while (var_252 > 1)
               {
               if (arr_global_492[var_244] < var_184)
                  {
                  var_252 = var_252 / 2;
                  var_244 = var_244 + var_252;
                  var_512 = var_244;
                  }
                     else
                  {
                  if (arr_global_492[var_244] <= var_184)
                     {
                     var_252 = 1;
                     }
                        else
                     {
                     var_252 = var_252 / 2;
                     var_244 = var_244 - var_252;
                     var_512 = var_244;
                     }
                  }
               }
            }
               else
            {
            arr_global_496[var_236] = var_200;
            if (var_220 + var_224 > 127)
               {
               var_224--;
               var_244 = var_224;
               var_512 = var_244;
               }
                  else
               {
               var_220++;
               var_244 = var_220;
               var_512 = var_244;
               }
            if (var_220 > 96) var_228 = 96; else var_228 = var_220;
            if (var_224 < 32) var_232 = 32; else var_232 = var_224;
            }
         var_252 = 64;
         var_248 = var_252;
         while (var_252 > 1)
            {
            if (arr_global_492[var_248] >= var_200)
               {
               if (arr_global_492[var_248 - 1] <= var_200)
                  {
                  var_252 = 1;
                  }
                     else
                  {
                  var_252 = var_252 / 2;
                  var_248 = var_248 - var_252;
                  }
               }
                  else
               {
               var_252 = var_252 / 2;
               var_248 = var_248 + var_252;
               }
            if ((var_248 == 127) && (var_200 > arr_global_492[127])) var_248 = 128;
            }
         if (var_256 > 127)
            {
            if (var_244 >= var_248)
               {
               if ((var_228 + 1 > var_248) && (var_232 - 1 < var_248))
                  {
                  var_192 = var_192 + var_200;
                  }
                     else
                  {
                  if ((var_232 > var_248) && (var_232 - 1 < var_244))
                     {
                     var_192 = var_192 + arr_global_492[var_232 - 1];
                     }
                  }
               }
                  else
               {
               if (var_232 >= var_248)
                  {
                  if ((var_228 + 1 < var_248) && (var_228 + 1 > var_244))
                     {
                     var_192 = var_192 + arr_global_492[var_228 + 1];
                     }
                  }
                     else
                  {
                  if (var_228 + 2 > var_248)
                     {
                     var_192 = var_192 + var_200;
                     }
                        else
                     {
                     if ((var_228 + 1 < var_248) && (var_228 + 1 > var_244))
                        {
                        var_192 = var_192 + arr_global_492[var_228 + 1];
                        }
                     }
                  }
               }
            if (var_244 > var_248)
               {
               if ((var_232 - 1 < var_244) && (var_228 + 1 > var_244))
                  {
                  var_192 = var_192 - arr_global_492[var_244];
                  }
                     else
                  {
                  if ((var_228 < var_244) && (var_228 + 1 > var_248))
                     {
                     var_192 = var_192 - arr_global_492[var_228];
                     }
                  }
               }
                  else
               {
               if ((var_228 + 1 > var_244) && (var_232 - 1 < var_244))
                  {
                  var_192 = var_192 - arr_global_492[var_244];
                  }
                     else
                  {
                  if ((var_232 > var_244) && (var_232 < var_248))
                     {
                     var_192 = var_192 - arr_global_492[var_232];
                     }
                  }
               }
            }
         if (var_244 <= var_248)
            {
            if (var_244 >= var_248)
               {
               arr_global_492[var_248] = var_200;
               }
                  else
               {
               for (var_516 = var_244 + 1; var_516 < var_248; var_516++) arr_global_492[var_516 - 1] = arr_global_492[var_516];
               arr_global_492[var_248 - 1] = var_200;
               }
            }
               else
            {
            for (var_520 = var_244 - 1; var_520 >= var_248; var_520--) arr_global_492[var_520 + 1] = arr_global_492[var_520];
            arr_global_492[var_248] = var_200;
            }
         if (var_256 <= 127)
            {
            var_192 = 0;
            for (var_528 = var_232; var_528 < var_228 + 1; var_528++) var_192 = var_192 + arr_global_492[var_528];
            }
         var_348 = var_192 / (var_228 - var_232 + 1);
         if (var_488 + 1 > 31) var_488 = 31; else var_488++;
         if (var_488 <= 30)
            {
            if (var_292 > 0.0) var_276 = var_260; else var_276 = var_260 - var_292 * var_396;
            if (var_324 < 0.0) var_308 = var_260; else var_308 = var_260 - var_324 * var_396;
            var_436 = var_lenars_8;
            if (var_488 != 30) continue;
            var_444 = var_lenars_8;
            if (MathCeil(var_372) >= 1.0) var_168 = MathCeil(var_372); else var_168 = 1;
            var_480 = var_168;
            if (MathFloor(var_372) >= 1.0) var_152 = MathFloor(var_372); else var_152 = 1;
            var_476 = var_152;
            if (var_480 == var_476)
               {
               var_356 = 1;
               }
                  else
               {
               var_168 = var_480 - var_476;
               var_356 = (var_372 - var_476) / var_168;
               }
            if (var_476 <= 29) var_212 = var_476; else var_212 = 29;
            if (var_480 <= 29) var_216 = var_480; else var_216 = 29;
            var_420 = (var_lenars_8 - arr_global_504[var_484 - var_212]) * (1 - var_356) / var_476 + (var_lenars_8 - arr_global_504[var_484 - var_216]) * var_356 / var_480;
            }
               else
            {
            if (var_404 >= MathPow(MathAbs(var_412 / var_348),var_388)) var_144 = MathPow(MathAbs(var_412 / var_348),var_388); else var_144 = var_404;
            if (var_144 < 1.0)
               {
               var_152 = 1.0;
               }
                  else
               {
               if (var_404 >= MathPow(MathAbs(var_412 / var_348),var_388)) var_160 = MathPow(MathAbs(var_412 / var_348),var_388); else var_160 = var_404;
               var_152 = var_160;
               }
            var_340 = var_152;
            var_364 = MathPow(var_396,MathSqrt(var_340));
            if (var_292 > 0.0) var_276 = var_260; else var_276 = var_260 - var_292 * var_364;
            if (var_324 < 0.0) var_308 = var_260; else var_308 = var_260 - var_324 * var_364;
            }
         }
      if (var_488 > 30)
         {
         var_300 = MathPow(var_332,var_340);
         var_444 = (1 - var_300) * var_lenars_8 + var_300 * var_444;
         var_452 = (var_lenars_8 - var_444) * (1 - var_332) + var_332 * var_452;
         var_460 = var_268 * var_452 + var_444;
         var_284 = var_300 * (-2.0);
         var_316 = var_300 * var_300;
         var_428 = var_284 + var_316 + 1.0;
         var_420 = (var_460 - var_436) * var_428 + var_316 * var_420;
         var_436 = var_436 + var_420;
         }
      }
   var_128 = var_436;
   if (inp_lenars_4 == 1) arr_global_76[var_124] = var_128; else arr_global_556[var_124] = var_128;
   }
return;
}
