//+------------------------------------------------------------------+
//|                                                         WPR2.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double lots=1.0;
extern int  period=14;
 int Slippage = 10;
bool IsTrading;
bool ErrorsOccured;
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
//---
  if(NewBar() && !ErrorsOccured)
  {
//---
  //Print("Starting A new Bar......: @ ");
static int ticket = -1;
//static IsTrading = true; = false;
static double y1 = 0;
static double m1 = 0;
static double y2 = 0;
static double m2 = 0;

static double X = iWPR(Symbol(),PERIOD_CURRENT,period,2);
static double Xfin = iWPR(Symbol(),PERIOD_CURRENT,period,1);
//Print("Trading:",IsTrading);
 //double finalWpr = iWPR(Symbol(),PERIOD_CURRENT,14,1);
 //double firstWpr = iWPR(Symbol(),PERIOD_CURRENT,14,2);
  Print("Start Trading: @ ", NormalizeDouble( Ask,Digits));
  
 if(!IsTrading) // Not Trading YET! we want to ENTER!
 {
 
 //Buy Order:  [Done!]
 //---------
 Print("check 123 Buy Trading: @ ", NormalizeDouble( Ask,Digits));
               if((X > -100 && X<-80) &&
                  (Xfin > -80 && Xfin <-50))
               {Print("Buy Trading: @ ", NormalizeDouble( Ask,Digits));
               
               ticket = OrderSend(Symbol(), OP_BUY, NormalizeDouble( lots,2),  NormalizeDouble(Ask,Digits), 10, NULL, NULL,NULL ,0,0,Blue); //1,Digits
               
                  if(ticket<0)
                     {
                       IsTrading = false;//Couldn't Open a New Buy Order!
                       Print("Failed in Placing a BUY Order@",NormalizeDouble( Ask,Digits), " Error: ", GetLastError() ); //, order number: ", OrderTicket(), " Error: ", GetLastError() ); 
                     }
                 if(ticket>0)
                     {
                           //Store Valuable Information!
                           y1 = iWPR(Symbol(),PERIOD_CURRENT,period,2);
                           y2 = iWPR(Symbol(),PERIOD_CURRENT,period,1);
                           m1 = Calc_m(y2,y1);
                           //
                        IsTrading = true;
                     }

               }
               
 
 //Sell Order: [Done!]
 //----------
 //if( (firstWpr>= -20 
     // && firstWpr<=0) && (finalWpr <= -20) )//Leaving OverBought Area
      
   //   {
      Print("check 123 Sell Trading: @ ", NormalizeDouble( Bid,Digits));
      if((X > -20 && X<0) &&
         (Xfin > -50 && Xfin <-20))
         {

      //Open  Sell Trade
      //IsOpenSell()= true; NO NO Only a boolean flag sloves this issue!
       if( OrdersTotal()<1)
         {  Print("Sell Trading: @ ", NormalizeDouble( Bid,Digits));
          // ticket = OrderSend(Symbol(), OP_SELL, NormalizeDouble(size,2), NormalizeDouble( Bid,Digits), 10, NormalizeDouble(Ask+StopLoss*Point,Digits), NormalizeDouble(Ask-TakeProfit*Point,Digits),NULL,0,0,Red); //1,Digits
          ticket = OrderSend(Symbol(), OP_SELL, NormalizeDouble( lots,2), NormalizeDouble( Bid,Digits), 10, NULL,NULL,NULL,0,0,Red); //1,Digits check params... BID to NormalizeDouble( Bid,Digits)
          
          if(ticket<0)
          {
              IsTrading = false;//Couldn't Open a New Sell Order!
              Print("Failed in Placing a SELL Order @",NormalizeDouble( Bid,Digits), " Error: ", GetLastError() ); //, order number: ", OrderTicket(), " Error: ", GetLastError() ); 
          }
           if(ticket>0)
          {
            //Store Valuable Information!
            y1 = iWPR(Symbol(),PERIOD_CURRENT,period,2);
            y2 = iWPR(Symbol(),PERIOD_CURRENT,period,1);
            m1 = Calc_m(y2,y1);
            //
             IsTrading = true;
          }
         }
      // else{ ticket = -1;}


         }
         
       }//END IF Is_NOT_Trading
       
       if(IsTrading==true)
       {
          /* CheckSlope() */
          // ====================
     bool response =  OrderSelect(ticket,SELECT_BY_TICKET);
         if(!response) //Not Found!
         {
         Print("Order Not FOund! Error: ", GetLastError() );
         
         }
         
       if(response) //Order is Selected!
         {
            if(y2 != iWPR(Symbol(),PERIOD_CURRENT,period,1))
            {
         y1 = y2;
         y2= iWPR(Symbol(),PERIOD_CURRENT,period,1);
         m2 = Calc_m(y2,y1);
         
         //Compute  'n' Evaluate...
         //-----------------------
         double resultat = m1 * m2;
            if(resultat <0)
            {
               if(OrderType()==OP_BUY)
               {
                  //bool IsClosed = closeAllbuys(); testing uncomment to continue
                 bool IsClosed =  CloseallBuysNU();
                  
                  
                                    if(IsClosed) //Closed = OK!
                                    {
                                       IsTrading = false; //Get out of this current loop, Start looking for new Orders!
                                    }
               }
               
                if(OrderType()==OP_SELL)
               {
            //       bool IsClosed =  closeAllSells();  //uncomment to continue
              bool IsClosed = CloseallSellsNU();                      
                                   if(IsClosed) //Closed = OK!
                                 {
                                    IsTrading = false; //Get out of this current loop, Start looking for new Orders!
                                 }
               }
            
            }
          }
         }
         
         /* CheckSlope() */ //END
          // ~~~~~~~~~~~~~~~~~~~~
          
          
       
            /* CheckRegion() */ 
           // ====================
         //Buy Order [Close Sell Orders]: [Done!]
        //---------
              if((X > -100 && X<-80) &&
                  (Xfin > -80 && Xfin <-50))
               {
              //  bool IsClosed =  closeAllSells(); //uncomment to continue
              bool IsClosed = CloseallSellsNU();
                
                    if(IsClosed) //Closed = OK!
                  {
                     IsTrading = false; //Get out of this current loop, Start looking for Sells!
                  }
               }
        
        //Sell Order [Close Buy Orders]: [Done!]
        //----------
       
             if((X > -20 && X<0) &&  
                  (Xfin > -50 && Xfin <-20)) //bool answer2 = CheckRegion();
         {
              //[Check 'n' Close Open Buys (N/A) ]
              
             //  bool IsClosed = closeAllbuys(); //uncomment this to continue 
             bool IsClosed = CloseallBuysNU();
             
                  if(IsClosed) //Closed = OK!
                  {
                     IsTrading = false; //Get out of this current loop, Start looking for Sells!
                  }
                  
                  // if(!IsClosed)
                //  {
                  //   IsTrading = true;
             //     }
         }
         
         
      //bool answer1 = CheckSlope();  // f f  t   t
      
     // bool answer2 = CheckRegion(); // f t  f   t
      
      //if(answer1 || answer2){}
       
       
       }
   //    else{
     //  if( (firstWpr>-100 && firstWpr <=-80) && finalWpr>-80)
 
       //  {
         // ticket = OrderSend(Symbol(), OP_SELL, NormalizeDouble( lots,Digits), Bid, 10, NULL,NULL,NULL,0,0,Red); //1,Digits
          
 
       //  }
        //  }//END IF
         //
         
         
      /*   else  //Are we Trading!
         {
         int orders = OrdersTotal();
         if(orders >0)
            {
            for(int i =orders; i>0;i--)//iterate through orders
            {
            //Select Order
             if(!OrderSelect(i,SELECT_BY_POS)) continue; 
            
              if( OrderType==OP_BUY)
              {
                 
              }
              
              if(OrderType == OP_SELL)
               {
               
               }
             }
             
            }
         
         }*/
        // }
         //if(IsTrading)
        // {
         
         
        // }
        //}
   }
   else if(ErrorsOccured)
   {
   //start taking every tick into consideration...
      //Error Handling here
   //TickActivated = true;
   
   //Handle the Error like a gentleman
   ErrorsOccured = false;
   
   }
  }
