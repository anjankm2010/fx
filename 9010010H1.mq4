
#property strict
//--External variables
extern int    MagicNumber       = 9010010;//Magic number
extern string EaComment         = "Grid_Template";//Order comment
extern double StaticLot         = 0.02;//Static lots size
extern bool   MM                = false;//Money Management
extern int    Risk              = 2;//Risk %
extern double TakeProfit        = 100.;//Take Profit in pips
extern double StopLoss          = 40.;//Stop loss in pips
extern double PriceDistance     = 20.;//Distance from price in pips
extern double GridStep          = 10.;//Step between grid orders in pips
extern int    GridOrders        =1;//Amount of grid orders
extern int    PendingExpiration = 2;//Pending expiration after xx hours
//--Internal variables
double PriceB,PriceS,StopB,StopS,
       TakeB,TakeS,_points,PT,Lots;
int LotDigits;
datetime _e = 0;
int Ticket  = 0;
//--
int OnInit()
  {
//--Determine digits
   _points=MarketInfo(Symbol(),MODE_POINT);
//--
   if(Digits==5 || Digits==3)
      PT = _points*10;
   else
      PT = _points;
//--
   return(INIT_SUCCEEDED);
  }
//--
void OnDeinit(const int reason)
  {

  }
//--
void OnTick()
  {
//If trade allowed and no positions exists by any chart - open a new set of grid orders
   if(IsTradeAllowed() && !IsTradeContextBusy())
     {
      if(PosSelect()==0)
        {
         GridPos(PriceDistance,TakeProfit,StopLoss);//Place grid
        }
      return;
     }
  }
///////////////////////////////////////////////////////////
//Grid order send function
void GridPos(double _Dist,double _Take,double _Stop)
  {
   int i;
   _e=TimeCurrent()+PendingExpiration*60*60;
//--
   for(i=0; i<GridOrders; i++)
     {
      PriceB = NormalizeDouble(Ask+(_Dist*PT)+(i*GridStep*PT),Digits);
      TakeB  = PriceB + _Take * PT;
      StopB  = PriceB - _Stop * PT;
      Ticket=OrderSend(Symbol(),OP_BUYSTOP,LotSize(),PriceB,3,StopB,TakeB,EaComment,MagicNumber,_e,Green);
      //--
      PriceS = NormalizeDouble(Bid-(_Dist*PT)-(i*GridStep*PT),Digits);
      TakeS  = PriceS - _Take * PT;
      StopS  = PriceS + _Stop * PT;
      Ticket=OrderSend(Symbol(),OP_SELLSTOP,LotSize(),PriceS,3,StopS,TakeS,EaComment,MagicNumber,_e,Red);
     }
   if(Ticket<1)
     {
      Print("Order send error - errcode: ",GetLastError());
      return;
     }
   else
     {
      Print("Grid placed successfully!");
     }
   return;
  }
//////////////////////////////////////////////////////////
//PositionSelector - Determines open positions
int PosSelect()
  {
   int posi=0;
   for(int k = OrdersTotal() - 1; k >= 0; k--)
     {
      if(!OrderSelect(k, SELECT_BY_POS))
        {
         Print("Order pos selection failed - errcode: ",GetLastError());
        }
      if(OrderSymbol()!=Symbol()&&OrderMagicNumber()!=MagicNumber)
        {
         continue;
        }
      if(OrderCloseTime() == 0 && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType() == OP_BUY)
            posi = 1; //Long position
         if(OrderType() == OP_SELL)
            posi = -1; //Short positon
         if(OrderType() == OP_BUYSTOP)
            posi = 1; //Pending Long position
         if(OrderType() == OP_SELLSTOP)
            posi = -1; //Pending Short positon
        }
     }
   return(posi);
  }
////////////////////////////////////////////////////////////
//Lots size calculation
double LotSize()
  {
 //  if(MM == true)
 //    { Lots = MathMin(MathMax((MathRound((AccountFreeMargin()*Risk/1000/100)
 //      /MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
 //      MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));}
 //  else
 //    { 
      Lots = MathMin(MathMax((MathRound(StaticLot/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),
      MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
 //    }

   return(Lots);
  }
//+----------------End of Grid Template EA-------------------+
