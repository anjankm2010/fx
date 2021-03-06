
#property strict

input double _Lots = 0.01;// Lot
input int _SL = 20;//SL
input int _TP = 10;//TP
input int _MagicNumber = 5010008;//Magic
input int _TrailingStop = 7;//Trailing Stop
input int _TrailingStep = 3;//Trailing Step
input string _Comment = "5010008";//Comments
input int _Slippage = 3;//Slippage
input bool _OnlyOneOpenedPos = true;//Only one pos per bar
input bool _AutoDigits = true;// Autodigits
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

double OP_LOTS = 0.0;
// autodetect class for decimal places of current tool 
class CKDig
{
   public:
      CKDig(const bool useAutoDigits)
      {
         Set(useAutoDigits);
      }
      
      ~CKDig(void)
      {
      }
      
      uint Get(void)
      {
         return m_value;
      }
      
   private:      
      uint m_value;      
      
      void Set(const bool useAutoDigits)
      {
         m_value = 1;
         if (!useAutoDigits)
         {
            return;
         }
         
         if (Digits() == 3 || Digits() == 5)
         {
            m_value = 10;
         }
      }
};

CKDig *KDig;
#define K_DIG (KDig.Get())

datetime LAST_BUY_BARTIME = 0;
datetime LAST_SELL_BARTIME = 0;
// ---

// ---
void OnInit()
{
	// ---
	get_lots_by_input();
	// ---
	KDig  = new CKDig(_AutoDigits);
	// ---
}

// ---
void OnDeinit(const int reason)
{
	// ---
	// ---
	if(CheckPointer(KDig))
	{
	   delete KDig;
	}
	// ---
}

// ---
void OnTick()
{
	//  closing a deal
	if(find_orders(_MagicNumber))
	{
		if(cl_buy_sig())
		{
			cbm(_MagicNumber, _Slippage, OP_BUY);
		}
		if(cl_sell_sig())
		{
			cbm(_MagicNumber, _Slippage, OP_SELL);
		}
	}
	
	// opening a deal
	if(!find_orders(_MagicNumber, (_OnlyOneOpenedPos ? -1 : OP_BUY)))
	{
		if(op_buy_sig() && LAST_BUY_BARTIME != iTime(Symbol(), Period(), 0))
		{
			LAST_BUY_BARTIME = iTime(Symbol(), Period(), 0);
			open_positions(OP_BUY, OP_LOTS);	
		}
	}
	// ---
	if(!find_orders(_MagicNumber, (_OnlyOneOpenedPos ? -1 : OP_SELL)))
	{
		if(op_sell_sig() && LAST_SELL_BARTIME != iTime(Symbol(), Period(), 0))
		{
			LAST_SELL_BARTIME = iTime(Symbol(), Period(), 0);
			open_positions(OP_SELL, OP_LOTS);	
		}
	}
	// ---
	T_SL();
}

// ---

// ---
// ---
void get_lots_by_input() 
{
//  volume assignment by input parameter 
  OP_LOTS = _Lots;
  double MinLot = MarketInfo(Symbol(),MODE_MINLOT);
  double MaxLot = MarketInfo(Symbol(),MODE_MAXLOT);
  double LotStep = MarketInfo(Symbol(),MODE_LOTSTEP);

  if (OP_LOTS < MinLot) OP_LOTS = MinLot;
  if (OP_LOTS > MaxLot) OP_LOTS = MaxLot;
}

// ---
// ---
bool find_orders(int magic = -1, int type = -1, int time = -1, string symb = "NULL", double price = -1, double lot = -1)
{
	// open order search function | 
// returns true if at least one order with suitable parameters is found
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			break;
		if (((OrderType() == type) || (type == -1))
			&& ((OrderMagicNumber() == magic) || (magic == -1))
			&& ((OrderSymbol() == symb) || (symb == "NULL" && OrderSymbol() == Symbol()))
			&& ((OrderOpenTime() >= time) || (time == -1))
			&& ((OrderLots() == lot) || (lot == -1))
			&& ((NormalizeDouble(OrderOpenPrice(), Digits) == NormalizeDouble(price, Digits)) || (price == -1)))
		{
			return (true);
			break;
		}
	}
	return (false);
}

