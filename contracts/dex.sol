// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "../contracts/wallet.sol";

contract Dex is Wallet {
    using SafeMath for uint256;

    enum Side {BUY, SELL}

    struct Order {
        uint256 id;
        address trader;
        Side side;
        bytes32 ticker;
        uint256 amount;
        uint256 price;
        bool filled;
    }

    mapping(bytes32 => mapping(uint256 => Order[])) public orderBook;

    uint256 orderId = 0;

    event OrderEvent(uint256 id, address trader, Side side, bytes32 ticker, uint256 OrderAmount, uint256 price, bool filled);

    function getOrderBook(bytes32 ticker, Side side)
        public
        view
        returns (Order[] memory)
    {
        return orderBook[ticker][uint256(side)];
    }

    function createLimitOrder(
        bytes32 ticker,
        Side side,
        uint256 amount,
        uint256 price
    ) public {
        uint256 ethBalance;
        uint256 tokenBalance;
        Order memory _order =
            Order(orderId, msg.sender, side, ticker, amount, price, false);

        ethBalance = balances[msg.sender][bytes32("ETH")];
        tokenBalance = balances[msg.sender][ticker];

        if (side == Side.BUY) {
            require(
                ethBalance >= amount.mul(price),
                "Eth balance is not enough"
            );
            orderBook[ticker][uint256(side)].push(_order);
            sortDescending(orderBook[ticker][uint256(side)]);
            orderId++;
        }
        if (side == Side.SELL) {
            require(tokenBalance >= amount, "Token balance is not enough");
            orderBook[ticker][uint256(side)].push(_order);
            sortAescending(orderBook[ticker][uint256(side)]);
            orderId++;
        }
    }

    function sortDescending(Order[] storage orders) private {
        // Bubble Sort

        uint256 l = orders.length;

        if (l > 1) {
            bool swap = true;

            while (swap) {
                uint256 numSwap = 0;

                for (uint256 i = 0; i < (l - 1); i++) {
                    Order memory temp;

                    if (orders[i].price < orders[i + 1].price) {
                        temp = orders[i];
                        orders[i] = orders[i + 1];
                        orders[i + 1] = temp;
                        numSwap++;
                        swap = true;
                    }
                }

                if (numSwap == 0) {
                    swap = false;
                }
            }
        }
    }

    function sortAescending(Order[] storage orders) private {
        // Bubble Sort

        uint256 l = orders.length;

        if (l > 1) {
            bool swap = true;

            while (swap) {
                uint256 numSwap = 0;

                for (uint256 i = 0; i < (l - 1); i++) {
                    Order memory temp;

                    if (orders[i].price > orders[i + 1].price) {
                        temp = orders[i];
                        orders[i] = orders[i + 1];
                        orders[i + 1] = temp;
                        numSwap++;
                        swap = true;
                    }
                }

                if (numSwap == 0) {
                    swap = false;
                }
            }
        }
    }

    function createMarketOrder(
        bytes32 _ticker,
        Side _side,
        uint256 _amount
    ) public {
        Side limitOrderSide;
        uint256 ethBalance = balances[msg.sender][bytes32("ETH")];
        uint256 tokenBalance = balances[msg.sender][_ticker];

              

        if (_side == Side.BUY) {
            limitOrderSide = Side.SELL;
        } else {
            limitOrderSide = Side.BUY;
            require(
                tokenBalance > _amount,
                "The token balance is not enough to place this sell order"
            );
        }

        Order[] storage orders = orderBook[_ticker][uint256(limitOrderSide)];
        
        uint256 filledAmount = 0;
        uint256 leftToFill = _amount.sub(filledAmount);

        for (uint256 i = 0; i < orders.length; i++) {
            uint256 ethValueOfOrder = 0;

            if (_amount < orders[i].amount) {
                filledAmount = _amount;
                leftToFill = _amount.sub(filledAmount);
                orders[i].amount = orders[i].amount.sub(filledAmount);

                emit OrderEvent(orders[i].id, orders[i].trader, orders[i].side, orders[i].ticker, orders[i].amount, orders[i].price, orders[i].filled) ;

            } else {
                filledAmount = orders[i].amount;
                leftToFill = _amount.sub(filledAmount);
                _amount = _amount.sub(filledAmount);
                orders[i].amount = orders[i].amount.sub(filledAmount);
                orders[i].filled = true;

                emit OrderEvent(orders[i].id, orders[i].trader, orders[i].side, orders[i].ticker, orders[i].amount, orders[i].price, orders[i].filled) ;
            }

            if (_side == Side.BUY) {

                ethValueOfOrder = filledAmount.mul(orders[i].price);

                require(
                    ethBalance >= ethValueOfOrder,
                    "Eth balance is not enough for the Buy market order"
                );
            }

            if (_side == Side.BUY) {
                executeTrade(
                    msg.sender,
                    orders[i].trader,
                    _ticker,
                    filledAmount,
                    ethValueOfOrder
                );
            } else {
                executeTrade(
                    orders[i].trader,
                    msg.sender,
                    _ticker,
                    filledAmount,
                    ethValueOfOrder
                );
            }

            if (leftToFill == 0  || (i == orders.length -1) ) {
                break;
            }
        }


         while(orders[0].filled == true){

                      
            for (uint j = 0; j < (orders.length -1); j++){

                    orders[j] = orders[j+1];

                }
            
            orders.pop();

            if (orders.length == 0){

                break ;

            }
                

        }


    }

    function executeTrade(
        address buyer,
        address seller,
        bytes32 _ticker,
        uint256 tokenamount,
        uint256 ethValue
    ) private {
        // the buyer should transfer the eth to the seller.
        balances[buyer][bytes32("ETH")] = balances[buyer][bytes32("ETH")].sub(
            ethValue
        );
        balances[seller][bytes32("ETH")] = balances[seller][bytes32("ETH")].add(
            ethValue
        );

        // the seller should transfer the token to the buyer.
        balances[buyer][_ticker] = balances[buyer][_ticker].add(tokenamount);
        balances[seller][_ticker] = balances[seller][_ticker].sub(tokenamount);

        // actual token transfer needs to be written.
    }
}
