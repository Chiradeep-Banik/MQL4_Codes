#include <func.mqh>

#property show_inputs

input double stoploss;
input double max_loss;

void OnStart()
{
   Alert(optimal_lot_size(stoploss , max_loss));
   
}
