//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {Base64} from "./libraries/Base64.sol";

contract PodCastNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(address[] memory _admin, bool givenHighestAuthority)
        ERC721("Henkaku NFT", "henkaku")
    {}

    function getSVG() public pure returns (string memory) {
        return
            "<svg enable-background='new 0 0 2000 2000' viewBox='0 0 2000 2000' xmlns='http://www.w3.org/2000/svg'><clipPath id='a'><circle cx='692.4' cy='1179.7' r='121.4'/></clipPath><switch><foreignObject/><g><image height='2000' width='2000' href='https://gateway.pinata.cloud/ipfs/QmUETsUz1cR6pi9LPyEFnGrcwQYoGtvZmDdzZ2GdL4kfwv'/><g fill='#fff'><path d='m462.4 1067.9 3.6-2.3-.7-1.1 4-2.6.7 1.1 3.9-2.5-.7-1.1 4-2.6.7 1.1 3.5-2.3 1.7 2.6-3.5 2.3 1.8 2.8-4.1 2.7.5.7 6.4-4.2 1.8 2.8c1.2 1.8.6 4.2-1.1 5.3l-3.2 2.1.5.7 7.6-4.9 1.7 2.6-7.6 4.9 1.7 2.5-3.7 2.4-1.7-2.5-7.6 4.9-1.7-2.6 7.6-4.9-.5-.7-6.5 4.2-3.9-6 6.5-4.2-.5-.7-4.2 2.7-1.8-2.8-3.6 2.3zm11.6 6.2 2.5-1.6-.6-.9-2.5 1.6zm-1.9-7.9 3.9-2.5-.4-.6-3.9 2.5zm8 3.9 2.4-1.5-.6-.9-2.4 1.5zm-24.3-23.5-3.4.2c.3 1.4 0 3.1-1 4.9l3.4 1.2c.9-1.9 1.3-3.9 1-6.3zm15.2 1.8c.4-1.2.6-1.7.6-2.3l-1.3-1.9-7.4 4.8.2-1.2 2-1.3c.5-.4.8-.9.9-1.5s-.1-1.2-.4-1.7l-2.5-3.9 5.3-3.4-1.7-2.6-7.9 5.1-.9-1.4-3.1 2 .9 1.4-7.6 5 1.7 2.6 5.6-3.6c.8 1.1 1.2 2 1.4 2.9.2 1.1.1 2.3-.4 3.4l2.8.4c-.2.7-.5 1.6-1 2.5-.8 1.4-1.7 2.7-2.5 3.5l1.7 2.6c.2-.1 1.4-1.1 2.2-2.2.7-1 1.3-2 1.3-2.1.8.1 1.6.2 2.5.1-.4.6-1.1 1.5-2.3 2.6-1.2 1-2.1 1.7-3.2 2.4l1.8 2.8c1.5-1 3.8-2.9 5.2-4.3 1.3-1.4 2.4-2.7 3-4 3.4-.2 7-1.9 10.3-3.9l-1.9-3c-2.7 1.7-4.7 2.6-6.3 2.9.2-.5.5-1.4 1-2.7zm-12.7-5.9 1.9-1.2 1.5 2.3s.5.7-.2 1.2l-1.3.9 2.4 2.2-1.9.7c0-1.2-.8-3.2-2.4-6.1zm8.3 8.2c-.3.7-.6 1.2-.9 1.4-.9.3-1.9.3-3 .1l4.4-2.8c0 .2-.2.7-.5 1.3zm-.6-12.6-1.3 3.2c.6 0 1.5.2 2.8.7 1.1.3 1.9.7 2.5 1.1l1.2-3.4c-.6-.3-1.4-.6-2.5-1-1.3-.4-2.1-.6-2.7-.6zm-55.2 61.3c-2.4 1.5-3.9 3.7-4.6 6.3-.7 2.7-.3 5.1 1.2 7.4l7.2 11.2 4.8-3.1-2.8-4.3 7.6-5 2.8 4.3 4.8-3.1-7.2-11.2c-1.4-2.2-3.5-3.6-6.2-4.1-2.7-.4-5.3.1-7.6 1.6zm10.5 8-7.6 5-1.5-2.4c-.6-1-.8-2-.5-3.2s1-2.1 2.1-2.8 2.2-.9 3.4-.7 2.1.8 2.7 1.8zm18.4-26.1-6.9 4.4-.7 11-4.8-7.4-4.8 3.1 12.2 18.9 4.8-3.1-5.3-8.2 11.7 4.1 6.9-4.5-14.6-4.5zm14.8-9.6 7.2 11.2c.6 1 .8 2 .5 3.2s-1 2.1-2.1 2.8-2.2.9-3.4.7-2.1-.8-2.7-1.8l-7.2-11.2-4.8 3.1 7.2 11.2c1.4 2.2 3.5 3.6 6.2 4.1s5.3-.1 7.6-1.6c2.4-1.5 3.9-3.7 4.6-6.3.7-2.7.3-5.1-1.2-7.4l-7.2-11.2zm-10.2 1.4-6.7-10.4 15.4 4.7 3.8-2.4-11.5-17.8-123.5-10.4 67.2 103.8.9-12.3 5.4 8.3 4.8-3.1-5.3-8.2 11.7 4.1 6.9-4.5-14.6-4.5 1.6-13.8-6.9 4.4-.7 11-2.1-3.3 2.1-28.7 7.4 11.5 4.7-3.1-4.6-7.2 7.7-5 4.6 7.2 4.7-3.1-11.6-17.9 4.6-3 11.6 17.9 13.1-8.5-2.9-4.5-8.3 5.4-1.8-2.7 8.3-5.4-2.9-4.5-8.3 5.4-1.8-2.7 8.3-5.4-2.3-3.5 4.5-2.9 11.5 17.8zm2.3-13.4-14-4.3 7.9-5.1zm-41.5 22.3-7.7 5-4-6.1v-.2l7.6-4.9z'/><path d='m1019.4 619.7-5.7-8.8-9.4 6.1 5.7 8.8-4.4 2.8-13.6-20.9 4.4-2.8 5.5 8.5 9.4-6.1-5.5-8.5 4.4-2.8 13.6 20.9z'/><path d='m1041.5 605.4-13.9 9-13.6-20.9 13.9-9 2.3 3.6-9.5 6.1 3.3 5 8.9-5.8 2.2 3.4-8.9 5.8 3.4 5.3 9.5-6.1z'/><path d='m1044.9 603.2-13.6-20.9 3.7-2.4 18.6 7.3.1-.1-8.8-13.6 4.2-2.7 13.6 20.9-3.6 2.3-18.7-7.4-.1.1 8.9 13.7z'/><path d='m1066.4 589.3-13.6-20.9 4.4-2.8 6.2 9.5.1-.1 1.7-14.6 4.9-3.2-1.7 14.3 15.8 6.3-5.2 3.4-11.9-4.7-.4 3.6 4.1 6.4z'/><path d='m1095.7 563.1-7.4 4.8 1.7 6.1-4.5 2.9-6.3-25.6 5.1-3.3 20.8 16.2-4.7 3zm-8.5.9 5.5-3.5-8.2-6.8-.1.1z'/><path d='m1107.4 562.8-13.6-20.9 4.4-2.8 6.2 9.5.1-.1 1.7-14.6 4.9-3.2-1.7 14.3 15.8 6.3-5.2 3.4-11.9-4.7-.4 3.6 4.1 6.4z'/><path d='m1126.2 539.5c1.7 2.7 4.5 3.4 7.3 1.6s3.2-4.6 1.5-7.3l-8.5-13.1 4.4-2.8 8.8 13.5c3 4.6 1.6 10-3.7 13.4-5.4 3.5-10.8 2.5-13.8-2.1l-8.8-13.5 4.4-2.8z'/><path d='m1172 520.9-9.1-14.1-.1.1 3.3 17.6-2.8 1.8-14.7-10.2-.1.1 9.1 14.1-3.9 2.5-13.6-20.9 5.1-3.3 15.6 11 .1-.1-3.7-18.7 5.1-3.3 13.6 20.9z'/><path d='m1193.6 506.9-13.9 9-13.6-20.9 13.9-9 2.3 3.6-9.5 6.1 3.3 5 8.9-5.8 2.2 3.4-8.9 5.8 3.4 5.3 9.5-6.1z'/><path d='m1215.3 492.9-9.1-14.1-.1.1 3.3 17.6-2.8 1.8-14.7-10.2-.1.1 9.1 14.1-3.9 2.5-13.6-20.9 5.1-3.3 15.6 11 .1-.1-3.7-18.7 5.1-3.3 13.6 20.9z'/><path d='m1223 487.9-13.6-20.9 9.1-5.9c3.9-2.5 7.7-2.1 9.8 1.1 1.5 2.3 1 5.3-1 7.1l.1.1c3-1.6 6.4-.9 8.2 1.9 2.4 3.7 1.1 7.8-3.4 10.7zm-3.5-15.1 3.1-2c2.3-1.5 3-3.4 1.9-5.2-1.1-1.7-2.9-1.9-4.9-.6l-3.6 2.3zm9.5 6.5c2.5-1.6 3.2-3.6 1.9-5.6s-3.4-2.1-5.9-.4l-3.7 2.4 3.9 6.1z'/><path d='m1256.2 466.4-13.9 9-13.6-20.9 13.9-9 2.3 3.6-9.5 6.1 3.3 5 8.9-5.8 2.2 3.4-8.9 5.8 3.4 5.3 9.5-6.1z'/><path d='m1264 461.3-4.4 2.8-13.6-20.9 8.6-5.6c4.8-3.1 9.2-2.4 11.9 1.8 1.7 2.7 1.8 5.9.1 8.4l9.8 5.5-5 3.2-8.9-5.1-3.5 2.3zm-7.1-10.8 3.8-2.4c2.2-1.4 2.7-3.5 1.3-5.6-1.3-2-3.5-2.5-5.7-1l-3.7 2.4z'/><path d='m1278.1 443.8c1.3 1.6 3.9 1.6 6.2.1s3.2-3.7 2.2-5.2c-.9-1.4-2.4-1.5-5.3-.4l-3.1 1.2c-4.4 1.7-7.6.9-9.5-2.1-2.5-3.9-.8-8.6 3.9-11.6 4.9-3.2 9.6-2.6 12.1 1.1l-4.1 2.7c-1.3-1.7-3.5-1.7-5.7-.3s-2.9 3.4-1.9 4.9c.8 1.3 2.3 1.4 5.1.4l2.9-1.1c4.8-1.8 7.8-1.2 9.8 2 2.6 4.1 1 8.8-4.2 12.1-5 3.3-9.8 2.9-12.5-.9z'/><path d='m1311.3 430.7-5.7-8.8-9.4 6.1 5.7 8.8-4.4 2.8-13.6-20.9 4.4-2.8 5.5 8.5 9.4-6.1-5.5-8.5 4.4-2.8 13.6 20.9z'/><path d='m1319.5 425.4-13.6-20.9 4.4-2.8 13.6 20.9z'/><path d='m1322.6 393.6c4.3-2.8 9.1-1.8 11.9 2.5s1.6 9.1-2.8 12l-3.9 2.5 4.3 6.6-4.4 2.8-13.6-20.9zm3 13.6 3-1.9c2.5-1.6 3.1-3.9 1.6-6.3s-3.9-2.8-6.4-1.1l-3 1.9z'/><path d='m1014.4 1197.1-3.8 2.5-11.8-18.2 7.5-4.8c4.2-2.7 8-2.1 10.3 1.5 1.5 2.3 1.6 5.1 0 7.3l8.5 4.7-4.3 2.8-7.7-4.5-3.1 2zm-6.1-9.4 3.3-2.1c1.9-1.2 2.3-3.1 1.2-4.9s-3.1-2.1-5-.9l-3.2 2.1z'/><path d='m1038.1 1168.8c3.8 5.8 2.7 11.6-2.7 15.1s-11.1 2.1-14.9-3.7-2.7-11.6 2.7-15.1 11.1-2.1 14.9 3.7zm-13.7 8.9c2.5 3.8 5.9 5 8.9 3.1s3.3-5.6.9-9.4c-2.5-3.8-6-5-8.9-3.1-3 1.9-3.3 5.6-.9 9.4z'/><path d='m1058.4 1168.6-11.8 7.6-11.8-18.2 3.8-2.5 9.8 15.1 8-5.2z'/><path d='m1072.5 1159.5-12.1 7.8-11.8-18.2 12.1-7.8 2 3.1-8.3 5.3 2.8 4.4 7.8-5 1.9 2.9-7.8 5 3 4.6 8.3-5.3z'/><text font-family='SFProDisplay-Regular' font-size='36.7647' letter-spacing='1' transform='matrix(.8393 -.5436 .5436 .8393 1034.6199 1239.8652)'>Podcast Beginner</text><path d='m854.6 952.2c1.2 1.4 3.4 1.4 5.4.1s2.8-3.2 1.9-4.5c-.8-1.2-2.1-1.3-4.6-.3l-2.7 1c-3.8 1.5-6.6.8-8.3-1.8-2.2-3.4-.7-7.5 3.4-10.1 4.2-2.7 8.3-2.3 10.5 1l-3.6 2.3c-1.1-1.5-3.1-1.5-5-.3s-2.6 2.9-1.7 4.3c.7 1.1 2 1.2 4.4.3l2.5-1c4.2-1.6 6.8-1 8.6 1.7 2.3 3.5.9 7.6-3.6 10.5-4.4 2.8-8.5 2.6-10.8-.8z'/><path d='m883.5 940.8-5-7.7-8.2 5.3 5 7.7-3.8 2.5-11.8-18.2 3.8-2.5 4.8 7.4 8.2-5.3-4.8-7.4 3.8-2.5 11.8 18.2z'/><path d='m901.6 916.2c3.8 5.8 2.7 11.6-2.7 15.1s-11.1 2.1-14.9-3.7-2.7-11.6 2.7-15.1c5.4-3.6 11.2-2.2 14.9 3.7zm-13.7 8.8c2.5 3.8 5.9 5 8.9 3.1s3.3-5.6.9-9.4c-2.5-3.8-6-5-8.9-3.1-3 1.9-3.3 5.6-.9 9.4z'/><path d='m916.8 919.2-3.6 2.3-16.6-15.1 3.9-2.6 11.4 11.3.1-.1-5.1-15.4 3.2-2.1 11.9 11 .1-.1-5.7-15.1 3.9-2.6 7 21.3-3.6 2.3-11.5-10.2-.1.1z'/><path d='m939.5 904.6-11.8-18.2 3.2-2.1 16.2 6.4.1-.1-7.7-11.9 3.6-2.4 11.8 18.2-3.2 2-16.2-6.4-.1.1 7.7 11.9z'/><path d='m965.6 881.4-6.4 4.1 1.5 5.3-3.9 2.5-5.5-22.3 4.5-2.9 18.1 14.1-4.1 2.6zm-7.4.7 4.8-3.1-7.2-5.9-.1.1z'/><path d='m991.7 870.7-8-12.3-.1.1 2.9 15.3-2.4 1.6-12.8-8.9-.1.1 8 12.3-3.4 2.2-11.8-18.3 4.4-2.9 13.5 9.6.1-.1-3.2-16.3 4.4-2.9 11.8 18.2z'/><path d='m1010.5 858.6-12.1 7.8-11.8-18.2 12.1-7.8 2 3.1-8.3 5.3 2.8 4.4 7.8-5 1.9 2.9-7.8 5 3 4.6 8.3-5.3z'/><text font-family='SFProDisplay-Regular' font-size='36.7647' letter-spacing='1' transform='matrix(.8393 -.5436 .5436 .8393 878.9883 999.5721)'>JOI ITO PODCAST</text><path d='m1203.1 708c3.7-2.4 7.9-1.6 10.3 2.1s1.4 8-2.5 10.4l-3.4 2.2 3.7 5.7-3.8 2.5-11.8-18.2zm2.5 11.8 2.6-1.7c2.2-1.4 2.7-3.4 1.4-5.5s-3.4-2.4-5.5-1l-2.6 1.7z'/><path d='m1234.6 700.5c3.8 5.8 2.7 11.6-2.7 15.1s-11.1 2.1-14.9-3.7-2.7-11.6 2.7-15.1 11.1-2.1 14.9 3.7zm-13.7 8.9c2.5 3.8 5.9 5 8.9 3 3-1.9 3.3-5.6.9-9.4-2.5-3.8-5.9-5-8.9-3.1-3 2-3.4 5.7-.9 9.5z'/><path d='m1243.1 707.9-11.8-18.2 3.8-2.5 11.8 18.2z'/><path d='m1250.2 703.3-11.8-18.2 3.2-2.1 16.2 6.4.1-.1-7.7-11.9 3.6-2.4 11.8 18.2-3.2 2-16.2-6.4-.1.1 7.7 11.9z'/><path d='m1272.9 688.6-9.8-15.1-5.3 3.4-2-3.1 14.3-9.3 2 3.1-5.3 3.4 9.8 15.1z'/><text font-family='SFProDisplay-Regular' font-size='36.7647' letter-spacing='1' transform='matrix(.8393 -.5436 .5436 .8393 1231.4888 771.2622)'>$10Henkaku</text><path d='m928.4 1056.4c3.7-2.4 7.9-1.6 10.3 2.1s1.4 8-2.5 10.4l-3.4 2.2 3.7 5.7-3.8 2.5-11.8-18.2zm2.5 11.9 2.6-1.7c2.2-1.4 2.7-3.4 1.4-5.5s-3.4-2.4-5.5-1l-2.6 1.7z'/><path d='m952.4 1066.8-3.8 2.5-11.8-18.2 7.5-4.8c4.2-2.7 8-2.1 10.3 1.5 1.5 2.3 1.6 5.1 0 7.3l8.5 4.7-4.3 2.8-7.7-4.5-3.1 2zm-6.1-9.5 3.3-2.1c1.9-1.2 2.3-3.1 1.2-4.9s-3.1-2.1-5-.9l-3.2 2.1z'/><path d='m976.1 1038.5c3.8 5.8 2.7 11.6-2.7 15.1s-11.1 2.1-14.9-3.7-2.7-11.6 2.7-15.1c5.4-3.6 11.1-2.1 14.9 3.7zm-13.7 8.8c2.5 3.8 5.9 5 8.9 3.1s3.3-5.6.9-9.4c-2.5-3.8-6-5-8.9-3.1s-3.4 5.6-.9 9.4z'/><path d='m988.6 1043.3-17.9-14.2 4.3-2.8 13.4 11.6.1-.1-5.1-17 4.2-2.7 5.7 22.2z'/><path d='m1013.2 1027.3-12.1 7.8-11.8-18.2 12.1-7.8 2 3.1-8.3 5.3 2.8 4.4 7.8-5 1.9 2.9-7.8 5 3 4.6 8.3-5.3z'/><path d='m1011.4 1002.7c5.5-3.5 10.8-2.4 14.5 3.4s2.7 11.3-2.7 14.8l-7 4.5-11.8-18.2zm6.6 17.1 2.7-1.7c3.4-2.2 3.9-5.5 1.4-9.4-2.5-3.8-5.7-4.7-9.1-2.5l-2.7 1.7z'/><path d='m1039.4 1010.3-11.8-18.2 7.9-5.1c3.4-2.2 6.7-1.9 8.5.9 1.3 2 .9 4.6-.9 6.2l.1.1c2.6-1.4 5.6-.8 7.1 1.6 2.1 3.2 1 6.8-2.9 9.3zm-3-13.1 2.7-1.8c2-1.3 2.6-3 1.6-4.5-.9-1.5-2.5-1.6-4.3-.5l-3.1 2zm8.3 5.7c2.2-1.4 2.8-3.1 1.6-4.9-1.1-1.7-2.9-1.8-5.2-.4l-3.2 2.1 3.4 5.3z'/><path d='m1060.4 996.8-4.4-6.8-13.7-7.3 4.2-2.7 9.1 5.1.1-.1-.9-10.4 4.1-2.6 1 15.5 4.4 6.8z'/><text font-family='SFProDisplay-Regular' font-size='36.7647' letter-spacing='1' transform='matrix(.8393 -.5436 .5436 .8393 956.8052 1119.7185)'>Henkaku Community</text><path d='m1283.2 826.6c5.5-3.5 10.8-2.4 14.5 3.4s2.7 11.3-2.7 14.8l-7 4.5-11.8-18.2zm6.6 17.1 2.7-1.7c3.4-2.2 3.9-5.5 1.4-9.4-2.5-3.8-5.7-4.7-9.1-2.5l-2.7 1.7z'/><path d='m1313 826.9-6.4 4.1 1.5 5.3-3.9 2.5-5.5-22.3 4.5-2.9 18.1 14.1-4.1 2.6zm-7.4.8 4.8-3.1-7.2-5.9-.1.1z'/><path d='m1325.4 825.1-9.8-15.1-5.3 3.4-2-3.1 14.3-9.3 2 3.1-5.3 3.4 9.8 15.1z'/><path d='m1348.6 810.1-12.1 7.8-11.8-18.2 12.1-7.8 2 3.1-8.3 5.3 2.8 4.4 7.8-5 1.9 2.9-7.8 5 3 4.6 8.3-5.3z'/><text font-family='SFProDisplay-Regular' font-size='36.7647' letter-spacing='1' transform='matrix(.8393 -.5436 .5436 .8393 1312.0984 889.6022)'>2022.02.15</text><text font-family='Helvetica-Bold' font-size='59.8892' transform='matrix(.8393 -.5436 .5436 .8393 709.9462 1399.4677)'>isbtty</text></g><g clip-path='url(#a)'><image height='426' overflow='visible' transform='matrix(.5037 -.3262 .3262 .5037 515.7773 1144.6727)' width='426' href='https://lh3.googleusercontent.com/QYRtSrq6MvDwr0Yy-P-1pzjS4W5xefhN61UYTthffTR6XHtRFioaTcvuzxl4Pn8_Wzl-XY6YiZZ-5WBTJ0iz0SmAcijMt6I0H26Y7is=w600'/></g><g fill='#fff'><text font-family='SFProDisplay-Regular' font-size='33.1887' letter-spacing='1' transform='matrix(.8393 -.5436 .5436 .8393 795.085 1436.4669)'>0xc3...CFe</text><path d='m771.3 1427.4-1.7 1.1-1.8-2.7c-1.7-2.6-5.1-3.3-7.7-1.7l-18.7 12.1c-2.6 1.7-3.3 5.1-1.7 7.7l12.1 18.7c1.7 2.6 5.1 3.3 7.7 1.7l18.7-12.1c2.6-1.7 3.3-5.1 1.7-7.7l-1.8-2.7 1.7-1.1c1.7-1.1 2.2-3.5 1.1-5.2l-4.5-6.9c-1-1.9-3.3-2.4-5.1-1.2zm5.2 19.3c.4.7.2 1.6-.4 2l-18.7 12.1c-.7.4-1.6.2-2-.4l-12.1-18.7c-.4-.7-.2-1.6.4-2l18.7-12.1c.7-.4 1.6-.2 2 .4l1.8 2.7-4.3 2.8c-1.7 1.1-2.2 3.5-1.1 5.2l4.5 6.9c1.1 1.7 3.5 2.2 5.2 1.1l4.3-2.8zm.8-9.4-1.4.9-3.5 2.3-4 2.6-4.1-6.3 4-2.6 3.5-2.3 1.4-.9z'/><path d='m768.2 1436.4c-.9.6-1.2 1.8-.6 2.8.6.9 1.8 1.2 2.8.6s1.2-1.8.6-2.8c-.6-.9-1.9-1.2-2.8-.6z'/></g></g></switch></svg>";
    }

    function mintAndTransfer(address _to) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        string memory svg = getSVG();
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": ',
                        '"Henkaku PodCast NFT",',
                        '"description": ',
                        '"Henkaku PodCast NFT prototype",',
                        '"image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        console.log(finalTokenUri);

        _safeMint(_to, newItemId);
        _setTokenURI(newItemId, finalTokenUri);

        return newItemId;
    }
}
