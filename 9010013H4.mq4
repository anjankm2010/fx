

bool New_Bar=false;                // Ôàêò íîâîãî áàðà  
                                
extern double StopLoss   =100;     // SL äëÿ îòêðûâàåìîãî îðäåðà
extern double TakeProfit =130;     // ÒÐ äëÿ îòêðûâàåìîãî îðäåðà

extern double MAp         =12;     // MA ïåðèîä
extern double MAs         =0;      // MA ñìåùåíèå
extern double MAm         =2;      // ÌÀ ìåòîä


extern double Lots       =1;     // Æåñòêî çàäàííîå êîëè÷åñòâî ëîòîâ
extern double Prots      =0.02;    // Ïðîöåíò ñâîáîäíûõ ñðåäñòâ


//--------------------------------------------------------------- 1 --
int start()
  {
   int
   Total,                           // Êîëè÷åñòâî îðäåðîâ â îêíå 
   Tip=-1,                          // Òèï âûáðàí. îðäåðà (B=0,S=1)
   Ticket;                          // Íîìåð îðäåðà
   double
   MA,                              // Çíà÷åí. ÌÀ
   Lot,                             // Êîëè÷. ëîòîâ â âûáðàí.îðäåðå
   Lts,                             // Êîëè÷. ëîòîâ â îòêðûâ.îðäåðå
   Min_Lot,                         // Ìèíèìàëüíîå êîëè÷åñòâî ëîòîâ
   Step,                            // Øàã èçìåíåíèÿ ðàçìåðà ëîòà
   Free,                            // Òåêóùèå ñâîáîäíûå ñðåäñòâà
   One_Lot,                         // Ñòîèìîñòü îäíîãî ëîòà
   Price,                           // Öåíà âûáðàííîãî îðäåðà
   SL,                              // SL âûáðàííîãî îðäåðà 
   TP;                              // TP âûáðàííîãî îðäåðà
   bool
   Cls_B=false,                     // Êðèòåðèé äëÿ çàêðûòèÿ  Buy
   Cls_S=false,                     // Êðèòåðèé äëÿ çàêðûòèÿ  Sell
   Opn_B=false,                     // Êðèòåðèé äëÿ îòêðûòèÿ  Buy
   Opn_S=false;                     // Êðèòåðèé äëÿ îòêðûòèÿ  Sell
//--------------------------------------------------------------- 2 --
   // Ó÷¸ò îðäåðîâ
   
   for(int i=1; i<=OrdersTotal(); i++)          // Öèêë ïåðåáîðà îðäåð
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // Åñëè åñòü ñëåäóþùèé
        {                                       // Àíàëèç îðäåðîâ:     
         Ticket=OrderTicket();                  // Íîìåð âûáðàíí. îðä.
         Tip   =OrderType();                    // Òèï âûáðàííîãî îðä.
         Price =OrderOpenPrice();               // Öåíà âûáðàíí. îðä.
         SL    =OrderStopLoss();                // SL âûáðàííîãî îðä.
         TP    =OrderTakeProfit();              // TP âûáðàííîãî îðä.
         Lot   =OrderLots();                    // Êîëè÷åñòâî ëîòîâ
        }
     }
//--------------------------------------------------------------- 3 --
   // Òîðãîâûå êðèòåðèè
   
   static datetime New_Time=0;                  // Âðåìÿ òåêóùåãî áàðà   
   New_Bar=false;                               // Íîâîãî áàðà íåò   
   if(New_Time!=Time[0])                        // Ñðàâíèâàåì âðåìÿ     
   {       
   New_Time=Time[0];                            // Òåïåðü âðåìÿ òàêîå      
   New_Bar=true;                                // Ïîéìàëñÿ íîâûé áàð     
   }
   
   MA=iMA(NULL,0,MAp,MAs,MAm,MODE_MAIN,0);      // Çàäàåì ÌÀ è ïàðàìåòðû
   
   if (Close[0]>MA && New_Bar==true)            // Åñëè öåíà çàêðûòèÿ áîëüøå ÌÀ è îáðàçîâàëñÿ íîâûé áàð...
     {                                          // 
      Opn_B=true;                               // ...Êðèòåðèé îòêð. Buy
      Cls_S=true;                               // Êðèòåðèé çàêð. Sell
     }
   if (Close[0]<MA && New_Bar==true)            // Åñëè öåíà çàêðûòèÿ ìåíüøå ÌÀ è îáðàçîâàëñÿ íîâûé áàð...
     {                                          // 
      Opn_S=true;                               // ...Êðèòåðèé îòêð. Sell
      Cls_B=true;                               // Êðèòåðèé çàêð. Buy
     }
