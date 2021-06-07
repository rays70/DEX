// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "../contracts/wallet.sol";

contract Dex is Wallet {
using SafeMath for uint256;


enum Side {
    BUY, 
    SELL
}

struct Order {
    uint id;
    address trader;
    Side side;
    bytes32 ticker;
    uint amount;
    uint price;
    bool filled;
}

mapping(bytes32 => mapping(uint => Order[])) public orderBook;

uint orderId = 0;

function getOrderBook(bytes32 ticker, Side side) view public returns (Order[] memory) {

    return orderBook[ticker][uint(side)];

}
function createLimitOrder(bytes32 ticker, Side side, uint amount, uint price) public {

    uint ethBalance;
    uint tokenBalance;
    Order memory _order = Order(orderId, msg.sender, side, ticker, amount, price, false);

    ethBalance = balances[msg.sender][bytes32("ETH")];
    tokenBalance = balances[msg.sender][ticker];

    if (side == Side.BUY){

        require(ethBalance >= amount.mul(price), "Eth balance is not enough");
        orderBook[ticker][uint(side)].push(_order);
        sortDescending(orderBook[ticker][uint(side)]);
        orderId++;
    }
    if (side == Side.SELL){

        require(tokenBalance >= amount, "Token balance is not enough");
        orderBook[ticker][uint(side)].push(_order);
        sortAescending(orderBook[ticker][uint(side)]);
        orderId++ ;
    }

}

function sortDescending(Order[] storage orders) private {
    // Bubble Sort

     uint l = orders.length;
     
     if (l > 1) {
     
        bool swap = true;
        
        while(swap){

            uint numSwap = 0;

            for(uint i = 0; i < l -2; i++){

                Order memory temp;
                
                if (orders[i].price < orders[i+1].price){
                    temp = orders[i];
                    orders[i] = orders[i+1];
                    orders[i+1] = temp;
                    numSwap++;
                    swap = true;
                }
            }

            if (numSwap == 0){
                swap = false;
            }
    
        }

     }

}

function sortAescending(Order[] storage orders) private {
    // Bubble Sort

     uint l = orders.length;

     if (l > 1) {

        bool swap = true;
        

        while(swap){

            uint numSwap = 0;

            for(uint i = 0; i < l -2; i++){

                Order memory temp;
                
                if (orders[i].price > orders[i+1].price){
                    temp = orders[i];
                    orders[i] = orders[i+1];
                    orders[i+1] = temp;
                    numSwap++;
                    swap = true;
                }
            }

            if (numSwap == 0){
                swap = false;
            }
    
        }

    }

}

function createMarketOrder(bytes32 _ticker, Side _side, uint _amount) public{

	Side limitOrderSide;
	uint ethBalance = balances[msg.sender][bytes32("ETH")];
    uint tokenBalance = balances[msg.sender][_ticker];
    
    Order storage _order = Order(orderId, msg.sender, _side, _ticker, _amount, _price, false);
	
    Order[] memory orders;
	uint price;
	
	if ( _side == Side.BUY ){
	
		limitOrderSide = Side.SELL
	
	}else {
	
		limitOrderSide = Side.BUY
		require (tokenBalance > _amount, "The token balance is not enough to place this sell order");
	
	}
	
	orders = getOrderBook(_ticker, limitOrderSide);
	
	uint filledAmount = 0;
	uint leftToFill = _amount.sub(filledAmount);
	
	
	while ( leftToFill > 0 ){
	
		for (uint i = 0; i < orders.length; i++){
		
			
			
			uint ethValueOfOrder = orders[i].amount.mul(orders[i].price);
				
			if ( _side == Side.BUY ) {
				
				require(ethBalance >= ethValueOfOrder, "Eth balance is not enough for the Buy market order");
				
			}
			if ( _amount < orders[i].amount ){

				filledAmount = _amount;
				leftToFill = _amount.sub(filledAmount);
				orders[i].amount = orders[i].amount.sub(filledAmount);
					 
			}
			else {
				
				filledAmount = orders[i].amount ;
				leftToFill = _amount.sub(filledAmount);
				orders[i].amount = orders[i].amount.sub(filledAmount);
				orders[i].filled = true ;
						
			}
				
			if ( _side == Side.BUY ) {
				
				executeTrade(msg.sender, orders[i].trader, _ticker, filledAmount, ethValueOfOrder  );
				
			}
			else {	
				
				executeTrade( orders[i].trader, msg.sender, _ticker, filledAmount, ethValueOfOrder  );
				
			}
			
						
		}
		
	}
}

function executeTrade(address buyer, address seller, bytes32 _ticker, uint tokenamount, uint ethValue) private {

	// the buyer should transfer the eth to the seller.
	balances[buyer][bytes32("ETH")] = balances[buyer][bytes32("ETH")].sub(ethValueOfOrder);
	balances[seller][bytes32("ETH")] = balances[seller][bytes32("ETH")].add(ethValueOfOrder) ;
	
	// the seller should transfer the token to the buyer.
	balances[buyer][_ticker] = balances[buyer][_ticker].add(tokenamount);
	balances[seller][_ticker] = balances[seller][_ticker].sub(tokenamount);

}


}
