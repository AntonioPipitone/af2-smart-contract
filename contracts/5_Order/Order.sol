/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Structs/OrderStructs.sol";

contract Order {
    mapping(address => mapping(bytes32 => PlayerOrder)) orders;
    mapping(address => bytes32[]) myOrderIds;
    mapping(address => OrderRequest[]) myRequest;

    function addMakerRequest(address maker, bytes32 orderID)
    public payable{
        myRequest[maker].push(OrderRequest(orderID,msg.sender, false));
    }

    function newOrder(bytes32 orderID, bytes32 hashDesign, uint256 pieces, bool betterQuality, uint256 requestedLayerHeight, MaterialType requestedMaterial, MaterialColor requestedColor, uint256 timestamp)
    public payable{
        Distribution[] memory distribution = getDistribution(orderID);
        orders[msg.sender][orderID]= PlayerOrder(orderID, hashDesign, pieces, betterQuality, requestedLayerHeight, requestedMaterial, requestedColor, distribution, false, timestamp);
        myOrderIds[msg.sender].push(orderID);
    }

    function getMyOrders()
    public view
    returns (PlayerOrder[] memory myOrders){
        myOrders = new PlayerOrder[](myOrderIds[msg.sender].length);

        for(uint256 i = 0; i<myOrderIds[msg.sender].length; i++){
            myOrders[i] = orders[msg.sender][myOrderIds[msg.sender][i]];
        }
        return myOrders;
    }

    function getMyOrdersCompleted()
    public view
    returns (PlayerOrder[] memory myOrders){
        myOrders = new PlayerOrder[](getMyOrdersCompletedN());
        for(uint256 i = 0; i<myOrders.length; i++){
            if (orders[msg.sender][myOrderIds[msg.sender][i]].complete){
                myOrders[i] = orders[msg.sender][myOrderIds[msg.sender][i]];
            }
        }
        return myOrders;
    }

    function getMyOrdersCompletedN()
    private view
    returns (uint256 n){
        for(uint256 i = 0; i<myOrderIds[msg.sender].length; i++){
            n = orders[msg.sender][myOrderIds[msg.sender][i]].complete ? n++ : n;
        }
        return n;
    }

    function getDistribution(bytes32 orderID)
    public payable
    returns(Distribution[] memory distribution){
        address[] memory makers = getMakerFromOracle(orderID);
        address[] memory printers = getPrinterFromOracle(orderID);
        uint256[] memory pieceDistribution =  getPiecesDistributionFromOracle(orderID);
        for (uint256 i=0; i<makers.length; i++){
            distribution[i]= Distribution(makers[i],printers[i],pieceDistribution[i]);
        }
        return distribution;
    }

    function getPrinterFromOracle(bytes32 orderID)
    public payable
    returns(address[] memory pieces){

    }

    function getMakerFromOracle(bytes32 orderID)
    public payable
    returns(address[] memory pieces){

    }
    
    function getPiecesDistributionFromOracle(bytes32 orderID)
    public payable
    returns(uint256[] memory pieces){

    }
}