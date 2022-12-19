// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// Note: That this contract is different from auction (in which the timer is reset on each bid -> 3 seconds/calls).
// Here, the timer is the total amount of time for which the player is available for purchase

contract TransferMarket{

    struct Player{
        string playerName;
        uint64 age;
        address payable currentClub;
        uint256 startingBid;
        uint256 buyNow;
    }

    struct Club{
        string clubName;
        address payable clubAccount;
    }

    Player[5] public players;
    uint256 i; //To change player after a player is sold
    Club[5] public clubs;

    Player public currentPlayer;

    struct Bider{
        address payable account;
        uint256 amount;
    }

    uint256 public highestBid;
    address payable public highestBiderAddress;
    uint256 currentBid;
    uint256 buyNowBid;
    Bider[] public biders;

    constructor() {
        i= 0;
        setPlayers();
        setClubs();
    }

    function setClubs() internal {

        clubs[0] = Club({
            clubName: "Real Madrid",
            clubAccount: payable(0xdD870fA1b7C4700F2BD7f44238821C26f7392148)
        });

        clubs[1] = Club({
            clubName: "FC Barcelona",
            clubAccount: payable(0x583031D1113aD414F02576BD6afaBfb302140225)
        });

        clubs[2] = Club({
            clubName: "PSG",
            clubAccount: payable(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB)
        });

        clubs[3] = Club({
            clubName: "Bayern Munich",
            clubAccount: payable(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C)
        });

        clubs[4] = Club({
            clubName: "Manchester United",
            clubAccount: payable(0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c)
        });

    }

    function setPlayers() internal {
        players[0] = Player({
            playerName: "Cristiano Ronaldo",
            age: 37,
            currentClub: payable(0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c), // Man Utd
            startingBid: 25000000000000000000,
            buyNow: 40000000000000000000
        });

        players[1] = Player({
            playerName: "Lionel Messi",
            age: 35,
            currentClub: payable(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C), // PSG
            startingBid: 30000000000000000000,
            buyNow: 40000000000000000000
        });

        players[2] = Player({
            playerName: "Robert Lewandowski",
            age: 34,
            currentClub: payable(0x583031D1113aD414F02576BD6afaBfb302140225), // FC Barcelona
            startingBid: 25000000000000000000,
            buyNow: 30000000000000000000
        });

        players[3] = Player({
            playerName: "Neymar JR",
            age: 30,
            currentClub: payable(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C), // PSG
            startingBid: 30000000000000000000,
            buyNow: 35000000000000000000
        });

        players[4] = Player({
            playerName: "Zlatan Ibrahimovic",
            age: 41,
            currentClub: payable(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678), // A.C. Milan
            startingBid: 15000000000000000000,
            buyNow: 25000000000000000000
        });

    }

    //----------------- Implementing a timer ----------------------
    uint start;
    uint end;

    function startTimer() internal {
        start = block.timestamp;
        uint total_time = 120; // 2 minutes
        end = total_time + start;
    }

    modifier timeOver{
        require(block.timestamp <= end, "------------ Time Over ------------");
        _;
    }

    function getTimeLeft() public timeOver view returns(uint){
        return (end - block.timestamp);
    }
    //------------------------------------------------------------

    function receiveAmount() public payable {
        require(payable(msg.sender) == highestBiderAddress);
        require(msg.value == highestBid);
    }

    // Subtracting commission for selling the player which is 10%
    function transferAmount() public payable {
        uint x;
        x = highestBid /10;
        x = highestBid - x;

        currentPlayer.currentClub.transfer(x);
    }

    function setPlayerForBid(Player memory p) internal {

        currentPlayer = p;
        currentBid = currentPlayer.startingBid;
        highestBid = currentBid;
        buyNowBid = currentPlayer.buyNow;

        i++;
    }

    function addBider(address payable account, uint amount) internal {
        Bider memory bid = Bider(account, amount);
        biders.push(bid);
    }

    function removeBider() internal {
        biders.pop();
    }

    modifier checkPlayers{
        require(i < 5, "------------------ All the players have been sold ------------------");
        _;
    }

    function startBiding() public checkPlayers { 
        setPlayerForBid(players[i]);
        startTimer();
        
    }

    function endBiding() internal {
        end = end - getTimeLeft();
    }

    // The biding will end if the player is bought with "Buy Now" amount
    // OR when the time of the biding has ended
    function placeBid(uint256 index, uint amount) public timeOver {

        currentBid = amount;

        if (currentBid >= buyNowBid){
            highestBiderAddress = clubs[index].clubAccount;
            highestBid = amount;
            addBider(clubs[index].clubAccount, amount);
            endBiding();
        }

        if (currentBid > highestBid){
            highestBiderAddress = clubs[index].clubAccount;
            highestBid = amount;
            addBider(clubs[index].clubAccount, amount);
        }
    }

}