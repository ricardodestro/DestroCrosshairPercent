//+------------------------------------------------------------------+
//|                                       DestroCrossHairPercent.mq5 |
//|                                                   Ricardo Destro |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Ricardo Destro"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plot crossLine
#property indicator_label1  "crossLine"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrBlack
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

// Buffers
double crossLineBuffer[];

//#define DEBUG

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0,crossLineBuffer,INDICATOR_DATA);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {

   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);

   datetime time; 
   double price; 
   int win;

#ifdef DEBUG  
   debug(id, lparam, dparam, sparam);
#endif 
  
   // Check event mouse move
   if(id==CHARTEVENT_MOUSE_MOVE) {
     
      int x = (int)lparam;
      int y = (int)dparam;
      
      // Get current chart information
      ChartXYToTimePrice(0,x,y,win,time,price);
      
      // Calculate and show percent variation      
      if ( sparam == "1" && crossLineBuffer[0] > 0) {
         double percent = ( ( price  - crossLineBuffer[0] ) / price ) * 100;

         ObjectCreate(0, "objPercent", OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0,"objPercent",OBJPROP_XDISTANCE,x+30);
         ObjectSetInteger(0,"objPercent",OBJPROP_YDISTANCE,y-30);
         if ( percent > 0 ) {
            ObjectSetInteger(0,"objPercent",OBJPROP_COLOR,Blue);         
         } else {
            ObjectSetInteger(0,"objPercent",OBJPROP_COLOR,Red);         
         }
         ObjectSetString(0, "objPercent", OBJPROP_TEXT, DoubleToString(percent,_Digits) + "%");         
         ObjectSetString(0,"objPercent",OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,"objPercent",OBJPROP_FONTSIZE,12);
         ObjectSetInteger(0,"objPercent",OBJPROP_SELECTABLE,false);         
         ChartRedraw(0);
      } 
      
      // Check hold mouse click and save first price
      if ( sparam == "1" && crossLineBuffer[0] == 0) {
         crossLineBuffer[0] = price;
      }
      
      if ( sparam == "0" ) {
         reset();
      }
   } else {
      reset();
   }
}

// Remove percent
void reset() {
   crossLineBuffer[0] = 0;
   if(ObjectFind(0,"objPercent") >= 0) {
      ObjectDelete(0,"objPercent");
   }
}

// Debug
void debug(const int &id, const long &lparam, const double &dparam, const string &sparam) {
   string txt = "";

   txt += "\nid.....: " + (string)id;
   txt += "\nlparam.: " + (string)lparam;
   txt += "\ndparam.: " + (string)dparam;
   txt += "\nsparam.: " + sparam;
   
   if(id==CHARTEVENT_CHART_CHANGE) { 
      txt += "\nChart moving...";
   } 

   if(id==CHARTEVENT_MOUSE_MOVE) { 
      txt += "\nMouse moving...";
   } 
   
   Comment(txt); 
}