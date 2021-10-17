//+------------------------------------------------------------------+
//|                                                         AMkA.mq4 |
//|                                 Copyright � 2006, D&S kiriyenko. |
//|                 http://groups.google.com/group/expert-developing |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, D&S Kiriyenko."
#property link      "http://groups.google.com/group/expert-developing"
//---- 
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 2
#property indicator_color3 Blue
#property indicator_width3 2
//+------------------------------------------------------------------+
//| ����������������                                                 |
//+------------------------------------------------------------------+
//---- ��������� ���������
#define INDICATOR_SHORT_NAME "AMkA"
#define MAIN "AMkA line"
#define UP   "UpTrend point"
#define DOWN "DownTrend point"
//+------------------------------------------------------------------+
//| ������� ����������                                               |
//+------------------------------------------------------------------+
//---- �������
extern int       periodAMA    = 9;    //������ ������� �-�� �������������
extern double    nfast        = 2;    //������ EMA ��� ������������ �����
extern double    nslow        = 30;   //������ EMA ��� �������������� �����
//---- ������ ������������ ���������
extern double    Pow          = 2.0;  //������� ������������� 
//---- ������ ��������
extern double    dK           = 1.0;  //����������� ��� �������
extern bool      use_stdev    = true; //������������ ����������� ����������
//---- ��������� � ����
extern int       app_price    = 5;    //�� ��������� - � ����������
//+------------------------------------------------------------------+
//| ���������� ����������                                            |
//+------------------------------------------------------------------+
//---- ������
double kAMAbuffer[];
double kAMAupsig[];
double kAMAdownsig[];
//---- ������������ ������������
double slowSC, fastSC;
//---- ���������� ����������
double ddAMA[];
//+------------------------------------------------------------------+
//| ������� �������� � ������ ����������                             |
//+------------------------------------------------------------------+
bool InsertDif(double a)
  {
//---- ��������, �������� �� ������
   for(int i = 0; i < periodAMA; i++) //��� ���� ��������� �������
     if(ddAMA[i] == 0) //���� ������� ����� ����
       {
         ddAMA[i] = a; //��������� �������� � ���� �������
         return (true); //� ������ �����������
       }
//---- ������ ��� ��������, ����� ��������� ������� � �����
   for(i = 0; i < periodAMA-1; i++) //��� �������� �������, ����� ����������
       ddAMA[i] = ddAMA[i+1]; //�������� ����� �� ���� �������
   ddAMA[periodAMA-1] = a; //� ���������� �������� � ����� ������ �������
   return (true); //����� ���� ������ �����������
  }
//+------------------------------------------------------------------+
//| ������ ���� ����                                                 |
//+------------------------------------------------------------------+
double Price(int i, int app = PRICE_TYPICAL)
  {
   switch(app)
     {
       case PRICE_CLOSE:    return(Close[i]);                          break;
       case PRICE_OPEN:     return(Open[i]);                           break;
       case PRICE_HIGH:     return(High[i]);                           break;
       case PRICE_LOW:      return(Low[i]);                            break;
       case PRICE_MEDIAN:   return((High[i] + Low[i])/2);              break;
       case PRICE_TYPICAL:  return((High[i] + Low[i] + Close[i])/3);   break;
       case PRICE_WEIGHTED: return((High[i] + Low[i] + Close[i]*2)/4); break;
     }
  }
//+------------------------------------------------------------------+
//| �������������                                                    |
//+------------------------------------------------------------------+
int init()
  {
//---- ������� �����
   SetIndexBuffer(0, kAMAbuffer);
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexLabel(0, MAIN);
   SetIndexEmptyValue(0, 0.0);
//---- ������������� ����������� ������
   SetIndexBuffer(1, kAMAupsig);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 159);
   SetIndexLabel(1, UP);
   SetIndexEmptyValue(1, 0.0);
//---- ������������� ����������� ������
   SetIndexBuffer(2, kAMAdownsig);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 159);
   SetIndexLabel(2, DOWN);
   SetIndexEmptyValue(2, 0.0);
