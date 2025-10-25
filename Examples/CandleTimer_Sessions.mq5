//+------------------------------------------------------------------+
//|                       CandleTimer_Sessions.mq5                   |
//|  ترکیب تایمر کندل و سشن‌های بازار برای متاتریدر 5               |
//|  توسط ChatGPT                                                    |
//+------------------------------------------------------------------+
#property copyright "ChatGPT"
#property version   "1.0"
#property indicator_chart_window
#property strict

input color LondonColor  = clrLime;
input color NYColor      = clrDodgerBlue;
input color AsiaColor    = clrGold;
input int   TextSize     = 12;
input color TextColor    = clrWhite;

//--- متغیر زمان
datetime candle_close_time;

//+------------------------------------------------------------------+
//| تابع رسم سشن‌ها                                                 |
//+------------------------------------------------------------------+
void DrawSession(string name, int start_hour, int end_hour, color clr)
{
   datetime today = iTime(_Symbol, PERIOD_D1, 0);
   datetime start = today + start_hour * 3600;
   datetime end   = today + end_hour * 3600;
   string objName = "SESSION_" + name;

   if (ObjectFind(0, objName) < 0)
   {
      ObjectCreate(0, objName, OBJ_RECTANGLE, 0, start, 0, end, 0);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, objName, OBJPROP_BACK, true);
      ObjectSetInteger(0, objName, OBJPROP_TRANSPARENCY, 80);
   }
}

//+------------------------------------------------------------------+
//| تابع اصلی محاسبه زمان باقی‌مانده کندل                           |
//+------------------------------------------------------------------+
void OnCalculate(const int rates_total,
                 const int prev_calculated,
                 const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[],
                 const long &tick_volume[],
                 const long &volume[],
                 const int &spread[])
{
   datetime current_candle_close = time[0] + PeriodSeconds();
   candle_close_time = current_candle_close;

   double chart_high = WindowPriceMax();
   double chart_low  = WindowPriceMin();
   double pos_y      = chart_high - (chart_high - chart_low) * 0.05;

   string timer_label = "CandleTimer";
   if (ObjectFind(0, timer_label) < 0)
   {
      ObjectCreate(0, timer_label, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, timer_label, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, timer_label, OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, timer_label, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, timer_label, OBJPROP_FONTSIZE, TextSize);
      ObjectSetInteger(0, timer_label, OBJPROP_COLOR, TextColor);
   }

   int seconds_left = (int)(candle_close_time - TimeCurrent());
   int m = seconds_left / 60;
   int s = seconds_left % 60;
   string text = StringFormat("⏱ %02d:%02d", m, s);
   ObjectSetString(0, timer_label, OBJPROP_TEXT, text);

   DrawSession("London", 8, 17, LondonColor);
   DrawSession("NewYork", 13, 22, NYColor);
   DrawSession("Asia", 0, 9, AsiaColor);
}

