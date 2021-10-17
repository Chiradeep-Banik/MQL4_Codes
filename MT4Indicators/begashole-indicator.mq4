//+------------------------------------------------------------------+
//|                                                    Begashole.mq4 |
//|                                  Copyright(c) 2010 Masaru Sasaki |
//|                                             youtarou.blogzine.jp |
//+------------------------------------------------------------------+
//
// 「免責事項」
//  *このプログラムに基づく行為の結果発生した障害、損失などについて
//    著作者は一切の責任を負いません。
//
// 「説明」
//  *ベガス方式のベガストンネルをチャート上に表示する
//   インジケーターです。
//
// 参考書籍：FXメタトレーダー入門 (PanRolling)
//           FXメタトレーダー実践プログラミング (PanRolling)
//
#property copyright "Copyright(c) 2010 Masaru Sasaki"
#property link      "youtarou.blogzine.jp"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Cyan
#property indicator_color2 Cyan
#property indicator_width1 1
#property indicator_width2 1

// 指標バッファ
double BufBegasHole1[];
double BufBegasHole2[];

// ベガスホールの移動平均値
extern int HOLE1_EMA_period = 144;
extern int HOLE2_EMA_period = 169;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   // 指標バッファの割り当て
   SetIndexBuffer(0, BufBegasHole1);
   SetIndexBuffer(1, BufBegasHole2);
   
   // 指標スタイルの設定
   SetIndexStyle(0, DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexStyle(1, DRAW_HISTOGRAM,STYLE_DOT);

   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars;
   
   for(int i=limit-1; i>=0; i-- )
   {
      BufBegasHole1[i] = iMA(NULL, 0, HOLE1_EMA_period, 0, MODE_EMA, PRICE_CLOSE, i);

      BufBegasHole2[i] = iMA(NULL, 0, HOLE2_EMA_period, 0, MODE_EMA, PRICE_CLOSE, i);

   } 
   return(0);
  }
//+------------------------------------------------------------------+