//+------------------------------------------------------------------+


double Calc_m(double y2, double y1)
{

double m =  (y2-y1)*(-1);

return m;
}


double Calc_Theta(double m1, double m2)
{

   double Th1 = atan(m1);
   
   double Th2 = atan(m2);

   double Th = MathAbs(Th1 - Th2);
   return Th;
   
}

class Trade

{

public:

  double fstWpr;
  double lstWpr;
  double Theta;
  
   Trade() {fstWpr = 0.0;  lstWpr = 0.0; Theta =0.0; } //Constructor
   Trade(double FstWpr, double LstWpr) { fstWpr = FstWpr; lstWpr = LstWpr; //2nd Constructor

   Theta =   Calc_m(fstWpr,lstWpr);
  
  }

};


class buyTrade : public Trade // After a colon we define the base class
{                            // from which inheritance is made




};



bool closeAllbuys()
{
 bool tikka = false; bool Ans= false;
//static int Slippage = 10;


if(OrdersTotal()>0)
   {
 for(int i = OrdersTotal()-1; i >= 0 ; i --)  //  <-- for loop to loop through all Orders . .   COUNT DOWN TO ZERO !
   {

         if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
         
                  if(OrderType() == OP_BUY && OrderSymbol() == Symbol() )
                  {
                  
                      tryClose(OP_BUY);
                      Ans=true;
                        break;
                  }//END IF OrderType
         
         }//END IF OrderSelect
     else 
     {Print("Order Selection Error No. "+ IntegerToString(GetLastError()));
      tikka = false;
     }
     if(!tikka)
     {
      Ans=false;
     }
     }//end for Loop
  }//End ordersTotal
      return(Ans);
}

