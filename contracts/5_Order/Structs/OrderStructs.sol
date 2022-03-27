pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


enum MaterialType  { ABS, PLA, PETG, NONE }
enum MaterialColor { NONE, BLACK, WHITE, BROWN, GRAY, YELLOW, ORANGE, RED, PINK, PURPLE, BLU, GREEN }

struct PlayerOrder{
    bytes32 orderID;
    bytes32 hashDesign;
    uint256 pieces; 
    bool betterQuality;
    uint256 requestedLayerHeight;
    MaterialType requestedMaterial;
    MaterialColor requestedColor;
    Distribution[] distribution;
    bool complete;
    uint256 timestamp_request;
}

struct Distribution{
    address makers;
    address printer;
    uint256 distribution;
}

struct OrderRequest{
    bytes32 orderID;
    address addressFrom;
    bool complete;
}
