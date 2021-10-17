//+------------------------------------------------------------------+
//|                                                      show123.mq4 |
//|         Copyright © 2006, Computer Objectives Designed & Evolved |
//| Version 1.0                                                      |
//|Supplied as Freeware. Code can be replicated and used as desired  |
//|              Built on and for Meta Trader version 4              |
//|  No responsibility taken for ANY trade decision made using this  |
//| software. No responsibility taken for ANY side effects           |
//| where this software is used.                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Computer Objectives Designed & Evolved"



#property indicator_chart_window


extern color downcolor= Red;
extern color upcolor = Green;
extern color faildncolor = DarkSalmon;
extern color failupcolor = DarkSeaGreen;
extern color bbreakcolor = DodgerBlue;
extern int  maxbars=300;
extern int aggression=1;
extern int behaviourswitches=259;//1+2+256;
                                 //allow 1&2on same 
                                 //allow 2&3 on same 
                                 // remove 123s where 2 is a RH
                                 
extern int rejectifheightlessthan=15;
extern int targetpercent123=100;
extern int targetstart123=2;
extern bool showrosshooks=true;
extern string fontname="Arial Black";
extern int fontsize=8;
extern int PipTextHeight=0;

extern bool showbandbreaks=false;
extern bool onlyshow1stbreak=true;
extern int bandperiod=20;
extern double banddev=2.0;


datetime upmarkers[][4],downmarkers[][4],uprh[],dnrh[],bbreakup[],bbreakdn[];
int totdnmarkers,totupmarkers,totuprh,totdnrh,totbbup,totbbdn;

double estpiptexth=0.0;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
// reset marker counts
   totdnmarkers =0;
   totupmarkers =0;
   totuprh=0;
   totdnrh=0;
   totbbdn=0;
   totbbup=0;
   estpiptexth=0.0;
   
   // make sure sensible values are set
   if ((targetstart123 <0) || (targetstart123 >3)) targetstart123=2;
   if (targetpercent123 <0) targetpercent123 = 0;
   if ((aggression <1) || (aggression >3)) aggression = 1;
   if (rejectifheightlessthan <0) rejectifheightlessthan=0;
   if (bandperiod <2) bandperiod =20;
   if (banddev < 0.1) banddev =2.0;
   
   // if user allows 1&2 on  same bar then definately dont allow 
   // new 1 on prev 2 or a new 2 on prev 2
   if ((behaviourswitches & 1)== 1)
   {
    if ((behaviourswitches & 4)== 4) behaviourswitches -=4;
    if ((behaviourswitches & 16)== 16) behaviourswitches -=16;
   }
   //if user allow 2&3 on same bar then def dont allow
   // 2 on prev 3 or a 3 on prev 2
   if ((behaviourswitches & 2)==2)
   {
    if ((behaviourswitches & 32)== 32) behaviourswitches -=32;
    if ((behaviourswitches & 64)== 64) behaviourswitches -=64;
   }
   return(0);
  }


void moveallmarkers()
{
int pos;
datetime tdt;

// get oldest date of all markers
 if (totupmarkers >0) tdt = upmarkers[0][0];
 if ((totdnmarkers >0) &&  (downmarkers[0][0] < tdt)) tdt = downmarkers[0][0];
 if ((totuprh >0) &&  (uprh[0] < tdt)) tdt = uprh[0];
 if ((totdnrh >0) &&  (dnrh[0] < tdt)) tdt = dnrh[0];
 if ((totbbup >0) &&  (bbreakup[0] < tdt)) tdt = bbreakup[0];
 if ((totbbdn >0) &&  (bbreakdn[0] < tdt)) tdt = bbreakdn[0];
 
 
 
 //get barnum for date 
  pos = iBarShift(NULL,0,tdt,true);
  
  // iterate all bars and force marker moves on hi & lo of every bar
  while (pos >=0)
  {
    movemarkers("123Up1,"+DoubleToStr(Time[pos],0));
    movemarkers("123Dp1,"+DoubleToStr(Time[pos],0));    
    pos--;
  }

}


// recalc & set marker positions on a bars high or low that corresponds to the 
// type of marker supplied in obname
void movemarkers(string obname)
{
   double yp=0;
   int obindx=0;
   string tstr;
   int pos;

   pos = iBarShift(NULL,0,StrToDouble(StringSubstr(obname,7,StringLen(obname)-7)),true); 

   
   if (obinset(obname,"B"))
   {
    /// move markers in bottom pos  
     yp = Low[pos];
     tstr ="123Dp2,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp-estpiptexth;
     }
     
     tstr ="123Up1,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp-estpiptexth;
     }

     tstr ="123Up3,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp-estpiptexth;
     }
     
     tstr = "123Drh,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp-estpiptexth;
     }

     tstr = "123Dbb,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp-estpiptexth;
     }
     
   }
   else
   {
    //move markers in top pos
     yp = High[pos]+estpiptexth;
     tstr ="123Up2,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp+estpiptexth;
     }
     
     tstr ="123Dp1,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp+estpiptexth;
     }

     tstr ="123Dp3,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp+estpiptexth;
     }

     tstr = "123Urh,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp+estpiptexth;
     }

     tstr = "123Ubb,"+StringSubstr(obname,7,StringLen(obname)-7);
     obindx = ObjectFind(tstr);
     if (obindx !=-1)
     {
      ObjectSet(tstr,OBJPROP_PRICE1,yp);
      yp=yp+estpiptexth;
     }
    
   }
}

