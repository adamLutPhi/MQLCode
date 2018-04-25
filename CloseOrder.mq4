//+------------------------------------------------------------------+
//|                                                   CloseOrder.mq4 |
//|                                                 Eng. Ahmad Lutfi |
//|                                         https://www.lutfipro.com |
//+------------------------------------------------------------------+
#property copyright "Eng. Ahmad Lutfi"
#property link      "https://www.lutfipro.com"
#property version   "1.00"
#property strict

int Counter, vSlippage;
double ticket, MagicNumber;
//+------------------------------------------------------------------+
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
//---
   
  }
//+------------------------------------------------------------------+


void close(int type){


if(OrdersTotal()>0){
for(Counter=OrdersTotal()-1;Counter>=0;Counter--){
OrderSelect(Counter,SELECT_BY_POS,MODE_TRADES);

if(type==OP_BUY && OrderType()==OP_BUY){
if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) {
RefreshRates(); 
OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits), vSlippage);
} }

if(type==OP_SELL && OrderType()==OP_SELL){
if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) {
RefreshRates(); OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),vSlippage); 
}}
}}}