// ---
string Market_Err_To_Str(int errCode)
{
	// error code decoding function 
// function covers only trading error codes
	string errText;
	switch (errCode)
	{
	case 0:
		errText = "0--" + _MagicNumber;
		break;
	case 1:
		errText = "1--"+ _MagicNumber;
		break;
	case 2:
		errText = "2--"+ _MagicNumber;
		break;
	case 3:
		errText = "3--"+ _MagicNumber;
		break;
	case 4:
		errText = "4--"+ _MagicNumber;
		break;
	case 5:
		errText = "5--"+ _MagicNumber;
		break;
	case 6:
		errText = "6--"+ _MagicNumber;
		break;
	case 7:
		errText = "7--"+ _MagicNumber;
		break;
	case 8:
		errText = "8--"+ _MagicNumber;
		break;
	case 9:
		errText = "9--"+ _MagicNumber;
		break;
	case 64:
		errText = "64--"+ _MagicNumber;
		break;
	case 65:
		errText = "65--"+ _MagicNumber;
		break;
	case 128:
		errText = "128--"+ _MagicNumber;
		break;
	case 129:
		errText = "129--"+ _MagicNumber;
		break;
	case 130:
		errText = "130--"+ _MagicNumber;
		break;
	case 131:
		errText = "131--"+ _MagicNumber;
		break;
	case 132:
		errText = "132--"+ _MagicNumber;
		break;
	case 133:
		errText = "133--"+ _MagicNumber;
		break;
	case 134:
		errText = "134--"+ _MagicNumber;
		break;
	case 135:
		errText = "135--"+ _MagicNumber;
		break;
	case 136:
		errText = "136--"+ _MagicNumber;
		break;
	case 137:
		errText = "137--"+ _MagicNumber;
		break;
	case 138:
		errText = "138--"+ _MagicNumber;
		break;
	case 139:
		errText = "139--"+ _MagicNumber;
		break;
	case 140:
		errText = "140--"+ _MagicNumber;
		break;
	case 141:
		errText = "141--"+ _MagicNumber;
		break;
	case 145:
		errText = "145--"+ _MagicNumber;
		break;
	case 146:
		errText = "146--"+ _MagicNumber;
		break;
	case 147:
		errText = "147--"+ _MagicNumber;
		break;
	case 148:
		errText = "148--"+ _MagicNumber;
		break;
	case 4000:
		errText = "4000--"+ _MagicNumber;
		break;
	case 4001:
		errText = "4001--"+ _MagicNumber;
		break;
	case 4002:
		errText = "4002--"+ _MagicNumber;
		break;
	case 4003:
		errText = "4003--"+ _MagicNumber;
		break;
	case 4004:
		errText = "4004--"+ _MagicNumber;
		break;
	case 4005:
		errText = "4005--"+ _MagicNumber;
		break;
	case 4006:
		errText = "4006--"+ _MagicNumber;
		break;
	case 4007:
		errText = "4007--"+ _MagicNumber;
		break;
	case 4008:
		errText = "4008--"+ _MagicNumber;
		break;
	case 4009:
		errText = "4009--"+ _MagicNumber;
		break;
	case 4010:
		errText = "4010--"+ _MagicNumber;
		break;
	case 4011:
		errText = "4011--"+ _MagicNumber;
		break;
	case 4012:
		errText = "4012--"+ _MagicNumber;
		break;
	case 4013:
		errText = "4013--"+ _MagicNumber;
		break;
	case 4014:
		errText = "4014--"+ _MagicNumber;
		break;
	case 4015:
		errText = "4015--"+ _MagicNumber;
		break;
	case 4016:
		errText = "4016--"+ _MagicNumber;
		break;
	case 4017:
		errText = "4017--"+ _MagicNumber;
		break;
	case 4018:
		errText = "4018--"+ _MagicNumber;
		break;
	case 4019:
		errText = "4019--"+ _MagicNumber;
		break;
	case 4020:
		errText = "4020--"+ _MagicNumber;
		break;
	case 4021:
		errText = "4021--"+ _MagicNumber;
		break;
	case 4022:
		errText = "4022--"+ _MagicNumber;
		break;
	case 4050:
		errText = "4050--"+ _MagicNumber;
		break;
	case 4051:
		errText = "4051--"+ _MagicNumber;
		break;
	case 4052:
		errText = "4052--"+ _MagicNumber;
		break;
	case 4053:
		errText =  "4053--"+ _MagicNumber;
		break;
	case 4054:
		errText = "4054--"+ _MagicNumber;
		break;
	case 4055:
		errText = "4055--"+ _MagicNumber;
		break;
	case 4056:
		errText = "4056--"+ _MagicNumber;
		break;
	case 4057:
		errText = "4057--"+ _MagicNumber;
		break;
	case 4058:
		errText = "4058--"+ _MagicNumber;
		break;
	case 4059:
		errText = "4059--"+ _MagicNumber;
		break;
	case 4060:
		errText = "4060--"+ _MagicNumber;
		break;
	case 4061:
		errText = "4061--"+ _MagicNumber;
		break;
	case 4062:
		errText = "4062--"+ _MagicNumber;
		break;
	case 4063:
		errText = "4063--"+ _MagicNumber;
		break;
	case 4064:
		errText = "4064--"+ _MagicNumber;
		break;
	case 4065:
		errText = "4065--"+ _MagicNumber;
		break;
	case 4066:
		errText = "4066--"+ _MagicNumber;
		break;
	case 4067:
		errText = "4067--"+ _MagicNumber;
		break;
	case 4099:
		errText = "4099--"+ _MagicNumber;
		break;
	case 4100:
		errText = "4100--"+ _MagicNumber;
		break;
	case 4101:
		errText = "4101--"+ _MagicNumber;
		break;
	case 4102:
		errText = "4102--"+ _MagicNumber;
		break;
	case 4103:
		errText = "4103--"+ _MagicNumber;
		break;
	case 4104:
		errText = "4104--"+ _MagicNumber;
		break;
	case 4105:
		errText = "4105--"+ _MagicNumber;
		break;
	case 4106:
		errText = "4106--"+ _MagicNumber;
		break;
	case 4107:
		errText = "4107--"+ _MagicNumber;
		break;
	case 4108:
		errText = "4108--"+ _MagicNumber;
		break;
	case 4109:
		errText = "4109--"+ _MagicNumber;
		break;
	case 4110:
		errText = "4110--"+ _MagicNumber;
		break;
	case 4111:
		errText = "4111--"+ _MagicNumber;
		break;
	case 4200:
		errText = "4200--"+ _MagicNumber;
		break;
	case 4201:
		errText = "4201--"+ _MagicNumber;
		break;
	case 4202:
		errText = "4202--"+ _MagicNumber;
		break;
	case 4203:
		errText = "4203--"+ _MagicNumber;
		break;
	case 4204:
		errText = "4204--"+ _MagicNumber;
		break;
	case 4205:
		errText = "4205--"+ _MagicNumber;
		break;
	case 4206:
		errText = "4206--"+ _MagicNumber;
		break;
	default:
		errText = "default"+ _MagicNumber;
	}
	// ---
	return (errText);
}

