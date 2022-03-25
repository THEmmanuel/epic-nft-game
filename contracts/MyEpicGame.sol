// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// String encoding libraries
import { Base64 } from "./libraries/Base64.sol";

import "hardhat/console.sol";


contract MyEpicGame is ERC721 {

  struct CharacterAttributes {
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
    uint CharacterIndex;

  }

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  mapping(uint => CharacterAttributes) public defaultAttributes;
  CharacterAttributes[] defaultCharacters;
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  struct BigBoss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
  }
  BigBoss public bigBoss;

  mapping(address => uint256) public nftHolders;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    string memory bossName,
    string memory bossImageURI,
    uint bossHp,
    uint bossAttackDmg
  )
    ERC721("Heroes", "HERO")
  {
    bigBoss = BigBoss({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossHp,
      maxHp: bossHp,
      attackDamage: bossAttackDmg
    });

    console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

    for(uint i = 0; i < characterIds.length; i += 1) {
      defaultAttributes[characterIds[i]] = CharacterAttributes({
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        attackDamage: characterAttackDmg[i]
      });

      CharacterAttributes memory c = defaultAttributes[characterIds[i]];
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }
    _tokenIds.increment();
  };

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            charAttributes.name,
            ' -- NFT #: ',
            Strings.toString(_tokenId),
            '", "description": "CriticalHit is a turn-based NFT game where you take turns to attack the boos.", "image": "',
            charAttributes.imageURI,
            '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value": 300 }, { "trait_type": "Attack Damage", "value": ',
            strAttackDamage,', "max_value": 400} ]}'
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
  };

  function mintCharacterNFT(uint _characterIndex) external {
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);    
    nftHolders[msg.sender] = newItemId;
    _tokenIds.increment();
    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  function attackBoss() public {
    // Get the state of the player's NFT.
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

    console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);
    
    // Make sure the player has more than 0 HP.
    require (
        player.hp > 0,
        "Error: character must have HP to attack boss."
    );

    // Make sure the boss has more than 0 HP.
    require (
        bigBoss.hp > 0,
        "Error: boss must have HP to attack boss."
    );
    
    // Allow player to attack boss.
    if (bigBoss.hp < player.attackDamage) {
        bigBoss.hp = 0;
    } else {
        bigBoss.hp = bigBoss.hp - player.attackDamage;
    }

    // Allow boss to attack player.
    if (player.hp < bigBoss.attackDamage) {
        player.hp = 0;
    } else {
        player.hp = player.hp - bigBoss.attackDamage;
    }
    
    // Console for ease.
    console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
    console.log("Boss attacked player. New player hp: %s\n", player.hp);
  };

  function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];

        // If the user has a tokenId in the map, return their character.
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        }

        // Else, return an empty character.
        else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        } 
  };

  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
  };

  function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    };
}