//--------------------------------------------------------------- 4 --
   // Çàêðûòèå îðäåðîâ
   
   while(true)                                  // Öèêë çàêðûòèÿ îðä.
     {
      if (Tip==0 && Cls_B==true)                // Îòêðûò îðäåð Buy è åñòü êðèòåðèé çàêð 
        {                                       // 
         OrderClose(Ticket,Lot,Bid,2);          // Çàêðûòèå Buy
         return;                                // Âûõîä èç start()
        }

      if (Tip==1 && Cls_S==true)                // Îòêðûò îðäåð Sell è åñòü êðèòåðèé çàêð 
        {                                       //        
         OrderClose(Ticket,Lot,Ask,2);          // Çàêðûòèå Sell
         return;                                // Âûõîä èç start()
        }
      break;                                    // Âûõîä èç while
     }
//--------------------------------------------------------------- 5 --
   // Ñòîèìîñòü îðäåðîâ (åñëè ëîò óêàçàí êàê "0")
   
   RefreshRates();                                // Îáíîâëåíèå äàííûõ
   Min_Lot=MarketInfo(NULL,MODE_MINLOT);          // Ìèíèì. êîëè÷. ëîòîâ 
   Free   =AccountFreeMargin();                   // Ñâîáîäí ñðåäñòâà
   One_Lot=MarketInfo(NULL,MODE_MARGINREQUIRED);  // Ñòîèìîñòü 1 ëîòà
   Step   =MarketInfo(NULL,MODE_LOTSTEP);         // Øàã èçìåíåí ðàçìåðà

   if (Lots > 0)                                  // Åñëè çàäàíû ëîòû,òî 
      Lts =Lots;                                  // ñ íèìè è ðàáîòàåì 
   else                                           // % ñâîáîäíûõ ñðåäñòâ
      Lts=MathFloor(Free*Prots/One_Lot/Step)*Step;// Äëÿ îòêðûòèÿ

   if(Lts < Min_Lot) Lts=Min_Lot;                 // Íå ìåíüøå ìèíèìàëüí
   if (Lts*One_Lot > Free)                        // Ëîò äîðîæå ñâîáîäí.
     {
      Alert(" Íå õâàòàåò äåíåã íà ", Lts," ëîòîâ");
      return;                                     // Âûõîä èç start()
     }
//--------------------------------------------------------------- 6 --
   // Îòêðûòèå îðäåðîâ
   
   while(true)                                             // Öèêë çàêðûòèÿ îðä.
     {
      if (OrdersTotal()==0 && Opn_B==true)                 // Îòêðûòûõ îðä. íåò +
        {                                                  // êðèòåðèé îòêð. Buy
         SL=Bid - StopLoss*Point;                          // Âû÷èñëåíèå SL îòêð.
         TP=Bid + TakeProfit*Point;                        // Âû÷èñëåíèå TP îòêð.
         OrderSend(Symbol(),OP_BUY,Lts,Ask,2,SL,TP);       //Îòêðûòèå Buy
         return;                                           // Âûõîä èç start()
        }
      
      if (OrdersTotal()==0 && Opn_S==true)                  // Îòêðûòûõ îðä. íåò +
        {                                                   // êðèòåðèé îòêð. Sell
         SL=Ask + StopLoss*Point;                           // Âû÷èñëåíèå SL îòêð.
         TP=Ask - TakeProfit*Point;                         // Âû÷èñëåíèå TP îòêð.
         OrderSend(Symbol(),OP_SELL,Lts,Bid,2,SL,TP);       //Îòêðûòèå Sel
         return;                                            // Âûõîä èç start()
        }
      break;                                                // Âûõîä èç while
     }
//--------------------------------------------------------------- 9 --
   return;                                           // Âûõîä èç start()
  }