// delete old markers of the type specified in mtype 
// from pos specifies the 
void deleteoldmarkers(string mtype,int frompos)
{
   // delete old 123 text markers
   // if frompos = -1 then delete all markers
   // else delete markers younger than the date supplied
   
   if (mtype == "D")
   {
      while (totdnmarkers > frompos) 
      {
         ObjectDelete("123Dp1,"+DoubleToStr(downmarkers[totdnmarkers-1][0],0));
         movemarkers("123Dp1,"+DoubleToStr(downmarkers[totdnmarkers-1][0],0));
         ObjectDelete("123Dp2,"+DoubleToStr(downmarkers[totdnmarkers-1][1],0));
         movemarkers("123Dp2,"+DoubleToStr(downmarkers[totdnmarkers-1][1],0));
         ObjectDelete("123Dp3,"+DoubleToStr(downmarkers[totdnmarkers-1][2],0));
         movemarkers("123Dp3,"+DoubleToStr(downmarkers[totdnmarkers-1][2],0));
         totdnmarkers--;
         ArrayResize(downmarkers,totdnmarkers);
      }
   }
   else if (mtype == "U")
   {
      while (totupmarkers > frompos)
      {
         ObjectDelete("123Up1,"+DoubleToStr(upmarkers[totupmarkers-1][0],0));
         movemarkers("123Up1,"+DoubleToStr(upmarkers[totupmarkers-1][0],0));
         ObjectDelete("123Up2,"+DoubleToStr(upmarkers[totupmarkers-1][1],0));
         movemarkers("123Up2,"+DoubleToStr(upmarkers[totupmarkers-1][1],0));
         ObjectDelete("123Up3,"+DoubleToStr(upmarkers[totupmarkers-1][2],0));
         movemarkers("123Up3,"+DoubleToStr(upmarkers[totupmarkers-1][2],0));
         totupmarkers--;
         ArrayResize(upmarkers,totupmarkers);
      }
   }
   else if (mtype == "URH")
   {
      while (totuprh >frompos)
      {
         ObjectDelete("123Urh,"+DoubleToStr(uprh[totuprh-1],0));
         movemarkers("123Urh,"+DoubleToStr(uprh[totuprh-1],0));
         totuprh--;
         ArrayResize(uprh,totuprh);
      }
   }
   else if (mtype == "DRH")
   {
     while (totdnrh >frompos)
     {
         ObjectDelete("123Drh,"+DoubleToStr(dnrh[totdnrh-1],0));
         movemarkers("123Drh,"+DoubleToStr(dnrh[totdnrh-1],0));
         totdnrh--;
         ArrayResize(dnrh,totdnrh);
     }
   }
   else if (mtype == "DBB")
   {
     while (totbbdn >frompos)
     {
         ObjectDelete("123Dbb,"+DoubleToStr(bbreakdn[totbbdn-1],0));
         movemarkers("123Dbb,"+DoubleToStr(bbreakdn[totbbdn-1],0));
         totbbdn--;
         ArrayResize(bbreakdn,totbbdn);
     }
   }
   else if (mtype == "UBB")
   {
     while (totbbup >frompos)
     {
         ObjectDelete("123Ubb,"+DoubleToStr(bbreakup[totbbup-1],0));
         movemarkers("123Ubb,"+DoubleToStr(bbreakup[totbbup-1],0));
         totbbup--;
         ArrayResize(bbreakup,totbbup);
     }
   }
  
   
}


// close the indicator ... delete all old markers 
int deinit()
{

   deleteoldmarkers("D",0); // remove down 123s
   deleteoldmarkers("U",0); // remove up 123s 
   deleteoldmarkers("DRH",0); // remove down ross hooks
   deleteoldmarkers("URH",0); // remove up ross hooks
   deleteoldmarkers("DBB",0); // remove down bol band breaks
   deleteoldmarkers("UBB",0); // remove up bol band breaks
   return(0);
}


// determine if an object is of the set type requested 
// basically determines if object is on the high or low of a bar
bool obinset(string obname,string typeset)
{

  if (typeset=="T")
  {
      // check if we have one 1 on top of price bar
      if ((StringSubstr(obname,0,6) =="123Dp1") || 
          (StringSubstr(obname,0,6) =="123Dp3") ||
          (StringSubstr(obname,0,6) =="123Up2") ||
          (StringSubstr(obname,0,6) =="123Ubb") ||
          (StringSubstr(obname,0,6) =="123Urh")) return(true); 
  }      
  else
  if (typeset=="B")
  {
      // check if we have one 1 on bottom of price bar
      if ((StringSubstr(obname,0,6) =="123Up1") || 
          (StringSubstr(obname,0,6) =="123Up3") ||
          (StringSubstr(obname,0,6) =="123Dp2") ||
          (StringSubstr(obname,0,6) =="123Dbb") ||
          (StringSubstr(obname,0,6) =="123Drh")) return(true);
  }
  return(false);
}


// returns the number of objects of the requested type at the requested position
int findobatpos(int barnum,string pointtype,string typeset)
{
int inx=0;
int res=0;
string tstr;
string fstr;
   
   // count  markers at datetime supplied in barnum 
   /// if point type = "" then count any 123 marker type
   /// else only count markers of type detailed in pointtype
   /// return number of markers at Point
   inx = ObjectsTotal();
   while ((inx >=0)&& (res==0))
   {
      tstr = ObjectName(inx);
      fstr = "123"+pointtype;
      if (((StringSubstr(tstr,0,StringLen(fstr)) ==fstr) && (typeset =="")) || 
         ((typeset!= "") && (obinset(tstr,typeset)) ))
      {
         if (StrToDouble(StringSubstr(tstr,7,StringLen(tstr)-7)) == barnum)
         {
            res++;
            inx--;
            if (pointtype =="")
            {
               while (inx >=0)
               {
                  tstr = ObjectName(inx);
                  fstr = "123"+pointtype;
                  if (((StringSubstr(tstr,0,StringLen(fstr)) ==fstr) && (typeset=="")) ||
                     ((typeset!= "") && (obinset(tstr,typeset)) ))
                  {
                     if (StrToDouble(StringSubstr(tstr,7,StringLen(tstr)-7)) == barnum)
                     res++;
                  }
                 inx--;
               }
            }
            
         }
      }
      inx--;
   }
   
   return(res);   
}


/// cacluate & return the estimated text height in pips
double getestpiptexth()
{
double range=0;
int st=0;
double result;
int texth=0;


// get the barnumber of the first bar on right edge of chart
st=FirstVisibleBar()-BarsPerWindow();
if (st <0) st=0;

 

// calculate the pip range on screen
//range =High[Highest(NULL,0,MODE_HIGH,BarsPerWindow(),st)]- Low[Lowest(NULL,0,MODE_LOW,BarsPerWindow(),st)];
range =High[Highest(NULL,0,MODE_HIGH,FirstVisibleBar()-st,st)]- Low[Lowest(NULL,0,MODE_LOW,FirstVisibleBar()-st,st)];
     

// add 8% of range to estimate window height in pips
range = range+((range*0.08)*Point);

// scale the fontsize use result var cos we need a double not int
result = fontsize;
texth= MathRound((result /8)*4);


result = (Point*texth)*(range/(range/(range/(Point*100))));

if (result < Point ) result = Point;

return(result);

}



