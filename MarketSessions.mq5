//+------------------------------------------------------------------+
//|           Market Sessions Display (MT5)                          |
//|     Shows Asian, London, and New York sessions on chart          |
//+------------------------------------------------------------------+
#property copyright "ChatGPT"
#property version   "1.10"
#property indicator_chart_window
#property indicator_plots 0
#property strict

// رنگ و تنظیمات سشن‌ها
input color AsiaColor   = clrAliceBlue;
input color LondonColor = clrPaleGreen;
input color NYColor     = clrLightCoral;
input int   Opacity     = 120;       // شفافیت 0-255
input bool  ShowLabels  = true;      // نمایش نام سشن‌ها

// ساعت‌های باز و بسته شدن (UTC)
input int AsiaOpenHour   = 0;
input int AsiaCloseHour  = 9;
input int LondonOpenHour = 7;
input int LondonCloseHour= 16;
input int NYOpenHour     = 12;
input int NYCloseHour    = 21;

#define PREFIX "Session_"

//+------------------------------------------------------------------+
int OnInit()
{
   DrawSessions();          // ⬅️ تابع پایین تعریف شده، بنابراین حالا شناخته می‌شود
   EventSetTimer(3600);     // هر ساعت یکبار آپدیت
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
   {
      string nm=ObjectName(0,i);
      if(StringFind(nm,PREFIX)==0)
         ObjectDelete(0,nm);
   }
}
//+------------------------------------------------------------------+
void OnTimer()
{
   DrawSessions();
}
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
   return(rates_total);
}
//+------------------------------------------------------------------+
//|  تبدیل ساعت UTC به ساعت سرور                                     |
//+------------------------------------------------------------------+
datetime ConvertUTCtoServer(datetime base,int hourUTC)
{
   datetime utcTime = base + hourUTC*3600;
   int offset = (int)(TimeCurrent() - TimeGMT());
   return(utcTime + offset);
}
//+------------------------------------------------------------------+
//|  رسم سشن‌ها                                                      |
//+------------------------------------------------------------------+
void DrawSessions()
{
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
   {
      string nm=ObjectName(0,i);
      if(StringFind(nm,PREFIX)==0)
         ObjectDelete(0,nm);
   }

   datetime now = TimeCurrent();
   datetime dayStart = StringToTime(TimeToString(now,TIME_DATE));

   for(int d=-2; d<=1; d++)
   {
      datetime base = dayStart + d*86400;

      datetime a_start = ConvertUTCtoServer(base, AsiaOpenHour);
      datetime a_end   = ConvertUTCtoServer(base, AsiaCloseHour);
      DrawSession("Asia", a_start, a_end, AsiaColor);

      datetime l_start = ConvertUTCtoServer(base, LondonOpenHour);
      datetime l_end   = ConvertUTCtoServer(base, LondonCloseHour);
      DrawSession("London", l_start, l_end, LondonColor);

      datetime n_start = ConvertUTCtoServer(base, NYOpenHour);
      datetime n_end   = ConvertUTCtoServer(base, NYCloseHour);
      DrawSession("NewYork", n_start, n_end, NYColor);
   }
}
//+------------------------------------------------------------------+
//|  رسم هر سشن                                                      |
//+------------------------------------------------------------------+
void DrawSession(string name, datetime start, datetime end, color c)
{
   if(start>=end) return;

   string objName = PREFIX+name+"_"+TimeToString(start,TIME_DATE|TIME_MINUTES);
   double top = ChartPriceMax(0);
   double bottom = ChartPriceMin(0);

   if(!ObjectCreate(0,objName,OBJ_RECTANGLE,0,start,top,end,bottom))
      return;

   ObjectSetInteger(0,objName,OBJPROP_COLOR,c);
   ObjectSetInteger(0,objName,OBJPROP_BACK,true);
   ObjectSetInteger(0,objName,OBJPROP_FILL,true);
   ObjectSetInteger(0,objName,OBJPROP_TRANSPARENCY,Opacity);
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false);

   if(ShowLabels)
   {
      string lbl=objName+"_lbl";
      ObjectCreate(0,lbl,OBJ_TEXT,0,start,top);
      ObjectSetString(0,lbl,OBJPROP_TEXT,name);
      ObjectSetInteger(0,lbl,OBJPROP_COLOR,c);
      ObjectSetInteger(0,lbl,OBJPROP_FONTSIZE,10);
   }
}

