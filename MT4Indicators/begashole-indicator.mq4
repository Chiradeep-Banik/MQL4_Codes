//+------------------------------------------------------------------+
//|                                                    Begashole.mq4 |
//|                                  Copyright(c) 2010 Masaru Sasaki |
//|                                             youtarou.blogzine.jp |
//+------------------------------------------------------------------+
//
// �u�Ɛӎ����v
//  *���̃v���O�����Ɋ�Â��s�ׂ̌��ʔ���������Q�A�����Ȃǂɂ���
//    ����҂͈�؂̐ӔC�𕉂��܂���B
//
// �u�����v
//  *�x�K�X�����̃x�K�X�g���l�����`���[�g��ɕ\������
//   �C���W�P�[�^�[�ł��B
//
// �Q�l���ЁFFX���^�g���[�_�[���� (PanRolling)
//           FX���^�g���[�_�[���H�v���O���~���O (PanRolling)
//
#property copyright "Copyright(c) 2010 Masaru Sasaki"
#property link      "youtarou.blogzine.jp"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Cyan
#property indicator_color2 Cyan
#property indicator_width1 1
#property indicator_width2 1

// �w�W�o�b�t�@
double BufBegasHole1[];
double BufBegasHole2[];

// �x�K�X�z�[���̈ړ����ϒl
extern int HOLE1_EMA_period = 144;
extern int HOLE2_EMA_period = 169;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   // �w�W�o�b�t�@�̊��蓖��
   SetIndexBuffer(0, BufBegasHole1);
   SetIndexBuffer(1, BufBegasHole2);
   
   // �w�W�X�^�C���̐ݒ�
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