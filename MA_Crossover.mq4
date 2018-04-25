//+------------------------------------------------------------------+
//|                                                 MA_Crossover.mq4 |
//|                                 Copyright 2017, Eng. Ahmad Lutfi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Eng. Ahmad Lutfi"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property strict

extern int maPeriod1 = 37;
extern int maMode1 = 0;
extern int Shift1 = 0;
extern int Appliedto1=0;
extern int maPeriod2 = 122;
extern int maMode2 = 0;
extern int Shift2 = 0;
extern int Appliedto2=0;
extern  double Lots = 1;
extern double LotMul = 1;

int Slippage=10;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//Change NewBar DFunctions
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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
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
 // if(NewBar())
//{
//---

static double size = Lots* LotMul;
//Print("lot Size ",size," lots ",Lots," LotMul ",LotMul);
static int ticket = 0;

  double CurrentMa1 =  iMA(Symbol(),PERIOD_CURRENT,maPeriod1,Shift1,maMode1,PRICE_TYPICAL,1);
   double CurrentMa2 =  iMA(Symbol(),PERIOD_CURRENT,maPeriod2,Shift2,maMode2,PRICE_TYPICAL,1);
   
   
  // double LastMa1 = iMA(Symbol(),PERIOD_CURRENT,maPeriod1,0,MODE_SMA,PRICE_TYPICAL,2);
  //  double LastMa2 = iMA(Symbol(),PERIOD_CURRENT,maPeriod2,0,MODE_SMA,PRICE_TYPICAL,2);
  
  
  //---
  //if short Perod ma was below the fast Perod ma
  //but now above the fast Perod ma
  
  if(CurrentMa1 >= CurrentMa2)
  {
       //Close Open Buys & SELL
       
          closeAllbuys();
           if(OrdersTotal()<1)
           {
           
        ticket = OrderSend(Symbol(), OP_SELL, NormalizeDouble(LotMul,2),NormalizeDouble( Bid,Digits), 10, 0,0,NULL,0,0,Red); //1,Digits
                Print("Sell  Bid @",NormalizeDouble( Bid,Digits));
                }
                
               ///
            
                   //ticket = OrderSend(Symbol(), OP_BUY, size/* NormalizeDouble( size,2)*/, NormalizeDouble(Ask*Point,Digits), 10,NULL, NULL,NULL,0,0,Blue); //1,Digits

  }//END IF
  ///---
             if(CurrentMa1 <= CurrentMa2)
            {
         //Close all Open Sells and BUY
           closeAllSells();
           if(OrdersTotal()<1)
           {
           
          
           ticket = OrderSend(Symbol(), OP_BUY, NormalizeDouble( LotMul,2),  NormalizeDouble(Ask,Digits),10 ,0, 0,NULL,0,0,Blue); //1,Digits
            Print("Buy Ask @",NormalizeDouble(Ask,Digits));
             }
            ///

            }
         //  }
  ///---
  }
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+
void tryClose(int Operation)//op: 0= buy, 1=sell;  //function assumes order has already been selected!
  {
 // Print("entering close...");
  static int number_try =2;
           while(number_try>0)
            {
            Print("entering while...numtires= ",IntegerToString(number_try));
            number_try--; //1
             Sleep(500);
             RefreshRates();
             //---
             bool result=false;//failed to close by default
                  if(Operation==1) //sell Order
                  {
                  Print("trying to close sell ");
                   result =OrderClose(OrderTicket(), OrderLots(),Ask, Slippage, Gold); //Ask for Closesell
                  }
                  if(Operation==0) //buy Order
                  {
                  Print("trying to close buy order ticket ="+OrderTicket()+"Bids=");
                    result =OrderClose(OrderTicket(), OrderLots(),Bid ,Slippage, Red); //Bid for Closebuy
                  
                  }
            //---
            int error=0;
                if(result != true)
               {
                  error = GetLastError();
                  Print("Last Known Error: ",error);
               }
              if(result == true)  //successful! true 
               {
               number_try =2;
                  error =0;
               break;
               }
               
               switch(error)
               {
                 case 135://ERR_PRICE_CHANGED
                 case 136://ERR_OFF_QUOTES
                 case 137://ERR_BROKER_BUSY
                 case 138://ERR_REQUOTE
                 case 146:Sleep(1000);RefreshRates();/*i++;*/break;//ERR_TRADE_CONTEXT_BUSY
               }
               
              
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
                  number_try++;//2
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