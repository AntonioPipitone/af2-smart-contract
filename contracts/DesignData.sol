
import './EnumType.sol';

library DesignData{

    struct designState
    {
        //bytes32 filehash;
        uint256 printVolume;
        uint256 kgMaterials;
        uint256 mMaterials;
        address vendor;
        uint256 timestamp;
        uint256 balance;
        //address manager;
        uint256 status;//to be removed
        uint256 status1;
        uint256 status2;
        uint256 taup;
        uint256 taur;
        uint256 deltaExp;
        uint256 deltaReveal;
        int result;
        EnumType.votingState phase;
    } 
}
