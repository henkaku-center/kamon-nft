//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PodCastNFT is ERC721, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant UPVOTE_FOR_ADMIN = keccak256("UPVOTE_FOR_ADMIN");
    bytes32 public constant UPVOTE_FOR_WITHDRAW = keccak256("UPVOTE_FOR_WITHDRAW");

    struct Vote {
      mapping(address => bool) voter;
      uint256 votes;
    }

    uint private _numberOfAdmins;
    mapping(bytes32 => mapping(address => Vote)) private votes;

    constructor(address[] memory _admins) ERC721("Henkaku NFT", "henkaku") {
      //_setRoleAdmin(ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
      addInitialAdmins(_admins);
    }

    function _hasConsensus(address _candidate, bytes32 _role) public view returns (bool) {
      return votes[_role][_candidate].votes >= _numberOfAdmins / 3;
    }

    function acceptAsAdmin(address _candidate) public {
        Vote storage _vote = votes[UPVOTE_FOR_ADMIN][_candidate];
        require(!_vote.voter[msg.sender], "You cannot vote more than once");
        _vote.voter[msg.sender] = true;
        _vote.votes ++;

        if (_hasConsensus(_candidate, UPVOTE_FOR_ADMIN)) {
          _grantRole(ADMIN_ROLE, _candidate);
          _numberOfAdmins ++;
        }
    }

    function acceptWithdraw(address _candidate) public {
        Vote storage _vote = votes[UPVOTE_FOR_WITHDRAW][_candidate];
        require(!_vote.voter[msg.sender], "You cannot vote more than once");
        _vote.voter[msg.sender] = true;
        _vote.votes ++;

        if (_hasConsensus(_candidate, UPVOTE_FOR_WITHDRAW)) {
          _revokeRole(ADMIN_ROLE, _candidate);
          _numberOfAdmins --;
        }
    }

    function addInitialAdmins(address[] memory _admins) private {
      for (uint i=0; i < _admins.length; i++) {
        _grantRole(ADMIN_ROLE, _admins[i]);
        _grantRole(DEFAULT_ADMIN_ROLE, _admins[i]);
        _numberOfAdmins ++;
      }
    }

    function updateNFT(uint256 tokenId) public {
      require(hasRole(ADMIN_ROLE, msg.sender), "You are not authorized to update nft");
      //TODO update nft
      console.log("Wow epic!!");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
