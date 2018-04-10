pragma solidity 0.4.19;

import './SpaceDataBase.sol';

contract SpaceUse {
    
    address public dataC;
    
    function SpaceUse(address _dataC) public {
        require(_dataC != address(0));
        dataC = _dataC;
    }
    
    modifier requireData {
        require(dataC != address(0));
        _;
    }
    
    function produceStar(uint64 _starId, uint8 _EMS) requireData public {
        SpaceDataBase data = SpaceDataBase(dataC);
        require(msg.sender == data.checkOwner(0, _starId));
        require(data.checkCooldown(0, _starId) > 1);
        data.updateCooldown(0, _starId);
        uint32 energyOutput;
        uint32 matterOutput;
        uint32 scienceOutput;
        (,,energyOutput,matterOutput,scienceOutput,) = data.getStar(_starId);
        if (_EMS == 0) {
            data.changeGoodBalance(msg.sender, 1, true, energyOutput);
        } else if (_EMS == 1) {
            data.changeGoodBalance(msg.sender, 2, true, matterOutput);
        } else if (_EMS == 2) {
            data.changeGoodBalance(msg.sender, 3, true, scienceOutput);
        } else {
            revert();
        }
        data.changeXPBalance(msg.sender, true, 1);
    }
    
    function producePlanet(uint64 _planetId) requireData public {
        SpaceDataBase data = SpaceDataBase(dataC);
        uint64 goodId;
        uint8 level;
        uint8 difficulty;
        (,, goodId, level, difficulty,) = data.getPlanet(_planetId);
        require(msg.sender == data.checkOwner(1, _planetId));
        data.produceGood(msg.sender, goodId, level, difficulty);
        data.updateCooldown(1, _planetId);
    }
    
    function attackAsset(uint8 _type, uint64 _assetId, uint256 _amt) requireData public {
        SpaceDataBase data = SpaceDataBase(dataC);
        require(data.getDrones(msg.sender) >= _amt);
        require(msg.sender != data.checkOwner(_type, _assetId));
        data.changeDroneBalance(msg.sender, false, _amt);
        if (_type == 0) {
            uint256 starDefenseForce;
            address starDefender;
            (starDefender,,,,,starDefenseForce) = data.getStar(_assetId);
            if (_amt > starDefenseForce) {
                data.changeAssetDrones(_type, _assetId, false, (starDefenseForce-10));
                data.transferStar(starDefender, msg.sender, _assetId);
            } else {
                data.changeAssetDrones(_type, _assetId, false, _amt);
            }
        } else if (_type == 1) {
            uint256 planetDefenseForce;
            address planetDefender;
            (planetDefender,,,,,planetDefenseForce) = data.getPlanet(_assetId);
            if (_amt > planetDefenseForce) {
                data.changeAssetDrones(_type, _assetId, false, (planetDefenseForce-10));
                data.transferPlanet(planetDefender, msg.sender, _assetId);
            } else {
                data.changeAssetDrones(_type, _assetId, false, _amt);
            }
        } else if (_type == 2) {
            uint256 stationDefenseForce;
            address stationDefender;
            (stationDefender,,,,stationDefenseForce) = data.getStation(_assetId);
            if (_amt > stationDefenseForce) {
                data.changeAssetDrones(_type, _assetId, false, (stationDefenseForce-10));
                data.transferStation(stationDefender, msg.sender, _assetId);
            } else {
                data.changeAssetDrones(_type, _assetId, false, _amt);
            }
        } else { revert(); }
    }
    
    function defendAsset(uint8 _type, uint64 _assetId, uint256 _amt) requireData public {
        SpaceDataBase data = SpaceDataBase(dataC);
        require(data.getDrones(msg.sender) >= _amt);
        require(msg.sender == data.checkOwner(_type, _assetId));
        data.changeDroneBalance(msg.sender, false, _amt);
        data.changeAssetDrones(_type, _assetId, true, _amt);
    }
    
    function freeDrones() requireData public {
        SpaceDataBase data = SpaceDataBase(dataC);
        data.changeDroneBalance(msg.sender, true, 100);
    }
}