// ---
void open_positions(int signal, double lot, double price = 0.0, string symb = "NONE", int mode = 0)
{
	// order opening function 
	RefreshRates();
	// ---
	int symbDigits = 0;
	string _symb = symb;
	// ---
	if (_symb == "NONE")
	{
		symbDigits = Digits;
		_symb = Symbol();
	}
	else
		symbDigits = int(MarketInfo(_symb, MODE_DIGITS));
	// ---
	if (signal == OP_BUY)
		price = NormalizeDouble(MarketInfo(_symb, MODE_ASK), symbDigits); // opening price for purchases
	if (signal == OP_SELL)
		price = NormalizeDouble(MarketInfo(_symb, MODE_BID), symbDigits); // closing price for purchases
	// ---
	int err = 0;
	for (int i = 0; i <= 5; i++)
	{
	   RefreshRates();
	   // ---
	      Alert("price: "  + price);
	      Alert("signal: "  + signal);
	      Alert("ask -- buy "  +  NormalizeDouble(MarketInfo(_symb, MODE_ASK), symbDigits));
	      Alert("bid -- sell "  + NormalizeDouble(MarketInfo(_symb, MODE_BID), symbDigits));   
	      
		int ticket = OrderSend(_symb, // symbol
			signal, // type order
			lot, // volyme
			NormalizeDouble(price, symbDigits), // opening price
			_Slippage * KDig.Get(), //level of allowable requote
			0, // Stop Loss
			0, // Take Profit
			_Comment, // comments
			_MagicNumber, // magic
			0, //expiration date (used in pending orders)
			CLR_NONE); //the color of the arrow on the chart (CLR_NONE - the arrow is not drawn)
		// ---
		if (ticket != -1)
		{
			err = 0;
			// ---
			if (!IsTesting())
				Sleep(1000);
			// ---
			RefreshRates();
			// ---
			if(_SL != 0 || _TP != 0)
			{
				for (int tryModify = 0; tryModify <= 5; tryModify++)
				{
					RefreshRates();
					// ---
					if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
					{
						double sl = NormalizeDouble(get_sl(_SL * KDig.Get(), signal, price, _symb), symbDigits);
						double tp = NormalizeDouble(get_tp(_TP * KDig.Get(), signal, price, _symb), symbDigits);
						// ---
						if (sl != 0 || tp != 0)
   						if (OrderModify(OrderTicket(), OrderOpenPrice(), sl, tp, OrderExpiration()))
   							break;
						// ---
						err = GetLastError(); // get the error code of the modification
					}
					// ---
					if (!IsTesting())
						Sleep(tryModify*1000);
				}
				// ---
				if (err != 0)
					Alert("Billing error SL/TP: " + Market_Err_To_Str(err));
			}
			// ---
			break;
		}
		else
		{
			err = GetLastError(); //get the error code opening

			if (err == 0)
				break;
			// ---
			i++;
			// ---
			if (!IsTesting())
				Sleep(i*500); // in case of an error, pause before a new attempt.

		}
	}
	// ---
	if (err != 0)
	{
		if(signal == OP_BUY)
			LAST_BUY_BARTIME = 0;
		if(signal == OP_SELL)
			LAST_SELL_BARTIME = 0;
		Alert("Open error: "  + Market_Err_To_Str(err)); // if there is an error, we display the message
	}
}

