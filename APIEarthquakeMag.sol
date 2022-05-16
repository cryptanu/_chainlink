// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract APIEarthquakeMag is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint256 public mag;
    string public minLat;
    string public minLong;
    string public maxLat;
    string public maxLong;
    string public starttime;
    string public endtime;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    string public url_a = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=";
    string public and  = "&endtime=";
    string public andminlat = "&minlatitude=";
    string public andminlong = "&minlongitude=";
    string public andmaxlat = "&maxlatitude=";
    string public andmaxlong = "&maxlongitude=";

    string public concat;
    
    constructor() {
        setPublicChainlinkToken();
        oracle = 0x9904415Db0B70fDd242b6Fe835d2bBc155466e8e;
        jobId = "69cf5186b05a4497be74f85236e8ba34";
        fee = 0.0 * 10 ** 18; // (Varies by network and job)
    }

    function inputLocation(
        string memory _minLat, 
        string memory _minLong, 
        string memory _maxLat, 
        string memory _maxLong, 
        string memory _starttime,
        string memory _endtime ) public 
        {
        minLat = _minLat;
        minLong = _minLong;
        maxLat = _maxLat;
        maxLong = _maxLong;
        starttime = _starttime;
        endtime = _endtime;

        concat = string(abi.encodePacked(url_a,starttime,and,_endtime,andminlat,_minLat,andminlong,_minLong,andmaxlat,_maxLat,andmaxlong,_maxLong));
        }
    
    function requestMagnitudeData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", concat);
        request.add("path", "features,0,properties,mag"); // Chainlink nodes 1.0.0 and later support this format
        
        // Multiply the result by 1000000000000000000 to remove decimals
        // int timesAmount = 10**18;
        // request.addInt("times", timesAmount);
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, uint256 _mag) public recordChainlinkFulfillment(_requestId)
    {
        mag = _mag;
    }
    
    // Implement a withdraw function to avoid locking your LINK in the contract
    function withdrawLink(address _to) external {
        // address(this).sendTransaction({ to: _to, value: address(this).balance });
        payable(address(_to)).transfer(address(this).balance);
    } 
}
