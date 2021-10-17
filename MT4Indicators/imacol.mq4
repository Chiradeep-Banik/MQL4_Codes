//+------------------------------------------------------------------+
//|                                                       iMACol.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 DeepSkyBlue
#property indicator_color3 Red
#property indicator_color4 DeepSkyBlue
#property indicator_color5 Red

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

//---- input parameters

extern   double   SwitchPoints   =  25;   // Определяет величину движения МА от ее 
                                          // максимума или минимума при котором происходит 
                                          // изменение цвета. Определяется в пунктах.
extern   int      MAPeriod       =  21;   // Период МА
extern   int      MAMethod       =  1;    // Метод МА: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA
extern   int      MAPrice        =  0;    // Цена МА: 0-Close, 1-Open, 2-High, 3-Low, 4-Median, 5-Typical, 6-Weighted

      
      
//---- buffers
double ma[];
double up[];
double dn[];
double up2[];
double dn2[];
double tr[];
double mx[];

double sp;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){

   sp=Point*SwitchPoints;

   IndicatorBuffers(7);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ma);
   SetIndexEmptyValue(0,0);   
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,up);
   SetIndexEmptyValue(1,0);   
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,dn);
   SetIndexEmptyValue(2,0);   
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,158);
   SetIndexBuffer(3,up2);
   SetIndexEmptyValue(3,0);   
   
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,158);
   SetIndexBuffer(4,dn2);
   SetIndexEmptyValue(4,0);   
   
   SetIndexBuffer(5,tr);
   SetIndexEmptyValue(5,0);
   SetIndexBuffer(6,mx);
   SetIndexEmptyValue(6,0);

   SetIndexLabel(0,"MA");
   SetIndexLabel(1,"");
   SetIndexLabel(2,"");
   SetIndexLabel(3,"");
   SetIndexLabel(4,"");

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

         int limit=Bars-IndicatorCounted();

            for(int i=limit-1;i>=0;i--){
               up[i]=0;
               dn[i]=0;
               up2[i]=0;
               dn2[i]=0;
               tr[i]=tr[i+1];
               mx[i]=mx[i+1];
               ma[i]=iMA(NULL,0,MAPeriod,0,MAMethod,MAPrice,i);                  
                  switch((int)tr[i]){
                     case 1:
                        mx[i]=MathMax(mx[i],ma[i]);
                           if(ma[i]<mx[i]-sp){
                              tr[i]=-1;
                              dn[i]=ma[i];
                              dn2[i]=ma[i];
                           }  
                           else{
                              up[i]=ma[i];
                           }                
                     break;
                     case 0:
                        if(ma[i]!=0){
                           if(mx[i]==0){
                              mx[i]=ma[i];
                           }
                           else{
                              if(ma[i]>mx[i]+sp){
                                 tr[i]=1;
                                 mx[i]=ma[i];
                                 up[i]=ma[i];
                              }
                              else{
                                 if(ma[i]<mx[i]-sp){
                                    tr[i]=-1;
                                    mx[i]=ma[i];
                                    dn[i]=ma[i];
                                 }                              
                              }
                           }
                        }
                     break;
                     case -1:
                        mx[i]=MathMin(mx[i],ma[i]);
                           if(ma[i]>mx[i]+sp){
                              tr[i]=1;
                              up[i]=ma[i];
                              up2[i]=ma[i];
                           }  
                           else{
                              dn[i]=ma[i];
                           }  
                     break;
                  }
                  
            }

   return(0);
}
//+------------------------------------------------------------------+