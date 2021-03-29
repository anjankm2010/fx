
#property strict
//////////////////////////////////////////////////////////////////////
//Update information
//v1.01 - New improved order send modules
//////////////////////////////////////////////////////////////////////
extern int    MagicNumber = 9010003; 
extern int    Slippage    = 5;
extern bool   MM          = false;//Money managament
extern double StaticLot   = 0.03;//Fixed lots size
extern int    Risk        = 2;//Risk %
extern double TakeProfit  =70;//Take proft in pips
extern double StopLoss    =20;//Stop loss in pips
input ENUM_TIMEFRAMES MovingTf = PERIOD_H4;//Moving time frame
input ENUM_MA_METHOD MovingMode = MODE_SMA;//Moving mode
input int     MovingPeriod  =52;//Moving average period
input int     MovingShift   =0;//Moving average shift
//--
double PT,Lots,SL,TP,indi;
int    Ticket = 0;
bool   rv=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---Set point
   if((Digits==5)||(Digits==3))
      PT = Point*10;
   else
      PT = Point;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(PosSelect()==0)
     {
      if(Signal() == 1)//Buy signal and no current chart positions exists
        {
         BuyOrder(LotSize(),StopLoss,TakeProfit);
        }
      if(Signal() == -1)//Sell signal and no current chart positions exists
        {
         SellOrder(LotSize(),StopLoss,TakeProfit);
        }
     }
   return;
  }
//////////////////////////////////////////////////////////////////////
//Moving Average signal function
int Signal()
  {
//---New bar
   if(Volume[0]>1)
      return(0);
//---
   int sig=0;
//---Ma indicator for signal
   indi=iMA(NULL,MovingTf,MovingPeriod,MovingShift,MovingMode,PRICE_CLOSE,0);
//---
   if(Open[1]>indi && Close[1]<indi)//Sell signal
      sig=-1;
//---
   if(Open[1]<indi && Close[1]>indi)//Buy signal
      sig=1;
//---
   return(sig);//Return value of sig
  }
//////////////////////////////////////////////////////////////////////
//Buy order function (ECN style -  stripping out the StopLoss and
//TakeProfit. Next, it modifies the newly opened market order by adding the desired SL and TP)
void BuyOrder(double vol,double stop,double take)
  {
   if(CheckMoneyForTrade(Symbol(),OP_BUY,vol))
      Ticket = OrderSend(Symbol(), OP_BUY, vol, Ask, Slippage, 0, 0, "", MagicNumber, 0, Blue);
   //---
   if(Ticket<1)
     {
      Print("Order send error BUY order - errcode : ",GetLastError());
      return;
     }
   else
      Print("BUY order, Ticket : ",DoubleToStr(Ticket,0),", executed successfully!");
//---
   if(OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      SL = Ask - stop * PT;
      TP = Ask + take * PT;
      if(!OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0))
        {
         Print("Failed setting SL/TP BUY order, Ticket : ",DoubleToStr(Ticket,0));
         return;
        }
      else
         Print("Successfully setting SL/TP BUY order, Ticket : ",DoubleToStr(Ticket,0));
     }
  }
//////////////////////////////////////////////////////////////////////
//Sell order function (ECN style -  stripping out the StopLoss and
//TakeProfit. Next, it modifies the newly opened market order by adding the desired SL and TP)
void SellOrder(double vol,double stop,double take)
  {
   if(CheckMoneyForTrade(Symbol(),OP_SELL,vol))
      Ticket = OrderSend(Symbol(), OP_SELL, vol, Bid, Slippage, 0, 0, "", MagicNumber, 0, Red);
//---
   if(Ticket<1)
     {
      Print("Order send error SELL order - errcode : ",GetLastError());
      return;
     }
   else
      Print("SELL order, Ticket : ",DoubleToStr(Ticket,0),", executed successfully!");
//---
   if(OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      SL = Bid + stop * PT;
      TP = Bid - take * PT;
      if(!OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0))
        {
         Print("Failed setting SL/TP SELL order, Ticket : ",DoubleToStr(Ticket,0));
         return;
        }
      else
         Print("Successfully setting SL/TP SELL order, Ticket : ",DoubleToStr(Ticket,0));
     }
  }
//////////////////////////////////////////////////////////////////////
//Position selector function
int PosSelect()
  {
   int posi=0;
   for(int k = OrdersTotal() - 1; k >= 0; k--)
     {
      if(!OrderSelect(k, SELECT_BY_POS))break;
      if(OrderSymbol()!=Symbol()&&OrderMagicNumber()!= MagicNumber)continue;
      if(OrderCloseTime() == 0 && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType() == OP_BUY)
            posi = 1; //Long position
         if(OrderType() == OP_SELL)
            posi = -1; //Short positon
        }
     }
   return(posi);
  }
//////////////////////////////////////////////////////////////////////
//Lots size calculation
double LotSize()
  {
   if(MM == true)
     {
      Lots = MathMin(MathMax((MathRound((AccountFreeMargin()*Risk/1000/100)
                                        /MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
                             MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
     }
   else
     {
      Lots = MathMin(MathMax((MathRound(StaticLot/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
                             MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
     }

   return(Lots);
  }
////////////////////////////////////////////////////////////////
//Money check
bool CheckMoneyForTrade(string symb,int type,double lots)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ",oper," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
