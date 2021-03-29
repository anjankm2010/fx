

static input string StrategyProperties__ = "------------"; // ------ Expert Properties ------
static input double Entry_Amount = 0.04; // Entry lots
input int Stop_Loss   = 60; // Stop Loss (pips)
input int Take_Profit = 110; // Take Profit (pips)
static input string Ind0 = "------------";// ----- RVI Signal -----
input int Ind0Param0 = 30; // Period
static input string Ind1 = "------------";// ----- Awesome Oscillator -----
input double Ind1Param0 = -2.0900; // Level

static input string ExpertSettings__ = "------------"; // ------ Expert Settings ------
static input int Magic_Number = 9010025; // Magic Number

#define TRADE_RETRY_COUNT 4
#define TRADE_RETRY_WAIT  100
#define OP_FLAT           -1

// Session time is set in seconds from 00:00
int sessionSundayOpen           = 0;     // 00:00
int sessionSundayClose          = 86400; // 24:00
int sessionMondayThursdayOpen   = 0;     // 00:00
int sessionMondayThursdayClose  = 86400; // 24:00
int sessionFridayOpen           = 0;     // 00:00
int sessionFridayClose          = 86400; // 24:00
bool sessionIgnoreSunday        = false;
bool sessionCloseAtSessionClose = false;
bool sessionCloseAtFridayClose  = false;

const double sigma   = 0.000001;

double posType       = OP_FLAT;
int    posTicket     = 0;
double posLots       = 0;
double posStopLoss   = 0;
double posTakeProfit = 0;

