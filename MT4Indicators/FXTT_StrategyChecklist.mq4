//+------------------------------------------------------------------+
//|                                      FXTT_StrategyChecklist.mq4 |
//|                                  Copyright 2016, Carlos Oliveira |
//|                                         http://carlosoliveira.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Carlos Oliveira"
#property link      "https://www.forextradingtools.eu?ref=mql5-sc"
#property version   "1.20"
#property strict
#property indicator_chart_window

#include <Controls\Dialog.mqh>
#include <Controls\CheckGroup.mqh>

extern string TAG = "1";   
extern ENUM_BASE_CORNER Position = CORNER_LEFT_UPPER; //Window Position
extern string Check01 = ">------- Example 1 -------<";
extern string Check02 = "Example 2";
extern string Check03 = "Example 3";
extern string Check04 = "";
extern string Check05 = "";
extern string Check06 = "";
extern string Check07 = "";
extern string Check08 = "";
extern string Check09 = "";
extern string Check10 = "";
extern string Check11 = "";
extern string Check12 = "";
extern string Check13 = "";
extern string Check14 = "";
extern string Check15 = "";
extern string Check16 = "";
extern string Check17 = "";
extern string Check18 = "";
extern string Check19 = "";
extern string Check20 = "";


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

string  DataFileName="data.bin";             // File name
string  DataDirectoryName="SChecklist";      // Folder name


