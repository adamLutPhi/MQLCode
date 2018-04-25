//+------------------------------------------------------------------+
//|                                                MA_Crossover2.mq4 |
//|                                 Copyright 2017, Eng. Ahmad Lutfi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Eng. Ahmad Lutfi"
#property link      "https://www.mql5.com"
#property version   "1.25"
#property strict

extern int maPeriod1 = 37;
extern int maPeriod2 = 122;
extern int maModeType1 = 0;
extern int maModeType2 = 0;
extern  double Lots = 1;
extern double LotMul = 1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


datetime PreviousBar;      // record the candle/bar time
bool NewBar() //Working!!!!
{
   if(PreviousBar<Time[0])
   {
      PreviousBar = Time[0];
      return(true);
   }
   else
   {
      return(false);
   }
   return(false);    // in case if - else statement is not executed
}
int OnInit()
  {
//---
   Print("Initialized!");
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
 if(NewBar())
{
//---
Print("started");
static double size = Lots* LotMul;
//Print("lot Size ",size," lots ",Lots," LotMul ",LotMul);
static int ticket = 0;

  double CurrentMa1 =  iMA(Symbol(),PERIOD_CURRENT,maPeriod1,0,maModeType1,PRICE_TYPICAL,1);
  double CurrentMa2 =  iMA(Symbol(),PERIOD_CURRENT,maPeriod2,0,maModeType1,PRICE_TYPICAL,1);
  
  double LastMa1 = iMA(Symbol(),PERIOD_CURRENT,maPeriod1,0,maModeType2,PRICE_TYPICAL,2);
  double LastMa2 = iMA(Symbol(),PERIOD_CURRENT,maPeriod2,0,maModeType2,PRICE_TYPICAL,2);
  
  
    
   
  
  //---
  //if short Perod ma was below the fast Perod ma
  //but now above the fast Perod ma
  
  if(LastMa1 <= LastMa2 &&CurrentMa1 >= CurrentMa2)
  {
       //Close Open Sells
  //Close Open Buys
        Print("lets close all buys...");
     closeAllbuys();
   //
  // closeAllSells();
   //Open Sell
  //ticket =  openSell(Lots) ;
  //   if( OrdersTotal()<1)
  // {
    Print("Orders less than 1, check 4 Sell...");
    //  ticket = OrderSend(Symbol(), OP_BUY, LotMul, Ask, 10, NormalizeDouble(Bid-StopLoss*Point,Digits), NormalizeDouble(Bid+TakeProfit*Point,Digits), "Set by SimpleSystem");
      ///
   //  ticket = OrderSend(Symbol(), OP_SELL, NormalizeDouble(LotMul,2)/* size \  NormalizeDouble( size,2)*/,NormalizeDouble( Bid,Digits) /*   NormalizeDouble( Bid*Point,Digits)*/, 10, NULL,NULL,NULL,0,0,Red); //1,Digits
   //  Print("Sell  Bid @",NormalizeDouble( Bid,Digits));
     ///
          ticket = OrderSend(Symbol(), OP_SELL, NormalizeDouble(LotMul,2)/* size \  NormalizeDouble( size,2)*/,NormalizeDouble( Bid,Digits) /*   NormalizeDouble( Bid*Point,Digits)*/, 10, NULL,NULL,NULL,0,0,Red); //1,Digits
     Print("Sell  Bid @",NormalizeDouble( Bid,Digits));
   

   ///

       //ticket = OrderSend(Symbol(), OP_BUY, size/* NormalizeDouble( size,2)*/, NormalizeDouble(Ask*Point,Digits), 10,NULL, NULL,NULL,0,0,Blue); //1,Digits
//}
//else{ ticket = -1;}
  }//END IF
  ///---
    if(LastMa1 >= LastMa2 &&
    CurrentMa1 < CurrentMa2)
   {
   
           Print("lets close all Sells...");
      closeAllSells();

//if( OrdersTotal()<1)
//{
 Print("Orders less than 1, check 4 Buy...");
        ticket = OrderSend(Symbol(), OP_BUY, NormalizeDouble( LotMul,2),  NormalizeDouble(Ask,Digits) /* NormalizeDouble(Ask*Point,Digits)*/, 10,NULL, NULL,NULL,0,0,Blue); //1,Digits
   Print("Buy Ask @",NormalizeDouble(Ask,Digits));
  
   ///
  //  }
    //else{ ticket = -1;}
   }
 }
  ///---
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+





bool closeAllbuys()
{
static int Slippage = 10; bool tikka = false; bool Ans= false;
int PositionIndex;    //  <-- this variable is the index used for the loop

int TotalNumberOfOrders;   //  <-- this variable will hold the number of orders currently in the Trade pool

TotalNumberOfOrders = OrdersTotal();    // <-- we store the number of Orders in the variable

if(TotalNumberOfOrders>0)
   {
for(PositionIndex = TotalNumberOfOrders - 1; PositionIndex >= 0 ; PositionIndex --)  //  <-- for loop to loop through all Orders . .   COUNT DOWN TO ZERO !
   {
      if( ! OrderSelect(PositionIndex, SELECT_BY_POS, MODE_TRADES) ) continue;   // <-- if the OrderSelect fails advance the loop to the next PositionIndex
      
      if( //OrderMagicNumber() == MagicNo  &&      // <-- does the Order's Magic Number match our EA's magic number ? 
         OrderSymbol() == Symbol()         // <-- does the Order's Symbol match the Symbol our EA is working on ? 
         && OrderType() == OP_BUY    )       // <-- Close Buy Orders       //
      
         if ( ! OrderClose( OrderTicket(), OrderLots(), OrderClosePrice(), Slippage ) )               // <-- try to close the order
         {
           // Print("Order Close failed, order number: ", OrderTicket(), " Error: ", GetLastError() );  // <-- if the Order Close failed print some helpful information
             tikka = false;break;
         }
          else{  tikka = true;}//Success in Closing A BUY Order
         //bool here!
   } //  end of For loop
    //  if(!tikka)
     //  {
      Ans = tikka;  //THis ONLY works with just One Buy Order at a Time! otherwise, use dynamic array
      
      // }
   }
   return (Ans);
}

//+------------------------------------------------------------------+


bool closeAllSells()
{
static int Slippage = 10;  bool tikka = false; bool Ans= false;
int PositionIndex;    //  <-- this variable is the index used for the loop

int TotalNumberOfOrders;   //  <-- this variable will hold the number of orders currently in the Trade pool

TotalNumberOfOrders = OrdersTotal();    // <-- we store the number of Orders in the variable
if(TotalNumberOfOrders>0)
   {
   for(PositionIndex = TotalNumberOfOrders - 1; PositionIndex >= 0 ; PositionIndex --)  //  <-- for loop to loop through all Orders . .   COUNT DOWN TO ZERO !
      {
      if( ! OrderSelect(PositionIndex, SELECT_BY_POS, MODE_TRADES) ) continue;   // <-- if the OrderSelect fails advance the loop to the next PositionIndex
      
      if( // OrderMagicNumber() == MagicNo       // <-- does the Order's Magic Number match our EA's magic number ?  && 
          OrderSymbol() == Symbol()         // <-- does the Order's Symbol match the Symbol our EA is working on ? 
         &&    OrderType() == OP_SELL  )      // <-- or is it a Sell Order ?
      
         if ( ! OrderClose( OrderTicket(), OrderLots(), OrderClosePrice(), Slippage ) )               // <-- try to close the order
            {
           //    Print("Order Close failed, order number: ", OrderTicket(), " Error: ", GetLastError() );  // <-- if the Order Close failed print some helpful information 
            tikka = false;break;
            }
            else {tikka = true;}//Success in Closing A SELL Order
      } //  end of For loop
      
         Ans = tikka;  //THis ONLY works with just One Buy Order at a Time! otherwise, use dynamic array
     
   }
   return (Ans);   
   }


//+------------------------------------------------------------------+