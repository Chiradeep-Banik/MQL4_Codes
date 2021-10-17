//+------------------------------------------------------------------+
//|                                                   PChannel_m.mq4 |
//+------------------------------------------------------------------+

#property indicator_chart_window //��������� ���� ��� ������ ������� (���, ��� ����)
#property indicator_buffers 3 //�������� ��� ���������� ��� ������
#property indicator_color1 DodgerBlue //��������� ���� ��� ����������� ������ 1 ������
#property indicator_color2 DodgerBlue //��������� ���� ��� ����������� ������ 2 ������
#property indicator_color3 DodgerBlue //��������� ���� ��� ����������� ������ 3 ������
//---- input parameters //���������� �������� ������� ����������
extern int Range=14; //�� ��������� �������� �������� ����� 14
//---- buffers
double UpBuffer[]; //��������� ���������� UpBuffer ���� "������ � ��������� ������"
double DnBuffer[]; //��������� ���������� DnBuffer ���� "������ � ��������� ������"
double MdBuffer[]; //��������� ���������� MdBuffer ���� "������ � ��������� ������"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() //������������� ����������
  {
   string short_name; //��������� ���������� short_name ���� "���������"
//---- indicator line
   SetIndexStyle(0,DRAW_LINE,1,2); //��������� ����� ��� ������� �������� ����������
   SetIndexStyle(1,DRAW_LINE,1,2); //��������� ����� ��� ������� �������� ����������
   SetIndexStyle(2,DRAW_LINE,2); //��������� ����� ��� �������� �������� ����������
   SetIndexBuffer(0,UpBuffer); //�������� ������������ � 0 ����� ����� ���������� UpBuffer
   SetIndexBuffer(1,DnBuffer); //�������� ������������ � 1 ����� ����� ���������� DnBuffer
   SetIndexBuffer(2,MdBuffer); //�������� ������������ � 2 ����� ����� ���������� MdBuffer
//---- name for DataWindow and indicator subwindow label
   short_name="PriceChannel("+Range+")";  //���������� short_name ����������� ���������
                                                  //�������� ������ ���������
   IndicatorShortName(short_name);  //��� ����������� �� ������� �������� ���������� �������
                                    //������������
   SetIndexLabel(0,"Up Channel");   //��� ����������� �� ������� �������� ����� ������������
                                    //�������� 0 ������ ��� Up Channel
   SetIndexLabel(1,"Down Channel"); //��� ����������� �� ������� �������� ����� ������������
                                    //�������� 1 ������ ��� Down Channel
   SetIndexLabel(2,"Middle Channel"); //��� ����������� �� ������� �������� ����� ������������
                                      //�������� 2 ������ ��� Middle Channel
//----
   SetIndexDrawBegin(0,0); //��������� ��������� ����� ���������� ��� 0 ������
   SetIndexDrawBegin(1,0); //��������� ��������� ����� ���������� ��� 1 ������
   SetIndexDrawBegin(2,0); //��������� ��������� ����� ���������� ��� 2 ������
//----
   return(0); //������� �� ������ �������������
  }
//+------------------------------------------------------------------+
//| PriceChannel                                                     |
//+------------------------------------------------------------------+
int start() //������ ��������� (�������)
  {
   int i; //���������� ������������� ���������� i,k,sch

//----
   
   for(i=Bars-1;i>=0;i--)
   {
      UpBuffer[i]=High[Highest(NULL,0,MODE_HIGH,Range,i)];
      DnBuffer[i]=Low[Lowest(NULL,0,MODE_LOW,Range,i)];
      MdBuffer[i]=(UpBuffer[i]+DnBuffer[i])/2;
   }
   return(0);
  }
//+------------------------------------------------------------------+