pragma solidity 0.4.19;

contract SpaceDataBase {
    
    
    //write
    function addStar(bytes32 _name, address _owner) public; 
    function addPlanet(bytes32 _name, uint64 _goodId, address _owner) public;
    function addStation(bytes32 _name, address _owner) public;
    function upgradeAsset(uint8 _assetType, uint8 _config, uint64 _assetId) public;
    function produceGood(address _address, uint64 _goodId, uint8 _level, uint8 _difficulty) public;
    function updateCooldown(uint8 _type, uint64 _assetId) public;
    function transferStar(address _from, address _to, uint64 _starId) public;
    function transferPlanet(address _from, address _to, uint64 _planetId) public;
    function transferStation(address _from, address _to, uint64 _stationId) public;
    function ownerTransferStar(address _to, uint64 _starId) public;
    function ownerTransferPlanet(address _to, uint64 _planetId) public;
    function ownerTransferStation(address _to, uint64 _stationId) public;
    function changeGoodBalance(address _target, uint64 _goodId, bool _dir, uint256 _amt) public;
    function changeDroneBalance(address _target, bool _dir, uint256 _amt) public;
    function changeXPBalance(address _target, bool _dir, uint256 _amt) public;
    function changeAssetDrones(uint8 _type, uint64 _assetId, bool _dir, uint256 _amt) public;
    
    
    //read
    function getStar(uint64 _starId) public view returns (address owner, uint64 objectId, uint32 energyOutput, uint32 matterOutput, uint32 scienceOutput, uint256 defenseForce);
    function getPlanet(uint64 _planetId) public view returns (address owner, uint64 objectId, uint64 goodId, uint8 level, uint8 difficulty, uint256 defenseForce);
    function getStation(uint64 _stationId) public view returns (address owner, uint64 objectId, uint8 level, uint8 difficulty, uint256 defenseForce);
    function getGoodBalance(address _address, uint64 _goodId) public view returns(uint256);
    function checkIfCraftable(uint64 _goodId) public view returns (bool);
    function checkOwner(uint8 _type, uint64 _assetId) public view returns(address);
    function checkCooldown(uint8 _type, uint64 _assetId) public view returns(uint);
    function getStarByIndex(address _owner, uint _index) public view returns(uint64);
    function getPlanetByIndex(address _owner, uint _index) public view returns(uint64);
    function getStationByIndex(address _owner, uint _index) public view returns(uint64);
    function getDrones(address _address) public view returns (uint256);
    function getGameTotals() public view returns (uint64, uint64, uint64);
    function getPlayerTotals(address _address) public view returns (uint256, uint256, uint256);
    function getPlayerAssets(address _address) public view returns (uint64[], uint64[], uint64[]);

}