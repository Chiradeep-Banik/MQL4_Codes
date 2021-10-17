//+------------------------------------------------------------------+
//|                                      FXTT_MTF_BollingerBands.mq4 |
//|                                  Copyright 2016, Carlos Oliveira |
//|                                         http://carlosoliveira.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Carlos Oliveira"
#property link      "http://forextradingtools.x10host.com/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 27

#include <Controls\Dialog.mqh>
#include <Controls\CheckGroup.mqh>

/*
#property indicator_color1    clrRoyalBlue  
#property indicator_width1    1
#property indicator_style1    STYLE_DOT

#property indicator_color2    clrMediumSeaGreen  
#property indicator_width2    1
#property indicator_style2    STYLE_DOT

#property indicator_color3    clrTomato  
#property indicator_width3    1
#property indicator_style3    STYLE_DOT

#property indicator_color4    clrRoyalBlue  
#property indicator_width4    1
#property indicator_style4    STYLE_DOT

#property indicator_color5    clrMediumSeaGreen  
#property indicator_width5    1
#property indicator_style5    STYLE_DOT

#property indicator_color6    clrTomato  
#property indicator_width6    1
#property indicator_style6    STYLE_DOT

#property indicator_color7    clrRoyalBlue  
#property indicator_width7    1
#property indicator_style7    STYLE_DOT

#property indicator_color8    clrMediumSeaGreen  
#property indicator_width8    1
#property indicator_style8    STYLE_DOT

#property indicator_color9    clrTomato  
#property indicator_width9    1
#property indicator_style9    STYLE_DOT

#property indicator_color10    clrRoyalBlue  
#property indicator_width10    1
#property indicator_style10    STYLE_DOT

#property indicator_color11    clrMediumSeaGreen  
#property indicator_width11    1
#property indicator_style11    STYLE_DOT

#property indicator_color12    clrTomato  
#property indicator_width12    1
#property indicator_style12    STYLE_DOT

#property indicator_color13    clrRoyalBlue  
#property indicator_width13    1
#property indicator_style13    STYLE_DOT

#property indicator_color14    clrMediumSeaGreen  
#property indicator_width14    1
#property indicator_style14    STYLE_DOT

#property indicator_color15    clrTomato  
#property indicator_width15    1
#property indicator_style15    STYLE_DOT

#property indicator_color16    clrTomato  
#property indicator_width16    1
#property indicator_style16    STYLE_DOT

#property indicator_color17    clrTomato  
#property indicator_width17    1
#property indicator_style17    STYLE_DOT

#property indicator_color18    clrTomato  
#property indicator_width18    1
#property indicator_style18    STYLE_DOT

#property indicator_color19    clrTomato  
#property indicator_width19    1
#property indicator_style19    STYLE_DOT

#property indicator_color20    clrTomato  
#property indicator_width20    1
#property indicator_style20    STYLE_DOT

#property indicator_color21    clrTomato  
#property indicator_width21    1
#property indicator_style21    STYLE_DOT

#property indicator_color22    clrTomato  
#property indicator_width22    1
#property indicator_style22    STYLE_DOT

#property indicator_color23    clrTomato  
#property indicator_width23    1
#property indicator_style23    STYLE_DOT

#property indicator_color24    clrTomato  
#property indicator_width24    1
#property indicator_style24    STYLE_DOT

#property indicator_color25    clrTomato  
#property indicator_width25    1
#property indicator_style25    STYLE_DOT

#property indicator_color26    clrTomato  
#property indicator_width26    1
#property indicator_style26    STYLE_DOT

#property indicator_color27    clrTomato  
#property indicator_width27    1
#property indicator_style27    STYLE_DOT
*/

extern int BBPeriod=20;                         //Bollinger Bands Period
extern int BBDeviations=2;                      //Bollinger Bands Deviations
extern int BBShift=0;                           //Bollinger Bands Shift

extern ENUM_LINE_STYLE UpperStyle = STYLE_DOT;  //Upper Band line style
extern int UpperLineWidth = 1;                  //Upper Band line width
extern color UpperLineColor = clrPurple;        //Upper Band line color

