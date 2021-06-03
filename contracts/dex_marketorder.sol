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

    uint ethBalance;
    uint tokenBalance;
    uint price;
    Order memory _order = Order(orderId, msg.sender, _side, _ticker, _amount, _price, false);
    Order[] memory orders;

    ethBalance = balances[msg.sender][bytes32("ETH")];
    tokenBalance = balances[msg.sender][_ticker];

    if (_side == Side.BUY){

        orders = getOrderBook(_ticker, Side.SELL);
        require (orders.length >0, "The Buy Market Order Can not be fulfilled now");

        for (uint i = 0; i < orders.length; i++){

            if ( orders[i].amount > _amount){

                // the market order can be fulfilled through this Sell Limit Order
                // the buyer should transfer the eth to the seller.
                // if the buyer does not have the required eth, then the transaction should revert.
                // the seller should transfer the required amount of token to the Buyer.
                // the eth balance of the buyer to go down and the eth balance of the seller to go up.
                // the token balance of the buyer to go up and the token balance of the seller to go down.
                // the sell limit order in the orderbook needs to be adjusted.

            }

        }


        
    }
    if (side == Side.SELL){

        // require(tokenBalance >= amount, "Token balance is not enough");
        orderBook[ticker][uint(side)].push(_order);
        sortAescending(orderBook[ticker][uint(side)]);
        orderId++ ;
    }




}
 



}
