
#property strict

extern int     interval          = 0;                               //Interval
extern double Lots = 0.01;// Lot
extern int SL = 70;//SL
extern int TP = 40;//TP
extern int MagicNumber = 9010008;//Magic
extern int TrailingStop = 30;//Trailing Stop
extern int TrailingStep = 3;//Trailing Step
extern string Comments = "9010008";//Comments
extern int Slippage = 3;//Slippage
extern bool OnlyOneOpenedPos = true;//Only one pos per bar
extern bool AutoDigits = true;// Autodigits
extern datetime ExpDateHours=60; //  variable to determine order's expiration time in hours

extern int          RenkoBoxSize = 1;                 //Renko box size 
double RenkoStartPrice = 0;
double RenkoMaxPrice = 0;
double RenkoMinPrice = 100;


int periodBIG = PERIOD_H4;
int periodSMALL = PERIOD_M30;
int periodTRADE = PERIOD_M5;

double   buyPrice,//define BuyStop price
buyTP,      //Take Profit BuyStop
buySL,      //Stop Loss BuyStop
sellPrice,  //define SellStop price
sellTP,     //Take Profit SellStop
sellSL;     //Stop Loss SellStop

double   open1BIG,//first candle Open price
open2BIG,    //second candle Open price
close1BIG,   //first candle Close price
close2BIG,   //second candle Close price
low1BIG,     //first candle Low price
low2BIG,     //second candle Low price
high1BIG,    //first candle High price
high2BIG;    //second candle High price

double   open1SMALL,//first candle Open price
open2SMALL,    //second candle Open price
close1SMALL,   //first candle Close price
close2SMALL,   //second candle Close price
low1SMALL,     //first candle Low price
low2SMALL,     //second candle Low price
high1SMALL,    //first candle High price
high2SMALL,   //second candle High price
open0SMALL,
close0SMALL,
low0SMALL,
high0SMALL;

double   open1TRADE,//first candle Open price
open2TRADE,    //second candle Open price
close1TRADE,   //first candle Close price
close2TRADE,   //second candle Close price
low1TRADE,     //first candle Low price
low2TRADE,     //second candle Low price
high1TRADE,    //first candle High price
high2TRADE;    //second candle High price



string colorBIG = "9010008";
string colorSMALL = "9010008";
datetime _ExpDate=0; // local variable to determine order's expiration time 


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//check hikenashi color on H4
   double   _bid     = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits); //define a lower price 
   double   _ask     = NormalizeDouble(MarketInfo(Symbol(), MODE_ASK), Digits); //define an upper price
   double   _point   = MarketInfo(Symbol(), MODE_POINT);
   
   
   int orderexists = 0;
   
   int buysignal1 = 0;
   int sellsignal1 = 0;
   
   int buysignal2 = 0;
   int sellsignal2 = 0;
   
