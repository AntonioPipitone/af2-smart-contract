// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import { IERC20 } from "./Utils/IERC20.sol";
import { Context } from "./Utils/Context.sol";

contract TestToken is IERC20 {

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private _decimals;

    mapping(address => uint256) public _balanceOf; //mapping prende una key ed un valore
    mapping(address =>  mapping(address => uint256)) public _allowance; /*mapping innestato: */

    constructor() { //constructor che viene eseguito ogni volta che viene deployato lo S.C
        _name = "AirFactories";
        _symbol = "AF2";
        _decimals = 18;
        _totalSupply = 1000000 * 10 ** 18;
        _balanceOf[msg.sender] = _totalSupply; //msg sender è una variabile globale, sender sta per l'address che chiama la funzione.

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /*
    nei valori che trasferiamo nella funzione transfer modificare amount mettendogli * 10 ** _decimals, per evitare problemi lato front-end.
    In questo caso, facendo la conversione qui e non nel front-end, evitiamo problemi durante l'acquiusto, se uno vuole acqusitare dieci token e invece scrivo 100000
    */
    function transfer(address recipient, uint256 amount) public override returns (bool success) { //Creo la funzione per trasferire i token.

        require(_balanceOf[msg.sender] >= amount); //controllo se il sender vuole mandare piu token di quanti ne possiede
        _balanceOf[msg.sender] -= amount; //diminuisco il balance del msg.sender del valore che è stato trasferito
        _balanceOf[recipient] += amount;   //aumento il balance dell'account che riceve
        emit Transfer(msg.sender, recipient, amount); //verifico l'evento transfer
        return true;
    }

    function approve(address owner,address spender, uint256 amount) public override returns(bool success) {
        _allowance[owner][spender] = amount; //abilito l'account _spender (address) a mandare un certo numero di token
        emit Approval(owner, spender, amount); //approvo l'evento
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool success) {
         require(amount <= _balanceOf[sender]); //require sender has enough token
         require(amount <= _allowance[sender][msg.sender]); //require allowance is big enough, non può essere > di quello che msg.sender ha approvato

         _balanceOf[sender] -= amount; //change the balance
         _balanceOf[recipient] += amount;

         _allowance[sender][msg.sender] -= amount; //update the allowance

         emit Transfer(sender, recipient, amount); //transfer event

         return true;

    }

    /**
    * @dev Returns the token decimals.
*/
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
    * @dev Returns the token symbol.
    */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory) {
        return _name;
    }


    function totalSupply() external override view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256){
        return _balanceOf[account];
    }

    function allowance(address owner, address spender) external override view returns (uint256){
        return _allowance[owner][spender];
    }

}