void CheckUps()
  {
int pos=0;
int up1pos =-1;
int up2pos=-1;
int up3pos=-1;
int up123lock=0;
double yadj=0,tv1;


   //check for Up 123s


  if (totupmarkers >0)
  {
    //use aggression setting to determine where to start from
    pos = iBarShift(NULL,0,upmarkers[totupmarkers-1][aggression-1],true)-1;
  }
  else pos = maxbars;

  while ((pos >0) &&(!IsStopped())) 
   {

      /// find potential 1 ie where this bars low is lower than the previous & next 
      // or where we have an inside bar
         while ((pos >0) && (up1pos ==-1)) 
         {
            if ( ((Low[pos]<= Low[pos+1]) && (Low[pos] <= Low[pos-1]))  || 
                 ((Low[pos] >= Low[pos+1]) && (High[pos] < High[pos+1]) && (Low[pos]<Low[pos-1])) )
           {
             up1pos =pos;
           }
           else pos--;
         }
         

        // if we havent found a 1 marker quit to while 
        if (up1pos ==-1) continue;
        
        // if we havent got a 2 point & we dont allow 1&2 on same bar then move to next bar
        if ((up1pos == pos) && ((behaviourswitches & 1) !=1) ) pos--;
        else
        if ((pos==up1pos) && (Open[pos]<= Close[pos])) up2pos=pos;
        
    
      /// find potential 2
        while ((pos >0) && (up2pos==-1))
        {   
         tv1 = High[Highest(NULL,0,MODE_HIGH,up1pos-pos,pos)];
          // if 1 point broken then quit trying
          if ((pos !=up1pos) && (Low[Lowest(NULL,0,MODE_LOW,up1pos-pos,pos)] < Low[up1pos])) break;
          else
          //if we have broken the top of the 1 bar && we have the highest high since breaking the top of the 1
          if ((tv1 >= High[up1pos]) && 
              (High[pos] == tv1))  up2pos =pos;
          else pos--;
        }
       

       ///if we havent got a 2 marker then quit to while
        if (up2pos ==-1) 
        {
         pos = up1pos-1; // restart at next bar after previous 1 pos
         up1pos =-1;
         continue;
        }

         // if pos1&2 on same bar then must move to next
         if ((up1pos == up2pos) && (pos == up1pos)) pos--; 
         else
         // if were not allowing 2&3 on same bar must move to next
         if (((behaviourswitches & 2) !=2) && (pos == up2pos)) pos--; 
         else
         if ((pos==up2pos) && (Open[pos] > Close[pos])) up3pos=pos;


        
      // find potential 3 marker
        while ((pos>=0) && (up3pos==-1))
        {
         tv1 = Low[Lowest(NULL,0,MODE_LOW,up2pos-pos,pos)];
         // if we break the 1 pos then quit trying
         if (Low[pos] < Low[up1pos]) break;
         else
         // if 1&2 on same bar && this is the lowest low since 1&2 && there is a lower high than the 2 pos
         if ((up1pos==up2pos) && (Low[pos] == Low[Lowest(NULL,0,MODE_LOW,up1pos-pos,pos)]) &&
              (High[Lowest(NULL,0,MODE_HIGH,up1pos-pos,pos)] < High[up2pos]))
         up3pos=pos;
         else
         if  ((up1pos!=up2pos)&&(pos!=up2pos)&&(tv1== Low[pos]) && 
               (tv1<= Low[up2pos]))      
             up3pos=pos; 
         else
         if (High[pos] > High[up2pos]) break;
         else pos--;
   
        } 


        //if no 3 marker then contiune from while
        if (up3pos==-1) 
        {
         // 1 pos broken so pattern dead start again 
         if (Low[pos] < Low[up1pos])
         {
          pos = up1pos-1;
          up1pos=-1;
          up2pos=-1;
         }
         else
         // else cant find 3 for this 12 so move 2 to next pos
         {
          pos=up2pos-1;
          up2pos=-1;
         }
         continue;
        }


        // we now have a 123 so lets see if 
           // we can break the 3 (then we search for another 3 with same 1&2
           // or trigger the 2 
           // or break the 1 then kill the pattern
        

        while (pos >=0) 
        {
          // 1 pos broken so pattern dead ... kill it
          if (Low[pos] < Low[up1pos])
          {
           pos = up1pos-1;
           up1pos=-1;
           up2pos=-1;
           up3pos=-1;
           break;
          }
          else
          //if we find a lower 3 point then kill the 3 point & resume main while
          if (Low[pos] < Low[up3pos]) 
          {
           up3pos=-1;
           break;
          }
          else
          if ((pos == up3pos) && (High[pos] > High[up2pos]) && (Open[pos] > Close[pos]))
          {
           pos=up2pos-1;
           up2pos=-1;
           up3pos=-1;
           break;
          }
          else
          if ((up2pos==up3pos) && (pos!=up2pos)&& (Low[Lowest(NULL,0,MODE_LOW,up3pos-pos,pos)] > Low[up3pos])&&
              (High[Lowest(NULL,0,MODE_HIGH,up2pos-pos,pos)] <= High[up2pos]) && (High[pos]> High[up2pos]))
          {
            up123lock=1;
            break;
          }
          else
          // if no lower high after 2&3 on same bar then 
          // keep 1 & kill 3 
          if ((up2pos==up3pos) && (pos !=up2pos) && ((Low[Lowest(NULL,0,MODE_LOW,up3pos-pos,pos)] < Low[up3pos])||(High[pos] >High[up2pos]) ))
          {
           //up2pos=-1;
           up3pos=-1;
           up123lock=0;
           break;
          }
          else
          // 2 pos triggered
          if ((up2pos != up3pos) && (High[pos] > High[up2pos]))// && (Low[pos] >= Low[up3pos])) ||
              //((High[pos] > High[up2pos]) && (up1pos==up2pos)) )
          {
           up123lock =1; // lock it as triggered
           break;
          }
          else pos--;
        }
         
        // if we have invalidated the 3 point then continue from while 
        if (up3pos ==-1) continue;
        
        // dismiss it if height is less than reject height
        if ((High[up2pos] - Low[up1pos]) < rejectifheightlessthan *Point)
        {
         pos=up2pos-1;
         up2pos=-1;
         up3pos=-1;
         up123lock=0;
         continue; 
        }
        
        // dont print 123 if 1&2 are on bar 1 & 3 on bar 0 or if 2&3 are on bar 0
        if (((up1pos==up2pos) && (up1pos==1)&& (up3pos==0)) ||
           ((up2pos==up3pos)&&(pos==0)) ) continue;

        //if we have found a 123 that falls within a previous 123 &
        // its trigger point is below the previous trigger point

       while (totupmarkers >0)
       {
         if ((Time[up3pos] < upmarkers[totupmarkers-1][2]) &&
            (High[up2pos] < High[iBarShift(NULL,0,upmarkers[totupmarkers-1][1],true)] ) )
            
            remove123(totupmarkers-1,"U");
            else
            break;
       }



 
         // if user doesnt want any following combo then restart at the appropriate pos
         if ( ((findobatpos(Time[up1pos],"Up2","") > 0) && ((behaviourswitches & 4) != 4)) ||
              ((findobatpos(Time[up1pos],"Up3","") > 0) && ((behaviourswitches & 8) != 8)) )
            
            {
               pos=up1pos-1;
               up1pos =-1;
               up2pos=-1;
               up3pos=-1;
               up123lock=0;
            }
         else               
         if ( ((findobatpos(Time[up2pos],"Up2","") > 0) && ((behaviourswitches & 16) != 16)) ||
              ((findobatpos(Time[up2pos],"Up3","") > 0) && ((behaviourswitches & 32) != 32)) ||  
              ((findobatpos(Time[up2pos],"Urh","") > 0) && ((behaviourswitches & 256) == 256))   )
            {
              pos=up2pos-1;
              up2pos=-1;
              up3pos=-1;
              up123lock=0;
            }
         else
         if ( ((findobatpos(Time[up3pos],"Up2","") > 0) && ((behaviourswitches & 64) != 64)) ||  
              ((findobatpos(Time[up3pos],"Up3","") > 0) && ((behaviourswitches & 128) != 128)) )
            {
              pos=up3pos-1;
              up3pos=-1;
              up123lock=0;
            }
         else
         {
         // create 123 markers & save positions
         
         //get number of markers at this bars low * estpiptextheight
         yadj= (findobatpos(Time[up1pos],"","B"))*estpiptexth;
         // create marker
         ObjectCreate("123Up1,"+DoubleToStr(Time[up1pos],0),OBJ_TEXT,0,Time[up1pos],Low[up1pos]-yadj);
         ObjectSetText("123Up1,"+DoubleToStr(Time[up1pos],0),"1",fontsize,fontname,upcolor);
        
         yadj = (findobatpos(Time[up2pos],"","T")+1)*estpiptexth; 
         ObjectCreate("123Up2,"+DoubleToStr(Time[up2pos],0),OBJ_TEXT,0,Time[up2pos],High[up2pos]+yadj);
         ObjectSetText("123Up2,"+DoubleToStr(Time[up2pos],0),"2",fontsize,fontname,upcolor);
         
         yadj= (findobatpos(Time[up3pos],"","B"))*estpiptexth;
         ObjectCreate("123Up3,"+DoubleToStr(Time[up3pos],0),OBJ_TEXT,0,Time[up3pos],Low[up3pos]-yadj);
         ObjectSetText("123Up3,"+DoubleToStr(Time[up3pos],0),"3",fontsize,fontname,upcolor);

         
         // resize array & store times of markers & its locked status
         totupmarkers++;
         ArrayResize(upmarkers,totupmarkers);
         upmarkers[totupmarkers-1][0] = Time[up1pos];
         upmarkers[totupmarkers-1][1] = Time[up2pos];
         upmarkers[totupmarkers-1][2] = Time[up3pos];
         upmarkers[totupmarkers-1][3] = up123lock;

         // restart checking at 1 bar after either this 123s 1 pos or 2 pos 
         if (aggression ==1) pos = up1pos-1; 
         else if (aggression==2) pos=up2pos-1;
         else pos = up3pos-1;
         

         // reset temp vars for next run
         up1pos =-1;
         up2pos=-1;
         up3pos=-1;
         up123lock=0;
         }
     

   }//while

}//func




