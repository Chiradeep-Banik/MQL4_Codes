#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Orange
#property indicator_color3 Yellow
#property indicator_color4 Lime
#property indicator_color5 Blue
#property indicator_color6 DodgerBlue
#property indicator_color7 DarkViolet
#property indicator_color8 DimGray

//---- input parameters

extern int       iPeriod=240;
extern int       iStartFrom=1; 
extern string    AddToObjName="1";
extern color     HandlerColor=Gray;
extern color     TextColor=Black; 
 
string ObjNPref="Spectrometr";
string ShortName;

int LastTime;
double A[],B[],R[],F[];

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];


int LastLeftBar;
int LastRightBar;
int LastLeftTime;
int LastRightTime;
int LastStartFrom;
int LastiStartFrom;
int LastiPeriod;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   ShortName=ObjNPref+"_"+AddToObjName;   
   ObjNPref=ObjNPref+"_"+AddToObjName+"_";  
   
  
   
   IndicatorShortName(ShortName);

   SetIndexStyle(0,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(0,ExtMapBuffer1);
   
   SetIndexStyle(1,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(1,ExtMapBuffer2);   
   
   SetIndexStyle(2,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(2,ExtMapBuffer3);      
   
   SetIndexStyle(3,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(3,ExtMapBuffer4);   
   
   SetIndexStyle(4,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(4,ExtMapBuffer5);     
   
   SetIndexStyle(5,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(5,ExtMapBuffer6);        
   
   SetIndexStyle(6,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(6,ExtMapBuffer7);
   
   SetIndexStyle(7,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(7,ExtMapBuffer8);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   fObjDeleteByPrefix(ObjNPref);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start(){


      string ObjName=ObjNPref+"Нулевая линия";
         
         if(ObjectFind(ObjName)!=WindowFind(ShortName)){
            LastStartFrom=iStartFrom;//
            LastLeftBar=iStartFrom+iPeriod-1;
            LastRightBar=iStartFrom;            
            LastLeftTime=Time[LastLeftBar];
            LastRightTime=Time[LastRightBar];         
            fObjTrendLine(ObjName,LastLeftTime,0,LastRightTime,0,false,HandlerColor,3,WindowFind(ShortName),0,true);
         }
         
      int NowLeftTime=ObjectGet(ObjName,OBJPROP_TIME1);
      int NowRightTime=ObjectGet(ObjName,OBJPROP_TIME2); 
      if(NowRightTime>Time[1])NowRightTime=Time[1];
      
      int NowLeftBar=iBarShift(NULL,0,NowLeftTime,false);
      int NowRightBar=iBarShift(NULL,0,NowRightTime,false);  
      iPeriod=NowLeftBar-NowRightBar+1; 
      int LastStartFromTime=iBarShift(NULL,0,LastRightTime,false);  
      iStartFrom=(NowRightBar-LastStartFromTime)+LastStartFrom; 
      
      LastStartFrom=iStartFrom;
      LastLeftBar=iStartFrom+iPeriod-1;
      LastRightBar=iStartFrom;            
      LastLeftTime=Time[LastLeftBar];
      LastRightTime=Time[LastRightBar];         
      fObjTrendLine(ObjName,LastLeftTime,0,LastRightTime,0,false,HandlerColor,3,WindowFind(ShortName),0,true);
      
      ObjName=ObjNPref+"iPeriod";
      fObjLabel(ObjName,80,5,"Period: "+iPeriod,3,TextColor,8,WindowFind(ShortName),"Arial Black",false);
      ObjName=ObjNPref+"iStartFrom";      
      fObjLabel(ObjName,10,5,"StartFrom: "+iStartFrom,3,TextColor,8,WindowFind(ShortName),"Arial Black",false);
      
      
   //=====================================================================================================    

      static int LastBars=0;

      if(iStartFrom==LastiStartFrom && iPeriod==LastiPeriod)if(Bars<LastBars+1)return(0);
      LastiStartFrom=iStartFrom;
      LastiPeriod=iPeriod;
      LastBars=Bars;
         
      ArrayInitialize(ExtMapBuffer1,EMPTY_VALUE);
      ArrayInitialize(ExtMapBuffer2,EMPTY_VALUE);
      ArrayInitialize(ExtMapBuffer3,EMPTY_VALUE);
      ArrayInitialize(ExtMapBuffer4,EMPTY_VALUE);
      ArrayInitialize(ExtMapBuffer5,EMPTY_VALUE);
      ArrayInitialize(ExtMapBuffer6,EMPTY_VALUE);
      ArrayInitialize(ExtMapBuffer7,EMPTY_VALUE);
      ArrayInitialize(ExtMapBuffer8,EMPTY_VALUE);
   
   //=====================================================================================================    

      int tPeriod; 
      double tVal_0;
      double tVal_1;
      double tB;
      double tMaxDev;
      double tStdError; 
      double tRSquared;
      double Arr[];

      fLinearRegressionAll2(iStartFrom,iStartFrom+iPeriod-1,0,tPeriod,tVal_0,tVal_1,tB,tMaxDev,tStdError,tRSquared,Arr);
                
   //======================================================================================================      
         
      fFurie(Arr,A,B,R,F);
   //======================================================================================================      
         
      int N=ArraySize(Arr);
         for(int i=0;i<N;i++){
            int ii=i+iStartFrom;
            ExtMapBuffer1[ii]=A[1]*MathSin(1*6.28*i/(N-1))+B[1]*MathCos(1*6.28*i/(N-1));
            ExtMapBuffer2[ii]=A[2]*MathSin(2*6.28*i/(N-1))+B[2]*MathCos(2*6.28*i/(N-1));               
            ExtMapBuffer3[ii]=A[3]*MathSin(3*6.28*i/(N-1))+B[3]*MathCos(3*6.28*i/(N-1));
            ExtMapBuffer4[ii]=A[4]*MathSin(4*6.28*i/(N-1))+B[4]*MathCos(4*6.28*i/(N-1));               
            ExtMapBuffer5[ii]=A[5]*MathSin(5*6.28*i/(N-1))+B[5]*MathCos(5*6.28*i/(N-1));               
            ExtMapBuffer6[ii]=A[6]*MathSin(6*6.28*i/(N-1))+B[6]*MathCos(6*6.28*i/(N-1));
            ExtMapBuffer7[ii]=A[7]*MathSin(7*6.28*i/(N-1))+B[7]*MathCos(7*6.28*i/(N-1));               
            ExtMapBuffer8[ii]=A[8]*MathSin(8*6.28*i/(N-1))+B[8]*MathCos(8*6.28*i/(N-1));                 
         }
   
   //======================================================================================================      
                                   //линии справа
      fObjTrendLine(ObjNPref+"1",Time[0]+Period()*60*3,R[1],Time[0]+Period()*60*3,-R[1],false,indicator_color1,8,WindowFind(ShortName),0,false);
      fObjTrendLine(ObjNPref+"2",Time[0]+Period()*60*5,R[2],Time[0]+Period()*60*5,-R[2],false,indicator_color2,8,WindowFind(ShortName),0,false);
      fObjTrendLine(ObjNPref+"3",Time[0]+Period()*60*7,R[3],Time[0]+Period()*60*7,-R[3],false,indicator_color3,8,WindowFind(ShortName),0,false);
      fObjTrendLine(ObjNPref+"4",Time[0]+Period()*60*9,R[4],Time[0]+Period()*60*9,-R[4],false,indicator_color4,8,WindowFind(ShortName),0,false);
      fObjTrendLine(ObjNPref+"5",Time[0]+Period()*60*11,R[5],Time[0]+Period()*60*11,-R[5],false,indicator_color5,8,WindowFind(ShortName),0,false);
      fObjTrendLine(ObjNPref+"6",Time[0]+Period()*60*13,R[6],Time[0]+Period()*60*13,-R[6],false,indicator_color6,8,WindowFind(ShortName),0,false);
      fObjTrendLine(ObjNPref+"7",Time[0]+Period()*60*15,R[7],Time[0]+Period()*60*15,-R[7],false,indicator_color7,8,WindowFind(ShortName),0,false);
      fObjTrendLine(ObjNPref+"8",Time[0]+Period()*60*17,R[8],Time[0]+Period()*60*17,-R[8],false,indicator_color8,8,WindowFind(ShortName),0,false);

         
   return(0);
}
//+------------------------------------------------------------------+
 
                                //надпись нижний левый угол                              
void fObjLabel(
   string aObjectName,     // 1 имя
   int aX,                 // 2 х
   int aY,                 // 3 у
   string aText,           // 4 текст
   int aCorner=0,          // 5 угол   0  1
                           //          2  3
   color aColor=Black,       // 6 цвет
   int aFontSize=8,        // 7 размер шрифта
   int aWindowNumber=0,    // 8 окно
   string aFont="Arial Black",   // 9 шрифт
   bool aBack=false        // 10 фон
   ){     

    
      if(ObjectFind(aObjectName)!=aWindowNumber){
         ObjectCreate(aObjectName,OBJ_LABEL,aWindowNumber,0,0);
      }      
   ObjectSet(aObjectName,OBJPROP_XDISTANCE,aX);
   ObjectSet(aObjectName,OBJPROP_YDISTANCE,aY);   
   ObjectSetText(aObjectName,aText,aFontSize,aFont,aColor);
   ObjectSet(aObjectName,OBJPROP_BACK,aBack);
   ObjectSet(aObjectName,OBJPROP_CORNER,aCorner);   
}

                               //отрисовка вертик линий
void fObjTrendLine(
   string aObjectName,  // 1 имя
   datetime aTime_1,    // 2 время 1
   double aPrice_1,     // 3 цена 1
   datetime aTime_2,    // 4 время 2
   double aPrice_2,     // 5 цена 2
   bool aRay=false,     // 6 луч
   color aColor=Black,    // 7 цвет
   int aWidth=1,        // 8 толщина
   int aWindowNumber=0, // 9 окно
   int aStyle=1,        // 10 0-STYLE_SOLID, 1-STYLE_DASH, 2-STYLE_DOT, 3-STYLE_DASHDOT, 4-STYLE_DASHDOTDOT
   bool aBack=false     // 11 фон
   ){                              
      if(ObjectFind(aObjectName)!=aWindowNumber){
         ObjectCreate(aObjectName,OBJ_TREND,aWindowNumber,aTime_1,aPrice_1,aTime_2,aPrice_2);
      }      
   ObjectSet(aObjectName,OBJPROP_TIME1,aTime_1);
   ObjectSet(aObjectName,OBJPROP_PRICE1,aPrice_1);   
   ObjectSet(aObjectName,OBJPROP_TIME2,aTime_2);       
   ObjectSet(aObjectName,OBJPROP_PRICE2,aPrice_2); 
   ObjectSet(aObjectName,OBJPROP_RAY,aRay);     
   ObjectSet(aObjectName,OBJPROP_COLOR,aColor);
   ObjectSet(aObjectName,OBJPROP_WIDTH,aWidth);
   ObjectSet(aObjectName,OBJPROP_BACK,aBack);
   ObjectSet(aObjectName,OBJPROP_STYLE,aStyle);                
}


int fLinearRegressionAll2(int i0,int i1, int aPrice, int & aPeriod, double & aVal_0, double & aVal_1, double & aB, double & aMaxDev, double & aStdError, double & aRSquared,double & aArr[]){
   int rRetError=0;
   double x,y,y1,y2,sumy,sumx,sumxy,sumx2,sumy2,sumx22,sumy22,div1,div2;   
   aPeriod=i1-i0+1;
   sumy=0.0;sumx=0.0;sumxy=0.0;sumx2=0.0;sumy2=0.0;
      for(int i=0; i<aPeriod; i++){
         y=iMA(NULL,0,1,0,0,aPrice,i0+i);
         x=i;
         sumy+=y;
         sumxy+=y*i;
         sumx+=x;
         sumx2+=MathPow(x,2);  
         sumy2+=MathPow(y,2);         
      } 
   sumx22=MathPow(sumx,2);  
   sumy22=MathPow(sumy,2);      
   div1=sumx2*aPeriod-sumx22;
   div2=MathSqrt((aPeriod*sumx2-sumx22)*(aPeriod*sumy2-sumy22));   

   //---- regression line ----
   
      if(div1!=0.0){
         aB=(sumxy*aPeriod-sumx*sumy)/div1;
         aVal_0=(sumy-sumx*aB)/aPeriod;
         aVal_1=aVal_0+aB*(aPeriod-1);
         rRetError+=-1;
      }
      else{
         rRetError+=-1;      
      }

   //--- stderr & maxdev

   aMaxDev=0;aStdError=0;
   
      for(i=0;i<aPeriod;i++){
         y1=iMA(NULL,0,1,0,0,aPrice,i0+i);
         y2=aVal_0+aB*i;
         aMaxDev=MathMax(MathAbs(y1-y2),aMaxDev);
         aStdError+=MathPow(y1-y2,2);
      }
      
   aStdError=MathSqrt(aStdError/aPeriod);

   //--- rsquared ---

      if(div2!=0){
         aRSquared=MathPow((aPeriod*sumxy-sumx*sumy)/div2,2);   
      }   
      else{
         rRetError+=-2;
      }
   
   //----
   
   ArrayResize(aArr,aPeriod);
      for(i=0; i<aPeriod; i++){
         y=iMA(NULL,0,1,0,0,aPrice,i0+i);
         x=aVal_0+i*(aVal_1-aVal_0)/aPeriod;
         aArr[i]=y-x;
      } 
   return(rRetError);   
}

void fFurie(double aArr[],double & aA[],double & aB[],double & aR[], double & aF[]){
   int tN=ArraySize(aArr);
   int tM=tN/2;
   
   ArrayResize(aA,tM);
   ArrayResize(aB,tM);  
   ArrayResize(aR,tM); 
   ArrayResize(aF,tM);                            
   
      for (int ti=1;ti<tM;ti++){
         aA[ti]=0;
         aB[ti]=0;
            for(int tj=0;tj<tN;tj++){
               aA[ti]+=aArr[tj]*MathSin(ti*6.28*tj/tN);
               aB[ti]+=aArr[tj]*MathCos(ti*6.28*tj/tN);
            }
         aA[ti]=2*aA[ti]/tN;
         aB[ti]=2*aB[ti]/tN;  
         aR[ti]=MathSqrt(MathPow(aA[ti],2)+MathPow(aB[ti],2));
         aF[ti]=fMyArcTan(aB[ti],aA[ti]);
      }
            
}

double fMyArcTan(double aS,double aC){
   if(aS==0){
      return(0);   
   }
   if(aC==0){
      if(aS>0){
         return(MathArctan(1)*2);
      }
      else{
         if(aS<0){
            return(MathArctan(1)*6);         
         }
      }
   }
   else{
      if(aS>0){
         if(aC>0){
            return(MathArctan(aS/aC));  
         }
         else{
            return(MathArctan(aS/aC)+MathArctan(1)*4);          
         }   
      }
      else{
         if(aC>0){
            return(MathArctan(aS/aC)+MathArctan(1)*8);           
         }
         else{
            return(MathArctan(aS/aC)+MathArctan(1)*4);           
         }      
      }
   }
}



void fObjDeleteByPrefix(string aPrefix){
   for(int i=ObjectsTotal()-1;i>=0;i--){
      if(StringFind(ObjectName(i),aPrefix,0)==0){
         ObjectDelete(ObjectName(i));
      }
   }
}

