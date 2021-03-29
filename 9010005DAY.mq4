 
#property strict

extern int            ID          =  9010005; //Magic number 
extern double         FlotSize    = 0.03; //Fixed sized lots
extern double         TakeProfit  = 90.0; //Take profit pips
extern double         StopLoss    =50.0; //Stop loss pips
extern double         BullsPwr    = 0.561; //Bulls power increase
extern double         BearsPwr    = -1.5957; //Bears power decrease


double
RequiredStop,
P,
Tsize;
int
Ticket=0;
bool
IsBarNew=false,
visual=false,
FillJournal=false;
string
dir;

int OnInit()
  {
   P=1;
   if((MarketInfo(Symbol(),MODE_DIGITS)==3)||(MarketInfo(Symbol(),MODE_DIGITS)==5))
      P=10;
   Tsize=MarketInfo(Symbol(),MODE_TICKSIZE)*P;
   RequiredStop=MarketInfo(Symbol(),MODE_STOPLEVEL)*Tsize;
   if(!IsTesting()||IsVisualMode())
     {
      visual=true;
      FillJournal=true;
     }
   Comment("\n\nNo incoming ticks yet...");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
//---
   Comment("");
  }

void OnTick()
  {
   if(visual)
      Comments();
   if(IsNewBar())
      IsBarNew=true;
   else
      IsBarNew=false;

   if(IsBarNew)
      EntrySignal();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EntrySignal()
  {
   double
   ForceCurr=iForce(NULL,0,13,MODE_SMA,PRICE_CLOSE,1),
   ForcePrev=iForce(NULL,0,13,MODE_SMA,PRICE_CLOSE,2);
   if(ForceCurr>BullsPwr&&ForcePrev<BullsPwr)
      if(CheckPositions()==0)
         OpBuy(TakeProfit,StopLoss,ID);
   if(ForceCurr<BearsPwr&&ForcePrev>BearsPwr)
      if(CheckPositions()==0)
         OpSell(TakeProfit,StopLoss,ID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpBuy(double _take,double _stop,int _id)
  {
   double
   _SL=0,_TP=0,
   Contract = CheckVolumeValue(LotManager());
   if(CheckMoneyForTrade(Symbol(),Contract,OP_BUY))
      Ticket = OrderSend(Symbol(),OP_BUY,Contract,Ask,5,0,0,NULL,_id,0,Green);
   if(OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      _TP = Ask+MSD(_take*Tsize);
      _SL = Bid-MSD(_stop*Tsize);
      if(!OrderModify(OrderTicket(), OrderOpenPrice(), _SL, _TP, 0))
        {
         Print("Setting SL/TP BUY failed,error ",GetLastError());
         return;
        }
      else
         if(FillJournal)
            Print("Order BUY sent successfully with contract size ",DoubleToStr(Contract,2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpSell(double _take,double _stop,int _id)
  {
   double
   _SL=0,_TP=0,
   Contract=CheckVolumeValue(LotManager());
   if(CheckMoneyForTrade(Symbol(),Contract,OP_SELL))
      Ticket = OrderSend(Symbol(),OP_SELL,Contract,Bid,5,0,0,NULL,_id,0,Red);
   if(OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      _TP = Bid-MSD(_take*Tsize);
      _SL = Ask+MSD(_stop*Tsize);
      if(!OrderModify(OrderTicket(), OrderOpenPrice(), _SL, _TP, 0))
        {
         Print("Setting SL/TP SELL failed,error ",GetLastError());
         return;
        }
      else
         if(FillJournal)
            Print("Order SELL sent successfully with contract size ",DoubleToStr(Contract,2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MSD(double checkval)
  {
   if(checkval<RequiredStop)
      checkval=RequiredStop;
   return(checkval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime BarLast;
   datetime BarCurrent = iTime(NULL,0,0);
   if(BarLast!=BarCurrent)
     {
      BarLast=BarCurrent;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Comments()
  {
   string errmsg;
   if(GetLastError()!=0)
      errmsg="\n\nAdviser encountered an error associated to err # "+DoubleToStr(GetLastError(),0)+",see documentation!";
   else
      errmsg="\n\nAdviser now working...";
   Comment(errmsg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckPositions()
  {
   int val=0;
   for(int x = OrdersTotal() - 1; x >= 0; x--)
     {
      if(!OrderSelect(x, SELECT_BY_POS))
         break;
      if(OrderSymbol()!=Symbol() && OrderMagicNumber()!=ID)
         continue;
      if((OrderCloseTime() == 0) && OrderSymbol()==Symbol() && OrderMagicNumber()==ID)
        {
         if(OrderType() == OP_BUY||OrderType() == OP_SELL)
            val = 1;
         if(!(OrderType() == OP_BUY||OrderType() == OP_SELL))
            val = -1;
        }
     }
   return(val);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotManager()
  {
   double
   lotval = MathMin(MathMax((MathRound(FlotSize/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
                            MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
   return(lotval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckVolumeValue(double checkedvol)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(checkedvol<min_volume)
      return(min_volume);

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(checkedvol>max_volume)
      return(max_volume);

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(checkedvol/volume_step);
   if(MathAbs(ratio*volume_step-checkedvol)>0.0000001)
      return(ratio*volume_step);
   return(checkedvol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