void CheckDowns()
  {
int pos=0;
int dn1pos =-1;
int dn2pos=-1;
int dn3pos=-1;
int dn123lock=0;
double yadj=0,tv1;


   //check for Down 123s


  if (totdnmarkers >0)
  {
    //use aggression setting to determine where to start from
    pos = iBarShift(NULL,0,downmarkers[totdnmarkers-1][aggression-1],true)-1;
  }
  else pos = maxbars;

  while ((pos >0) &&(!IsStopped())) 
   {

      /// find potential 1 ie where this bars low is lower than the previous & next 
      // or where we have an inside bar
         while ((pos >0) && (dn1pos ==-1)) 
         {
            if ( ((High[pos]>= High[pos+1]) && (High[pos] >= High[pos-1]))   
                 || ((High[pos] <= High[pos+1]) && (Low[pos] > Low[pos+1])&& (High[pos] > High[pos-1])) )
           {
             dn1pos =pos;
           }
           else pos--;
         }
         

        // if we havent found a 1 marker quit to while 
        if (dn1pos ==-1) continue;
        
        // if we havent got a 2 point & we dont allow 1&2 on same bar then move to next bar
        if ((dn1pos == pos) && ((behaviourswitches & 1) !=1) ) pos--;
        else         
        if ((pos==dn1pos) && (Open[pos]>= Close[pos])) dn2pos=pos;

      /// find potential 2
        while ((pos >0) && (dn2pos==-1))
        {
         tv1 =Low[Lowest(NULL,0,MODE_LOW,dn1pos-pos,pos)];         
          // if 1 point broken then quit trying
          //if ((pos !=dn1pos) && (High[Highest(NULL,0,MODE_HIGH,dn1pos-pos,pos)] > High[dn1pos])) break;
          if ((High[pos]>High[dn1pos])) break;
          else
          //if we have broken the top of the 1 bar && we have the highest high since breaking the top of the 1
          if ((tv1 <= Low[dn1pos]) && 
              (Low[pos] == tv1))  dn2pos =pos;
          else pos--;
        }
       

       ///if we havent got a 2 marker then quit to while
        if (dn2pos ==-1) 
        {
         pos = dn1pos-1; // restart at next bar after previous 1 pos
         dn1pos =-1;
         continue;
        }

         // if pos1&2 on same bar then must move to next
         if ((dn1pos == dn2pos) && (pos == dn1pos)) pos--; 
         else
         // if were not allowing 2&3 on same bar must move to next
         if (((behaviourswitches & 2) !=2) && (pos == dn2pos)) pos--; 
         else
         if ((pos==dn2pos) && (Open[pos] < Close[pos])) dn3pos=pos;

        
      // find potential 3 marker
        while ((pos>=0) && (dn3pos==-1))
        {
         tv1= High[Highest(NULL,0,MODE_HIGH,dn2pos-pos,pos)];
         // if we break the 1 pos then quit trying
         if (High[pos] > High[dn1pos]) break;
         else
         // if 1&2 on same bar && this is the lowest low since 1&2 && there is a lower high than the 2 pos
         if ((dn1pos==dn2pos) && (High[pos] == High[Highest(NULL,0,MODE_HIGH,dn1pos-pos,pos)]) &&
              (Low[Highest(NULL,0,MODE_LOW,dn1pos-pos,pos)] > Low[dn2pos]))
         dn3pos=pos;
         else
         if  ((dn1pos!=dn2pos)&&(pos!=dn2pos)&&(tv1== High[pos]) && 
               (tv1>= High[dn2pos]))      
             dn3pos=pos; 
         else
         if (Low[pos] < Low[dn2pos]) break;
         else pos--;
   
        } 

        //if no 3 marker then contiune from while
        if (dn3pos==-1) 
        {
         // 1 pos broken so pattern dead start again 
         if (High[pos] > High[dn1pos])
         {
          pos = dn1pos-1;
          dn1pos=-1;
          dn2pos=-1;
         }
         else
         // else cant find 3 for this 12 so move 2 to next pos
         {
          pos=dn2pos-1;
          dn2pos=-1;
         }
         continue;
        }


        // we now have a 123 so lets see if 
           // we can break the 3 (then we search for another 3 with same 1&2
           // or trigger the 2 
           // or break the 1 then kill the pattern

       

        while (pos >=0) 
        {
          // 1 pos broken so pattern dead ... kill it
          if (High[pos] > High[dn1pos])
          {
           pos = dn1pos-1;
           dn1pos=-1;
           dn2pos=-1;
           dn3pos=-1;
           break;
          }
          else
          //if we find a lower 3 point then kill the 3 point & resume main while
          if (High[pos] > High[dn3pos]) 
          {
           dn3pos=-1;
           break;
          }
          else
          if ((pos == dn3pos) && (Low[pos] < Low[dn2pos]) && (Open[pos] < Close[pos]))
          {
           pos=dn2pos-1;
           dn2pos=-1;
           dn3pos=-1;
           break;
          }
          else
          if ((dn2pos==dn3pos) && (pos!=dn2pos)&& (High[Highest(NULL,0,MODE_HIGH,dn3pos-pos,pos)] < Low[dn3pos])&&
              (Low[Highest(NULL,0,MODE_LOW,dn2pos-pos,pos)] >= Low[dn2pos]) && (Low[pos]< Low[dn2pos]))
          {
            dn123lock=1;
            break;
          }
          else
          // if no lower high after 2&3 on same bar then 
          // keep 1 & kill 3 
          if ((dn2pos==dn3pos) && (pos !=dn2pos) && ((High[Highest(NULL,0,MODE_HIGH,dn3pos-pos,pos)] > High[dn3pos])||(Low[pos] <Low[dn2pos]) ))
          {
           //up2pos=-1;
           dn3pos=-1;
           dn123lock=0;
           break;
          }
          else
          // 2 pos triggered
          if ((dn2pos != dn3pos) && (Low[pos] < Low[dn2pos]))// && (Low[pos] >= Low[up3pos])) ||
              //((High[pos] > High[up2pos]) && (up1pos==up2pos)) )
          {
           dn123lock =1; // lock it as triggered
           break;
          }
          else pos--;
        }
         
        // if we have invalidated the 3 point then continue from while 
        if (dn3pos ==-1) continue;

        // dismiss it if height is less than reject height
        if ((High[dn1pos] - Low[dn2pos]) < rejectifheightlessthan *Point)
        {
         pos=dn2pos-1;
         dn2pos=-1;
         dn3pos=-1;
         dn123lock=0;
         continue; 
        }
        
        // dont print 123 if 1&2 are on bar 1 & 3 on bar 0 or if 2&3 are on bar 0
        if (((dn1pos==dn2pos) && (dn1pos==1)&& (dn3pos==0)) ||
           ((dn2pos==dn3pos)&&(pos==0)) ) continue;

        //if we have found a 123 that falls within a previous 123 &
        // its trigger point is below the previous trigger point


       while (totdnmarkers >0)
       {
         if ((Time[dn3pos] < downmarkers[totdnmarkers-1][2]) &&
            (Low[dn2pos] > Low[iBarShift(NULL,0,downmarkers[totdnmarkers-1][1],true)] ) )
            
            remove123(totdnmarkers-1,"D");
            else
            break;
       }
 
         // if user doesnt want any following combo then kill 123
         if ( ((findobatpos(Time[dn1pos],"Dp2","") > 0) && ((behaviourswitches & 4) != 4)) ||
              ((findobatpos(Time[dn1pos],"Dp3","") > 0) && ((behaviourswitches & 8) != 8))  )
             {
               pos=dn1pos-1;
               dn1pos =-1;
               dn2pos=-1;
               dn3pos=-1;
               dn123lock=0;
             }
         else            
         if ( ((findobatpos(Time[dn2pos],"Dp2","") > 0) && ((behaviourswitches & 16) != 16)) ||
             ((findobatpos(Time[dn2pos],"Dp3","") > 0) && ((behaviourswitches & 32) != 32)) || 
             ((findobatpos(Time[dn2pos],"Drh","") > 0) && ((behaviourswitches & 256) == 256))   )
             {
               pos=dn2pos-1;
               dn2pos=-1;
               dn3pos=-1;
               dn123lock=0;              
             }
         else
         if  ( ((findobatpos(Time[dn3pos],"Dp2","") > 0) && ((behaviourswitches & 64) != 64)) ||  
               ((findobatpos(Time[dn3pos],"Dp3","") > 0) && ((behaviourswitches & 128) != 128)) )
            {
               pos=dn3pos-1;
               dn3pos=-1;
               dn123lock=0;
            }
         else
         {
         // create 123 markers & save positions
         
         //get number of markers at this bars low * estpiptextheight
         yadj= (findobatpos(Time[dn1pos],"","T")+1)*estpiptexth;
         // create marker
         ObjectCreate("123Dp1,"+DoubleToStr(Time[dn1pos],0),OBJ_TEXT,0,Time[dn1pos],High[dn1pos]+yadj);
         ObjectSetText("123Dp1,"+DoubleToStr(Time[dn1pos],0),"1",fontsize,fontname,downcolor);
        
         yadj = (findobatpos(Time[dn2pos],"","B"))*estpiptexth; 
         ObjectCreate("123Dp2,"+DoubleToStr(Time[dn2pos],0),OBJ_TEXT,0,Time[dn2pos],Low[dn2pos]-yadj);
         ObjectSetText("123Dp2,"+DoubleToStr(Time[dn2pos],0),"2",fontsize,fontname,downcolor);
         
         yadj= (findobatpos(Time[dn3pos],"","T")+1)*estpiptexth;
         ObjectCreate("123Dp3,"+DoubleToStr(Time[dn3pos],0),OBJ_TEXT,0,Time[dn3pos],High[dn3pos]+yadj);
         ObjectSetText("123Dp3,"+DoubleToStr(Time[dn3pos],0),"3",fontsize,fontname,downcolor);

         
         // resize array & store times of markers & its locked status
         totdnmarkers++;
         ArrayResize(downmarkers,totdnmarkers);
         downmarkers[totdnmarkers-1][0] = Time[dn1pos];
         downmarkers[totdnmarkers-1][1] = Time[dn2pos];
         downmarkers[totdnmarkers-1][2] = Time[dn3pos];
         downmarkers[totdnmarkers-1][3] = dn123lock;

         // restart checking at 1 bar after either this 123s 1 pos or 2 pos 
         if (aggression ==1) pos = dn1pos-1; 
         else if (aggression==2) pos=dn2pos-1;
         else pos = dn3pos-1;

         // reset temp vars for next run
         dn1pos =-1;
         dn2pos=-1;
         dn3pos=-1;
         dn123lock=0;
         }
     

   }//while

}//func


