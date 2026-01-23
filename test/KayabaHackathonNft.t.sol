// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/KayabaHackathonNFT.sol";

contract KayabaHackathonNFTTest is Test {
    KayabaHackathonNFT public nft;
    address public owner;
    address public participant1;
    address public participant2;
    address public participant3;
    
    uint256 constant MINT_FEE = 0.0003 ether;
    
    string constant WINNER_URI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreiax7rgyoayiug5d4hx24j2bv4wjvnthskll64m46y33l2mnek6t4m";
    string constant RUNNERUP_URI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreih7pn3uwr27yfnqi4cf4xr3pd2mljsa5bb4oothqaifnrciwk2zge";
    string constant FINALIST_URI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreih5bnjfkqaxiysgrikxmqemsq72ksxk633hewtpch2ryk26yufhim";
    string constant PARTICIPANT_URI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreiahc72ix4nwyczdzsick6wsfayfi3ggztc4jmcecxo5swig4ptzym";
    string constant ACHIEVEMENT_PREFIX = "KL-HACK";
    
    // Add receive function to accept ETH
    receive() external payable {}
    
    function setUp() public {
        owner = address(this);
        participant1 = address(0x1);
        participant2 = address(0x2);
        participant3 = address(0x3);
        
        nft = new KayabaHackathonNFT(
            WINNER_URI,
            RUNNERUP_URI,
            FINALIST_URI,
            PARTICIPANT_URI,
            ACHIEVEMENT_PREFIX
        );
        
        // Fund test addresses
        vm.deal(participant1, 10 ether);
        vm.deal(participant2, 10 ether);
        vm.deal(participant3, 10 ether);
    }
    
    // ===== BASIC MINTING TESTS =====
    
    function testMintWinnerWithFee() public {
        vm.prank(participant1);
        (uint256 tokenId, string memory achievementId) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "DeFi Dashboard",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        assertEq(nft.ownerOf(tokenId), participant1);
        assertEq(tokenId, 0);
        assertEq(achievementId, "KL-HACK-0001");
        assertEq(address(nft).balance, MINT_FEE);
    }
    
    function testMintRunnerUpWithFee() public {
        vm.prank(participant1);
        (uint256 tokenId, string memory achievementId) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "NFT Marketplace",
            KayabaHackathonNFT.AchievementLevel.RUNNER_UP,
            "January 18, 2026"
        );
        
        assertEq(nft.ownerOf(tokenId), participant1);
        assertEq(achievementId, "KL-HACK-0001");
    }
    
    function testMintFinalistWithFee() public {
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "DAO Tooling",
            KayabaHackathonNFT.AchievementLevel.FINALIST,
            "January 18, 2026"
        );
        
        assertEq(nft.ownerOf(tokenId), participant1);
    }
    
    function testMintParticipantWithFee() public {
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "Web3 Game",
            KayabaHackathonNFT.AchievementLevel.PARTICIPANT,
            "January 18, 2026"
        );
        
        assertEq(nft.ownerOf(tokenId), participant1);
    }
    
    function testMintFailsWithInsufficientFee() public {
        vm.prank(participant1);
        vm.expectRevert("Insufficient minting fee");
        nft.mintAchievement{value: 0.0001 ether}(
            participant1,
            "ETHGlobal Paris 2024",
            "DeFi Dashboard",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
    }
    
    function testMintFailsWithEmptyHackathonName() public {
        vm.prank(participant1);
        vm.expectRevert("Hackathon name required");
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "",
            "DeFi Dashboard",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
    }
    
    function testMintFailsWithEmptyProjectName() public {
        vm.prank(participant1);
        vm.expectRevert("Project name required");
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
    }
    
    function testExcessPaymentRefunded() public {
        vm.prank(participant1);
        uint256 balanceBefore = participant1.balance;
        
        nft.mintAchievement{value: 0.001 ether}(
            participant1,
            "ETHGlobal Paris 2024",
            "DeFi Dashboard",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        uint256 balanceAfter = participant1.balance;
        uint256 spent = balanceBefore - balanceAfter;
        
        // Should only spend MINT_FEE + gas
        assertGt(spent, MINT_FEE); // More than fee due to gas
        assertLt(spent, 0.001 ether); // Less than what was sent (excess refunded)
    }
    
    // ===== AUTO ID GENERATION TESTS =====
    
    function testAutoIncrementingAchievementIds() public {
        // Mint first achievement
        vm.prank(participant1);
        (, string memory id1) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "Project 1",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        // Mint second achievement
        vm.prank(participant2);
        (, string memory id2) = nft.mintAchievement{value: MINT_FEE}(
            participant2,
            "ETHGlobal Paris 2024",
            "Project 2",
            KayabaHackathonNFT.AchievementLevel.RUNNER_UP,
            "January 18, 2026"
        );
        
        // Mint third achievement
        vm.prank(participant3);
        (, string memory id3) = nft.mintAchievement{value: MINT_FEE}(
            participant3,
            "ETHGlobal Paris 2024",
            "Project 3",
            KayabaHackathonNFT.AchievementLevel.PARTICIPANT,
            "January 18, 2026"
        );
        
        assertEq(id1, "KL-HACK-0001");
        assertEq(id2, "KL-HACK-0002");
        assertEq(id3, "KL-HACK-0003");
        assertEq(nft.totalSupply(), 3);
    }
    
    // ===== METADATA URI TESTS =====
    
    function testWinnerGetsCorrectMetadata() public {
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "Winner Project",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        string memory uri = nft.tokenURI(tokenId);
        assertEq(uri, WINNER_URI);
    }
    
    function testRunnerUpGetsCorrectMetadata() public {
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "Runner-up Project",
            KayabaHackathonNFT.AchievementLevel.RUNNER_UP,
            "January 18, 2026"
        );
        
        string memory uri = nft.tokenURI(tokenId);
        assertEq(uri, RUNNERUP_URI);
    }
    
    function testFinalistGetsCorrectMetadata() public {
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "Finalist Project",
            KayabaHackathonNFT.AchievementLevel.FINALIST,
            "January 18, 2026"
        );
        
        string memory uri = nft.tokenURI(tokenId);
        assertEq(uri, FINALIST_URI);
    }
    
    function testParticipantGetsCorrectMetadata() public {
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "Participant Project",
            KayabaHackathonNFT.AchievementLevel.PARTICIPANT,
            "January 18, 2026"
        );
        
        string memory uri = nft.tokenURI(tokenId);
        assertEq(uri, PARTICIPANT_URI);
    }
    
    // ===== BATCH MINTING TESTS =====
    
    function testBatchMintDifferentLevels() public {
        address[] memory recipients = new address[](4);
        recipients[0] = participant1;
        recipients[1] = participant2;
        recipients[2] = participant3;
        recipients[3] = address(0x4);
        
        string[] memory projects = new string[](4);
        projects[0] = "Winner Project";
        projects[1] = "Runner-up Project";
        projects[2] = "Finalist Project";
        projects[3] = "Participant Project";
        
        KayabaHackathonNFT.AchievementLevel[] memory levels = new KayabaHackathonNFT.AchievementLevel[](4);
        levels[0] = KayabaHackathonNFT.AchievementLevel.WINNER;
        levels[1] = KayabaHackathonNFT.AchievementLevel.RUNNER_UP;
        levels[2] = KayabaHackathonNFT.AchievementLevel.FINALIST;
        levels[3] = KayabaHackathonNFT.AchievementLevel.PARTICIPANT;
        
        string[] memory dates = new string[](4);
        dates[0] = "January 18, 2026";
        dates[1] = "January 18, 2026";
        dates[2] = "January 18, 2026";
        dates[3] = "January 18, 2026";
        
        string[] memory achievementIds = nft.batchMintAchievements(
            recipients,
            "ETHGlobal Paris 2024",
            projects,
            levels,
            dates
        );
        
        assertEq(nft.totalSupply(), 4);
        assertEq(achievementIds[0], "KL-HACK-0001");
        assertEq(achievementIds[1], "KL-HACK-0002");
        assertEq(achievementIds[2], "KL-HACK-0003");
        assertEq(achievementIds[3], "KL-HACK-0004");
        
        // Check each has correct metadata
        assertEq(nft.tokenURI(0), WINNER_URI);
        assertEq(nft.tokenURI(1), RUNNERUP_URI);
        assertEq(nft.tokenURI(2), FINALIST_URI);
        assertEq(nft.tokenURI(3), PARTICIPANT_URI);
    }
    
    function testBatchMintOnlyOwner() public {
        address[] memory recipients = new address[](1);
        recipients[0] = participant1;
        
        string[] memory projects = new string[](1);
        projects[0] = "Project";
        
        KayabaHackathonNFT.AchievementLevel[] memory levels = new KayabaHackathonNFT.AchievementLevel[](1);
        levels[0] = KayabaHackathonNFT.AchievementLevel.WINNER;
        
        string[] memory dates = new string[](1);
        dates[0] = "January 18, 2026";
        
        vm.prank(participant1);
        vm.expectRevert();
        nft.batchMintAchievements(recipients, "Hackathon", projects, levels, dates);
    }
    
    function testBatchMintArrayLengthMismatch() public {
        address[] memory recipients = new address[](2);
        recipients[0] = participant1;
        recipients[1] = participant2;
        
        string[] memory projects = new string[](1); // Wrong length!
        projects[0] = "Project";
        
        KayabaHackathonNFT.AchievementLevel[] memory levels = new KayabaHackathonNFT.AchievementLevel[](2);
        levels[0] = KayabaHackathonNFT.AchievementLevel.WINNER;
        levels[1] = KayabaHackathonNFT.AchievementLevel.RUNNER_UP;
        
        string[] memory dates = new string[](2);
        dates[0] = "January 18, 2026";
        dates[1] = "January 18, 2026";
        
        vm.expectRevert("Recipients and projects length mismatch");
        nft.batchMintAchievements(recipients, "Hackathon", projects, levels, dates);
    }
    
    // ===== SOULBOUND TESTS =====
    
    function testCannotTransferAchievement() public {
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "DeFi Dashboard",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        vm.prank(participant1);
        vm.expectRevert("Achievement is soulbound and cannot be transferred");
        nft.transferFrom(participant1, participant2, tokenId);
    }
    
    function testCannotSafeTransferAchievement() public {
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "DeFi Dashboard",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        vm.prank(participant1);
        vm.expectRevert("Achievement is soulbound and cannot be transferred");
        nft.safeTransferFrom(participant1, participant2, tokenId);
    }
    
    // ===== FEE WITHDRAWAL TESTS =====
    
    function testWithdrawFees() public {
        // Mint some achievements to collect fees
        vm.prank(participant1);
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "Project 1",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        vm.prank(participant2);
        nft.mintAchievement{value: MINT_FEE}(
            participant2,
            "ETHGlobal Paris 2024",
            "Project 2",
            KayabaHackathonNFT.AchievementLevel.RUNNER_UP,
            "January 18, 2026"
        );
        
        uint256 balanceBefore = owner.balance;
        nft.withdrawFees();
        uint256 balanceAfter = owner.balance;
        
        assertEq(balanceAfter - balanceBefore, MINT_FEE * 2);
        assertEq(address(nft).balance, 0);
    }
    
    function testWithdrawFeesOnlyOwner() public {
        vm.prank(participant1);
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "Project",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        vm.prank(participant1);
        vm.expectRevert();
        nft.withdrawFees();
    }
    
    function testWithdrawFeesFailsWhenNoFunds() public {
        vm.expectRevert("No funds to withdraw");
        nft.withdrawFees();
    }
    
    // ===== DATA RETRIEVAL TESTS =====
    
    function testGetAchievementInfo() public {
        vm.prank(participant1);
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "DeFi Dashboard",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        (
            string memory achievementId,
            string memory hackathonName,
            string memory projectName,
            KayabaHackathonNFT.AchievementLevel level,
            string memory date,
            address participant
        ) = nft.getAchievementInfo(0);
        
        assertEq(achievementId, "KL-HACK-0001");
        assertEq(hackathonName, "ETHGlobal Paris 2024");
        assertEq(projectName, "DeFi Dashboard");
        assertTrue(level == KayabaHackathonNFT.AchievementLevel.WINNER);
        assertEq(date, "January 18, 2026");
        assertEq(participant, participant1);
    }
    
    function testGetAchievementId() public {
        vm.prank(participant1);
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "ETHGlobal Paris 2024",
            "DeFi Dashboard",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "January 18, 2026"
        );
        
        string memory achievementId = nft.getAchievementId(0);
        assertEq(achievementId, "KL-HACK-0001");
    }
    
    function testGetLevelString() public {
        // Mint one of each level
        vm.prank(participant1);
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "Hackathon",
            "Project 1",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "Jan 18"
        );
        
        vm.prank(participant2);
        nft.mintAchievement{value: MINT_FEE}(
            participant2,
            "Hackathon",
            "Project 2",
            KayabaHackathonNFT.AchievementLevel.RUNNER_UP,
            "Jan 18"
        );
        
        vm.prank(participant3);
        nft.mintAchievement{value: MINT_FEE}(
            participant3,
            "Hackathon",
            "Project 3",
            KayabaHackathonNFT.AchievementLevel.FINALIST,
            "Jan 18"
        );
        
        vm.prank(participant1);
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "Hackathon",
            "Project 4",
            KayabaHackathonNFT.AchievementLevel.PARTICIPANT,
            "Jan 18"
        );
        
        assertEq(nft.getLevelString(0), "Winner");
        assertEq(nft.getLevelString(1), "Runner-up");
        assertEq(nft.getLevelString(2), "Finalist");
        assertEq(nft.getLevelString(3), "Participant");
    }
    
    function testGetParticipantAchievements() public {
        // Mint multiple achievements for participant1
        vm.startPrank(participant1);
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "Hackathon 1",
            "Project 1",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "Jan 18"
        );
        
        nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "Hackathon 2",
            "Project 2",
            KayabaHackathonNFT.AchievementLevel.FINALIST,
            "Feb 20"
        );
        vm.stopPrank();
        
        // Mint one for participant2
        vm.prank(participant2);
        nft.mintAchievement{value: MINT_FEE}(
            participant2,
            "Hackathon 1",
            "Project 3",
            KayabaHackathonNFT.AchievementLevel.PARTICIPANT,
            "Jan 18"
        );
        
        uint256[] memory p1Achievements = nft.getParticipantAchievements(participant1);
        uint256[] memory p2Achievements = nft.getParticipantAchievements(participant2);
        
        assertEq(p1Achievements.length, 2);
        assertEq(p1Achievements[0], 0);
        assertEq(p1Achievements[1], 1);
        
        assertEq(p2Achievements.length, 1);
        assertEq(p2Achievements[0], 2);
    }
    
    // ===== ADMIN FUNCTIONS TESTS =====
    
    function testSetMetadataURIs() public {
        string memory newWinnerURI = "https://new.winner.uri";
        string memory newRunnerupURI = "https://new.runnerup.uri";
        string memory newFinalistURI = "https://new.finalist.uri";
        string memory newParticipantURI = "https://new.participant.uri";
        
        nft.setMetadataURIs(newWinnerURI, newRunnerupURI, newFinalistURI, newParticipantURI);
        
        // Mint and check new URI is used
        vm.prank(participant1);
        (uint256 tokenId, ) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "Hackathon",
            "Project",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "Jan 18"
        );
        
        assertEq(nft.tokenURI(tokenId), newWinnerURI);
    }
    
    function testSetMetadataURIsOnlyOwner() public {
        vm.prank(participant1);
        vm.expectRevert();
        nft.setMetadataURIs("uri1", "uri2", "uri3", "uri4");
    }
    
    function testSetAchievementPrefix() public {
        nft.setAchievementPrefix("NEW-PREFIX");
        assertEq(nft.achievementPrefix(), "NEW-PREFIX");
        
        // Mint and check new prefix is used
        vm.prank(participant1);
        (, string memory achievementId) = nft.mintAchievement{value: MINT_FEE}(
            participant1,
            "Hackathon",
            "Project",
            KayabaHackathonNFT.AchievementLevel.WINNER,
            "Jan 18"
        );
        
        assertEq(achievementId, "NEW-PREFIX-0001");
    }
    
    function testSetAchievementPrefixOnlyOwner() public {
        vm.prank(participant1);
        vm.expectRevert();
        nft.setAchievementPrefix("NEW-PREFIX");
    }
}