pragma solidity >=0.6.0 <0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wallet{

    struct Token{
        bytes32 ticker;
        address tokenAddress;
        }

    mapping (bytes32 => Token) tokenMapping;
    bytes32[] public tokenList;
    mapping (address => mapping(bytes32 => uint256)) public balances;

    function addToken(bytes32 _ticker, address _tokenAddress) external {

        tokenMapping[_ticker] = Token(_ticker, _tokenAddress);
        tokenList.push(_ticker);

    }

    function deposit(uint amount, bytes32 ticker) {


    }

    function withdraw(uint amount, bytes32 ticker){

        require(balances[msg.sender][ticker] >= amount, "Balance is not sufficient");
        require(tokenMapping[ticker].tokenaddress != address(0));
        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount);
        IERC20(tokenMapping[ticker].tokenaddress).transfer(msg.sender, amount);


    }


}