int start()
{
double tmpeh;


  if (maxbars >= Bars) maxbars = Bars-1;
  
  
  if (PipTextHeight == 0) 
  {
    // see if markers need to be moved 
    // I.E. auto rescale has occured
    tmpeh =getestpiptexth();
    if (tmpeh != estpiptexth) 
    {
         estpiptexth = tmpeh;
         moveallmarkers();         
    }

  }
  else
  estpiptexth = (PipTextHeight *Point);
 
   
   // remove the most recent up & down 123s if we have any 
   // and if they havent triggered
   if (totupmarkers >0)  
   if (upmarkers[totupmarkers-1][3] ==0) deleteoldmarkers("U",totupmarkers-1);
   if (totdnmarkers >0) 
   if (downmarkers[totdnmarkers-1][3]==0) deleteoldmarkers("D",totdnmarkers-1);
   
   //*** remove all rh younger than the last 123 3 pos
   if (totuprh >0) removerhpost123("U");
   if (totdnrh >0) removerhpost123("D");
   
   
   // check for 123s
   CheckDowns();
   CheckUps();
    
   // check if 123s have triggered / failed / or failed/hit target

   check123locksntargets();
   
   // check for ross hooks
   if (showrosshooks) checkrosshooks();
   
   
   // remove most recent bol break markers if we have any
   if (totbbdn >0) deleteoldmarkers("DBB",totbbdn-1);
   if (totbbup >0) deleteoldmarkers("UBB",totbbup-1);

   //check for bollinger band breaks
   if (showbandbreaks) checkbandbreaks();   

  
  return(0);
}


