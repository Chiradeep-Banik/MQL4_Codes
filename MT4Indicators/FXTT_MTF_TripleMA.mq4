//+------------------------------------------------------------------+
//|                                      FXTT_MTF_BollingerBands.mq4 |
//|                                  Copyright 2016, Carlos Oliveira |
//|                                         http://carlosoliveira.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Carlos Oliveira"
#property link      "https://www.forextradingtools.eu/?utm_campaign=properties.indicator&utm_medium=special&utm_source=mt4terminal"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 27

#include <Controls\Dialog.mqh>
#include <Controls\CheckGroup.mqh>

extern int FMAPeriod=50;                                    //Fast MA Period
extern int FMAShift=0;                                      //Fast MA shift
extern ENUM_MA_METHOD FMAMethod = MODE_SMA;                 //Fast MA Method
extern ENUM_APPLIED_PRICE FMAAppliedPrice = PRICE_CLOSE;    //Fast MA Applied Price
input string Group1; //---------------------------------------------------
extern int MMAPeriod=100;                                   //Middle MA Period
extern int MMAShift=0;                                      //Middle MA shift
extern ENUM_MA_METHOD MMAMethod = MODE_SMA;                 //Middle MA Method
extern ENUM_APPLIED_PRICE MMAAppliedPrice = PRICE_CLOSE;    //Middle MA Applied Price
input string Group2; //---------------------------------------------------
extern int SMAPeriod=200;                                   //Slow MA Period
extern int SMAShift=0;                                      //Slow MA shift
extern ENUM_MA_METHOD SMAMethod = MODE_SMA;                 //Slow MA Method
extern ENUM_APPLIED_PRICE SMAAppliedPrice = PRICE_CLOSE;    //Slow MA Applied Price
input string Group3; //---------------------------------------------------
extern ENUM_LINE_STYLE UpperStyle = STYLE_DOT;              //Fast MA line style
extern int UpperLineWidth = 1;                              //Fast MA line width
extern color UpperLineColor = clrTomato;                    //Fast MA line color
input string Group4; //---------------------------------------------------
extern ENUM_LINE_STYLE MainStyle = STYLE_DOT;               //Middle MA line style
extern int MainLineWidth = 1;                               //Middle MA line style
extern color MainLineColor=clrMediumSeaGreen;               //Middle MA line style
input string Group5; //---------------------------------------------------
extern ENUM_LINE_STYLE LowerStyle = STYLE_DOT;              //Slow MA line style
extern int LowerLineWidth = 1;                              //Slow MA line style
extern color LowerLineColor = clrPurple;                    //Slow MA line style

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define OBJPREFIX                            "MTF Triple MA" 
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (230)     // size by X coordinate
#define GROUP_HEIGHT                        (57)      // size by Y coordinate

string  DataFileName="data.bin";                      // File name
string  DataDirectoryName="MTFTMA";                   // Folder name
//+------------------------------------------------------------------+
//| Class CPanelDialog                                               |
//| Usage: main dialog of the SimplePanel application                |
//+------------------------------------------------------------------+
class CPanelDialog : public CAppDialog
  {
private:
   CCheckGroup       m_check_group;                   // the check box group object   
public:
   bool              m_M1;
   bool              m_M5;
   bool              m_M15;
   bool              m_M30;
   bool              m_H1;
   bool              m_H4;
   bool              m_D1;
   bool              m_W1;
   bool              m_MN1;

                     CPanelDialog(void);
                    ~CPanelDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   void              WriteIndicatorsData(void);
   void              ReadIndicatorsData(void);
   void              DrawIndicatorsData(void);
   void              SetMultipleIndexStyle(int idx1,int idx2,int idx3,int style);
protected:
   //--- create dependent controls   
   bool              CreateCheckGroup(void);
   //--- internal event handlers
   virtual bool      OnResize(void);
   //--- handlers of the dependent controls events   
   void              OnChangeCheckGroup(void);
   //-- Draw the text labels   
   void              DrawLabels();
   bool              OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CPanelDialog)
