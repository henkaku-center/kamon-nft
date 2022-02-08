//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ConsensusAdminable is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPVOTE_FOR_ADMIN = keccak256("UPVOTE_FOR_ADMIN");
    bytes32 public constant UPVOTE_FOR_WITHDRAW = keccak256("UPVOTE_FOR_WITHDRAW");
    uint public constant PERCENTAGE_OF_CONSENSUS = 3;

    struct Vote {
      mapping(address => bool) voter;
      uint256 votes;
    }

    uint private _numberOfAdmins;
    mapping(bytes32 => mapping(address => Vote)) private votes;

    constructor(address[] memory _admin, bool givenHighestAuthority) {
      addInitialAdmins(_admin, givenHighestAuthority);
    }

    function _hasConsensus(address _candidate, bytes32 _role) public view returns (bool) {
      return votes[_role][_candidate].votes >= _numberOfAdmins / PERCENTAGE_OF_CONSENSUS;
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

    function addInitialAdmins(address[] memory _admins, bool givenHighestAuthority) internal {
      for (uint i=0; i < _admins.length; i++) {
        _grantRole(ADMIN_ROLE, _admins[i]);
        if (givenHighestAuthority) {
          _grantRole(DEFAULT_ADMIN_ROLE, _admins[i]);
        }
        _numberOfAdmins ++;
      }
    }
}