void removerhpost123(string mtype)
{
 if (mtype == "U")
 {  
   while (totuprh >0)
   {
     if (uprh[totuprh-1] > upmarkers[totupmarkers-1][2])
     {
      ObjectDelete("123Urh,"+DoubleToStr(uprh[totuprh-1],0));
      movemarkers("123Urh,"+DoubleToStr(uprh[totuprh-1],0));
      totuprh--;
      ArrayResize(uprh,totuprh);
     }
     else break;
   }
 }
 else
 {
   while (totdnrh >0)
   {
     if (dnrh[totdnrh-1] > downmarkers[totdnmarkers-1][2])
     {
      ObjectDelete("123Drh,"+DoubleToStr(dnrh[totdnrh-1],0));
      movemarkers("123Drh,"+DoubleToStr(dnrh[totdnrh-1],0));
      totdnrh--;
      ArrayResize(dnrh,totdnrh);
     }
     else break;
   }
 }
}

int getnearest123(int barpos,string mtype)
{
 int res;
  
 if (mtype == "U")
 {
  // while time of 3 pos > this bar keep moving down 123 array
  res = totupmarkers-1;
  while ((upmarkers[res][2] > Time[barpos]) && (res >0)) res--; 
 }
 else
 {
  res = totdnmarkers-1;
  while ((downmarkers[res][2] > Time[barpos]) && (res >0)) res--;
 }
 return(res);
}

void checkrosshooks()
{
int barpos;
int indx123;
int mpos2,mpos1;
int mrhpos,tx;
bool bmarkrh;
double yadj;
string tstr;
   // check Up rosshooks
   
   // if we dont have  any 123 ups then cant have rosshooks
   if (totupmarkers >0)
   {
     // start at last known up ross hook or at 3 point of 1st 123
     // which ever is youngest
     barpos = iBarShift(NULL,0,upmarkers[0][2],true)-1;
     tx = barpos;
     if (totuprh >0)
     tx = iBarShift(NULL,0,uprh[totuprh-1],true)-1;
     if (tx < barpos) barpos=tx;
     
     while (barpos >0) 
     {
      // get index of nearest previous 123 
      indx123 = getnearest123(barpos,"U");
      // get bar posits of previous 123s 1& 2 pos
      mpos2 = iBarShift(NULL,0,upmarkers[indx123][1],true);
      mpos1 = iBarShift(NULL,0,upmarkers[indx123][0],true);
      
      // get bar posit of previous rh that is younger than 3 point of the previous 123      
      mrhpos = -1;
      if (totuprh >0)
      {
        if (uprh[totuprh-1] >= upmarkers[indx123][2])
        mrhpos = iBarShift(NULL,0,uprh[totuprh-1],true);
      }

      bmarkrh=false;
      

      // if we fail to make a new high 
         if ( (High[barpos] > High[mpos2]) && (High[barpos-1] <= High[barpos])&&
              (Low[mpos1] <= Low[Lowest(NULL,0,MODE_LOW,mpos1-(barpos+1),barpos+1)]) )
         {
            bmarkrh = true;

            // if we have a rosshook younger than the nearest 123
            // & price failed above Rh then mark as rh
            // if we are above the 123 2 pos && we havent broken the 1 pos of 123 in the meantime
             if (mrhpos >-1)
             {
               if (High[barpos] <= High[mrhpos]) bmarkrh = false;
             }
          }
       
         if ((bmarkrh) && (barpos >1))
         {
            tstr = "Rh";
            // if there is a 123 with 2 point at rh point then kill the 123
            // if the user wants us to   
            if ((behaviourswitches & 256) == 256)
            {
              if (findobatpos(Time[barpos],"Up2","") >0)
              {
                tx = totupmarkers-1;
                while (upmarkers[tx][1] != Time[barpos]) tx--;
                remove123(tx,"U");
              }
            }
            

            yadj= (findobatpos(Time[barpos],"","T")+1)*estpiptexth;
            // create marker
            ObjectCreate("123Urh,"+DoubleToStr(Time[barpos],0),OBJ_TEXT,0,Time[barpos],High[barpos]+yadj);
            ObjectSetText("123Urh,"+DoubleToStr(Time[barpos],0),tstr,fontsize,fontname,upcolor);
            totuprh++;
            ArrayResize(uprh,totuprh);
            uprh[totuprh-1] = Time[barpos];
            
         }
    
      barpos--;
     }
   }
   
   // check down ross hooks
   // if we dont have  any 123 downs then cant have rosshooks
   if (totdnmarkers >0)
   {
     // start at last known up ross hook or at 3 point of 1st 123
     // which ever is youngest
     barpos = iBarShift(NULL,0,downmarkers[0][2],true)-1;
     tx = barpos;
     if (totdnrh >0)
     tx = iBarShift(NULL,0,dnrh[totdnrh-1],true)-1;
     if (tx < barpos) barpos=tx;
     
     while (barpos >0) 
     {
      // get index of nearest previous 123 
      indx123 = getnearest123(barpos,"D");
      // get bar posits of previous 123s 1& 2 pos
      mpos2 = iBarShift(NULL,0,downmarkers[indx123][1],true);
      mpos1 = iBarShift(NULL,0,downmarkers[indx123][0],true);
      // get bar posit of previous rh that is younger than 3 point of the previous 123      
      mrhpos = -1;
      if (totdnrh >0)
      {
        if (dnrh[totdnrh-1] >= downmarkers[indx123][2])
        mrhpos = iBarShift(NULL,0,dnrh[totdnrh-1],true);
      }
      
      bmarkrh =false;
      // if we fail to make a new Low
         if ( (Low[barpos] < Low[mpos2]) && (Low[barpos-1] >= Low[barpos]) &&
              (High[mpos1] >= High[Highest(NULL,0,MODE_HIGH,mpos1-(barpos+1),barpos+1)]) )
         {
            bmarkrh = true;

            // if we have a rosshook younger than the nearest 123
            // & price failed above Rh then mark as rh
            // if we are above the 123 2 pos && we havent broken the 1 pos of 123 in the meantime
             if (mrhpos >-1) 
             {
               if (Low[barpos] >= Low[mrhpos]) bmarkrh = false;
             }
          }
                                                             
         if ((bmarkrh) && (barpos >1))         {
            tstr = "Rh";
            // if there is a 123 with 2 point at rh point then kill the 123
            // if the user wants us to   
            if ((behaviourswitches & 256) == 256)
            {
              if (findobatpos(Time[barpos],"Dp2","") >0)
              {
                tx = totdnmarkers-1;
                while (downmarkers[tx][1] != Time[barpos]) tx--;
                remove123(tx,"D");
              }
            }
            

            yadj= (findobatpos(Time[barpos],"","B"))*estpiptexth;
            // create marker
            ObjectCreate("123Drh,"+DoubleToStr(Time[barpos],0),OBJ_TEXT,0,Time[barpos],Low[barpos]-yadj);
            ObjectSetText("123Drh,"+DoubleToStr(Time[barpos],0),tstr,fontsize,fontname,downcolor);
            totdnrh++;
            ArrayResize(dnrh,totdnrh);
            dnrh[totdnrh-1] = Time[barpos];
            
         }
      
      barpos--;
     }
   }


}


