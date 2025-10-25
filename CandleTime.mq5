//+------------------------------------------------------------------+
//|                         Candle Timer (Simple) - MT5              |
//|                 Shows time remaining for current candle          |
//+------------------------------------------------------------------+
#property copyright "ChatGPT"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
#property strict

// تنظیمات قابل تغییر توسط کاربر
input color  TimerColor = clrLime;        // رنگ تایمر
input int    FontSize   = 14;             // سایز فونت
input string FontName   = "Arial Bold";   // فونت متن

//+------------------------------------------------------------------+
int OnInit()
{
   // ایجاد آبجکت متنی (اگر از قبل بود، حذف و بازسازی شود)
   if(ObjectFind(0,"CandleTimer") != -1)
      ObjectDelete(0,"CandleTimer");

   ObjectCreate(0, "CandleTimer", OBJ_TEXT, 0, 0, 0);
   ObjectSetInteger(0, "CandleTimer", OBJPROP_COLOR, TimerColor);
   ObjectSetInteger(0, "CandleTimer", OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, "CandleTimer", OBJPROP_FONT, FontName);
   // قرار گرفتن متن در لایه بالا
   ObjectSetInteger(0, "CandleTimer", OBJPROP_ZORDER, 0);

   EventSetTimer(1); // هر ثانیه به‌روزرسانی شود
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete(0, "CandleTimer");
}

//+------------------------------------------------------------------+
//| تابع اجباری OnCalculate با امضای صحیح (stub)                     |
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
                const int &spread[])
{
   // چون اندیکاتور ما از آبجکت‌ها و تایمر استفاده می‌کند،
   // این تابع فقط برای رفع نیاز کامپایلر وجود دارد.
   return(rates_total);
}

//+------------------------------------------------------------------+
//| به‌روزرسانی هر ثانیه (نمایش روی قیمت آخر)                       |
//+------------------------------------------------------------------+
void OnTimer()
{
   datetime candle_close = iTime(_Symbol, _Period, 0) + PeriodSeconds(_Period);
   int remaining = int(candle_close - TimeCurrent());
   if (remaining < 0) remaining = 0;

   int minutes = remaining / 60;
   int seconds = remaining % 60;

   string text = StringFormat("%02d:%02d", minutes, seconds);

   // موقعیت نمایش: کنار قیمت آخر (قیمت بسته شدن کندل جاری)
   double last_price = iClose(_Symbol, _Period, 0);
   datetime bar_time = iTime(_Symbol, _Period, 0);

   // حرکت آبجکت به مختصات (bar_time, last_price)
   // اگر حرکت شکست خورد (مثلاً به دلیل layout)، سعی کن در گوشه نمایش دهی
   if(!ObjectMove(0, "CandleTimer", 0, bar_time, last_price))
   {
      // fallback: نمایش در گوشه بالا راست
      ObjectSetInteger(0, "CandleTimer", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, "CandleTimer", OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, "CandleTimer", OBJPROP_YDISTANCE, 20);
   }

   ObjectSetString(0, "CandleTimer", OBJPROP_TEXT, text);
}

