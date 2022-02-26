/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


//          INTERFACE DEFINITION
//############################################
abstract contract IUser  {
        
    // TO BE CHECKED
    mapping(address=>bool) public isPlayer;
    //function getAirPlayerInfo(address _playerAddress)external view returns(AirPlayer memory);
    function getPlayerWeight(address _playerAddress) virtual external view returns(uint256);
    function getPlayerReputation(address _playerAddress) virtual external view returns(int256);
    function setPlayerWeigth(address playerAddress,uint256 weight)virtual external view ;
    function setPlayerReputation(address playerAdrress, int256 reputation)virtual external view; 
}
 //                  END
//############################################