datetime barTime;
int      digits;
double   pip;
double   stopLevel;
bool     isTrailingStop=false;
bool     setProtectionSeparately=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   barTime        = Time[0];
   digits         = (int) MarketInfo(_Symbol, MODE_DIGITS);
   pip            = GetPipValue(digits);
   stopLevel      = MarketInfo(_Symbol, MODE_STOPLEVEL);
   isTrailingStop = isTrailingStop && Stop_Loss > 0;

   const ENUM_INIT_RETCODE initRetcode = ValidateInit();

   return (initRetcode);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Time[0]>barTime)
     {
      barTime=Time[0];
      OnBar();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnBar()
  {
   UpdatePosition();

   if(posType!=OP_FLAT && IsForceSessionClose())
     {
      ClosePosition();
      return;
     }

   if(IsOutOfSession())
      return;

   if(posType!=OP_FLAT)
     {
      ManageClose();
      UpdatePosition();
     }

   if(posType!=OP_FLAT && isTrailingStop)
     {
      double trailingStop=GetTrailingStop();
      ManageTrailingStop(trailingStop);
      UpdatePosition();
     }

   if(posType==OP_FLAT)
     {
      ManageOpen();
      UpdatePosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatePosition()
  {
   posType   = OP_FLAT;
   posTicket = 0;
   posLots   = 0;
   int total = OrdersTotal();

   for(int pos=total-1; pos>=0; pos--)
     {
      if(OrderSelect(pos,SELECT_BY_POS) &&
         OrderSymbol()==_Symbol &&
         OrderMagicNumber()==Magic_Number)
        {
         posType       = OrderType();
         posLots       = OrderLots();
         posTicket     = OrderTicket();
         posStopLoss   = OrderStopLoss();
         posTakeProfit = OrderTakeProfit();
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageOpen()
  {
   double ind0val1 = iRVI(NULL,0,Ind0Param0,MODE_MAIN,1) - iRVI(NULL,0,Ind0Param0,MODE_SIGNAL,1);
   double ind0val2 = iRVI(NULL,0,Ind0Param0,MODE_MAIN,2) - iRVI(NULL,0,Ind0Param0,MODE_SIGNAL,2);
   bool ind0long  = ind0val1 < 0 - sigma && ind0val2 > 0 + sigma;
   bool ind0short = ind0val1 > 0 + sigma && ind0val2 < 0 - sigma;

   const bool canOpenLong  = ind0long;
   const bool canOpenShort = ind0short;

   if(canOpenLong && canOpenShort)
      return;

   if(canOpenLong)
      OpenPosition(OP_BUY);
   else if(canOpenShort)
      OpenPosition(OP_SELL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageClose()
  {
   double ind1val1 = iAO(NULL,0,1);
   bool ind1long  = ind1val1 < Ind1Param0 - sigma;
   bool ind1short = ind1val1 > -Ind1Param0 + sigma;

   if(posType==OP_BUY && ind1long)
      ClosePosition();
   else if(posType==OP_SELL && ind1short)
      ClosePosition();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPosition(int command)
  {
   for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
     {
      int    ticket     = 0;
      int    lastError  = 0;
      bool   modified   = false;
      double stopLoss   = GetStopLoss(command);
      double takeProfit = GetTakeProfit(command);
      string comment    = IntegerToString(Magic_Number);
      color  arrowColor = command==OP_BUY ? clrGreen : clrRed;

      if(IsTradeContextFree())
        {
         double price=MarketInfo(_Symbol,command==OP_BUY ? MODE_ASK : MODE_BID);
         if(setProtectionSeparately)
           {
            ticket=OrderSend(_Symbol,command,Entry_Amount,price,10,0,0,comment,Magic_Number,0,arrowColor);
            if(ticket>0 && (Stop_Loss>0 || Take_Profit>0))
              {
               modified=OrderModify(ticket,0,stopLoss,takeProfit,0,clrBlue);
              }
           }
         else
           {
            ticket=OrderSend(_Symbol,command,Entry_Amount,price,10,stopLoss,takeProfit,comment,Magic_Number,0,arrowColor);
            lastError=GetLastError();
            if(ticket<=0 && lastError==130)
              {
               ticket=OrderSend(_Symbol,command,Entry_Amount,price,10,0,0,comment,Magic_Number,0,arrowColor);
               if(ticket>0 && (Stop_Loss>0 || Take_Profit>0))
                 {
                  modified=OrderModify(ticket,0,stopLoss,takeProfit,0,clrBlue);
                 }
               if(ticket>0 && modified)
                 {
                  setProtectionSeparately=true;
                  Print("Detected ECN type position protection.");
                 }
              }
           }
        }

      if(ticket>0)
         break;

      lastError=GetLastError();
      if(lastError!=135 && lastError!=136 && lastError!=137 && lastError!=138)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Open Position retry no: "+IntegerToString(attempt+2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition()
  {
   for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
     {
      bool closed;
      int lastError=0;

      if(IsTradeContextFree())
        {
         double price=MarketInfo(_Symbol,posType==OP_BUY ? MODE_BID : MODE_ASK);
         closed=OrderClose(posTicket,posLots,price,10,clrYellow);
         lastError=GetLastError();
        }

      if(closed)
         break;

      if(lastError==4108)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Close Position retry no: "+IntegerToString(attempt+2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyPosition()
  {
   for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++)
     {
      bool modified;
      int lastError=0;

      if(IsTradeContextFree())
        {
         modified=OrderModify(posTicket,0,posStopLoss,posTakeProfit,0,clrBlue);
         lastError=GetLastError();
        }

      if(modified)
         break;

      if(lastError==4108)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Modify Position retry no: "+IntegerToString(attempt+2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLoss(int command)
  {
   if(Stop_Loss==0)
      return (0);

   double delta    = MathMax(pip*Stop_Loss, _Point*stopLevel);
   double price    = MarketInfo(_Symbol, command==OP_BUY ? MODE_BID : MODE_ASK);
   double stopLoss = command==OP_BUY ? price-delta : price+delta;
   return (NormalizeDouble(stopLoss, digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTakeProfit(int command)
  {
   if(Take_Profit==0)
      return (0);

   double delta      = MathMax(pip*Take_Profit, _Point*stopLevel);
   double price      = MarketInfo(_Symbol, command==OP_BUY ? MODE_BID : MODE_ASK);
   double takeProfit = command==OP_BUY ? price+delta : price-delta;
   return (NormalizeDouble(takeProfit, digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrailingStop()
  {
   double bid=MarketInfo(_Symbol,MODE_BID);
   double ask=MarketInfo(_Symbol,MODE_ASK);
   double stopLevelPoints=_Point*stopLevel;
   double stopLossPoints=pip*Stop_Loss;

   if(posType==OP_BUY)
     {
      double stopLossPrice=High[1]-stopLossPoints;
      if(posStopLoss<stopLossPrice-pip)
        {
         if(stopLossPrice<bid)
           {
            if(stopLossPrice>=bid-stopLevelPoints)
               return (bid - stopLevelPoints);
            else
               return (stopLossPrice);
           }
         else
           {
            return (bid);
           }
        }
     }

   else if(posType==OP_SELL)
     {
      double stopLossPrice1=Low[1]+stopLossPoints;
      if(posStopLoss>stopLossPrice1+pip)
        {
         if(stopLossPrice1>ask)
           {
            if(stopLossPrice1<=ask+stopLevelPoints)
               return (ask + stopLevelPoints);
            else
               return (stopLossPrice1);
           }
         else
           {
            return (ask);
           }
        }
     }

   return (posStopLoss);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageTrailingStop(double trailingStop)
  {
   double bid=MarketInfo(_Symbol,MODE_BID);
   double ask=MarketInfo(_Symbol,MODE_ASK);

   if(posType==OP_BUY && MathAbs(trailingStop-bid)<_Point)
     {
      ClosePosition();
     }

   else if(posType==OP_SELL && MathAbs(trailingStop-ask)<_Point)
     {
      ClosePosition();
     }

   else if(MathAbs(trailingStop-posStopLoss)>_Point)
     {
      posStopLoss=NormalizeDouble(trailingStop,digits);
      ModifyPosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(int bar)
  {
   return Time[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(int bar)
  {
   return Open[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double High(int bar)
  {
   return High[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Low(int bar)
  {
   return Low[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(int bar)
  {
   return Close[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPipValue(int digit)
  {
   if(digit==4 || digit==5)
      return (0.0001);
   if(digit==2 || digit==3)
      return (0.01);
   if(digit==1)
      return (0.1);
   return (1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeContextFree()
  {
   if(IsTradeAllowed())
      return (true);

   uint startWait=GetTickCount();
   Print("Trade context is busy! Waiting...");

   while(true)
     {
      if(IsStopped())
         return (false);

      uint diff=GetTickCount()-startWait;
      if(diff>30*1000)
        {
         Print("The waiting limit exceeded!");
         return (false);
        }

      if(IsTradeAllowed())
        {
         RefreshRates();
         return (true);
        }
      Sleep(TRADE_RETRY_WAIT);
     }
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOutOfSession()
  {
   MqlDateTime time0; TimeToStruct(Time[0],time0);
   int weekDay           = time0.day_of_week;
   long timeFromMidnight = Time[0]%86400;
   int periodLength      = PeriodSeconds(_Period);
   bool skipTrade        = false;

   if(weekDay==0)
     {
      if(sessionIgnoreSunday) return true;
      int lastBarFix=sessionCloseAtSessionClose ? periodLength : 0;
      skipTrade=timeFromMidnight<sessionSundayOpen || timeFromMidnight+lastBarFix>sessionSundayClose;
     }
   else if(weekDay<5)
     {
      int lastBarFix1=sessionCloseAtSessionClose ? periodLength : 0;
      skipTrade=timeFromMidnight<sessionMondayThursdayOpen || timeFromMidnight+lastBarFix1>sessionMondayThursdayClose;
     }
   else
     {
      int lastBarFix2=sessionCloseAtFridayClose || sessionCloseAtSessionClose ? periodLength : 0;
      skipTrade=timeFromMidnight<sessionFridayOpen || timeFromMidnight+lastBarFix2>sessionFridayClose;
     }

   return (skipTrade);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsForceSessionClose()
  {
   if(!sessionCloseAtFridayClose && !sessionCloseAtSessionClose)
      return (false);

   MqlDateTime time0; TimeToStruct(Time[0],time0);
   int weekDay           = time0.day_of_week;
   long timeFromMidnight = Time[0]%86400;
   int periodLength      = PeriodSeconds(_Period);

   bool forceExit=false;
   if(weekDay==0 && sessionCloseAtSessionClose)
     {
      forceExit=timeFromMidnight+periodLength>sessionSundayClose;
     }
   else if(weekDay<5 && sessionCloseAtSessionClose)
     {
      forceExit=timeFromMidnight+periodLength>sessionMondayThursdayClose;
     }
   else if(weekDay == 5)
     {
      forceExit=timeFromMidnight+periodLength>sessionFridayClose;
     }

   return (forceExit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE ValidateInit()
  {
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
/*STRATEGY MARKET Premium Data; EURJPY; H1 */
/*STRATEGY CODE {"properties":{"entryLots":0.1,"stopLoss":72,"takeProfit":32,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"RVI Signal","listIndexes":[1,0,0,0,0],"numValues":[42,0,0,0,0,0]}],"closeFilters":[{"name":"Awesome Oscillator","listIndexes":[3,0,0,0,0],"numValues":[-2.09,0,0,0,0,0]}]} */
