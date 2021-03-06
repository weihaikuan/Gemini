#property copyright "笑傲1－3号"
#import "Kernel32.dll"
   void GetSystemTime(int& a0[]);
#import

extern string aaa = "加载于EURUSD M5  另开M1 M15 H1";
extern string GMT设置 = "Nord平台 冬令时GMT = 1 夏令时GMT = 2 挂机测试不需要设置此项";
extern int    GMT_Mode = 1;
extern bool   Use_ECN = false;
extern bool   Use_Rossie1 = true;
extern bool   Use_Rossie2 = true;
extern bool   Use_Rossie3 = true;
extern bool   Use_FanBei = false;
extern double FanBei = 2;
extern double Lots = 0.1;
extern bool   Use_MM = false;
extern double Risk = 8;

string Comment1 = "笑傲1号-";
string Comment2 = "笑傲2号-";
string Comment3 = "笑傲3号-";
int Magic1 = 111;
int Magic2 = 222;
int Magic3 = 333;
double Lots1;
double Rossie1;
double ymhRossie1 = 1;
double Lots2;
double Rossie2;
double ymhRossie2 = 1;
double Lots3;
double Rossie3;
double ymhRossie3 = 1;
int Slippage = 3;
int gi_196 = 0;
int gi_200 = 2;
int gi_204 = 0;
int gi_240 = 0;
int gi_244 = 2;
int gi_248 = 0;
int gi_284 = 0;
int gi_288 = 2;
int gi_292 = 0;
double MaxLot1 = 10000;
double MaxLot2 = 10000;
string Scalping = "==== 震荡策略参数设置 ====";
int StopLoss = 100;
int TakeProfit = 20;
int g_period_336 = 60;
int TREND_STR = 20;
int g_period_344 = 18;
int OSC_open = 10;
int OSC_close = 13;
int gi_356 = -5;
int gi_360 = 21;
int gi_368 = 6;
string Breakout = "==== 突破策略参数设置 ====";
int TakeProfit_II = 160;
int StopLoss_II = 25;
int MaxPipsTrailing2 = 180;
int MinPipsTrailing2 = 10;
int Break = 13;
int g_period_400 = 1;
int g_period_404 = 19;
double gd_408 = 1.4;
double ATRTrailingFactor2 = 4.7;
int gi_424 = 300;
int gi_428 = 270;
int gi_432 = 20;
int gi_436 = 0;
int gi_440 = 8;
int gi_444 = 7;
int gi_448 = 18;
int gi_452 = 17;
int gi_456 = 13;
int gi_460 = 14;
int gi_464 = 6;
int gi_468 = 9;
int gi_472 = 2;
int gi_476 = 3;
string Reversal = "==== 抄底策略参数设置 ====";
int BegHourSys_III = 22;
int EndHourSys_III = 0;
double TakeProfit_III = 160;
int StopLoss_III = 100;
int gi_508 = 300;
int MaxPipsTrailing3 = 60;
int MinPipsTrailing3 = 20;
int g_period_520 = 60;
double gd_524 = 13;
int g_period_532 = 26;
int gi_536 = -3;
int gi_540 = 30;
bool gi_544 = TRUE;
string gs_548 = "";
double g_minlot_556 = 0;
double g_maxlot_564 = 0;
int g_leverage_572 = 0;
int g_lotsize_576 = 0;
int g_stoplevel_580 = 0;
int g_datetime_584 = 0;
int g_datetime_588 = 0;
int l_count0;
int li_44;
int ld_35;
double ld_36;

int init() {
   Lots1 = Lots;
   Lots2 = Lots;
   Lots3 = Lots;
   Rossie1 = Risk;
   Rossie2 = Risk;
   Rossie3 = Risk;
   if(Use_FanBei) {
      ymhRossie1 = 1;
      ymhRossie2 = FanBei;
      ymhRossie3 = FanBei;
    }
   g_minlot_556 = MarketInfo(Symbol(), MODE_MINLOT);
   g_maxlot_564 = MarketInfo(Symbol(), MODE_MAXLOT);
   g_leverage_572 = AccountLeverage();
   g_lotsize_576 = MarketInfo(Symbol(), MODE_LOTSIZE);
   g_stoplevel_580 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (Digits == 3 || Digits == 5) ld_35 = 10;
   else ld_35 = 1;
   ld_36 = ld_35*Point;
  return(0);
}