void tryClose(int Operation)//op: 0= buy, 1=sell;  //function assumes order has already been selected!
  {
 // Print("entering close...");
  static int number_try =2;
           while(number_try>0)//2>0  ok!
            {
            Print("1. entering while...numtires= ",IntegerToString(number_try));//2
            number_try--; //1
             Sleep(500);
             RefreshRates();
             //---
             bool result=false;//failed to close by default
                  if(Operation==1) //sell Order
                  {
                  Print("2.1. trying to close the sell order ticket = "+IntegerToString(OrderTicket())+" Ask = "+DoubleToStr(Ask,2));
                   result =OrderClose(OrderTicket(), OrderLots(),Ask, Slippage, Gold); //Ask for Closesell
                  }
                  if(Operation==0) //buy Order
                  {
                  Print("2.2. trying to close the buy order ticket = "+IntegerToString(OrderTicket())+" Bids= "+DoubleToStr(Bid,2));
                    result =OrderClose(OrderTicket(), OrderLots(),Bid ,Slippage, Red); //Bid for Closebuy
                  
                  }
            //---
            int error=0;
               if(result == true) //successful! true 
               {
               number_try =0; //this was equal to 2!
                  error =0;
               break;
               }
                if(result != true)
               {

                  error = GetLastError();
                  Print("Order could not be closed...Last Known Error: "+ IntegerToString(error)+" numTries = "+IntegerToString(number_try));
                  number_try =2; //Reset num Tries Back to 2<should have been deleted>
               }

                   Print("error occured... Entering  Switch");Sleep(500);
               switch(error)
               {

                 case 135://ERR_PRICE_CHANGED
                 case 136://ERR_OFF_QUOTES
                 case 137://ERR_BROKER_BUSY
                 case 138://ERR_REQUOTE
                 case 146:Sleep(1000);RefreshRates();/*i++;*/break;//ERR_TRADE_CONTEXT_BUSY
               }
                              Print("Exiting Switch"); Sleep(500);
              
               if(error==0)//no errors occured while closing this order
               {
                 number_try=0;  //get Out of the while loop!
                 Print("Order was Successfully Closed!");
                 Comment("Order was Successfully Closed!");
                 //or better
                 //return 
                 //return true;
               }
               else
               {
                  number_try=2;//2
                  Print("Couldn't close order, retrying...");
               Comment("Couldn't close order, retrying...");
               }
            
            }//end While!

}
//+------------------------------------------------------------------+
bool closeAllSells()
{
 bool tikka = false; bool Ans= false;
//int error;
if(OrdersTotal()>0)
   {
   for(int i = OrdersTotal() - 1; i >= 0 ; i--)  //  <-- for loop to loop through all Orders . .   COUNT DOWN TO ZERO !
      {
         if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
            
                        if(OrderType() == OP_SELL && OrderSymbol() == Symbol() )
                        {
                        
                          tryClose(OP_SELL);
                         Ans=true;
                       break;
                        }//END IF OrderType
            
            }//END IF OrderSelect
     else 
     {Print("Order Selecting Error No. "+ IntegerToString(GetLastError()));
      tikka = false;
     }
     if(!tikka)
     {
      Ans=false;
     }
     }//end for Loop
     
  }//End orders total
    return(Ans);
}
//+------------------------------------------------------------------+

void KellyClarkson(double lot)
{
double AmendedLots = lot;
    if(OrdersHistoryTotal()>=10)//It's possible to derive kelly now
     {
         
     }
     else
     {
      AmendedLots = 0.01;
     }
}
//+------------------------------------------------------------------+
/*
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
            Print("Order Close failed, order number: ", OrderTicket(), " Error: ", GetLastError() );  // <-- if the Order Close failed print some helpful information
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
               Print("Order Close failed, order number: ", OrderTicket(), " Error: ", GetLastError() );  // <-- if the Order Close failed print some helpful information 
            tikka = false;break;
            }
            else {tikka = true;}//Success in Closing A SELL Order
      } //  end of For loop
      
         Ans = tikka;  //THis ONLY works with just One Buy Order at a Time! otherwise, use dynamic array
     
   }
   return (Ans);   
}

*/


bool CloseallSellsNU()
{
bool IsClosed,result ;
  int total = OrdersTotal();
        for(int i=total-1;i>=0;i--)
        {
          OrderSelect(i, SELECT_BY_POS);
            if(OrderType()==OP_SELL)
            {
            
                  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                                                  IsClosed = result;   
                                 
                                  if(!result)
                                  {
                                  IsClosed = false;
                                  break;
                                  }
            
                   
           }
      
        }
        return(IsClosed);
}

bool CloseallBuysNU()
{
bool IsClosed,result;
  int total = OrdersTotal();
        for(int i=total-1;i>=0;i--)
        {
                if(OrderSelect(i, SELECT_BY_POS))
                {
               // int type   = OrderType();
            
               
                
                      if(OrderType()==OP_BUY)
                        {
                  //Close opened long positions
                                 result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                                    //  break;
                                                  IsClosed = result;   
                                 
                                  if(!result)
                                  {
                                  IsClosed = false;
                                  break;
                                  }
            
                  
                        }
                
            
               }
        }
   return(IsClosed);
}