//--- define prices of necessary bars
   open1BIG        = NormalizeDouble(iOpen(Symbol(), periodBIG, 1), Digits);
   open2BIG        = NormalizeDouble(iOpen(Symbol(), periodBIG, 2), Digits);
   close1BIG       = NormalizeDouble(iClose(Symbol(), periodBIG, 1), Digits);
   close2BIG       = NormalizeDouble(iClose(Symbol(), periodBIG, 2), Digits);
   low1BIG         = NormalizeDouble(iLow(Symbol(), periodBIG, 1), Digits);
   low2BIG         = NormalizeDouble(iLow(Symbol(), periodBIG, 2), Digits);
   high1BIG        = NormalizeDouble(iHigh(Symbol(), periodBIG, 1), Digits);
   high2BIG        = NormalizeDouble(iHigh(Symbol(), periodBIG, 2), Digits);
   
   //--- define prices of necessary bars
   open0SMALL        = NormalizeDouble(iOpen(Symbol(), periodSMALL, 0), Digits);
   close0SMALL       = NormalizeDouble(iClose(Symbol(), periodSMALL, 0), Digits);
   low0SMALL         = NormalizeDouble(iLow(Symbol(), periodSMALL, 0), Digits);
   high0SMALL        = NormalizeDouble(iHigh(Symbol(), periodSMALL, 0), Digits);
   open1SMALL        = NormalizeDouble(iOpen(Symbol(), periodSMALL, 1), Digits);
   open2SMALL        = NormalizeDouble(iOpen(Symbol(), periodSMALL, 2), Digits);
   close1SMALL       = NormalizeDouble(iClose(Symbol(), periodSMALL, 1), Digits);
   close2SMALL       = NormalizeDouble(iClose(Symbol(), periodSMALL, 2), Digits);
   low1SMALL         = NormalizeDouble(iLow(Symbol(), periodSMALL, 1), Digits);
   low2SMALL         = NormalizeDouble(iLow(Symbol(), periodSMALL, 2), Digits);
   high1SMALL        = NormalizeDouble(iHigh(Symbol(), periodSMALL, 1), Digits);
   high2SMALL        = NormalizeDouble(iHigh(Symbol(), periodSMALL, 2), Digits);
   
   //--- define prices of necessary bars
   open1TRADE        = NormalizeDouble(iOpen(Symbol(), periodTRADE, 1), Digits);
   open2TRADE        = NormalizeDouble(iOpen(Symbol(), periodTRADE, 2), Digits);
   close1TRADE       = NormalizeDouble(iClose(Symbol(), periodTRADE, 1), Digits);
   close2TRADE       = NormalizeDouble(iClose(Symbol(), periodTRADE, 2), Digits);
   low1TRADE         = NormalizeDouble(iLow(Symbol(), periodTRADE, 1), Digits);
   low2TRADE         = NormalizeDouble(iLow(Symbol(), periodTRADE, 2), Digits);
   high1TRADE        = NormalizeDouble(iHigh(Symbol(), periodTRADE, 1), Digits);
   high2TRADE        = NormalizeDouble(iHigh(Symbol(), periodTRADE, 2), Digits);

   //--- Define prices for placing orders and stop orders
      buyPrice=NormalizeDouble(_ask,Digits); //define a price of order placing with intervals
     // buySL = NormalizeDouble(low1TRADE-interval * _point,Digits); //define a stop loss with interval
    //  buyTP=NormalizeDouble(buyPrice+TP*_point,Digits);       //define a take profit
      _ExpDate=TimeCurrent()+ExpDateHours*60*60;                   //a pending order expiration time calculation
   //--- We also calculate sell orders
      sellPrice=NormalizeDouble(_bid,Digits);
    //  sellSL=NormalizeDouble(high1+interval*_point,Digits);
   //   sellTP=NormalizeDouble(sellPrice-TP*_point,Digits);
   
   
   
   // BIG period heikenashi R or G
   double BIG_MA_1=iMA(NULL,periodBIG,20,0,MODE_EMA,PRICE_MEDIAN,1); // МА_2
   double closeBIG = (open1BIG + close1BIG +low1BIG+high1BIG)/4.0;
   double openBIG= (open2BIG + close2BIG)/2.0;
   if(closeBIG > openBIG){
      colorBIG = "GREEN";
   }
   if(closeBIG < openBIG){
      colorBIG = "RED";
   }
   
   if(closeBIG == openBIG){
      if(BIG_MA_1 > closeBIG ){ colorBIG = "RED";}
      if(BIG_MA_1 <= closeBIG){ colorBIG = "GREEN";}
   }
       
   // SMALL period heikenashi R or G
   double SMALL_MA_1=iMA(NULL,periodSMALL,20,0,MODE_EMA,PRICE_MEDIAN,1); // МА_1
   double closeSMALL = (open0SMALL + close0SMALL +low0SMALL+high0SMALL)/4.0;
   double openSMALL= (open1SMALL + close1SMALL)/2.0;
   if(closeSMALL > openSMALL){
      colorSMALL = "GREEN";
   }
   if(closeSMALL < openSMALL){
      colorSMALL = "RED";
   }
   
   if(closeSMALL == openSMALL){
      if(SMALL_MA_1 > closeSMALL ){ colorSMALL = "RED";}
      if(SMALL_MA_1 <= closeSMALL){ colorSMALL = "GREEN";}
   }
   //--------slope of MA calculation------------------------------------------------------------------------------------------
   double MA_1=iMA(NULL,periodSMALL,20,0,MODE_EMA,PRICE_MEDIAN,1); // МА_1
   double MA_2=iMA(NULL,periodSMALL,20,0,MODE_EMA,PRICE_MEDIAN,5); // МА_2
   
   string maslopeSMALL ="hi";
   
   if(MA_1 > MA_2){
      maslopeSMALL = "GREEN";
   }
   if(MA_1 <= MA_2){
      maslopeSMALL = "RED";
   }
   
   if(colorBIG==colorSMALL  && colorSMALL==maslopeSMALL){
   
      if(maslopeSMALL == "GREEN"){
            buysignal1 = 1;
            sellsignal1 = 0;
            
      }
      
         if(maslopeSMALL == "RED"){
            buysignal1 = 0;
            sellsignal1 = 1;
      }
   
   }
   buysignal2 = 1;
   sellsignal2 = 1;
   // check if order exists
   
   int  total=OrdersTotal();
   //Print("The total orders open =",   total);
   //--- it is important to enter the market correctly, but it is more important to exit it correctly...
   for(int cnt=0; cnt<total; cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {
                   Print(" buy order open RenkoMaxPrice, bid= ", RenkoMaxPrice," ",   _bid, " ",RenkoMaxPrice - _bid, " ", RenkoBoxSize*0.0020 );
                   Sleep(2000000000);
                  sellsignal2 = 0;
                  if(RenkoMaxPrice <= _bid){
                     RenkoMaxPrice = _bid;
                      Print(" buy order open RenkoMaxPrice= ", RenkoMaxPrice);
                     buysignal2 = 0;
                     orderexists = 1;
                  }
                  
                  if(RenkoMaxPrice > _bid){
                    double RenkoDiff = RenkoMaxPrice -_bid;
                    if (RenkoDiff >RenkoBoxSize*0.0020){
                                 if(!OrderClose(OrderTicket(),Lots,_bid,3,CLR_NONE)){
                                       Print("The order has errors while closing.",   GetLastError());
                                       orderexists = 1;
                                 }else{
                                       buysignal2 = 1;
                                       RenkoMaxPrice=0;  
                                       orderexists = 0;
                                                                      
                                 }
                    }else{
                     buysignal2 = 0;
                     orderexists = 1;
                    }
                  
                  }
           }
         else // go to short position
           {

                   Print(" sell order open RenkoMinPrice, bid= ", RenkoMinPrice," ",   _ask, " ",_ask - RenkoMinPrice, " ", RenkoBoxSize*0.0020 );
                   Sleep(2000000000);
                   buysignal2 = 0;
                  if(RenkoMinPrice >= _ask){
                     RenkoMinPrice = _ask;
                     sellsignal2 = 0;
                     orderexists = 1;
                  }
                  if(RenkoMinPrice < _ask){
                    double RenkoDiff = _ask - RenkoMinPrice;
                    if (RenkoDiff >RenkoBoxSize*0.0020){
                                 if(!OrderClose(OrderTicket(),Lots,_ask,3,CLR_NONE)){
                                       Print("The order has errors while closing.",   GetLastError());
                                       orderexists = 1;
                                 }else{
                                       sellsignal2 = 1;
                                       RenkoMinPrice=100;
                                       buysignal2 = 0;
                                       orderexists = 0;
                                 }
                    }else{
                     sellsignal2 = 0;
                     orderexists = 1;
                    }
                  
                  }



           }
        }
     }
     
        
   //check if order needs to be close
   
   // if so close order
   
   // check if buy signal exists and order does not exist
   
   //if so buy
   if( buysignal1 == 1 && buysignal2 == 1 && orderexists == 0){
   
       OrderOpenBuy(Symbol(),OP_BUY,Lots,_ask,Slippage,0,0,NULL,MagicNumber,_ExpDate,CLR_NONE);
       RenkoMaxPrice=_ask;
        buysignal1 =0;
        buysignal2 =0;
        sellsignal1 = 0;
        sellsignal2 = 0;
        orderexists = 1;
   }
   // check if sell signal exists and order does not exist
   
   //if so sell
   if( sellsignal1 == 1 && sellsignal2 == 1 && orderexists == 0){
   
        OrderOpenSell(Symbol(),OP_SELL,Lots,_bid,Slippage,0,0,NULL,MagicNumber,_ExpDate,CLR_NONE);
        RenkoMinPrice=_bid;
        buysignal1 =0;
        buysignal2 =0;
        sellsignal1 = 0;
        sellsignal2 = 0;
        orderexists = 1;
    } 
    
  } // end ontick()

