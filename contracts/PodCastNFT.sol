//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";

contract PodCastNFT is ERC721, ERC2771Context {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(MinimalForwarder forwarder)
    ERC721("Henkaku PodCast NFT", "HenkakuPod")
    ERC2771Context(address(forwarder)) {
    }

    // TODO: 管理者のみ実行可能にする必要あり
    function mintAndTransfer(address _to) public returns (uint256){
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint( _msgSender(), newItemId);
        safeTransferFrom( _msgSender(), _to, newItemId);

        return newItemId;
    }


     function _msgSender() internal view override(Context, ERC2771Context)
        returns (address sender) {
        sender = ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context)
        returns (bytes calldata) {
        return ERC2771Context._msgData();
    }
}
