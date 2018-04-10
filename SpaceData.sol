pragma solidity 0.4.19;

import './SpaceDataBase.sol';

contract SpaceData is SpaceDataBase {
    
    struct Star {
        bytes32 name;
        address owner;
        uint64 objectId;
        uint32 energyOutput;
        uint32 matterOutput;
        uint32 scienceOutput;
        uint256 defenseForce;
        uint256 lastProduce;
        uint256 createTime;
    }
    
    struct Planet {
        bytes32 name;
        address owner;
        uint64 objectId;
        uint64 goodId;
        uint8 level;
        uint8 difficulty;
        uint256 defenseForce;
        uint256 lastProduce;
        uint256 createTime;
    }
    
    struct Station {
        bytes32 name;
        address owner;
        uint64 objectId;
        uint8 level;
        uint8 difficulty;
        uint256 defenseForce;
        uint256 lastProduce;
        uint256 createTime;
    }
    
    struct Good {
        bytes32 name;
        uint64 goodId;
        bool craftable;
        bool extractable;
        mapping(address => uint256) goodBalances;
    }
    
    mapping(uint64 => Good) public goodCollection;
    
    mapping(uint64 => uint64[]) public goodCraftingIds;
    mapping(uint64 => uint8[]) public goodCraftingAmts;
    
    //event NewStar(bytes32 _name, uint _id, address _owner);
    //event NewPlanet(bytes32 _name, uint _id, address _owner);
    //event NewStation(bytes32 _name, uint _id, address _owner);
    
    mapping(address => uint256) public droneBalances;
    mapping(address => uint256) public XPBalances;
    
    mapping(uint64 => Star) public starCollection;
    mapping(address => uint64[]) public playerStars;
    
    mapping(uint64 => Planet) public planetCollection;
    mapping(address => uint64[]) public playerPlanets;
    
    mapping(uint64 => Station) public stationCollection;
    mapping(address => uint64[]) public playerStations;
    
    uint64 public totalStars = 0;
    uint64 public totalPlanets = 0;
    uint64 public totalStations = 0;
    uint64 public totalGoods = 0;
    
    function SpaceData() public {
        addGoodType("Energy");
        addGoodType("Matter");
        addGoodType("Science");
        addGoodType("Steel");
    }
    
    //write
    
    function addStar(bytes32 _name, address _owner) public {
        totalStars++;
        Star storage newStar = starCollection[totalStars];
        newStar.name = _name;
        newStar.owner = _owner;
        newStar.objectId = totalStars;
        newStar.energyOutput = 1;
        newStar.matterOutput = 1;
        newStar.scienceOutput = 1;
        newStar.defenseForce = 10;
        newStar.lastProduce = block.number;
        newStar.createTime = block.number;
        playerStars[_owner].push(totalStars);
        //emit NewStar(_name, totalStars, msg.sender); 
    }
    
    function addPlanet(bytes32 _name, uint64 _goodId, address _owner) public {
        require(_goodId <= totalGoods);
        require(_goodId > 2);
        totalPlanets++;
        Planet storage newPlanet = planetCollection[totalPlanets];
        newPlanet.name = _name;
        newPlanet.owner = _owner;
        newPlanet.objectId = totalPlanets;
        newPlanet.goodId = _goodId;
        newPlanet.level = 1;
        newPlanet.difficulty = 1;
        newPlanet.defenseForce = 10;
        newPlanet.lastProduce = block.number;
        newPlanet.createTime = block.number;
        playerPlanets[_owner].push(totalPlanets);
        //emit NewPlanet(_name, totalPlanets, msg.sender);
    }
    
    function addStation(bytes32 _name, address _owner) public {
        totalStations++;
        Station storage newStation = stationCollection[totalStations];
        newStation.name = _name;
        newStation.owner = _owner;
        newStation.objectId = totalStations;
        newStation.level = 1;
        newStation.difficulty = 1;
        newStation.defenseForce = 10;
        newStation.lastProduce = block.number;
        newStation.createTime = block.number;
        playerStations[_owner].push(totalStations);
        //emit NewStation(_name, totalStations, msg.sender);
    }
    
    function addGoodType(bytes32 _name) public {
        totalGoods++;
        Good storage newGood = goodCollection[totalGoods];
        newGood.name = _name;
        newGood.goodId = totalGoods;
    }
    
    function addProductionRecipe(uint64 _outputId, uint64[] _inputIds, uint8[] _inputAmts) public {
        require(_inputIds.length == _inputAmts.length);
        require(goodCollection[_outputId].craftable == false);
        goodCollection[_outputId].craftable = true;
        goodCraftingIds[_outputId] = _inputIds;
        goodCraftingAmts[_outputId] = _inputAmts;
    }
    
    function upgradeAsset(uint8 _assetType, uint8 _config, uint64 _assetId) public {
        if (_assetType == 0) {
            //uint starXP = starCollection[_assetId].energyOutput + starCollection[_assetId].matterOutput + starCollection[_assetId].scienceOutput;
            if (_config == 0) {
                starCollection[_assetId].energyOutput++;
            } else if (_config == 1) {
                starCollection[_assetId].matterOutput++;
            } else if (_config == 2) {
                starCollection[_assetId].matterOutput++;
            } else { revert(); }
        } else if (_assetType == 1) {
            //uint planetXP = 10 * planetCollection[_assetId].level;
            if (_config == 0) {
                planetCollection[_assetId].level++;
                planetCollection[_assetId].difficulty++;
            } else if (_config == 1) {
                planetCollection[_assetId].difficulty--;
            } else { revert(); }
        } else if (_assetType == 2) {
            //uint stationXP = 10 * stationCollection[_assetId].level;
            if (_config == 0) {
                stationCollection[_assetId].level++;
                stationCollection[_assetId].difficulty++;
            } else if (_config == 1) {
                stationCollection[_assetId].difficulty--;
            } else { revert(); }
        } else { revert(); }
    }
    
    function produceGood(address _address, uint64 _goodId, uint8 _level, uint8 _difficulty) public {
        require(goodCollection[_goodId].craftable == true);
        for (uint i = 0; i < goodCraftingIds[_goodId].length; i++) {
            require(goodCollection[goodCraftingIds[_goodId][i]].goodBalances[_address] >= goodCraftingAmts[_goodId][i]*_difficulty);
            goodCollection[goodCraftingIds[_goodId][i]].goodBalances[_address] -= goodCraftingAmts[_goodId][i]*_difficulty;
        }
        goodCollection[_goodId].goodBalances[_address] += _level;
    }
    
    function changeGoodBalance(address _target, uint64 _goodId, bool _dir, uint256 _amt) public {
        if (_dir == true) {
            goodCollection[_goodId].goodBalances[_target] += _amt;
        } else if (_dir == false) {
            if (_amt >= goodCollection[_goodId].goodBalances[_target]) {
                goodCollection[_goodId].goodBalances[_target] = 0;
            } else {
                goodCollection[_goodId].goodBalances[_target] -= _amt;
            }
        }
    }
    
    function changeXPBalance(address _target, bool _dir, uint256 _amt) public {
        if (_dir == true) {
            XPBalances[_target] += _amt;
        } else if (_dir == false) {
            require(XPBalances[_target] >= _amt);
            XPBalances[_target] -= _amt;
        }
    }
    
    function changeDroneBalance(address _target, bool _dir, uint256 _amt) public {
        if (_dir == true) {
            droneBalances[_target] += _amt;
        } else if (_dir == false) {
            if (_amt >= droneBalances[_target]) {
                droneBalances[_target] = 0;
            } else {
                droneBalances[_target] -= _amt;
            }
        }
    }
    
    function changeAssetDrones(uint8 _type, uint64 _assetId, bool _dir, uint256 _amt) public {
        if (_type == 0) {
            if (_dir == true) {
                starCollection[_assetId].defenseForce += _amt;
            } else if (_dir == false) {
                if (_amt > starCollection[_assetId].defenseForce) {
                    starCollection[_assetId].defenseForce = 0;
                } else {
                    starCollection[_assetId].defenseForce -= _amt;
                }
            }
        } else if (_type == 1) {
            if (_dir == true) {
                planetCollection[_assetId].defenseForce += _amt;
            } else if (_dir == false) {
                if (_amt > planetCollection[_assetId].defenseForce) {
                    planetCollection[_assetId].defenseForce = 0;
                } else {
                    planetCollection[_assetId].defenseForce -= _amt;
                }
            }
        } else if (_type == 2) {
            if (_dir == true) {
                stationCollection[_assetId].defenseForce += _amt;
            } else if (_dir == false) {
                if (_amt > stationCollection[_assetId].defenseForce) {
                    stationCollection[_assetId].defenseForce = 0;
                } else {
                    stationCollection[_assetId].defenseForce -= _amt;
                }
            }
        } else { revert(); }
    }
    
    function updateCooldown(uint8 _type, uint64 _assetId) public {
        if (_type == 0) {
            starCollection[_assetId].lastProduce = block.number;
        } else if (_type == 1) {
            planetCollection[_assetId].lastProduce = block.number;
        } else if (_type == 2) {
            stationCollection[_assetId].lastProduce = block.number;
        }
    }
    
    function quickGood(uint64 _goodId) public {
        goodCollection[_goodId].goodBalances[msg.sender] += 20;
    }
    
    function transferStar(address _from, address _to, uint64 _starId) public {
        require(starCollection[_starId].owner == _from);
        require(_from != _to);
        uint foundIndex = 0;
        uint64[] storage objIdList = playerStars[_from];
        for (; foundIndex < objIdList.length; foundIndex++) {
            if (objIdList[foundIndex] == _starId) {
                break;
            }
        }
        if (foundIndex < objIdList.length) {
            objIdList[foundIndex] = objIdList[objIdList.length-1];
            delete objIdList[objIdList.length-1];
            objIdList.length--;
            starCollection[_starId].owner = _to;
            playerStars[_to].push(_starId);
        }
    }
    
    function transferPlanet(address _from, address _to, uint64 _planetId) public {
        require(planetCollection[_planetId].owner == _from);
        require(_from != _to);
        uint foundIndex = 0;
        uint64[] storage objIdList = playerPlanets[_from];
        for (; foundIndex < objIdList.length; foundIndex++) {
            if (objIdList[foundIndex] == _planetId) {
                break;
            }
        }
        if (foundIndex < objIdList.length) {
            objIdList[foundIndex] = objIdList[objIdList.length-1];
            delete objIdList[objIdList.length-1];
            objIdList.length--;
            planetCollection[_planetId].owner = _to;
            playerPlanets[_to].push(_planetId);
        }
    }
    
    function transferStation(address _from, address _to, uint64 _stationId) public {
        require(stationCollection[_stationId].owner == _from);
        require(_from != _to);
        uint foundIndex = 0;
        uint64[] storage objIdList = playerStations[_from];
        for (; foundIndex < objIdList.length; foundIndex++) {
            if (objIdList[foundIndex] == _stationId) {
                break;
            }
        }
        if (foundIndex < objIdList.length) {
            objIdList[foundIndex] = objIdList[objIdList.length-1];
            delete objIdList[objIdList.length-1];
            objIdList.length--;
            stationCollection[_stationId].owner = _to;
            playerStations[_to].push(_stationId);
        }
    }
    
    function ownerTransferStar(address _to, uint64 _starId) public {
        require(starCollection[_starId].owner == msg.sender);
        transferStar(msg.sender, _to, _starId);
    }
    
    function ownerTransferPlanet(address _to, uint64 _planetId) public {
        require(planetCollection[_planetId].owner == msg.sender);
        transferPlanet(msg.sender, _to, _planetId);
    }
    
    function ownerTransferStation(address _to, uint64 _stationId) public {
        require(stationCollection[_stationId].owner == msg.sender);
        transferStation(msg.sender, _to, _stationId);
    }
    
    //read
    
    function getStar(uint64 _starId) public view returns (address owner, uint64 objectId, uint32 energyOutput, uint32 matterOutput, uint32 scienceOutput, uint256 defenseForce) {
        Star memory star = starCollection[_starId];
        owner = star.owner;
        objectId = star.objectId;
        energyOutput = star.energyOutput;
        matterOutput = star.matterOutput;
        scienceOutput = star.scienceOutput;
        defenseForce = star.defenseForce;
    }
    
    function getPlanet(uint64 _planetId) public view returns (address owner, uint64 objectId, uint64 goodId, uint8 level, uint8 difficulty, uint256 defenseForce) {
        Planet memory planet = planetCollection[_planetId];
        owner = planet.owner;
        objectId = planet.objectId;
        goodId = planet.goodId;
        level = planet.level;
        difficulty = planet.difficulty;
        defenseForce = planet.defenseForce;
    }
    
    function getStation(uint64 _stationId) public view returns (address owner, uint64 objectId, uint8 level, uint8 difficulty, uint256 defenseForce) {
        Station memory station = stationCollection[_stationId];
        owner = station.owner;
        objectId = station.objectId;
        level = station.level;
        difficulty = station.difficulty;
        defenseForce = station.defenseForce;
    }
    
    function getGoodBalance(address _address, uint64 _goodId) public view returns(uint256) {
        return(goodCollection[_goodId].goodBalances[_address]);
    }
    
    function getDrones(address _address) public view returns (uint256) {
        return droneBalances[_address];
    }
    
    function getStarByIndex(address _owner, uint _index) public view returns(uint64) {
        require(_index <= playerStars[_owner].length);
        return playerStars[_owner][_index];
    }
    
    function getPlanetByIndex(address _owner, uint _index) public view returns(uint64) {
        require(_index <= playerPlanets[_owner].length);
        return playerPlanets[_owner][_index];
    }
    
    function getStationByIndex(address _owner, uint _index) public view returns(uint64) {
        require(_index <= playerStations[_owner].length);
        return playerStations[_owner][_index];
    }
    
    function checkIfCraftable(uint64 _goodId) public view returns (bool) {
        return goodCollection[_goodId].craftable;
    }
    
    function checkCooldown(uint8 _type, uint64 _assetId) public view returns(uint) {
        if (_type == 0) {
            return (block.number - starCollection[_assetId].lastProduce);
        } else if (_type == 1) {
            return (block.number - planetCollection[_assetId].lastProduce);
        } else if (_type == 2) {
            return (block.number - stationCollection[_assetId].lastProduce);
        }
    }
    
    function checkOwner(uint8 _type, uint64 _assetId) public view returns(address) {
        if (_type == 0) {
            return starCollection[_assetId].owner;
        } else if (_type == 1) {
            return planetCollection[_assetId].owner;
        } else if (_type == 2) {
            return stationCollection[_assetId].owner;
        }
    }
    
    function getGameTotals() public view returns (uint64, uint64, uint64) {
        return (totalStars, totalPlanets, totalStations);
    }
    
    function getPlayerTotals(address _address) public view returns (uint256, uint256, uint256) {
        return(playerStars[_address].length, playerPlanets[_address].length, playerStations[_address].length);
    }
    
    function getPlayerAssets(address _address) public view returns (uint64[], uint64[], uint64[]) {
        return(playerStars[_address], playerPlanets[_address], playerStations[_address]);
    }
}