void check123locksntargets()
{
int pos,mpos1,mpos2,mpos3;
int barpos;
double tgtval;


 //check all non triggerd UP 123s ... delete non triggered&failed  or lock triggered
 pos=0;
 // iterate all up 123s
 while (pos < totupmarkers) 
 {
  
  // if 123 is not locked
  if (upmarkers[pos][3] ==0)
  {
   mpos1=iBarShift(NULL,0,upmarkers[pos][0],true);
   mpos2=iBarShift(NULL,0,upmarkers[pos][1],true);
   mpos3=iBarShift(NULL,0,upmarkers[pos][2],true);
   barpos = mpos3-1; 
   while (barpos >0)
   {
    // if 2 pos is triggered && didnt break 1 pos on same bar
    // then lock as triggerd
    if ((High[barpos] > High[mpos2]) && (Low[barpos] >= Low[mpos1])) 
    {
     upmarkers[pos][3] =1;
     break;
    }
    else
    // if 1 pos broken then mark it as failed
    if (Low[barpos] < Low[mpos1]) 
    {
     upmarkers[pos][3]=-1;
     break;
    }
    barpos--;
   }
  }
  // if lock = -1 then delete as its a non triggered & failed
  if (upmarkers[pos][3]==-1)
  {
   remove123(pos,"U");
  }
  else
  pos++;
 }
  
 // test triggered up 123 for targets 
 // Set as failed if target not met before 1 pos broken
 if (targetstart123 >0)
 {
   pos =0;
   while (pos < totupmarkers)
   {
    //if triggered but not hit target then check it
    if (upmarkers[pos][3] == 1)
    {
      mpos1=iBarShift(NULL,0,upmarkers[pos][0],true);
      mpos2=iBarShift(NULL,0,upmarkers[pos][1],true);
      mpos3=iBarShift(NULL,0,upmarkers[pos][2],true);
      
      tgtval = ((High[mpos2] -Low[mpos1]) * targetpercent123)/100;
      if (targetstart123 ==1) tgtval = tgtval + Low[mpos1];
      else
      if (targetstart123 ==2) tgtval = tgtval + High[mpos2];
      else
      if (targetstart123 ==3) tgtval = tgtval + Low[mpos3];
            
      barpos = mpos3-1; 
      while (barpos >0)
      {
       //  hit target so mark as 3 (triggered & target hit)
       if (High[barpos] >= tgtval) 
       {
        upmarkers[pos][3] =3;
        break;
       }
       else
       // if 1 pos broken then mark it as failed
       if (Low[barpos] < Low[mpos1]) 
       {
        upmarkers[pos][3]=2;
        break;
       }
       barpos--;
      }
     
      // recolor markers if its failed target
      if (upmarkers[pos][3] ==2)
      {
        ObjectSet("123Up1,"+DoubleToStr(upmarkers[pos][0],0),OBJPROP_COLOR,failupcolor);
        ObjectSet("123Up2,"+DoubleToStr(upmarkers[pos][1],0),OBJPROP_COLOR,failupcolor);
        ObjectSet("123Up3,"+DoubleToStr(upmarkers[pos][2],0),OBJPROP_COLOR,failupcolor);        
      }
    } 
  
    pos++;
   }
 }
 
 // now do the downs
 

 //check all non triggerd DOWN 123s ... delete non triggered&failed  or lock triggered
 pos=0;
 // iterate all up 123s
 while (pos < totdnmarkers) 
 {
  // if 123 is not locked
  if (downmarkers[pos][3] ==0)
  {
   mpos1=iBarShift(NULL,0,downmarkers[pos][0],true);
   mpos2=iBarShift(NULL,0,downmarkers[pos][1],true);
   mpos3=iBarShift(NULL,0,downmarkers[pos][2],true);
   barpos = mpos3-1; 
   while (barpos >0)
   {
    // if 2 pos is triggered && didnt break 1 pos on same bar
    // then lock as triggerd
    if ((Low[barpos] < Low[mpos2]) && (High[barpos] <= High[mpos1])) 
    {
     downmarkers[pos][3] =1;
     break;
    }
    else
    // if 1 pos broken then mark it as failed
    if (High[barpos] > High[mpos1]) 
    {
     downmarkers[pos][3]=-1;
     break;
    }
    barpos--;
   }
  }
  // if lock = -1 then delete as its a non triggered & failed
  if (downmarkers[pos][3]==-1)
  {
   remove123(pos,"D");
  }
  else
  pos++;
 }


 // test triggered up 123 for targets 
 // Set as failed if target not met before 1 pos broken
 if (targetstart123 >0)
 {
   pos =0;
   while (pos < totdnmarkers)
   {
    //if triggered but not hit target then check it
    if (downmarkers[pos][3] == 1)
    {
      mpos1=iBarShift(NULL,0,downmarkers[pos][0],true);
      mpos2=iBarShift(NULL,0,downmarkers[pos][1],true);
      mpos3=iBarShift(NULL,0,downmarkers[pos][2],true);
      
      tgtval = ((Low[mpos2] -High[mpos1]) * targetpercent123)/100;
      if (targetstart123 ==1) tgtval = tgtval + High[mpos1];
      else
      if (targetstart123 ==2) tgtval = tgtval + Low[mpos2];
      else
      if (targetstart123 ==3) tgtval = tgtval + High[mpos3];
            
      barpos = mpos3-1; 
      while (barpos >0)
      {
       //  hit target so mark as 3 (triggered & target hit)
       if (Low[barpos] <= tgtval) 
       {
        downmarkers[pos][3] =3;
        break;
       }
       else
       // if 1 pos broken then mark it as failed
       if (High[barpos] > High[mpos1]) 
       {
        downmarkers[pos][3]=2;
        break;
       }
       barpos--;
      }
     
      // recolor markers if its failed target
      if (downmarkers[pos][3] ==2)
      {
        ObjectSet("123Dp1,"+DoubleToStr(downmarkers[pos][0],0),OBJPROP_COLOR,faildncolor);
        ObjectSet("123Dp2,"+DoubleToStr(downmarkers[pos][1],0),OBJPROP_COLOR,faildncolor);
        ObjectSet("123Dp3,"+DoubleToStr(downmarkers[pos][2],0),OBJPROP_COLOR,faildncolor);        
      }
    } 
  
    pos++;
   }
 }
 
}

