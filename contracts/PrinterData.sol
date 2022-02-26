 
import './EnumType.sol';
 
 
 library PrinterData{
       
 
 struct materialDetails{
        bytes32 name;
        EnumType.materialType mType;
        EnumType.materialColor color;
        uint256 quantityKG;
        uint256 quantityM;
        uint256 printTemperature;
        uint256 bedTemperature;
    }


 }