// ---
double get_tp(int tp_value, int type, double price = 0.0, string symb = "NONE")
{
// Take Profit calculation function for orders 
	double _price = price;
	string _symb = symb;
	// ---
	if (_symb == "NONE")
		_symb = Symbol();
	int symbDigits = int(MarketInfo(_symb, MODE_DIGITS));
	// ---
	if (_price == 0)
	{
		if (type == OP_BUY)
			_price = NormalizeDouble(MarketInfo(_symb, MODE_ASK), symbDigits);
		// ---
		if (type == OP_SELL)
			_price = NormalizeDouble(MarketInfo(_symb, MODE_BID), symbDigits);
	}
	// ---
	if (tp_value > 0)
	{
		if (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP)
			return NormalizeDouble(_price + tp_value * MarketInfo(_symb, MODE_POINT), symbDigits);
		// ---
		if (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP)
			return NormalizeDouble(_price - tp_value *  MarketInfo(_symb, MODE_POINT), symbDigits);
	}
	// ---
	return 0.0;
}

// ---
double get_sl(int sl_value, int type, double price = 0.0, string _symb = "NONE")
{
// MQL4 | Stop Loss calculation function for orders using a fixed SL value
	if (_symb == "NONE")
		_symb = Symbol();
	int symbDigits = int(MarketInfo(_symb, MODE_DIGITS));
	double symbPoint = MarketInfo(_symb, MODE_POINT);
	// ---
	if (price == 0.0)
	{
		if (type == OP_BUY)
			price = NormalizeDouble(MarketInfo(_symb, MODE_ASK), symbDigits);
		if (type == OP_SELL)
			price = NormalizeDouble(MarketInfo(_symb, MODE_BID), symbDigits);
	}
	// ---
	if (sl_value > 0)
	{
		if (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP)
			return NormalizeDouble(price - sl_value * symbPoint, symbDigits);
		if (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP)
			return NormalizeDouble(price + sl_value * symbPoint, symbDigits);
	}
	// ---
	return 0.0;
}