// remove a 123 ... delete its markers and then shuffle all other 123s up the marker arrays & resize arrays
void remove123(int posi,string mtype)
{
 int x;
 if (mtype == "U")
 {
   ObjectDelete("123Up1,"+DoubleToStr(upmarkers[posi][0],0));
   movemarkers("123Up1,"+DoubleToStr(upmarkers[posi][0],0));
   ObjectDelete("123Up2,"+DoubleToStr(upmarkers[posi][1],0));
   movemarkers("123Up2,"+DoubleToStr(upmarkers[posi][1],0));
   ObjectDelete("123Up3,"+DoubleToStr(upmarkers[posi][2],0)); 
   movemarkers("123Up3,"+DoubleToStr(upmarkers[posi][2],0));
   for (x=posi; x < totupmarkers-1;x++)
   {
    upmarkers[x][0] = upmarkers[x+1][0];
    upmarkers[x][1] = upmarkers[x+1][1];
    upmarkers[x][2] = upmarkers[x+1][2];
    upmarkers[x][3] = upmarkers[x+1][3];  
   }
   totupmarkers--;
   ArrayResize(upmarkers,totupmarkers);
 }
 else
 {
   ObjectDelete("123Dp1,"+DoubleToStr(downmarkers[posi][0],0));
   movemarkers("123Dp1,"+DoubleToStr(downmarkers[posi][0],0));
   ObjectDelete("123Dp2,"+DoubleToStr(downmarkers[posi][1],0));
   movemarkers("123Dp2,"+DoubleToStr(downmarkers[posi][1],0));
   ObjectDelete("123Dp3,"+DoubleToStr(downmarkers[posi][2],0)); 
   movemarkers("123Dp3,"+DoubleToStr(downmarkers[posi][2],0));
   for (x=posi; x < totdnmarkers-1;x++)
   {
    downmarkers[x][0] = downmarkers[x+1][0];
    downmarkers[x][1] = downmarkers[x+1][1];
    downmarkers[x][2] = downmarkers[x+1][2];
    downmarkers[x][3] = downmarkers[x+1][3];  
   }
   totdnmarkers--;
   ArrayResize(downmarkers,totdnmarkers);
 }
 
}



void checkbandbreaks()
{
int pos;
double yadj;
bool bmark;

   // check upper band breaks
  if (totbbup >0)
  pos = iBarShift(NULL,0,bbreakup[totbbup-1],true)-1;
  else pos = maxbars;
 
  while (pos >=0) 
  {
   if (High[pos] > iBands(NULL,0,bandperiod,banddev,0,PRICE_CLOSE,MODE_UPPER,pos))
   {
     bmark = true;
     // if user only wants to see the 1st bb break && this isnt the 1st then 
     if ((onlyshow1stbreak) &&
         (High[pos+1] > iBands(NULL,0,bandperiod,banddev,0,PRICE_CLOSE,MODE_UPPER,pos+1)))
          bmark = false;
     
     if (bmark)
     {
         yadj = (findobatpos(Time[pos],"","T")+1)*estpiptexth; 
         ObjectCreate("123Ubb,"+DoubleToStr(Time[pos],0),OBJ_TEXT,0,Time[pos],High[pos]+yadj);
         ObjectSetText("123Ubb,"+DoubleToStr(Time[pos],0),"B",fontsize,fontname,bbreakcolor);       
         
         totbbup++;
         ArrayResize(bbreakup,totbbup);
         bbreakup[totbbup-1] = Time[pos];
      }
   }
   pos--;
  }

   // check lower band breaks
  if (totbbdn >0)
  pos = iBarShift(NULL,0,bbreakdn[totbbdn-1],true)-1;
  else pos = maxbars;
 
  while (pos >=0) 
  {
   if (Low[pos] < iBands(NULL,0,bandperiod,banddev,0,PRICE_CLOSE,MODE_LOWER,pos))
   {
      bmark = true;

      if ((onlyshow1stbreak) &&
          (Low[pos+1] < iBands(NULL,0,bandperiod,banddev,0,PRICE_CLOSE,MODE_LOWER,pos+1)))
          bmark= false;
      
      if (bmark)
      {
         yadj = (findobatpos(Time[pos],"","B"))*estpiptexth; 
         ObjectCreate("123Dbb,"+DoubleToStr(Time[pos],0),OBJ_TEXT,0,Time[pos],Low[pos]-yadj);
         ObjectSetText("123Dbb,"+DoubleToStr(Time[pos],0),"B",fontsize,fontname,bbreakcolor);       
         
         totbbdn++;
         ArrayResize(bbreakdn,totbbdn);
         bbreakdn[totbbdn-1] = Time[pos];
      }
   }
   pos--;
  }

}