ON_EVENT(ON_CHANGE,m_check_group,OnChangeCheckGroup)
ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPanelDialog::CPanelDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPanelDialog::~CPanelDialog(void)
  {
   WriteIndicatorsData();
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CPanelDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls   
   if(!CreateCheckGroup())
      return(false);

   m_M1=false;
   m_M5=false;
   m_M15=false;
   m_M30=false;
   m_H1=false;
   m_H4=false;
   m_D1=false;
   m_W1=false;
   m_MN1=false;

   ReadIndicatorsData();

   m_check_group.Check(0, m_M1);
   m_check_group.Check(1, m_M5);
   m_check_group.Check(2, m_M15);
   m_check_group.Check(3, m_M30);
   m_check_group.Check(4,m_H1);
   m_check_group.Check(5,m_H4);
   m_check_group.Check(6,m_D1);
   m_check_group.Check(7,m_W1);
   m_check_group.Check(8,m_MN1);

//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup" element                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::CreateCheckGroup(void)
  {

   if(!m_check_group.Create(m_chart_id,m_name+"CheckGroup",m_subwin,0,0,112,170))
      return(false);
   if(!Add(m_check_group))
      return(false);

   if(!m_check_group.AddItem("M1",1<<0))
      return(false);
   if(!m_check_group.AddItem("M5",1<<1))
      return(false);
   if(!m_check_group.AddItem("M15",1<<2))
      return(false);
   if(!m_check_group.AddItem("M30",1<<3))
      return(false);
   if(!m_check_group.AddItem("H1",1<<4))
      return(false);
   if(!m_check_group.AddItem("H4",1<<5))
      return(false);
   if(!m_check_group.AddItem("D1",1<<6))
      return(false);
   if(!m_check_group.AddItem("W1",1<<7))
      return(false);
   if(!m_check_group.AddItem("MN1",1<<8))

      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Handler of resizing                                              |
//+------------------------------------------------------------------+
bool CPanelDialog::OnResize(void)
  {
//--- call method of parent class
   if(!CAppDialog::OnResize()) return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CPanelDialog::OnChangeCheckGroup(void)
  {
   m_M1=m_check_group.Check(0);
   m_M5=m_check_group.Check(1);
   m_M15=m_check_group.Check(2);
   m_M30=m_check_group.Check(3);
   m_H1=m_check_group.Check(4);
   m_H4=m_check_group.Check(5);
   m_D1=m_check_group.Check(6);
   m_W1=m_check_group.Check(7);
   m_MN1=m_check_group.Check(8);

   DrawIndicatorsData();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::SetMultipleIndexStyle(int idx1,int idx2,int idx3,int style)
  {
   SetIndexStyle(idx1,style);
   SetIndexStyle(idx2,style);
   SetIndexStyle(idx3,style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::DrawIndicatorsData()
  {
   if(m_MN1)
      SetMultipleIndexStyle(0,1,2,DRAW_LINE);
   else
      SetMultipleIndexStyle(0,1,2,DRAW_NONE);

   if(m_W1 && _Period<=PERIOD_W1)
      SetMultipleIndexStyle(3,4,5,DRAW_LINE);
   else
      SetMultipleIndexStyle(3,4,5,DRAW_NONE);

   if(m_D1 && _Period<=PERIOD_D1)
      SetMultipleIndexStyle(6,7,8,DRAW_LINE);
   else
      SetMultipleIndexStyle(6,7,8,DRAW_NONE);

   if(m_H4 && _Period<=PERIOD_H4)
      SetMultipleIndexStyle(9,10,11,DRAW_LINE);
   else
      SetMultipleIndexStyle(9,10,11,DRAW_NONE);

   if(m_H1 && _Period<=PERIOD_H1)
      SetMultipleIndexStyle(12,13,14,DRAW_LINE);
   else
      SetMultipleIndexStyle(12,13,14,DRAW_NONE);

   if(m_M30 && _Period<=PERIOD_M30)
      SetMultipleIndexStyle(15,16,17,DRAW_LINE);
   else
      SetMultipleIndexStyle(15,16,17,DRAW_NONE);

   if(m_M15 && _Period<=PERIOD_M15)
      SetMultipleIndexStyle(18,19,20,DRAW_LINE);
   else
      SetMultipleIndexStyle(18,19,20,DRAW_NONE);

   if(m_M5 && _Period<=PERIOD_M5)
      SetMultipleIndexStyle(21,22,23,DRAW_LINE);
   else
      SetMultipleIndexStyle(21,22,23,DRAW_NONE);

   if(m_M1 && _Period<=PERIOD_M1)
      SetMultipleIndexStyle(24,25,26,DRAW_LINE);
   else
      SetMultipleIndexStyle(24,25,26,DRAW_NONE);

   DrawLabels();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::DrawLabels()
  {
   string fastText=" "+IntegerToString(FMAPeriod)+" MA";
   string middleText=" "+IntegerToString(MMAPeriod)+" MA";
   string slowText=" "+IntegerToString(SMAPeriod)+" MA";

   DrawPriceLabel(m_M1 && _Period<=PERIOD_M1,lblM1h,bufferM1FMA[0],"M1"+fastText,UpperLineColor);
   DrawPriceLabel(m_M1 && _Period<=PERIOD_M1,lblM1m,bufferM1MMA[0],"M1"+middleText,MainLineColor);
   DrawPriceLabel(m_M1 && _Period<=PERIOD_M1,lblM1l,bufferM1SMA[0],"M1"+slowText,LowerLineColor);

   DrawPriceLabel(m_M5 && _Period<=PERIOD_M5,lblM5h,bufferM5FMA[0],"M5"+fastText,UpperLineColor);
   DrawPriceLabel(m_M5 && _Period<=PERIOD_M5,lblM5m,bufferM5MMA[0],"M5"+middleText,MainLineColor);
   DrawPriceLabel(m_M5 && _Period<=PERIOD_M5,lblM5l,bufferM5SMA[0],"M5"+slowText,LowerLineColor);

   DrawPriceLabel(m_M15 && _Period<=PERIOD_M15,lblM15h,bufferM15FMA[0],"M15"+fastText,UpperLineColor);
   DrawPriceLabel(m_M15 && _Period<=PERIOD_M15,lblM15m,bufferM15MMA[0],"M15"+middleText,MainLineColor);
   DrawPriceLabel(m_M15 && _Period<=PERIOD_M15,lblM15l,bufferM15SMA[0],"M15"+slowText,LowerLineColor);

   DrawPriceLabel(m_M30 && _Period<=PERIOD_M30,lblM30h,bufferM30FMA[0],"M30"+fastText,UpperLineColor);
   DrawPriceLabel(m_M30 && _Period<=PERIOD_M30,lblM30m,bufferM30MMA[0],"M30"+middleText,MainLineColor);
   DrawPriceLabel(m_M30 && _Period<=PERIOD_M30,lblM30l,bufferM30SMA[0],"M30"+slowText,LowerLineColor);

   DrawPriceLabel(m_H1 && _Period<=PERIOD_H1,lblH1h,bufferH1FMA[0],"H1"+fastText,UpperLineColor);
   DrawPriceLabel(m_H1 && _Period<=PERIOD_H1,lblH1m,bufferH1MMA[0],"H1"+middleText,MainLineColor);
   DrawPriceLabel(m_H1 && _Period<=PERIOD_H1,lblH1l,bufferH1SMA[0],"H1"+slowText,LowerLineColor);

   DrawPriceLabel(m_H4 && _Period<=PERIOD_H4,lblH4h,bufferH4FMA[0],"H4"+fastText,UpperLineColor);
   DrawPriceLabel(m_H4 && _Period<=PERIOD_H4,lblH4m,bufferH4MMA[0],"H4"+middleText,MainLineColor);
   DrawPriceLabel(m_H4 && _Period<=PERIOD_H4,lblH4l,bufferH4SMA[0],"H4"+slowText,LowerLineColor);

   DrawPriceLabel(m_D1 && _Period<=PERIOD_D1,lblD1h,bufferD1FMA[0],"D1"+fastText,UpperLineColor);
   DrawPriceLabel(m_D1 && _Period<=PERIOD_D1,lblD1m,bufferD1MMA[0],"D1"+middleText,MainLineColor);
   DrawPriceLabel(m_D1 && _Period<=PERIOD_D1,lblD1l,bufferD1SMA[0],"D1"+slowText,LowerLineColor);

   DrawPriceLabel(m_W1 && _Period<=PERIOD_W1,lblW1h,bufferW1FMA[0],"W1"+fastText,UpperLineColor);
   DrawPriceLabel(m_W1 && _Period<=PERIOD_W1,lblW1m,bufferW1MMA[0],"W1"+middleText,MainLineColor);
   DrawPriceLabel(m_W1 && _Period<=PERIOD_W1,lblW1l,bufferW1SMA[0],"W1"+slowText,LowerLineColor);

   DrawPriceLabel(m_MN1,lblMN1h,bufferMN1FMA[0],"MN1"+fastText,UpperLineColor);
   DrawPriceLabel(m_MN1,lblMN1m,bufferMN1MMA[0],"MN1"+middleText,MainLineColor);
   DrawPriceLabel(m_MN1,lblMN1l,bufferMN1SMA[0],"MN1"+slowText,LowerLineColor);
  }
//+------------------------------------------------------------------+
//| Rest events handler                                                    |
//+------------------------------------------------------------------+
bool CPanelDialog::OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   return(false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CPanelDialog ExtDialog;

double bufferMN1FMA[];
double bufferMN1MMA[];
double bufferMN1SMA[];

double bufferW1FMA[];
double bufferW1MMA[];
double bufferW1SMA[];

double bufferD1FMA[];
double bufferD1MMA[];
double bufferD1SMA[];

double bufferH4FMA[];
double bufferH4MMA[];
double bufferH4SMA[];

double bufferH1FMA[];
double bufferH1MMA[];
double bufferH1SMA[];

double bufferM30FMA[];
double bufferM30MMA[];
double bufferM30SMA[];

double bufferM15FMA[];
double bufferM15MMA[];
double bufferM15SMA[];

double bufferM5FMA[];
double bufferM5MMA[];
double bufferM5SMA[];

double bufferM1FMA[];
double bufferM1MMA[];
double bufferM1SMA[];

int lblM1h,lblM1m,lblM1l;
int lblM5h,lblM5m,lblM5l;
int lblM15h,lblM15m,lblM15l;
int lblM30h,lblM30m,lblM30l;
int lblH1h,lblH1m,lblH1l;
int lblH4h,lblH4m,lblH4l;
int lblD1h,lblD1m,lblD1l;
int lblW1h,lblW1m,lblW1l;
int lblMN1h,lblMN1m,lblMN1l;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(ChartID(),OBJPREFIX);
   InitBuffers();
//--- create application dialog
   if(!ExtDialog.Create(0,OBJPREFIX,0,10,10,130,208))
      return(INIT_FAILED);
//--- run application
   if(!ExtDialog.Run())
      return(INIT_FAILED);
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(),OBJPREFIX);

//--- destroy application dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
// Call function ManageEvents on every MT4 tick   
   RunIndicators();

   ExtDialog.DrawIndicatorsData();

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void InitBuffers()
  {

   AddBuffer(0,bufferMN1FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"MN1 Fast MA");
   AddBuffer(1,bufferMN1MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"MN1 Middle MA");
   AddBuffer(2,bufferMN1SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"MN1 Slow MA");

   AddBuffer(3,bufferW1FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"W1 Fast MA");
   AddBuffer(4,bufferW1MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"W1 Middle MA");
   AddBuffer(5,bufferW1SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"W1 Slow MA");

   AddBuffer(6,bufferD1FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"D1 Fast MA");
   AddBuffer(7,bufferD1MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"D1 Middle MA");
   AddBuffer(8,bufferD1SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"D1 Slow MA");

   AddBuffer(9,bufferH4FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"H4 Fast MA");
   AddBuffer(10,bufferH4MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"H4 Middle MA");
   AddBuffer(11,bufferH4SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"H4 Slow MA");

   AddBuffer(12,bufferH1FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"H1 Fast MA");
   AddBuffer(13,bufferH1MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"H1 Middle MA");
   AddBuffer(14,bufferH1SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"H1 Slow MA");

   AddBuffer(15,bufferM30FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"M30 Fast MA");
   AddBuffer(16,bufferM30MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"M30 Middle MA");
   AddBuffer(17,bufferM30SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"M30 Slow MA");

   AddBuffer(18,bufferM15FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"M15 Fast MA");
   AddBuffer(19,bufferM15MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"M15 Middle MA");
   AddBuffer(20,bufferM15SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"M15 Slow MA");

   AddBuffer(21,bufferM5FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"M5 Fast MA");
   AddBuffer(22,bufferM5MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"M5 Middle MA");
   AddBuffer(23,bufferM5SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"M5 Slow MA");

   AddBuffer(24,bufferM1FMA,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"M1 Fast MA");
   AddBuffer(25,bufferM1MMA,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"M1 Middle MA");
   AddBuffer(26,bufferM1SMA,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"M1 Slow MA");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddBuffer(int idx,double &buffer[],int type,int style=EMPTY,int width=EMPTY,color clr=clrNONE,string text="")
  {
   SetIndexBuffer(idx,buffer);
   SetIndexStyle(idx,type,style,width,clr);
   SetIndexLabel(idx,text);
  }
//+------------------------------------------------------------------+
int RunIndicators()
  {
   int limit;
   int counted_bars=IndicatorCounted();
   datetime tfMN1[],tfW1[],tfD1[],tfH4[],tfH1[],tfM30[],tfM15[],tfM5[],tfM1[];
   int iMN1=0,iW1=0,iD1=0,iH4=0,iH1=0,iM30=0,iM15=0,iM5=0,iM1=0;

//---- check for possible errors 
   if(counted_bars<0)
      return(-1);

//---- the last counted bar will be recounted 
   if(counted_bars>0)
      counted_bars--;

   ArrayCopySeries(tfMN1,MODE_TIME,Symbol(),PERIOD_MN1);
   ArrayCopySeries(tfW1,MODE_TIME,Symbol(),PERIOD_W1);
   ArrayCopySeries(tfD1,MODE_TIME,Symbol(),PERIOD_D1);
   ArrayCopySeries(tfH4,MODE_TIME,Symbol(),PERIOD_H4);
   ArrayCopySeries(tfH1,MODE_TIME,Symbol(),PERIOD_H1);
   ArrayCopySeries(tfM30,MODE_TIME,Symbol(),PERIOD_M30);
   ArrayCopySeries(tfM15,MODE_TIME,Symbol(),PERIOD_M15);
   ArrayCopySeries(tfM5,MODE_TIME,Symbol(),PERIOD_M5);
   ArrayCopySeries(tfM1,MODE_TIME,Symbol(),PERIOD_M1);

   limit=Bars-counted_bars;

//---- main loop 
   for(int i=0; i<limit; i++)
     {
      if(iMN1<ArraySize(tfMN1) && Time[i]<tfMN1[iMN1]) iMN1++;
      if(iW1<ArraySize(tfW1) && Time[i]<tfW1[iW1]) iW1++;
      if(iD1<ArraySize(tfD1) && Time[i]<tfD1[iD1]) iD1++;
      if(iH4<ArraySize(tfH4) && Time[i]<tfH4[iH4]) iH4++;
      if(iH1<ArraySize(tfH1) && Time[i]<tfH1[iH1]) iH1++;
      if(iM30<ArraySize(tfM30) && Time[i]<tfM30[iM30]) iM30++;
      if(iM15<ArraySize(tfM15) && Time[i]<tfM15[iM15]) iM15++;
      if(iM5<ArraySize(tfM5) && Time[i]<tfM5[iM5]) iM5++;
      if(iM1<ArraySize(tfM1) && Time[i]<tfM1[iM1]) iM1++;

      bufferMN1FMA[i]   = iMA(NULL,PERIOD_MN1,FMAPeriod,FMAShift,FMAMethod, FMAAppliedPrice,iMN1);
      bufferMN1MMA[i]   = iMA(NULL,PERIOD_MN1,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iMN1);
      bufferMN1SMA[i]   = iMA(NULL,PERIOD_MN1,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iMN1);

      bufferW1FMA[i]    = iMA(NULL,PERIOD_W1,FMAPeriod,FMAShift, FMAMethod, FMAAppliedPrice,iW1);
      bufferW1MMA[i]    = iMA(NULL,PERIOD_W1,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iW1);
      bufferW1SMA[i]    = iMA(NULL,PERIOD_W1,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iW1);

      bufferD1FMA[i]    = iMA(NULL,PERIOD_D1,FMAPeriod,FMAShift, FMAMethod, FMAAppliedPrice,iD1);
      bufferD1MMA[i]    = iMA(NULL,PERIOD_D1,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iD1);
      bufferD1SMA[i]    = iMA(NULL,PERIOD_D1,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iD1);

      bufferH4FMA[i]    = iMA(NULL,PERIOD_H4,FMAPeriod,FMAShift, FMAMethod, FMAAppliedPrice,iH4);
      bufferH4MMA[i]    = iMA(NULL,PERIOD_H4,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iH4);
      bufferH4SMA[i]    = iMA(NULL,PERIOD_H4,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iH4);

      bufferH1FMA[i]    = iMA(NULL,PERIOD_H1,FMAPeriod,FMAShift, FMAMethod, FMAAppliedPrice,iH1);
      bufferH1MMA[i]    = iMA(NULL,PERIOD_H1,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iH1);
      bufferH1SMA[i]    = iMA(NULL,PERIOD_H1,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iH1);

      bufferM30FMA[i]   = iMA(NULL,PERIOD_M30,FMAPeriod,FMAShift, FMAMethod, FMAAppliedPrice,iM30);
      bufferM30MMA[i]   = iMA(NULL,PERIOD_M30,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iM30);
      bufferM30SMA[i]   = iMA(NULL,PERIOD_M30,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iM30);

      bufferM15FMA[i]   = iMA(NULL,PERIOD_M15,FMAPeriod,FMAShift, FMAMethod, FMAAppliedPrice,iM15);
      bufferM15MMA[i]   = iMA(NULL,PERIOD_M15,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iM15);
      bufferM15SMA[i]   = iMA(NULL,PERIOD_M15,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iM15);

      bufferM5FMA[i]    = iMA(NULL,PERIOD_M5,FMAPeriod,FMAShift, FMAMethod, FMAAppliedPrice,iM5);
      bufferM5MMA[i]    = iMA(NULL,PERIOD_M5,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iM5);
      bufferM5SMA[i]    = iMA(NULL,PERIOD_M5,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iM5);

      bufferM1FMA[i]    = iMA(NULL,PERIOD_M1,FMAPeriod,FMAShift, FMAMethod, FMAAppliedPrice,iM1);
      bufferM1MMA[i]    = iMA(NULL,PERIOD_M1,MMAPeriod,MMAShift,MMAMethod,MMAAppliedPrice,iM1);
      bufferM1SMA[i]    = iMA(NULL,PERIOD_M1,SMAPeriod,SMAShift,SMAMethod,SMAAppliedPrice,iM1);
     }
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceLabel(bool show,int lblHwnd,double price,string text,color foreground,color background=clrLightGray)
  {
   string name=OBJPREFIX+text;
   ObjectDelete(0,name);
   if(show)
     {
      int x,y;
      datetime fwdTime;
      int      window=0;

      ChartTimePriceToXY(0,0,Time[0],price,x,y);
      x = x + 50;
      y = y - 8;
      ChartXYToTimePrice(0,x,y,window,fwdTime,price);

      ObjectCreate(name,OBJ_TEXT,0,fwdTime,price);
      ObjectSetText(name,text,9,"Verdana",foreground);
      ObjectSet(name,OBJPROP_CORNER,0);
      ObjectSet(name,OBJPROP_XDISTANCE,250);
      ObjectSet(name,OBJPROP_YDISTANCE,20);
     }
  }
//+------------------------------------------------------------------+

void CPanelDialog::WriteIndicatorsData()
  {
   bool arr[9];
   string path=DataDirectoryName+"//"+Symbol()+DataFileName;

   arr[0] = m_M1;
   arr[1] = m_M5;
   arr[2] = m_M15;
   arr[3] = m_M30;
   arr[4] = m_H1;
   arr[5] = m_H4;
   arr[6] = m_D1;
   arr[7] = m_W1;
   arr[8] = m_MN1;

//--- open the file
   ResetLastError();
   int handle = FileOpen(path,FILE_READ|FILE_WRITE|FILE_BIN);
   if(handle != INVALID_HANDLE)
     {
      //--- write array data 
      FileWriteArray(handle,arr);
      //--- close the file
      FileClose(handle);
     }
   else
     {
      Print("Failed to open the file, error: "+(string) GetLastError());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::ReadIndicatorsData()
  {
   bool arr[];
   string path=DataDirectoryName+"//"+Symbol()+DataFileName;

//--- open the file
   ResetLastError();
   int file_handle = FileOpen(path,FILE_READ|FILE_BIN);
   if(file_handle != INVALID_HANDLE)
     {
      //--- read all data from the file to the array
      FileReadArray(file_handle,arr);
      int size=ArraySize(arr);

      m_M1 = arr[0];
      m_M5 = arr[1];
      m_M15 = arr[2];
      m_M30 = arr[3];
      m_H1 = arr[4];
      m_H4 = arr[5];
      m_D1 = arr[6];
      m_W1 = arr[7];
      m_MN1= arr[8];

      //--- close the file
      FileClose(file_handle);
     }
   else
     {
      Print("File open failed, error: "+(string) GetLastError());
     }

  }
//+------------------------------------------------------------------+
