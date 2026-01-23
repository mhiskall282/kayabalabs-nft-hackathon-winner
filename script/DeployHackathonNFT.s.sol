// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/KayabaHackathonNFT.sol";

contract DeployHackathonNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // REPLACE WITH YOUR 4 METADATA URIs FROM LIGHTHOUSE
       
        string memory winnerURI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreiax7rgyoayiug5d4hx24j2bv4wjvnthskll64m46y33l2mnek6t4m";
    string memory runnerupURI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreih7pn3uwr27yfnqi4cf4xr3pd2mljsa5bb4oothqaifnrciwk2zge";
    string memory finalistURI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreih5bnjfkqaxiysgrikxmqemsq72ksxk633hewtpch2ryk26yufhim";
    string memory participantURI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreiahc72ix4nwyczdzsick6wsfayfi3ggztc4jmcecxo5swig4ptzym";
        
        // Achievement prefix for IDs
        string memory achievementPrefix = "KL-HACK";
        
        vm.startBroadcast(deployerPrivateKey);
        
        KayabaHackathonNFT nft = new KayabaHackathonNFT(
            winnerURI,
            runnerupURI,
            finalistURI,
            participantURI,
            achievementPrefix
        );
        
        console.log("====================================");
        console.log("Kayaba Hackathon Achievement NFT Deployed!");
        console.log("====================================");
        console.log("Contract Address:", address(nft));
        console.log("Achievement Prefix:", achievementPrefix);
        console.log("====================================");
        console.log("");
        console.log("Metadata URIs:");
        console.log("  Winner:      ", winnerURI);
        console.log("  Runner-up:   ", runnerupURI);
        console.log("  Finalist:    ", finalistURI);
        console.log("  Participant: ", participantURI);
        console.log("====================================");
        console.log("");
        console.log("Achievement IDs (auto-generated):");
        console.log("  Token #0 = KL-HACK-0001");
        console.log("  Token #1 = KL-HACK-0002");
        console.log("  Token #2 = KL-HACK-0003");
        console.log("  ... and so on");
        console.log("====================================");
        console.log("");
        console.log("Achievement Levels:");
        console.log("  0 = Winner     -> Shows GOLD trophy");
        console.log("  1 = Runner-up  -> Shows SILVER trophy");
        console.log("  2 = Finalist   -> Shows BRONZE trophy");
        console.log("  3 = Participant -> Shows STANDARD badge");
        console.log("====================================");
        
        vm.stopBroadcast();
    }
}