extern ENUM_LINE_STYLE MainStyle = STYLE_DOT;   //Main Band line style
extern int MainLineWidth = 1;                   //Main Band line style
extern color MainLineColor = clrRed;            //Main Band line style

extern ENUM_LINE_STYLE LowerStyle = STYLE_DOT;  //Lower Band line style
extern int LowerLineWidth = 1;                  //Lower Band line style
extern color LowerLineColor = clrPurple;        //Lower Band line style

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (230)     // size by X coordinate
#define GROUP_HEIGHT                        (57)      // size by Y coordinate

string  DataFileName="data.bin";                // File name
string  DataDirectoryName="MTFBBands";   // Folder name
//+------------------------------------------------------------------+
//| Class CPanelDialog                                               |
//| Usage: main dialog of the SimplePanel application                |
//+------------------------------------------------------------------+
class CPanelDialog : public CAppDialog
  {
private:
   CCheckGroup       m_check_group;                   // the check box group object   
public:
   bool              mM1;
   bool              mM5;
   bool              mM15;
   bool              mM30;
   bool              mH1;
   bool              mH4;
   bool              mD1;
   bool              mW1;
   bool              mMN1;

                     CPanelDialog(void);
                    ~CPanelDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   void              WriteIndicatorsData(void);
   void              ReadIndicatorsData(void);
   void              DrawIndicatorsData(void);
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

   mM1=false;
   mM5=false;
   mM15=false;
   mM30=false;
   mH1=false;
   mH4=false;
   mD1=false;
   mW1=false;
   mMN1=false;

   ReadIndicatorsData();

   m_check_group.Check(0, mM1);
   m_check_group.Check(1, mM5);
   m_check_group.Check(2, mM15);
   m_check_group.Check(3, mM30);
   m_check_group.Check(4,mH1);
   m_check_group.Check(5,mH4);
   m_check_group.Check(6,mD1);
   m_check_group.Check(7,mW1);
   m_check_group.Check(8,mMN1);
   
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup" element                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::CreateCheckGroup(void)
  {
/*
   //--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+GROUP_WIDTH;
   int y2=y1+GROUP_HEIGHT;
//--- create
   if(!m_check_group.Create(m_chart_id,m_name+"CheckGroup",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_check_group))
      return(false);
//--- fill out with strings
   if(!m_check_group.AddItem("Mail if Trade event",1<<0))
   */

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
   mM1=m_check_group.Check(0);
   mM5=m_check_group.Check(1);
   mM15=m_check_group.Check(2);
   mM30=m_check_group.Check(3);
   mH1=m_check_group.Check(4);
   mH4=m_check_group.Check(5);
   mD1=m_check_group.Check(6);
   mW1=m_check_group.Check(7);
   mMN1=m_check_group.Check(8);

   DrawIndicatorsData();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::DrawIndicatorsData()
  {
   if((mMN1))
     {
      SetIndexStyle(0,DRAW_LINE);
      SetIndexStyle(1,DRAW_LINE);
      SetIndexStyle(2,DRAW_LINE);
     }
   else
     {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBMN");
     }

   if((mW1))
     {
      SetIndexStyle(3,DRAW_LINE);
      SetIndexStyle(4,DRAW_LINE);
      SetIndexStyle(5,DRAW_LINE);
        }else{
      SetIndexStyle(3,DRAW_NONE);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBW1");
     }

   if((mD1))
     {
      SetIndexStyle(6,DRAW_LINE);
      SetIndexStyle(7,DRAW_LINE);
      SetIndexStyle(8,DRAW_LINE);
        }else{
      SetIndexStyle(6,DRAW_NONE);
      SetIndexStyle(7,DRAW_NONE);
      SetIndexStyle(8,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBD1");
     }

   if((mH4))
     {
      SetIndexStyle(9,DRAW_LINE);
      SetIndexStyle(10,DRAW_LINE);
      SetIndexStyle(11,DRAW_LINE);
        }else{
      SetIndexStyle(9,DRAW_NONE);
      SetIndexStyle(10,DRAW_NONE);
      SetIndexStyle(11,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBH4");
     }

   if((mH1))
     {
      SetIndexStyle(12,DRAW_LINE);
      SetIndexStyle(13,DRAW_LINE);
      SetIndexStyle(14,DRAW_LINE);
        }else{
      SetIndexStyle(12,DRAW_NONE);
      SetIndexStyle(13,DRAW_NONE);
      SetIndexStyle(14,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBH1");
     }

   if((mM30))
     {
      SetIndexStyle(15,DRAW_LINE);
      SetIndexStyle(16,DRAW_LINE);
      SetIndexStyle(17,DRAW_LINE);
        }else{
      SetIndexStyle(15,DRAW_NONE);
      SetIndexStyle(16,DRAW_NONE);
      SetIndexStyle(17,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBM30");
     }

   if((mM15))
     {
      SetIndexStyle(18,DRAW_LINE);
      SetIndexStyle(19,DRAW_LINE);
      SetIndexStyle(20,DRAW_LINE);
        }else{
      SetIndexStyle(18,DRAW_NONE);
      SetIndexStyle(19,DRAW_NONE);
      SetIndexStyle(20,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBM15");
     }

   if((mM5))
     {
      SetIndexStyle(21,DRAW_LINE);
      SetIndexStyle(22,DRAW_LINE);
      SetIndexStyle(23,DRAW_LINE);
        }else{
      SetIndexStyle(21,DRAW_NONE);
      SetIndexStyle(22,DRAW_NONE);
      SetIndexStyle(23,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBM5");
     }

   if((mM1))
     {
      SetIndexStyle(24,DRAW_LINE);
      SetIndexStyle(25,DRAW_LINE);
      SetIndexStyle(26,DRAW_LINE);
        }else{
      SetIndexStyle(24,DRAW_NONE);
      SetIndexStyle(25,DRAW_NONE);
      SetIndexStyle(26,DRAW_NONE);
      ObjectsDeleteAll(ChartID(),"BBM1");
     }

   DrawLabels();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::DrawLabels()
  {

   DrawPriceLabel(mM1,lblM1h,bufferM1BBh[0],"M1 Upper Band",UpperLineColor);
   DrawPriceLabel(mM1,lblM1m,bufferM1BBm[0],"M1 Main Band",MainLineColor);
   DrawPriceLabel(mM1,lblM1l,bufferM1BBl[0],"M1 Lower Band",LowerLineColor);

   DrawPriceLabel(mM5,lblM5h,bufferM5BBh[0],"M5 Upper Band",UpperLineColor);
   DrawPriceLabel(mM5,lblM5m,bufferM5BBm[0],"M5 Main Band",MainLineColor);
   DrawPriceLabel(mM5,lblM5l,bufferM5BBl[0],"M5 Lower Band",LowerLineColor);

   DrawPriceLabel(mM15,lblM15h,bufferM15BBh[0],"M15 Upper Band",UpperLineColor);
   DrawPriceLabel(mM15,lblM15m,bufferM15BBm[0],"M15 Main Band",MainLineColor);
   DrawPriceLabel(mM15,lblM15l,bufferM15BBl[0],"M15 Lower Band",LowerLineColor);

   DrawPriceLabel(mM30,lblM30h,bufferM30BBh[0],"M30 Upper Band",UpperLineColor);
   DrawPriceLabel(mM30,lblM30m,bufferM30BBm[0],"M30 Main Band",MainLineColor);
   DrawPriceLabel(mM30,lblM30l,bufferM30BBl[0],"M30 Lower Band",LowerLineColor);

   DrawPriceLabel(mH1,lblH1h,bufferH1BBh[0],"H1 Upper Band",UpperLineColor);
   DrawPriceLabel(mH1,lblH1m,bufferH1BBm[0],"H1 Main Band",MainLineColor);
   DrawPriceLabel(mH1,lblH1l,bufferH1BBl[0],"H1 Lower Band",LowerLineColor);

   DrawPriceLabel(mH4,lblH4h,bufferH4BBh[0],"H4 Upper Band",UpperLineColor);
   DrawPriceLabel(mH4,lblH4m,bufferH4BBm[0],"H4 Main Band",MainLineColor);
   DrawPriceLabel(mH4,lblH4l,bufferH4BBl[0],"H4 Lower Band",LowerLineColor);

   DrawPriceLabel(mD1,lblD1h,bufferD1BBh[0],"D1 Upper Band",UpperLineColor);
   DrawPriceLabel(mD1,lblD1m,bufferD1BBm[0],"D1 Main Band",MainLineColor);
   DrawPriceLabel(mD1,lblD1l,bufferD1BBl[0],"D1 Lower Band",LowerLineColor);

   DrawPriceLabel(mW1,lblW1h,bufferW1BBh[0],"W1 Upper Band",UpperLineColor);
   DrawPriceLabel(mW1,lblW1m,bufferW1BBm[0],"W1 Main Band",MainLineColor);
   DrawPriceLabel(mW1,lblW1l,bufferW1BBl[0],"W1 Lower Band",LowerLineColor);

   DrawPriceLabel(mMN1,lblMN1h,bufferMN1BBh[0],"MN1 Upper Band",UpperLineColor);
   DrawPriceLabel(mMN1,lblMN1m,bufferMN1BBm[0],"MN1 Main Band",MainLineColor);
   DrawPriceLabel(mMN1,lblMN1l,bufferMN1BBl[0],"MN1 Lower Band",LowerLineColor);
  }
//+------------------------------------------------------------------+
//| Rest events handler                                                    |
//+------------------------------------------------------------------+
bool CPanelDialog::OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- restore buttons' states after mouse move'n'click
//if(id==CHARTEVENT_CLICK)
//m_radio_group.RedrawButtonStates();
//--- let's handle event by parent
   return(false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CPanelDialog ExtDialog;

double bufferMN1BBh[];
double bufferMN1BBm[];
double bufferMN1BBl[];

double bufferW1BBh[];
double bufferW1BBm[];
double bufferW1BBl[];

double bufferD1BBh[];
double bufferD1BBm[];
double bufferD1BBl[];

double bufferH4BBh[];
double bufferH4BBm[];
double bufferH4BBl[];

double bufferH1BBh[];
double bufferH1BBm[];
double bufferH1BBl[];

double bufferM30BBh[];
double bufferM30BBm[];
double bufferM30BBl[];

double bufferM15BBh[];
double bufferM15BBm[];
double bufferM15BBl[];

double bufferM5BBh[];
double bufferM5BBm[];
double bufferM5BBl[];

double bufferM1BBh[];
double bufferM1BBm[];
double bufferM1BBl[];

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
   ObjectsDeleteAll(ChartID(),"MTF BBands");

   InitBuffers();

//--- create application dialog
   if(!ExtDialog.Create(0,"MTF BBands",0,10,10,130,208))
      //if(!ExtDialog.Create(0,"MTF BBands",0,10,10,230,308))
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
   ObjectsDeleteAll(ChartID(),"MTF BBands");

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

   AddBuffer(0,bufferMN1BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"MN1 BB Upper");
   AddBuffer(1,bufferMN1BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"MN1 BB Main");
   AddBuffer(2,bufferMN1BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"MN1 BB Lower");

   AddBuffer(3,bufferW1BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"W1 BB Upper");
   AddBuffer(4,bufferW1BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"W1 BB Main");
   AddBuffer(5,bufferW1BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"W1 BB Lower");

   AddBuffer(6,bufferD1BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"D1 BB Upper");
   AddBuffer(7,bufferD1BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"D1 BB Main");
   AddBuffer(8,bufferD1BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"D1 BB Lower");

   AddBuffer(9,bufferH4BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"H4 BB Upper");
   AddBuffer(10,bufferH4BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"H4 BB Main");
   AddBuffer(11,bufferH4BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"H4 BB Lower");

   AddBuffer(12,bufferH1BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"H1 BB Upper");
   AddBuffer(13,bufferH1BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"H1 BB Main");
   AddBuffer(14,bufferH1BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"H1 BB Lower");

   AddBuffer(15,bufferM30BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"M30 BB Upper");
   AddBuffer(16,bufferM30BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"M30 BB Main");
   AddBuffer(17,bufferM30BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"M30 BB Lower");

   AddBuffer(18,bufferM15BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"M15 BB Upper");
   AddBuffer(19,bufferM15BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"M15 BB Main");
   AddBuffer(20,bufferM15BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"M15 BB Lower");

   AddBuffer(21,bufferM5BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"M5 BB Upper");
   AddBuffer(22,bufferM5BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"M5 BB Main");
   AddBuffer(23,bufferM5BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"M5 BB Lower");

   AddBuffer(24,bufferM1BBh,DRAW_NONE,UpperStyle,UpperLineWidth,UpperLineColor,"M1 BB Upper");
   AddBuffer(25,bufferM1BBm,DRAW_NONE,MainStyle,MainLineWidth,MainLineColor,"M1 BB Main");
   AddBuffer(26,bufferM1BBl,DRAW_NONE,LowerStyle,LowerLineWidth,LowerLineColor,"M1 BB Lower");
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

      bufferMN1BBh[i]   = iBands(NULL,PERIOD_MN1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iMN1);
      bufferMN1BBm[i]   = iBands(NULL,PERIOD_MN1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iMN1);
      bufferMN1BBl[i]   = iBands(NULL,PERIOD_MN1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iMN1);
      bufferW1BBh[i]    = iBands(NULL,PERIOD_W1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iW1);
      bufferW1BBm[i]    = iBands(NULL,PERIOD_W1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iW1);
      bufferW1BBl[i]    = iBands(NULL,PERIOD_W1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iW1);
      bufferD1BBh[i]    = iBands(NULL,PERIOD_D1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iD1);
      bufferD1BBm[i]    = iBands(NULL,PERIOD_D1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iD1);
      bufferD1BBl[i]    = iBands(NULL,PERIOD_D1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iD1);
      bufferH4BBh[i]    = iBands(NULL,PERIOD_H4,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iH4);
      bufferH4BBm[i]    = iBands(NULL,PERIOD_H4,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iH4);
      bufferH4BBl[i]    = iBands(NULL,PERIOD_H4,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iH4);
      bufferH1BBh[i]    = iBands(NULL,PERIOD_H1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iH1);
      bufferH1BBm[i]    = iBands(NULL,PERIOD_H1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iH1);
      bufferH1BBl[i]    = iBands(NULL,PERIOD_H1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iH1);
      bufferM30BBh[i]   = iBands(NULL,PERIOD_M30,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iM30);
      bufferM30BBm[i]   = iBands(NULL,PERIOD_M30,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iM30);
      bufferM30BBl[i]   = iBands(NULL,PERIOD_M30,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iM30);
      bufferM15BBh[i]   = iBands(NULL,PERIOD_M15,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iM15);
      bufferM15BBm[i]   = iBands(NULL,PERIOD_M15,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iM15);
      bufferM15BBl[i]   = iBands(NULL,PERIOD_M15,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iM15);
      bufferM5BBh[i]    = iBands(NULL,PERIOD_M5,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iM5);
      bufferM5BBm[i]    = iBands(NULL,PERIOD_M5,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iM5);
      bufferM5BBl[i]    = iBands(NULL,PERIOD_M5,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iM5);
      bufferM1BBh[i]    = iBands(NULL,PERIOD_M1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,iM1);
      bufferM1BBm[i]    = iBands(NULL,PERIOD_M1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_MAIN,iM1);
      bufferM1BBl[i]    = iBands(NULL,PERIOD_M1,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,iM1);
     }
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceLabel(bool show,int lblHwnd,double price,string text,color foreground,color background=clrLightGray)
  {
   string name="MTF BBands"+text;
   ObjectDelete(0,name);
   if(show)
     {
      int x,y;
      datetime fwdTime;
      int      window=0;

      ChartTimePriceToXY(0,0,Time[0],price,x,y);
      x = x + 30;
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

   arr[0] = mM1;
   arr[1] = mM5;
   arr[2] = mM15;
   arr[3] = mM30;
   arr[4] = mH1;
   arr[5] = mH4;
   arr[6] = mD1;
   arr[7] = mW1;
   arr[8] = mMN1;

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

      mM1 = arr[0];
      mM5 = arr[1];
      mM15 = arr[2];
      mM30 = arr[3];
      mH1 = arr[4];
      mH4 = arr[5];
      mD1 = arr[6];
      mW1 = arr[7];
      mMN1= arr[8];

      //--- close the file
      FileClose(file_handle);
     }
   else
     {
      Print("File open failed, error: "+(string) GetLastError());
     }

  }
//+------------------------------------------------------------------+