//+---------------------------------------------------------------------------------------------------------------------+
//| The function opens or sets an order                                                                                 |
//| symbol      - symbol, at which a deal is performed.                                                                 |
//| cmd         - a deal Can have any value of trade operations.                                                        |
//| volume      - amount of lots.                                                                                       |
//| price       - Open price.                                                                                           |
//| slippage    - maximum price deviation for market buy or sell orders.         |
//| stoploss    - position close price when an unprofitability level is reached (0 if there is no unprofitability level)|
//| takeprofit  - position close price when a profitability level is reached (0 if there is no profitability level).    |
//| comment     - order comment. The last part of comment can be changed by the trade server.                           |
//| magic       - order magic number. Can be used as an identifier determined by user.                                  |
//| expiration  - pending order expiration time.                                                                        |
//| arrow_color - Opening arrow's color on the chart. If the parameter is missing or its value equals CLR_NONE          |
//|               then the opening arrow is not displayed on the chart.                                                 |
//+---------------------------------------------------------------------------------------------------------------------+
int OrderOpenBuy(string     OO_symbol,
               int        OO_cmd,
               double     OO_volume,
               double     OO_price,
               int        OO_slippage,
               double     OO_stoploss,
               double     OO_takeprofit,
               string     OO_comment,
               int        OO_magic,
               datetime   OO_expiration,
               color      OO_arrow_color)
  {
   int      result      = -1;    //result of opening an order
   int      Error       = 0;     //error when opening an order
   int      attempt     = 0;     //amount of performed attempts
   int      attemptMax  = 5;     //maximum amount of attempts
   bool     exit_loop   = false; //exit the loop
   string   lang=TerminalInfoString(TERMINAL_LANGUAGE);  //trading terminal language, for defining the language of the messages

//--- while loop
   while(!exit_loop)
     {
      result=OrderSend(OO_symbol,OO_cmd,OO_volume,OO_price,OO_slippage,OO_stoploss,OO_takeprofit,OO_comment,OO_magic,OO_expiration,OO_arrow_color); //attempt to open an order using the specified parameters
      //--- if there is an error when opening an order
      if(result<0)
        {
         Error = GetLastError();                                     //assign a code to an error
         switch(Error)                                               //error enumeration
           {                                                         //order closing error enumeration and an attempt to fix them
            case  2:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;                                         //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  3:
               RefreshRates();
               exit_loop = true;                                     //exit while
               break;                                                //exit switch   
            case  4:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  5:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch   
            case  6:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(5000);                                       //3 seconds of delay
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  8:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(7000);                                       //3 seconds of delay
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 64:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 65:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 128:
               Sleep(3000);
               RefreshRates();
               continue;                                             //exit switch
            case 129:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 130:
               exit_loop=true;                                       //exit while
               break;
            case 131:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 132:
               Sleep(10000);                                         //sleep for 10 seconds
               RefreshRates();                                       //update data
                                                                     //exit_loop = true;                                   //exit while
               break;                                                //exit switch
            case 133:
               exit_loop=true;                                       //exit while
               break;                                                //exit switch
            case 134:
               exit_loop=true;                                       //exit while
               break;                                                //exit switch
            case 135:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 136:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 137:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(2000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 138:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(1000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 139:
               exit_loop=true;
               break;
            case 141:
               Sleep(5000);
               exit_loop=true;
               break;
            case 145:
               exit_loop=true;
               break;
            case 146:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(2000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 147:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  OO_expiration=0;
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 148:
               exit_loop=true;
               break;
            default:
               Print("Error: ",Error);
               exit_loop=true; //exit while 
               break;          //other options 
           }
        }
      //--- if no errors detected
      else
        {
         Print("The order is successfully opened 111.", result);
         Error = 0;                                //reset the error code to zero
         Sleep(20000000);
         break;                                    //exit while
                                                   //errorCount =0;                          //reset the amount of attempts to zero
        }
     }
   return(result);
  }
//+---------------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------------+
//| The function opens or sets an order                                                                                 |
//| symbol      - symbol, at which a deal is performed.                                                                 |
//| cmd         - a deal Can have any value of trade operations.                                                        |
//| volume      - amount of lots.                                                                                       |
//| price       - Open price.                                                                                           |
//| slippage    - maximum price deviation for market buy or sell orders.         |
//| stoploss    - position close price when an unprofitability level is reached (0 if there is no unprofitability level)|
//| takeprofit  - position close price when a profitability level is reached (0 if there is no profitability level).    |
//| comment     - order comment. The last part of comment can be changed by the trade server.                           |
//| magic       - order magic number. Can be used as an identifier determined by user.                                  |
//| expiration  - pending order expiration time.                                                                        |
//| arrow_color - Opening arrow's color on the chart. If the parameter is missing or its value equals CLR_NONE          |
//|               then the opening arrow is not displayed on the chart.                                                 |
//+---------------------------------------------------------------------------------------------------------------------+
int OrderOpenSell(string     OO_symbol,
               int        OO_cmd,
               double     OO_volume,
               double     OO_price,
               int        OO_slippage,
               double     OO_stoploss,
               double     OO_takeprofit,
               string     OO_comment,
               int        OO_magic,
               datetime   OO_expiration,
               color      OO_arrow_color)
  {
   int      result      = -1;    //result of opening an order
   int      Error       = 0;     //error when opening an order
   int      attempt     = 0;     //amount of performed attempts
   int      attemptMax  = 5;     //maximum amount of attempts
   bool     exit_loop   = false; //exit the loop
   string   lang=TerminalInfoString(TERMINAL_LANGUAGE);  //trading terminal language, for defining the language of the messages
   
//--- while loop
   while(!exit_loop)
     {
      result=OrderSend(OO_symbol,OO_cmd,OO_volume,OO_price,OO_slippage,OO_stoploss,OO_takeprofit,OO_comment,OO_magic,OO_expiration,OO_arrow_color); //attempt to open an order using the specified parameters
      //--- if there is an error when opening an order
      if(result<0)
        {
         Error = GetLastError();                                     //assign a code to an error
         switch(Error)                                               //error enumeration
           {                                                         //order closing error enumeration and an attempt to fix them
            case  2:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;                                         //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  3:
               RefreshRates();
               exit_loop = true;                                     //exit while
               break;                                                //exit switch   
            case  4:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  5:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch   
            case  6:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(5000);                                       //3 seconds of delay
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  8:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(7000);                                       //3 seconds of delay
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 64:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 65:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 128:
               Sleep(3000);
               RefreshRates();
               continue;                                             //exit switch
            case 129:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 130:
               exit_loop=true;                                       //exit while
               break;
            case 131:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 132:
               Sleep(10000);                                         //sleep for 10 seconds
               RefreshRates();                                       //update data
                                                                     //exit_loop = true;                                   //exit while
               break;                                                //exit switch
            case 133:
               exit_loop=true;                                       //exit while
               break;                                                //exit switch
            case 134:
               exit_loop=true;                                       //exit while
               break;                                                //exit switch
            case 135:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 136:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 137:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(2000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 138:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(1000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 139:
               exit_loop=true;
               break;
            case 141:
               Sleep(5000);
               exit_loop=true;
               break;
            case 145:
               exit_loop=true;
               break;
            case 146:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(2000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 147:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  OO_expiration=0;
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 148:
               exit_loop=true;
               break;
            default:
               Print("Error: ",Error);
               exit_loop=true; //exit while 
               break;          //other options 
           }
        }
      //--- if no errors detected
      else
        {
         Print("The order is successfully opened 222.", result);
         Error = 0;                                //reset the error code to zero
          Sleep(20000000);
         break;                                    //exit while
                                                   //errorCount =0;                          //reset the amount of attempts to zero
        }
     }
   return(result);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+