// ---
bool close_by_ticket(const int ticket, const int slippage)
{
	/*
MQL4 | function of closing a transaction by its number (ticket) | 
When closing a market order, the level of maximum allowable slippage is taken into account (slipage)
 */
	if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) //we choose an order by ticket
{
	   return false;
	}
	
	int err = 0;
	
	for (int i = 0; i < 5; i++)
	{
	   ResetLastError();
	   
		RefreshRates();
		
		double price = 0.0;
		
		if (OrderType() == OP_BUY)
		{
			price = NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_BID), (int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS));
		}
		if (OrderType() == OP_SELL)
		{
			price = NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK), (int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS));
		}
		// if a market order is closing it; if a pending order is deleted		   
	   bool result = false;
	   
		if (OrderType() <= OP_SELL) 
		{
			result = OrderClose(OrderTicket(), OrderLots(), price, slippage * KDig.Get(), clrNONE);
	   }
		else
		{
			result = OrderDelete(OrderTicket());
		}
		
		if (result) // if closing or deleting is successful, return true and exit the loop
		{
			return (true);
		}
		
		err = GetLastError();
		
		if (err != 0)
		{
			Print("Error of close_by_ticket() #" + (string)err + ": " + Market_Err_To_Str(err)); // if there is an error, we decrypt the log
		}
		
		Sleep(300 * i);
	}
	return (false);
}

// ---
bool cbm(int magic, int slippage, int type)
{
	/*
close by magic (closing all orders of this type with this MagicNumber)
Take into account the maximum allowed slip (slipage)
The close_by_ticket function is used.
*/
	int n = 0;
	RefreshRates();
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			break;
		if ((OrderType() == type) && (OrderMagicNumber() == magic) && (Symbol() == OrderSymbol()))
		{
			close_by_ticket(OrderTicket(), slippage); // closing a deal
			n++; // we increase the counter of closed transactions
		}
	}
	if (n > 0) // if closing attempts were greater than 0, the function returns true
			return (true);
	return (false);
}

double e_High1()
{
	return High[1];
}
double e_Low1()
{
	return Low[1];
}
double e_High()
{
	return High[0];
}
double e_Low()
{
	return Low[0];
}
double e_Close()
{
	return Close[0];
}
double e_Open()
{
	return Open[0];
}
// ---
bool op_buy_sig()
{
	if(((e_High() - e_Low()) > ((e_High1() - e_Low1()) * 2)) && (e_Close() > e_Open()))
		return true;
	// ---
	return false;
}
// ---
bool op_sell_sig()
{
	if(((e_High() - e_Low()) > ((e_High1() - e_Low1()) * 2)) && (e_Close() < e_Open()))
		return true;
	// ---
	return false;
}
// ---
bool cl_buy_sig()
{
	return false;
}
// ---
bool cl_sell_sig()
{
	return false;
}
// ---
void T_SL()
{
	// Trailing Stop Loss function 
// work logic is identical to the usual trailing stop loss
	if (_TrailingStop <= 0)
		return; //if trailing stop loss is disabled, then exit the function
	for (int i = 0; i < OrdersTotal(); i++)
	{
		if (!(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)))
			continue;
		if (OrderSymbol() != Symbol())
			continue;
		if (OrderMagicNumber() != _MagicNumber)
			continue;
		if (OrderType() == OP_BUY)
		{
			if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) > NormalizeDouble(_TrailingStop * K_DIG * Point, Digits))
			{
				if (NormalizeDouble(OrderStopLoss(), Digits) < NormalizeDouble(Bid - (_TrailingStop*K_DIG + _TrailingStep*K_DIG - 1)*Point, Digits) || OrderStopLoss() == 0)
				{
					if(OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - _TrailingStop*K_DIG*Point, Digits), OrderTakeProfit(), OrderExpiration()))
					{
					}
				}
		   }
		}
		else if (OrderType() == OP_SELL)
		{
			if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) > NormalizeDouble(_TrailingStop * K_DIG * Point, Digits))
			{
				if (NormalizeDouble(OrderStopLoss(), Digits) > NormalizeDouble(Ask + (_TrailingStop*K_DIG + _TrailingStep*K_DIG - 1)*Point, Digits) || OrderStopLoss() == 0)
				{
					if(OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + _TrailingStop*K_DIG*Point, Digits), OrderTakeProfit(), OrderExpiration()))
					{
					}
				}
			}
		}
	}
}