//---- ��������� ����������
   IndicatorDigits(4);
   string name = StringConcatenate(INDICATOR_SHORT_NAME,
                                   " (", periodAMA, "/", nfast, "/", nslow, ")");
   IndicatorShortName(name);
//---- ������ �-���    
   slowSC = (2.0 / (nslow + 1)); //��������� �-� �����������
   fastSC = (2.0 / (nfast + 1)); //������� �-� �����������
//---- ���������� �������
   ArrayResize(ddAMA, periodAMA);
   ArrayInitialize(ddAMA, 0.);
//---- ������
   return(0);
  }
//+------------------------------------------------------------------+
//| ���������������                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| ������������ �������                                             |
//+------------------------------------------------------------------+
int start()
  {
//---- ����������� ������������������   
   if(Bars <= periodAMA + 2) 
       return (0); //���� ����� �� ������� ������� ����, �������
//---- ����������� ���� ����������
   int counted_bars = IndicatorCounted(); //����� �����, �� ��������� � ���������� ������
   if(counted_bars < 0) 
       return (0); //���������� �� ������
   else 
       if(counted_bars > 0) 
           counted_bars--; //��������� ����������� ��� ����� ����������
   int pos = Bars - periodAMA - 2; //������� � ������ �������
   if(counted_bars > 0) 
       pos = Bars - counted_bars; //��� ���������� �������
//---- ���������� ����������
   double AMA0 = Price(pos+1, app_price); //���������� ��� �� �������������
   if(kAMAbuffer[pos+1] > 0)
       AMA0 = kAMAbuffer[pos+1]; //��� �������������
   if(AMA0 == 0) 
       Print(Bars - pos);
//---- ������ ����������
   while(pos >= 0)
     {
       //---- ������ �������
       double signal = MathAbs(Price(pos, app_price) - Price(pos + periodAMA, app_price));
       //---- ������ ����
       double noise = 0.000000001;
       for(int i = 0; i < periodAMA; i++)
         {
           noise = noise + MathAbs(Price(pos+i, app_price) - Price(pos + i + 1, app_price));
         }
       //---- ������ ������������ �����������
       double ER = signal / noise; //����������� �������������
       double SSC = ER*(fastSC - slowSC) + slowSC; //����������� �����������
       //---- ������ ������� �����
       double AMA = AMA0 + (MathPow(SSC, Pow)*(Price(pos, app_price) - AMA0)); //������
       AMA = NormalizeDouble(AMA, Digits);
       kAMAbuffer[pos] = AMA; //�����
       //---- ������ ���������� ������
       double ddK = (AMA - AMA0) / Point; //��������
       if(use_stdev)
         {
           InsertDif(ddK); //����������� ����������
           if(pos < Bars - 2*(periodAMA + 2)) //���� ����� ���������� ����������
             {
               //---- ������ �������� ���������������
               double SMAdif = 0; //������� ����� ����
               for(i = 0; i < periodAMA; i++)
                 {
                   SMAdif += ddAMA[i]; //��������������� ���������
                 }
               SMAdif /= periodAMA; //� ����� �� ����������
               //---- ������ ������������ ����������
               double StDev = 0; //������� ����� ����
               for(i = 0; i < periodAMA; i++)
                 {
                   StDev += MathPow(ddAMA[i] - SMAdif, 2); //��������� �������� ����������
                 }
               StDev = MathSqrt(StDev)/periodAMA; //��������� ������ � ����� �� ����������
               //---- ������ �������
               double Filter = dK*StDev;
             }
           else 
               Filter = 100000;
         }
       else 
           Filter = dK;
       //---- ��������� ��������
       double var1 = 0, var2 = 0;
       if(ddK > Filter) 
           var1 = AMA; //���� ���������� �����
       if(ddK < -Filter) 
           var2 = AMA; //���� ���������� �����
       kAMAupsig[pos] = var1; //��� ����������� ������
       kAMAdownsig[pos] = var2; // ��� ����������� ������
       //---- ������� � ����� �����
       AMA0 = AMA; //��������� ���������� �������� AMA
       pos--; //��������� � ���������� ����
     }
//---- ���������� ������
   return(0); //������
  }
//+------------------------------------------------------------------+


