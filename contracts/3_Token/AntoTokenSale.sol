// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "./TestToken.sol";

contract AntoTokenSale {
    address admin; //state variable
    address payable addr = payable(address(admin));
    TestToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    event Sell(address _buyer, uint256 _amount);

    constructor(TestToken _tokenContract, uint256 _tokenPrice) {
        admin = msg.sender; //Assign the admin, msg.sender is global variable who dedploy cotnract
        tokenContract = _tokenContract;  //Token Contract interact
        tokenPrice = _tokenPrice; //Token price in wei/ether
    }
    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    //Buy tokens

    function buyTokens(uint256 _numberOfTokens) public payable {

        require(msg.value == multiply(_numberOfTokens, tokenPrice)); //require that the value is equal to tokens
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens); //require that are enough tokens in the contract
        require(tokenContract.transfer(msg.sender, (_numberOfTokens * 10 ** 18) )); //require that a transfer is successful
        tokensSold += _numberOfTokens; //keep track of TokensSold

        emit Sell(msg.sender, _numberOfTokens); //trigger Sell Event
    }


    function endSale() public {
    require(msg.sender == admin, 'Just admin can end token sale');

    // Return all remaining unsold tokens to admin
    require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))), 'Return all unsold tokens to admin');

    // Destroy contract
    selfdestruct(addr);
  }
}
