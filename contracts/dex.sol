// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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
}

mapping(bytes32 => mapping(uint => Order[])) public orderBook;

uint orderId = 0;

function getOrderBook(bytes32 ticker, Side side) view public returns (Order[] memory) {

    return orderBook[ticker][uint(side)];

}
function createLimitOrder(bytes32 ticker, Side side, uint amount, uint price) public {

    uint ethBalance;
    uint tokenBalance;
    Order memory _order = Order(orderId, msg.sender, side, ticker, amount, price);

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

function sortDescending(Order[] memory orders) private pure{
    // Bubble Sort

     uint l = orders.length;
     bool swap = true;
     uint numSwap = 0;

     while(swap){

        for(uint i = 0; i < l -1; i++){

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

function sortAescending(Order[] memory orders) private pure{
    // Bubble Sort

     uint l = orders.length;
     bool swap = true;
     uint numSwap = 0;

     while(swap){

        for(uint i = 0; i < l -1; i++){

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
