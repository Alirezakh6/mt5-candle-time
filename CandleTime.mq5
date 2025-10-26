#                        Candle Timer - MT5              
#                Shows time remaining for current candle          
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
#property strict

input color  TimerColor = clrLime;        
input int    FontSize   = 14;             
input string FontName   = "Arial Bold";  

int OnInit()
{
   if(ObjectFind(0,"CandleTimer") != -1)
      ObjectDelete(0,"CandleTimer");

   ObjectCreate(0, "CandleTimer", OBJ_TEXT, 0, 0, 0);
   ObjectSetInteger(0, "CandleTimer", OBJPROP_COLOR, TimerColor);
   ObjectSetInteger(0, "CandleTimer", OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, "CandleTimer", OBJPROP_FONT, FontName);
   ObjectSetInteger(0, "CandleTimer", OBJPROP_ZORDER, 0);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete(0, "CandleTimer");
}

int OnCalculate(const int rates_total,
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
   return(rates_total);
}

void OnTimer()
{
   datetime candle_close = iTime(_Symbol, _Period, 0) + PeriodSeconds(_Period);
   int remaining = int(candle_close - TimeCurrent());
   if (remaining < 0) remaining = 0;

   int minutes = remaining / 60;
   int seconds = remaining % 60;

   string text = StringFormat("%02d:%02d", minutes, seconds);

   double last_price = iClose(_Symbol, _Period, 0);
   datetime bar_time = iTime(_Symbol, _Period, 0);

   if(!ObjectMove(0, "CandleTimer", 0, bar_time + 30, last_price))
{
      ObjectSetInteger(0, "CandleTimer", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, "CandleTimer", OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, "CandleTimer", OBJPROP_YDISTANCE, 20);
   }

   ObjectSetString(0, "CandleTimer", OBJPROP_TEXT, text);
}