//+------------------------------------------------------------------+
//| Class CPanelDialog                                               |
//| Usage: main dialog of the SimplePanel application                |
//+------------------------------------------------------------------+
class CPanelDialog : public CAppDialog
  {
private:
   CCheckGroup       m_check_group;                   // the check box group object   
public:
   bool              chk01;
   bool              chk02;
   bool              chk03;
   bool              chk04;
   bool              chk05;
   bool              chk06;
   bool              chk07;
   bool              chk08;
   bool              chk09;
   bool              chk10;
   
   bool              chk11;
   bool              chk12;
   bool              chk13;
   bool              chk14;
   bool              chk15;
   bool              chk16;
   bool              chk17;
   bool              chk18;
   bool              chk19;
   bool              chk20;

                     CPanelDialog(void);
                    ~CPanelDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   void              WriteIndicatorsData(void);
   void              ReadIndicatorsData(void);   
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

   chk01=false;
   chk02=false;
   chk03=false;
   chk04=false;
   chk05=false;
   chk06=false;
   chk07=false;
   chk08=false;
   chk09=false;
   chk10=false;
   chk11=false;
   chk12=false;
   chk13=false;
   chk14=false;
   chk15=false;
   chk16=false;
   chk17=false;
   chk18=false;
   chk19=false;
   chk20=false;

   ReadIndicatorsData();

   m_check_group.Check(0, chk01);
   m_check_group.Check(1, chk02);
   m_check_group.Check(2, chk03);
   m_check_group.Check(3, chk04);
   m_check_group.Check(4, chk05);
   m_check_group.Check(5, chk06);
   m_check_group.Check(6, chk07);
   m_check_group.Check(7, chk08);
   m_check_group.Check(8, chk09);
   m_check_group.Check(9, chk10);   
   m_check_group.Check(10, chk11);
   m_check_group.Check(11, chk12);
   m_check_group.Check(12, chk13);
   m_check_group.Check(13, chk14);
   m_check_group.Check(14, chk15);
   m_check_group.Check(15, chk16);
   m_check_group.Check(16, chk17);
   m_check_group.Check(17, chk18);
   m_check_group.Check(18, chk19);
   m_check_group.Check(19, chk20);
    
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup" element                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::CreateCheckGroup(void)
  {   
   if(!m_check_group.Create(m_chart_id,TAG+m_name+"CheckGroup",m_subwin,0,0,312 , GetNumLines() * 18))
      return(false);
   if(!Add(m_check_group))
      return(false);
            
                              
   if(StringLen(Check01) > 0 && !m_check_group.AddItem(Check01,1<<0))
      return(false);   
   if(StringLen(Check02) > 0 && !m_check_group.AddItem(Check02,1<<1))
      return(false);
   if(StringLen(Check03) > 0 && !m_check_group.AddItem(Check03,1<<2))
      return(false);
   if(StringLen(Check04) > 0 && !m_check_group.AddItem(Check04,1<<3))
      return(false);
   if(StringLen(Check05) > 0 && !m_check_group.AddItem(Check05,1<<4))
      return(false);
   if(StringLen(Check06) > 0 && !m_check_group.AddItem(Check06,1<<5))
      return(false);
   if(StringLen(Check07) > 0 && !m_check_group.AddItem(Check07,1<<6))
      return(false);
   if(StringLen(Check08) > 0 && !m_check_group.AddItem(Check08,1<<7))
      return(false);
   if(StringLen(Check09) > 0 && !m_check_group.AddItem(Check09,1<<8))
      return(false);
   if(StringLen(Check10) > 0 && !m_check_group.AddItem(Check10,1<<9))
      return(false);      
   if(StringLen(Check11) > 0 && !m_check_group.AddItem(Check11,1<<10))
      return(false);   
   if(StringLen(Check12) > 0 && !m_check_group.AddItem(Check12,1<<11))
      return(false);
   if(StringLen(Check13) > 0 && !m_check_group.AddItem(Check13,1<<12))
      return(false);
   if(StringLen(Check14) > 0 && !m_check_group.AddItem(Check14,1<<13))
      return(false);
   if(StringLen(Check15) > 0 && !m_check_group.AddItem(Check15,1<<14))
      return(false);
   if(StringLen(Check16) > 0 && !m_check_group.AddItem(Check16,1<<15))
      return(false);
   if(StringLen(Check17) > 0 && !m_check_group.AddItem(Check17,1<<16))
      return(false);
   if(StringLen(Check18) > 0 && !m_check_group.AddItem(Check18,1<<17))
      return(false);
   if(StringLen(Check19) > 0 && !m_check_group.AddItem(Check19,1<<18))
      return(false);
   if(StringLen(Check20) > 0 && !m_check_group.AddItem(Check20,1<<19))
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
     
   chk01=m_check_group.Check(0);
   chk02=m_check_group.Check(1);
   chk03=m_check_group.Check(2);
   chk04=m_check_group.Check(3);
   chk05=m_check_group.Check(4);
   chk06=m_check_group.Check(5);
   chk07=m_check_group.Check(6);
   chk08=m_check_group.Check(7);
   chk09=m_check_group.Check(8);
   chk10=m_check_group.Check(9);   
   chk11=m_check_group.Check(10);
   chk12=m_check_group.Check(11);
   chk13=m_check_group.Check(12);
   chk14=m_check_group.Check(13);
   chk15=m_check_group.Check(14);
   chk16=m_check_group.Check(15);
   chk17=m_check_group.Check(16);
   chk18=m_check_group.Check(17);
   chk19=m_check_group.Check(18);
   chk20=m_check_group.Check(19);
  }

//+------------------------------------------------------------------+
//| Rest events handler                                                    |
//+------------------------------------------------------------------+
bool CPanelDialog::OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- let's handle event by parent
   return(false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CPanelDialog ExtDialog;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(ChartID(),TAG);

//--- create application dialog
   int chartHeight=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   int chartWidth=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   
   int wndWidth = 330;
   int wndHeight = GetNumLines() * 18 + 50;
   
   int pX1 = 10;  //window x spacing
   int pY1 = 10;  //window y spacing
   
   switch(Position)
     {      
      case CORNER_LEFT_LOWER:   
         pY1 = chartHeight - wndHeight - pY1;
        break;
      case CORNER_RIGHT_LOWER:     
         pX1 = chartWidth - wndWidth - pX1;
         pY1 = chartHeight - wndHeight - pY1;
        break;
      case CORNER_RIGHT_UPPER:       
         pX1 = chartWidth - wndWidth - pX1; 
        break;      
     }
   int pX2 = pX1 + wndWidth;
   int pY2 = pY1 + wndHeight;     
     
   if(!ExtDialog.Create(0,TAG+"-Strategy Checklist",0,pX1,pY1,pX2,pY2))
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
   ObjectsDeleteAll(ChartID(),TAG);

//--- destroy application dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
// Call function ManageEvents on every MT4 tick            
   
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

void CPanelDialog::WriteIndicatorsData()
  {
   bool arr[20];
   string path=DataDirectoryName+"//"+Symbol()+DataFileName;

   arr[0] = chk01;
   arr[1] = chk02;
   arr[2] = chk03;
   arr[3] = chk04;
   arr[4] = chk05;
   arr[5] = chk06;
   arr[6] = chk07;
   arr[7] = chk08;
   arr[8] = chk09;
   arr[9] = chk10;
   
   arr[10] = chk11;
   arr[11] = chk12;
   arr[12] = chk13;
   arr[13] = chk14;
   arr[14] = chk15;
   arr[15] = chk16;
   arr[16] = chk17;
   arr[17] = chk18;
   arr[18] = chk19;
   arr[19] = chk20;

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

      chk01 = arr[0];
      chk02 = arr[1];
      chk03 = arr[2];
      chk04 = arr[3];
      chk05 = arr[4];
      chk06 = arr[5];
      chk07 = arr[6];
      chk08 = arr[7];
      chk09 = arr[8];
      chk10 = arr[9];
      
      chk11 = arr[10];
      chk12 = arr[11];
      chk13 = arr[12];
      chk14 = arr[13];
      chk15 = arr[14];
      chk16 = arr[15];
      chk17 = arr[16];
      chk18 = arr[17];
      chk19 = arr[18];
      chk20 = arr[19];

      //--- close the file
      FileClose(file_handle);
     }
   else
     {
      Print("File open failed, error: "+(string) GetLastError());
     }

  }
//+------------------------------------------------------------------+

int GetNumLines()
{
   int dy = 0;
   
   if(StringLen(Check01) > 0)
      dy++;
   if(StringLen(Check02) > 0)
      dy++;
   if(StringLen(Check03) > 0)
      dy++;
   if(StringLen(Check04) > 0)
      dy++;
   if(StringLen(Check05) > 0)
      dy++;
   if(StringLen(Check06) > 0)
      dy++;
   if(StringLen(Check07) > 0)
      dy++;
   if(StringLen(Check08) > 0)
      dy++;
   if(StringLen(Check09) > 0)
      dy++;
   if(StringLen(Check10) > 0)
      dy++;      
   if(StringLen(Check11) > 0)
      dy++;   
   if(StringLen(Check12) > 0)
      dy++;
   if(StringLen(Check13) > 0)
      dy++;
   if(StringLen(Check14) > 0)
      dy++;
   if(StringLen(Check15) > 0)
      dy++;
   if(StringLen(Check16) > 0)
      dy++;
   if(StringLen(Check17) > 0)
      dy++;
   if(StringLen(Check18) > 0)
      dy++;
   if(StringLen(Check19) > 0)
      dy++;
   if(StringLen(Check20) > 0)
      dy++;
   
   return dy;
}