int start() {
   double l_price_0;
   double l_price_8;
   double l_price_16;
   color l_color_24;
   bool l_bool_28;
   bool l_bool_32;
   int l_ticket_48;
   int l_ticket_52;
   int l_ticket_56;
   double l_price_60;
   double l_price_68;
   double l_price_76;
   double l_price_84;
   double ld_92;
   double l_price_100;
   double l_price_108;
   double l_price_116;
   double ld_124;
   double l_price_132;
   double l_lots_140;
   string ls_148;
   double l_lots_156;
   double l_lots_164;
   if(StringSubstr(Symbol(),0,6) != "EURUSD") {
     Alert("请加载于 EURUSD!");
     Sleep(10000);
     return(0);
     }
   if(Period() != PERIOD_M5) {
     Alert("请加载于 M5 周期!");
     Sleep(10000);
     return(0);
     }
   if(!IsDllsAllowed() && !IsTesting()) {
     Alert("dll 调用不了!");
     Sleep(10000);
     return(0);
     }
   if(!WindowHandle(Symbol(),PERIOD_M1) && !IsTesting()) {
     Alert("请再打开 EURUSD M1 周期图表!");
     Sleep(10000);
     return(0);
     }
   if(!WindowHandle(Symbol(),PERIOD_M15) && !IsTesting()) {
     Alert("请再打开 EURUSD M15 周期图表!");
     Sleep(10000);
     return(0);
     }
   if(!WindowHandle(Symbol(),PERIOD_H1) && !IsTesting()) {
     Alert("请再打开 EURUSD H1 周期图表!");
     Sleep(10000);
     return(0);
     }
   if(IsTesting()) li_44 = GMT_Mode;
   else li_44 = AutoGMT();
   ObjectCreate("klc", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc", " GMT = " + DoubleToStr(li_44,0), 15, "宋体", Lime);
   ObjectSet("klc", OBJPROP_CORNER, 0);
   ObjectSet("klc", OBJPROP_XDISTANCE, 0);
   ObjectSet("klc", OBJPROP_YDISTANCE, 22);
   HideTestIndicators(FALSE);
   double l_iclose_212 = iClose(NULL, PERIOD_M15, 1);
   double l_ima_220 = iMA(NULL, PERIOD_M15, g_period_336, 0, MODE_SMMA, PRICE_CLOSE, 1);
   double l_iwpr_228 = iWPR(NULL, PERIOD_M15, g_period_344, 1);
   double l_iatr_236 = iATR(NULL, PERIOD_H1, g_period_404, 1);
   double l_ima_244 = iMA(NULL, PERIOD_H1, g_period_400, 0, MODE_EMA, PRICE_CLOSE, 1);
   double ld_252 = l_ima_244 + l_iatr_236 * gd_408;
   double ld_260 = l_ima_244 - l_iatr_236 * gd_408;
   double l_iclose_268 = iClose(NULL, PERIOD_M5, 1);
   double l_iatr_276 = iATR(NULL, PERIOD_M5, g_period_520, 1);
   double l_ihigh_284 = iHigh(NULL, PERIOD_H1, 1);
   double l_ilow_292 = iLow(NULL, PERIOD_H1, 1);
   double l_ibands_300 = iBands(NULL, PERIOD_H1, g_period_532, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double l_ibands_308 = iBands(NULL, PERIOD_H1, g_period_532, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   HideTestIndicators(FALSE);
   if (TakeProfit < g_stoplevel_580 / ld_35) TakeProfit = g_stoplevel_580 / ld_35;
   if (TakeProfit_II < g_stoplevel_580 / ld_35) TakeProfit_II = g_stoplevel_580 / ld_35;
   if (StopLoss < g_stoplevel_580 / ld_35) StopLoss = g_stoplevel_580 / ld_35;
   if (StopLoss_II < g_stoplevel_580 / ld_35) StopLoss_II = g_stoplevel_580 / ld_35;
   if (TakeProfit_III < g_stoplevel_580 / ld_35) TakeProfit_III = g_stoplevel_580 / ld_35;
   if (StopLoss_III < g_stoplevel_580 / ld_35) StopLoss_III = g_stoplevel_580 / ld_35;
   int li_316 = gi_360 + li_44;
   int li_320 = gi_360 + li_44;
   int li_324 = BegHourSys_III + li_44;
   int li_328 = EndHourSys_III + li_44;
   if (li_316 > 23) li_316 -= 24;
   if (li_316 < 0) li_316 += 24;
   if (li_324 > 23) li_324 -= 24;
   if (li_324 < 0) li_324 += 24;
   if (li_320 > 23) li_320 -= 24;
   if (li_320 < 0) li_320 += 24;
   if (li_328 > 23) li_328 -= 24;
   if (li_328 < 0) li_328 += 24;
   int li_332 = gi_436 + li_44;
   int li_336 = gi_440 + li_44;
   int li_340 = gi_444 + li_44;
   int li_344 = gi_448 + li_44;
   int li_348 = gi_452 + li_44;
   int li_352 = gi_456 + li_44;
   int li_356 = gi_460 + li_44;
   int li_360 = gi_464 + li_44;
   int li_364 = gi_468 + li_44;
   int li_368 = gi_472 + li_44;
   int li_372 = gi_476 + li_44;
   if (li_332 > 23) li_332 -= 24;
   if (li_332 < 0) li_332 += 24;
   if (li_336 > 23) li_336 -= 24;
   if (li_336 < 0) li_336 += 24;
   if (li_340 > 23) li_340 -= 24;
   if (li_340 < 0) li_340 += 24;
   if (li_344 > 23) li_344 -= 24;
   if (li_344 < 0) li_344 += 24;
   if (li_348 > 23) li_348 -= 24;
   if (li_348 < 0) li_348 += 24;
   if (li_352 > 23) li_352 -= 24;
   if (li_352 < 0) li_352 += 24;
   if (li_356 > 23) li_356 -= 24;
   if (li_356 < 0) li_356 += 24;
   if (li_360 > 23) li_360 -= 24;
   if (li_360 < 0) li_360 += 24;
   if (li_364 > 23) li_364 -= 24;
   if (li_364 < 0) li_364 += 24;
   if (li_368 > 23) li_368 -= 24;
   if (li_368 < 0) li_368 += 24;
   if (li_372 > 23) li_372 -= 24;
   if (li_372 < 0) li_372 += 24;
   Slippage = Slippage * ld_35;
   int l_count_376 = 0;
   int l_count_380 = 0;
   int l_count_384 = 0;
   int l_count_388 = 0;
   int l_count_392 = 0;
   int l_count_396 = 0;
   int li_404 = g_datetime_584 + gi_424;
   int li_412 = g_datetime_588 + gi_508;
   for (int l_pos_416 = OrdersTotal() - 1; l_pos_416 >= 0; l_pos_416--) {
      if (!OrderSelect(l_pos_416, SELECT_BY_POS, MODE_TRADES)) Print("选择定单错误:", l_pos_416);
      else {
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol()) {
            if (OrderMagicNumber() == Magic1) {
               if (OrderType() == OP_BUY) {
                  if (OrderStopLoss() == 0) {
                     l_price_60 = NormalizeDouble(Ask - StopLoss * ld_36, Digits);
                     l_price_68 = NormalizeDouble(Ask + TakeProfit * ld_36, Digits);
                     if (CheckStop(OrderType(), l_price_60) && CheckTarget(OrderType(), l_price_68)) OrderModify(OrderTicket(), OrderOpenPrice(), l_price_60, l_price_68, 0, Green);
                  }
                  if (l_iwpr_228 > (-OSC_close) && Bid > l_iclose_212 + gi_356 * ld_36) {
                     RefreshRates();
                     OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), Slippage, Violet);
                  } else l_count_376++;
               } else {
                  if (OrderStopLoss() == 0) {
                     l_price_60 = NormalizeDouble(Bid + StopLoss * ld_36, Digits);
                     l_price_68 = NormalizeDouble(Bid - TakeProfit * ld_36, Digits);
                     if (CheckStop(OrderType(), l_price_60) && CheckTarget(OrderType(), l_price_68)) OrderModify(OrderTicket(), OrderOpenPrice(), l_price_60, l_price_68, 0, Green);
                  }
                  if (l_iwpr_228 < OSC_close + (-100) && Bid < l_iclose_212 - gi_356 * ld_36) {
                     RefreshRates();
                     OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), Slippage, Violet);
                  } else l_count_380++;
               }
            }
            if (OrderMagicNumber() == Magic2) {
               if (OrderType() == OP_BUY) {
                  if (OrderStopLoss() == 0) {
                     l_price_76 = NormalizeDouble(Ask - StopLoss_II * ld_36, Digits);
                     l_price_84 = NormalizeDouble(Ask + TakeProfit_II * ld_36, Digits);
                     if (CheckStop(OrderType(), l_price_76) && CheckTarget(OrderType(), l_price_84)) OrderModify(OrderTicket(), OrderOpenPrice(), l_price_76, l_price_84, 0, Green);
                  }
                  if (l_iclose_268 <= ld_260 - Break * ld_36) {
                     RefreshRates();
                     OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), Slippage, Violet);
                  } else l_count_384++;
                  if (TimeCurrent() >= li_404) {
                     ld_92 = l_iatr_236 * ATRTrailingFactor2;
                     if (ld_92 > MaxPipsTrailing2 * ld_36) ld_92 = MaxPipsTrailing2 * ld_36;
                     if (ld_92 < MinPipsTrailing2 * ld_36) ld_92 = MinPipsTrailing2 * ld_36;
                     if (Bid - OrderOpenPrice() > gi_428 * ld_36) ld_92 = gi_432 * ld_36;
                     l_price_100 = NormalizeDouble(Bid - ld_92, Digits);
                     if (Bid - OrderOpenPrice() > ld_92) {
                        if (OrderStopLoss() < l_price_100 && CheckStop(OrderType(), l_price_100)) {
                           l_bool_28 = OrderModify(OrderTicket(), OrderOpenPrice(), l_price_100, OrderTakeProfit(), 0, Blue);
                           if (l_bool_28) {
                              g_datetime_584 = TimeCurrent();
                           }
                        }
                     }
                  }
               } else {
                  if (OrderStopLoss() == 0) {
                     l_price_76 = NormalizeDouble(Bid + StopLoss_II * ld_36, Digits);
                     l_price_84 = NormalizeDouble(Bid - TakeProfit_II * ld_36, Digits);
                     if (CheckStop(OrderType(), l_price_76) && CheckTarget(OrderType(), l_price_84)) OrderModify(OrderTicket(), OrderOpenPrice(), l_price_76, l_price_84, 0, Green);
                  }
                  if (l_iclose_268 >= ld_252 + Break * ld_36) {
                     RefreshRates();
                     OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), Slippage, Violet);
                  } else l_count_388++;
                  if (TimeCurrent() >= li_404) {
                     ld_92 = l_iatr_236 * ATRTrailingFactor2;
                     if (ld_92 > MaxPipsTrailing2 * ld_36) ld_92 = MaxPipsTrailing2 * ld_36;
                     if (ld_92 < MinPipsTrailing2 * ld_36) ld_92 = MinPipsTrailing2 * ld_36;
                     if (OrderOpenPrice() - Ask > gi_428 * ld_36) ld_92 = gi_432 * ld_36;
                     l_price_100 = NormalizeDouble(Ask + ld_92, Digits);
                     if (OrderOpenPrice() - Ask > ld_92) {
                        if (OrderStopLoss() > l_price_100 && CheckStop(OrderType(), l_price_100)) {
                           l_bool_28 = OrderModify(OrderTicket(), OrderOpenPrice(), l_price_100, OrderTakeProfit(), 0, Red);
                           if (l_bool_28) {
                              g_datetime_584 = TimeCurrent();
                           }
                        }
                     }
                  }
               }
            }
            if (OrderMagicNumber() == Magic3) {
               if (OrderType() == OP_BUY) {
                  if (OrderStopLoss() == 0) {
                     l_price_108 = NormalizeDouble(Ask - StopLoss_III * ld_36, Digits);
                     l_price_116 = NormalizeDouble(Ask + TakeProfit_III * ld_36, Digits);
                     if (CheckStop(OrderType(), l_price_108) && CheckTarget(OrderType(), l_price_116)) OrderModify(OrderTicket(), OrderOpenPrice(), l_price_108, l_price_116, 0, Green);
                  }
                  if ((li_324 <= li_328 && TimeHour(TimeCurrent()) >= li_324 && TimeHour(TimeCurrent()) <= li_328) || (li_324 > li_328 && TimeHour(TimeCurrent()) >= li_324 || TimeHour(TimeCurrent()) <= li_328) &&
                     l_ibands_300 - l_ibands_308 >= gi_540 * ld_36 && l_ihigh_284 > l_ibands_300 + gi_536 * ld_36) {
                     RefreshRates();
                     OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), Slippage, Violet);
                  } else l_count_392++;
                  if (TimeCurrent() >= li_412) {
                     ld_124 = l_iatr_276 * gd_524;
                     if (ld_124 > MaxPipsTrailing3 * ld_36) ld_124 = MaxPipsTrailing3 * ld_36;
                     if (ld_124 < MinPipsTrailing3 * ld_36) ld_124 = MinPipsTrailing3 * ld_36;
                     l_price_132 = NormalizeDouble(Bid - ld_124, Digits);
                     if (Bid - OrderOpenPrice() > ld_124) {
                        if (OrderStopLoss() < l_price_132 && CheckStop(OrderType(), l_price_132)) {
                           l_bool_32 = OrderModify(OrderTicket(), OrderOpenPrice(), l_price_132, OrderTakeProfit(), 0, Blue);
                           if (l_bool_32) {
                              g_datetime_588 = TimeCurrent();
                           }
                        }
                     }
                  }
               } else {
                  if (OrderStopLoss() == 0) {
                     l_price_108 = NormalizeDouble(Bid + StopLoss_III * ld_36, Digits);
                     l_price_116 = NormalizeDouble(Bid - TakeProfit_III * ld_36, Digits);
                     if (CheckStop(OrderType(), l_price_108) && CheckTarget(OrderType(), l_price_116)) OrderModify(OrderTicket(), OrderOpenPrice(), l_price_108, l_price_116, 0, Green);
                  }
                  if ((li_324 <= li_328 && TimeHour(TimeCurrent()) >= li_324 && TimeHour(TimeCurrent()) <= li_328) || (li_324 > li_328 && TimeHour(TimeCurrent()) >= li_324 || TimeHour(TimeCurrent()) <= li_328) &&
                     l_ibands_300 - l_ibands_308 >= gi_540 * ld_36 && l_ilow_292 < l_ibands_308 - gi_536 * ld_36) {
                     RefreshRates();
                     OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), Slippage, Violet);
                  } else l_count_396++;
                  if (TimeCurrent() >= li_412) {
                     ld_124 = l_iatr_276 * gd_524;
                     if (ld_124 > MaxPipsTrailing3 * ld_36) ld_124 = MaxPipsTrailing3 * ld_36;
                     if (ld_124 < MinPipsTrailing3 * ld_36) ld_124 = MinPipsTrailing3 * ld_36;
                     l_price_132 = NormalizeDouble(Ask + ld_124, Digits);
                     if (OrderOpenPrice() - Ask > ld_124) {
                        if (OrderStopLoss() > l_price_132 && CheckStop(OrderType(), l_price_132)) {
                           l_bool_32 = OrderModify(OrderTicket(), OrderOpenPrice(), l_price_132, OrderTakeProfit(), 0, Red);
                           if (l_bool_32) {
                              g_datetime_588 = TimeCurrent();
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
   l_count0 = 0;
   for(int i = OrdersHistoryTotal() - 1;i >= 0;i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        if(OrderMagicNumber() == Magic1 || OrderMagicNumber() == Magic2 || OrderMagicNumber() == Magic3) {
          if(TimeDay(OrderCloseTime()) != TimeDay(TimeCurrent())) break;
          l_count0++;
          if(l_count0 >= 10) {
            Alert("今天的单子数太多了 看看有没有错误 明天才能挂机了!");
            Sleep(10000);
            return(0);
            }
          }
       }
    }
   int l_cmd_420 = -1;
   if (Use_Rossie1) {
      if (Lots1 != 0) {
         l_lots_140 = MathMin(g_maxlot_564, MathMax(g_minlot_556, Lots1));
         if (Use_MM) l_lots_140 = MathMax(g_minlot_556, MathMin(g_maxlot_564, NormalizeDouble(CalcRossie1() / 100 * AccountFreeMargin() / g_minlot_556 / (g_lotsize_576 / 100), 0) * g_minlot_556));
         if (l_lots_140 > MaxLot2) l_lots_140 = MaxLot2;
         if (AccountFreeMargin() < Ask * l_lots_140 * g_lotsize_576 / g_leverage_572) {
            Alert("钱不够了. 下单量 = ", l_lots_140, " , 自由保证金 = ", AccountFreeMargin());
            return (0);
         }
         if (l_count_376 < 1 && (l_iclose_212 > l_ima_220 + TREND_STR * ld_36 && l_iwpr_228 < OSC_open + (-100) && Bid < l_iclose_212 - gi_356 * ld_36) || (l_iwpr_228 < gi_368 +
            (-100) && Bid < l_iclose_212 - gi_356 * ld_36 && Hour() == li_316 || Hour() == li_320)) {
            ls_148 = "BUY";
            l_cmd_420 = 0;
            l_color_24 = Aqua;
            RefreshRates();
            l_price_0 = NormalizeDouble(Ask, Digits);
            l_price_8 = l_price_0 - StopLoss * ld_36;
            l_price_16 = l_price_0 + TakeProfit * ld_36;
         }
         if (l_count_380 < 1 && (l_iclose_212 < l_ima_220 - TREND_STR * ld_36 && l_iwpr_228 > (-OSC_open) && Bid > l_iclose_212 + gi_356 * ld_36) || (l_iwpr_228 > (-gi_368) &&
            Bid > l_iclose_212 + gi_356 * ld_36 && Hour() == li_316 || Hour() == li_320)) {
            ls_148 = "SELL";
            l_cmd_420 = 1;
            l_color_24 = Red;
            RefreshRates();
            l_price_0 = NormalizeDouble(Bid, Digits);
            l_price_8 = l_price_0 + StopLoss * ld_36;
            l_price_16 = l_price_0 - TakeProfit * ld_36;
         }
      }
   }
   if (l_cmd_420 >= OP_BUY && g_stoplevel_580 == 0 || (CheckStop(l_cmd_420, l_price_8) && CheckTarget(l_cmd_420, l_price_16))) {
      if (g_stoplevel_580 == 0 || Use_ECN == TRUE) l_ticket_48 = OrderSend(Symbol(), l_cmd_420, l_lots_140, l_price_0, Slippage, 0, 0, Comment1, Magic1, 0, l_color_24);
      else l_ticket_48 = OrderSend(Symbol(), l_cmd_420, l_lots_140, l_price_0, Slippage, l_price_8, l_price_16, Comment1, Magic1, 0, l_color_24);
      Sleep(5000);
      if (l_ticket_48 > 0) {
         if (OrderSelect(l_ticket_48, SELECT_BY_TICKET, MODE_TRADES)) Alert("定单 " , ls_148 , " 开仓了!: ", OrderOpenPrice());
      } else Alert("开仓错误 " , ls_148 , " 定单!: ", GetLastError());
   }
   l_cmd_420 = -1;
   if (!(TimeHour(TimeCurrent()) != li_332 && TimeHour(TimeCurrent()) != li_336 && TimeHour(TimeCurrent()) != li_340 && TimeHour(TimeCurrent()) != li_344 && TimeHour(TimeCurrent()) != li_348 &&
      TimeHour(TimeCurrent()) != li_352 && TimeHour(TimeCurrent()) != li_356 && TimeHour(TimeCurrent()) != li_360 && TimeHour(TimeCurrent()) != li_364 && TimeHour(TimeCurrent()) != li_368) ||
      !(TimeHour(TimeCurrent()) != li_372)) {
      if (Use_Rossie2) {
         if (Lots2 != 0) {
            l_lots_156 = MathMin(g_maxlot_564, MathMax(g_minlot_556, Lots2));
            if (Use_MM) l_lots_156 = MathMax(g_minlot_556, MathMin(g_maxlot_564, NormalizeDouble(CalcRossie2() / 100 * AccountFreeMargin() / g_minlot_556 / (g_lotsize_576 / 100), 0) * g_minlot_556));
            if (l_lots_156 > MaxLot2) l_lots_156 = MaxLot2;
            if (AccountFreeMargin() < Ask * l_lots_156 * g_lotsize_576 / g_leverage_572) {
               Alert("钱不够了. 下单量 = ", l_lots_156, " , 自由保证金 = ", AccountFreeMargin());
               return (0);
            }
            if (l_count_388 < 1 && l_iclose_268 <= ld_260 - Break * ld_36) {
               ls_148 = "SELL";
               l_cmd_420 = 1;
               l_color_24 = Yellow;
               l_price_0 = NormalizeDouble(Bid, Digits);
               l_price_8 = l_price_0 + StopLoss_II * ld_36;
               l_price_16 = l_price_0 - TakeProfit_II * ld_36;
            }
            if (l_count_384 < 1 && l_iclose_268 >= ld_252 + Break * ld_36) {
               ls_148 = "BUY";
               l_cmd_420 = 0;
               l_color_24 = DodgerBlue;
               l_price_0 = NormalizeDouble(Ask, Digits);
               l_price_8 = l_price_0 - StopLoss_II * ld_36;
               l_price_16 = l_price_0 + TakeProfit_II * ld_36;
            }
         }
      }
   }
   if (l_cmd_420 >= OP_BUY && g_stoplevel_580 == 0 || (CheckStop(l_cmd_420, l_price_8) && CheckTarget(l_cmd_420, l_price_16))) {
      if (g_stoplevel_580 == 0 || Use_ECN == TRUE) l_ticket_52 = OrderSend(Symbol(), l_cmd_420, l_lots_156, l_price_0, Slippage, 0, 0, Comment2, Magic2, 0, l_color_24);
      else l_ticket_52 = OrderSend(Symbol(), l_cmd_420, l_lots_156, l_price_0, Slippage, l_price_8, l_price_16, Comment2, Magic2, 0, l_color_24);
      Sleep(5000);
      if (l_ticket_52 > 0) {
         if (OrderSelect(l_ticket_52, SELECT_BY_TICKET, MODE_TRADES)) Alert("Order " , ls_148 , " opened!: ", OrderOpenPrice());
      } else Alert("开仓错误 " , ls_148 , " 定单!: ", GetLastError());
   }
   l_cmd_420 = -1;
   if (Use_Rossie3) {
      if (Lots3 != 0) {
         l_lots_164 = MathMin(g_maxlot_564, MathMax(g_minlot_556, Lots3));
         if (Use_MM) l_lots_164 = MathMax(g_minlot_556, MathMin(g_maxlot_564, NormalizeDouble(CalcRossie3() / 100 * AccountFreeMargin() / g_minlot_556 / (g_lotsize_576 / 100), 0) * g_minlot_556));
         if (l_lots_164 > MaxLot2) l_lots_164 = MaxLot2;
         if (AccountFreeMargin() < Ask * l_lots_164 * g_lotsize_576 / g_leverage_572) {
            Alert("钱不够了. 下单量 = ", l_lots_164, " , 自由保证金 = ", AccountFreeMargin());
            return (0);
         }
         if (l_count_392 < 1 && (li_324 <= li_328 && TimeHour(TimeCurrent()) >= li_324 && TimeHour(TimeCurrent()) <= li_328) || (li_324 > li_328 && TimeHour(TimeCurrent()) >= li_324 ||
            TimeHour(TimeCurrent()) <= li_328) && l_ibands_300 - l_ibands_308 >= gi_540 * ld_36 && l_ilow_292 < l_ibands_308 - gi_536 * ld_36) {
            ls_148 = "BUY";
            l_cmd_420 = 0;
            l_color_24 = Aqua;
            RefreshRates();
            l_price_0 = NormalizeDouble(Ask, Digits);
            l_price_8 = l_price_0 - StopLoss_III * ld_36;
            l_price_16 = l_price_0 + TakeProfit_III * ld_36;
         }
         if (l_count_396 < 1 && (li_324 <= li_328 && TimeHour(TimeCurrent()) >= li_324 && TimeHour(TimeCurrent()) <= li_328) || (li_324 > li_328 && TimeHour(TimeCurrent()) >= li_324 ||
            TimeHour(TimeCurrent()) <= li_328) && l_ibands_300 - l_ibands_308 >= gi_540 * ld_36 && l_ihigh_284 > l_ibands_300 + gi_536 * ld_36) {
            ls_148 = "SELL";
            l_cmd_420 = 1;
            l_color_24 = DeepPink;
            RefreshRates();
            l_price_0 = NormalizeDouble(Bid, Digits);
            l_price_8 = l_price_0 + StopLoss_III * ld_36;
            l_price_16 = l_price_0 - TakeProfit_III * ld_36;
         }
      }
   }
   if (l_cmd_420 >= OP_BUY && g_stoplevel_580 == 0 || (CheckStop(l_cmd_420, l_price_8) && CheckTarget(l_cmd_420, l_price_16))) {
      if (g_stoplevel_580 == 0 || Use_ECN == TRUE) l_ticket_56 = OrderSend(Symbol(), l_cmd_420, l_lots_164, l_price_0, Slippage, 0, 0, Comment3, Magic3, 0, l_color_24);
      else l_ticket_56 = OrderSend(Symbol(), l_cmd_420, l_lots_164, l_price_0, Slippage, l_price_8, l_price_16, Comment3, Magic3, 0, l_color_24);
      Sleep(5000);
      if (l_ticket_56 > 0) {
         if (OrderSelect(l_ticket_56, SELECT_BY_TICKET, MODE_TRADES)) Alert("Order " , ls_148 , " opened!: ", OrderOpenPrice());
      } else Alert("开仓错误 " , ls_148 , " 定单!: ", GetLastError());
   }
   return (0);
}

int AutoGMT() {
   int lia_0[4];
   int lia_4[43];
   string ls_unused_8;
   GetSystemTime(lia_0);
   int li_16 = lia_0[0] & 65535;
   int li_20 = lia_0[0] >> 16;
   int li_24 = lia_0[1] >> 16;
   int li_28 = lia_0[2] & 65535;
   int li_32 = lia_0[2] >> 16;
   int li_36 = lia_0[3] & 65535;
   string ls_40 = FormatDateTime(li_16, li_20, li_24, li_28, li_32, li_36);
   double ld_48 = TimeCurrent() - StrToTime(ls_40);
   return (MathRound(ld_48 / 3600.0));
}

string FormatDateTime(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20) {
   string ls_24 = ai_4 + 100;
   ls_24 = StringSubstr(ls_24, 1);
   string ls_32 = ai_8 + 100;
   ls_32 = StringSubstr(ls_32, 1);
   string ls_40 = ai_12 + 100;
   ls_40 = StringSubstr(ls_40, 1);
   string ls_48 = ai_16 + 100;
   ls_48 = StringSubstr(ls_48, 1);
   string ls_56 = ai_20 + 100;
   ls_56 = StringSubstr(ls_56, 1);
   return (StringConcatenate(ai_0, ".", ls_24, ".", ls_32, " ", ls_40, ":", ls_48, ":", ls_56));
}

double CalcRossie1() {
   int li_0;
   double ld_4;
   double ld_ret_12 = Rossie1;
   int li_20 = 0;
   if (Digits <= 3) ld_4 = 0.01;
   else ld_4 = 0.0001;
   for (int l_hist_total_24 = OrdersHistoryTotal(); l_hist_total_24 >= 0; l_hist_total_24--) {
      if (OrderSelect(l_hist_total_24, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic1) {
            if (OrderProfit() > 0.0) {
               if (gi_204 == 0) break;
               if (MathAbs(OrderClosePrice() - OrderOpenPrice()) / ld_4 > gi_204) break;
            } else li_20++;
         }
      }
   }
   if (li_20 > gi_196 && gi_200 > 1) {
      li_0 = MathMod(li_20, gi_200);
      ld_ret_12 *= MathPow(ymhRossie1, li_0);
   }
   if (MaxLot1 > 0.0 && ld_ret_12 > MaxLot1) ld_ret_12 = MaxLot1;
   return (ld_ret_12);
}

double CalcRossie2() {
   int li_0;
   double ld_4;
   double ld_ret_12 = Rossie2;
   int li_20 = 0;
   if (Digits <= 3) ld_4 = 0.01;
   else ld_4 = 0.0001;
   for (int l_hist_total_24 = OrdersHistoryTotal(); l_hist_total_24 >= 0; l_hist_total_24--) {
      if (OrderSelect(l_hist_total_24, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic2) {
            if (OrderProfit() > 0.0) {
               if (gi_248 == 0) break;
               if (MathAbs(OrderClosePrice() - OrderOpenPrice()) / ld_4 > gi_248) break;
            } else li_20++;
         }
      }
   }
   if (li_20 > gi_240 && gi_244 > 1) {
      li_0 = MathMod(li_20, gi_244);
      ld_ret_12 *= MathPow(ymhRossie2, li_0);
   }
   if (MaxLot1 > 0.0 && ld_ret_12 > MaxLot1) ld_ret_12 = MaxLot1;
   return (ld_ret_12);
}

double CalcRossie3() {
   int li_0;
   double ld_4;
   double ld_ret_12 = Rossie3;
   int li_20 = 0;
   if (Digits <= 3) ld_4 = 0.01;
   else ld_4 = 0.0001;
   for (int l_hist_total_24 = OrdersHistoryTotal(); l_hist_total_24 >= 0; l_hist_total_24--) {
      if (OrderSelect(l_hist_total_24, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic3) {
            if (OrderProfit() > 0) {
               if (gi_292 == 0) break;
               if (MathAbs(OrderClosePrice() - OrderOpenPrice()) / ld_4 > gi_292) break;
            } else li_20++;
         }
      }
   }
   if (li_20 > gi_284 && gi_288 > 1) {
      li_0 = MathMod(li_20, gi_288);
      ld_ret_12 *= MathPow(ymhRossie3, li_0);
   }
   if (MaxLot1 > 0 && ld_ret_12 > MaxLot1) ld_ret_12 = MaxLot1;
   return (ld_ret_12);
}

int CheckStop(int ai_0, double ad_4) {
   bool li_ret_12 = TRUE;
   int l_stoplevel_16 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (l_stoplevel_16 > 0 && ad_4 > 0 && ai_0 == 0 && ad_4 > Bid - l_stoplevel_16 * Point) li_ret_12 = FALSE;
   else
      if (l_stoplevel_16 > 0 && ad_4 > 0 && ai_0 == 1 && ad_4 < Ask + l_stoplevel_16 * Point) li_ret_12 = FALSE;
   return (li_ret_12);
}

int CheckTarget(int ai_0, double ad_4) {
   bool li_ret_12 = TRUE;
   int l_stoplevel_16 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (l_stoplevel_16 > 0 && ad_4 > 0 && ai_0 == 0 && ad_4 < Bid + l_stoplevel_16 * Point) li_ret_12 = FALSE;
   else
      if (l_stoplevel_16 > 0 && ad_4 > 0 && ai_0 == 1 && ad_4 > Ask - l_stoplevel_16 * Point) li_ret_12 = FALSE;
   return (li_ret_12);
}